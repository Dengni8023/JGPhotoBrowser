//
//  JGPBBrowserController.h
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2018/6/11.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JGPBPhoto;

@interface JGPBBrowserController : UIViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithPhotos:(NSArray<JGPBPhoto *> *)photos index:(NSInteger)curIndex;
- (instancetype)initWithPhotos:(NSArray<JGPBPhoto *> *)photos index:(NSInteger)curIndex showSave:(BOOL)showSaveBtn;

// 显示
- (void)show;

@end

DEPRECATED_MSG_ATTRIBUTE("Use JGPBBrowserController instead") @interface JGPhotoBrowser : JGPBBrowserController

@end

NS_ASSUME_NONNULL_END
