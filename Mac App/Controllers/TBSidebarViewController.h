//
//  TBSidebarViewController.h
//  Tribo
//
//  Created by Carter Allen on 5/26/12.
//  Copyright (c) 2012 Opt-6 Products, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TBViewController.h"

@protocol TBSidebarViewControllerDelegate;

@class TBPost;

@interface TBSidebarViewController : TBViewController
@property (nonatomic, unsafe_unretained) id <TBSidebarViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *viewControllers;
@end

@protocol TBSidebarViewControllerDelegate <NSObject>

@required
- (void)postsViewDidSelectPost:(TBPost *)post;

@end
