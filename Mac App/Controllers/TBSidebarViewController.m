//
//  TBSidebarViewController.m
//  Tribo
//
//  Created by Carter Allen on 5/26/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import "TBSidebarViewController.h"
#import "TBTabView.h"
#import "TBPostsViewController.h"
#import "TBTemplatesViewController.h"
#import "TBSourceViewController.h"
#import "TBStatusViewController.h"

@interface TBSidebarViewController () <TBTabViewDelegate, TBPostsViewControllerDelegate>
@property (readonly) TBViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedViewControllerIndex;
@property (nonatomic, assign) IBOutlet TBTabView *tabView;
@property (nonatomic, assign) IBOutlet NSView *containerView;
@property (nonatomic, assign) NSView *currentView;
@property (nonatomic, strong) TBStatusViewController *statusViewController;

- (IBAction)switchToPosts:(id)sender;
- (IBAction)switchToTemplates:(id)sender;
- (IBAction)switchToSources:(id)sender;

@end

@implementation TBSidebarViewController

@synthesize delegate = _delegate;
@synthesize viewControllers = _viewControllers;
@synthesize selectedViewControllerIndex = _selectedViewControllerIndex;
@synthesize tabView = _tabView;
@synthesize containerView = _containerView;
@synthesize currentView = _currentView;
@synthesize statusViewController=_statusViewController;

- (NSString *)defaultNibName {
	return @"TBSidebarView";
}

- (void)viewDidLoad {
	TBPostsViewController *postsViewController = [TBPostsViewController new];
	postsViewController.document = self.document;
	postsViewController.delegate = self;
	
	TBTemplatesViewController *templatesController = [TBTemplatesViewController new];
    templatesController.document = self.document;
    
    TBSourceViewController *sourcesController = [TBSourceViewController new];
    sourcesController.document = self.document;
	
	self.viewControllers = [NSArray arrayWithObjects:postsViewController, templatesController, sourcesController, nil];
	self.selectedViewControllerIndex = 0;
	
	self.tabView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
	
}

#pragma mark - View Controller Management

- (TBViewController *)selectedViewController {
	return [self.viewControllers objectAtIndex:self.selectedViewControllerIndex];
}

- (void)setSelectedViewControllerIndex:(NSUInteger)selectedViewControllerIndex {
	_selectedViewControllerIndex = selectedViewControllerIndex;
	NSView *newView = [[self.viewControllers objectAtIndex:_selectedViewControllerIndex] view];
	if (self.currentView == newView)
		return;
	if (self.currentView)
		[self.currentView removeFromSuperview];
	newView.frame = self.containerView.bounds;
	newView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
	[self.containerView addSubview:newView];
	self.currentView = newView;
}

- (void)setViewControllers:(NSArray *)viewControllers {
	_viewControllers = viewControllers;
	self.tabView.titles = [self.viewControllers valueForKey:@"title"];
	self.tabView.selectedIndex = self.selectedViewControllerIndex;
}

- (IBAction)switchToPosts:(id)sender {
    self.tabView.selectedIndex = 0;
}

- (IBAction)switchToTemplates:(id)sender {
    self.tabView.selectedIndex = 1;
}

- (IBAction)switchToSources:(id)sender {
    self.tabView.selectedIndex = 2;
}

#pragma mark - Tab View Delegate Methods

- (void)tabView:(TBTabView *)tabView didSelectIndex:(NSUInteger)index {
	self.selectedViewControllerIndex = index;
}


#pragma mark - Posts View Controller Delegate Methods

- (void)postsViewDidSelectPost:(TBPost *)post {
	if (self.delegate) [self.delegate postsViewDidSelectPost:post];
}

@end
