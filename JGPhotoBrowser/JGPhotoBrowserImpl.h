//
//  JGPhotoBrowserImpl.h
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JGPhoto;

@interface JGPhotoBrowser : UIViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithPhotos:(NSArray<JGPhoto *> *)photos index:(NSInteger)curIndex;
- (instancetype)initWithPhotos:(NSArray<JGPhoto *> *)photos index:(NSInteger)curIndex showSave:(BOOL)showSaveBtn;

// 显示
- (void)show;

@end

NS_ASSUME_NONNULL_END
