//
//  TBPostsViewController.h
//  Tribo
//
//  Created by Carter Allen on 10/24/11.
//  Copyright (c) 2012 The Tribo Authors.
//  See the included License.md file.
//

#import "TBViewController.h"
#import <Quartz/Quartz.h>

@class TBSiteDocument;
@class TBPost;

@protocol TBPostsViewControllerDelegate;

@interface TBPostsViewController : TBViewController <QLPreviewPanelDelegate, QLPreviewPanelDataSource>
@property (nonatomic, assign) IBOutlet NSTableView *postTableView;
@property (nonatomic, unsafe_unretained) id <TBPostsViewControllerDelegate> delegate;
- (IBAction)editPost:(id)sender;
- (IBAction)previewPost:(id)sender;
- (IBAction)revealPost:(id)sender;
@end

@protocol TBPostsViewControllerDelegate <NSObject>

- (void)postsViewDidSelectPost:(TBPost *)post;

@end
