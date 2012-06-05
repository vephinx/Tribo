//
//  TBSiteWindowController.m
//  Tribo
//
//  Created by Carter Allen on 10/21/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBSiteWindowController.h"
#import "TBSidebarViewController.h"
#import "TBAddPostSheetController.h"
#import "TBSettingsSheetController.h"
#import "TBPublishSheetController.h"
#import "TBStatusViewController.h"
#import "TBSiteDocument.h"
#import "TBSite.h"
#import "TBHTTPServer.h"

const NSEdgeInsets TBAccessoryViewInsets = {
	.top = 0.0,
	.right = 4.0
};

@interface TBSiteWindowController () <NSSplitViewDelegate>
@property (nonatomic, assign) IBOutlet NSView *accessoryView;
@property (nonatomic, assign) IBOutlet NSMenu *actionMenu;
@property (nonatomic, assign) IBOutlet NSSplitView *splitView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *splitViewBottomConstraint;
@property (nonatomic, assign) IBOutlet NSView *leftPane;
@property (nonatomic, assign) IBOutlet NSView *rightPane;
@property (nonatomic, assign) IBOutlet NSTextView *editorView;
@property (nonatomic, strong) TBAddPostSheetController *addPostSheetController;
@property (nonatomic, strong) TBSettingsSheetController *settingsSheetController;
@property (nonatomic, strong) TBPublishSheetController *publishSheetController;
@property (nonatomic, strong) TBStatusViewController *statusViewController;
- (IBAction)showAddPostSheet:(id)sender;
@end

@implementation TBSiteWindowController

@synthesize accessoryView=_accessoryView;
@synthesize actionMenu=_actionMenu;
@synthesize splitView=_splitView;
@synthesize splitViewBottomConstraint=_splitViewBottomConstraint;
@synthesize leftPane=_leftPane;
@synthesize rightPane=_rightPane;
@synthesize editorView=_editorView;
@synthesize sidebarViewController=_sidebarViewController;
@synthesize addPostSheetController=_addPostSheetController;
@synthesize settingsSheetController=_settingsSheetController;
@synthesize publishSheetController=_publishSheetController;
@synthesize statusViewController=_statusViewController;

- (id)init {
	self = [super initWithWindowNibName:@"TBSiteWindow"];
	return self;
}

#pragma mark - View Controller Management

- (IBAction)showAddPostSheet:(id)sender {
	TBSiteDocument *document = (TBSiteDocument *)self.document;
	[self.addPostSheetController runModalForWindow:[document windowForSheet] completionBlock:^(NSString *title, NSString *slug) {
        NSError *error = nil;
        NSURL *siteURL = [document.site addPostWithTitle:title slug:slug error:&error];
        if (!siteURL) {
            [self presentError:error];
        }
	}];
}

- (IBAction)showActionMenu:(id)sender {
	NSPoint clickedPoint = [[NSApp currentEvent] locationInWindow];
	NSEvent *event = [NSEvent mouseEventWithType:NSRightMouseDown location:clickedPoint modifierFlags:0 timestamp:0.0 windowNumber:[self.window windowNumber] context:[NSGraphicsContext currentContext] eventNumber:1 clickCount:1 pressure:0.0];
	[NSMenu popUpContextMenu:self.actionMenu withEvent:event forView:self.accessoryView];
}

- (IBAction)preview:(id)sender {
	TBSiteDocument *document = (TBSiteDocument *)self.document;
	NSMenuItem *previewMenuItem = (NSMenuItem *)sender;
	if (!document.server.isRunning) {
		
		[self toggleStatusView];
		self.statusViewController.title = @"Starting local preview...";
		[document startPreview:^(NSURL *localURL, NSError *error) {
			
			if (error)
				[self presentError:error];
			previewMenuItem.title = @"Stop Preview";
			
			self.statusViewController.title = @"Local preview running";
			self.statusViewController.link = localURL;
			__unsafe_unretained id weakSelf = self;
			[self.statusViewController setStopHandler:^() {
				if (weakSelf) [weakSelf preview:sender];
			}];
			
		}];
		
	}
	else {
		previewMenuItem.title = @"Preview";
		[document stopPreview];
		[self toggleStatusView];
	}
}

- (IBAction)publish:(id)sender {
	[self.publishSheetController runModalForWindow:self.window site:[self.document site]];
}

- (IBAction)showSettingsSheet:(id)sender {
	[self.settingsSheetController runModalForWindow:self.window site:[self.document site]];
}

- (void)toggleStatusView {
	NSTimeInterval animationDuration = 0.1;
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:animationDuration];
	NSView *statusView = self.statusViewController.view;
	NSRect hiddenStatusViewFrame = NSMakeRect(0.0, -statusView.frame.size.height, self.splitView.frame.size.width, statusView.frame.size.height);
	NSRect displayedStatusViewFrame = hiddenStatusViewFrame;
	displayedStatusViewFrame.origin.y = 0.0;
	if (statusView.superview) {
		[[NSAnimationContext currentContext] setCompletionHandler:^{
			[statusView removeFromSuperview];
		}];
		[[statusView animator] setFrame:hiddenStatusViewFrame];
		[[self.splitViewBottomConstraint animator] setConstant:0];
	}
	else {
		statusView.autoresizingMask = NSViewWidthSizable;
		statusView.frame = hiddenStatusViewFrame;
		[self.splitView.superview addSubview:statusView];
		[[statusView animator] setFrame:displayedStatusViewFrame];
		[[self.splitViewBottomConstraint animator] setConstant:(-1 * statusView.frame.size.height)];
	}
	[NSAnimationContext endGrouping];
}

#pragma mark - Split View Delegate Methods

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
	if (view == self.leftPane) return NO;
	return YES;
}

#pragma mark - Window Delegate Methods

- (void)windowDidLoad {
	[super windowDidLoad];
	
	self.sidebarViewController = [TBSidebarViewController new];
	self.sidebarViewController.document = self.document;
	self.sidebarViewController.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
	
	self.addPostSheetController = [TBAddPostSheetController new];
	self.settingsSheetController = [TBSettingsSheetController new];
	self.publishSheetController = [TBPublishSheetController new];
	self.statusViewController = [TBStatusViewController new];
	
	NSView *themeFrame = [self.window.contentView superview];
	NSRect accessoryFrame = self.accessoryView.frame;
	NSRect containerFrame = themeFrame.frame;
	accessoryFrame = NSMakeRect(containerFrame.size.width - accessoryFrame.size.width -  TBAccessoryViewInsets.right, containerFrame.size.height - accessoryFrame.size.height - TBAccessoryViewInsets.top, accessoryFrame.size.width, accessoryFrame.size.height);
	self.accessoryView.frame = accessoryFrame;
	self.accessoryView.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin;
	[[(NSButton *)self.accessoryView cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[[(NSButton *)self.accessoryView cell] setShowsStateBy:NSPushInCellMask];
	[[(NSButton *)self.accessoryView cell] setHighlightsBy:NSContentsCellMask];
	[themeFrame addSubview:self.accessoryView];
	
	[self.leftPane addSubview:self.sidebarViewController.view];
	self.sidebarViewController.view.frame = self.leftPane.bounds;
	
}

@end
