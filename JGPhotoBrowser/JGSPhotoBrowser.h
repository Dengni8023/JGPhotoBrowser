//
//  JGSPhotoBrowser.h
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<JGSPhotoBrowser/JGSPhotoBrowser.h>)
#import <JGSPhotoBrowser/JGSPhoto.h>
#else
#import "JGSPhoto.h"
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN CGFloat JGSPhotoBrowserDescriptionHeight; // 图片文字描述展示高度
/** 设置图片文字描述展示高度，大于44有效 */
FOUNDATION_EXTERN void JGSPhotoBrowserSetDescriptionHeight(CGFloat descriptionHeight);

@interface JGSPhotoBrowser : UIViewController

@property (nonatomic, copy) NSArray<JGSPhoto *> *photos; // 所有的图片对象
@property (nonatomic, assign) NSUInteger currentIndex; // 当前展示的图片索引
@property (nonatomic, assign) BOOL showSaveBtn; // 显示保存按钮

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithPhotos:(NSArray<JGSPhoto *> *)photos index:(NSInteger)curIndex;
- (instancetype)initWithPhotos:(NSArray<JGSPhoto *> *)photos index:(NSInteger)curIndex showSave:(BOOL)showSaveBtn;

- (void)show; // 显示

@end

NS_ASSUME_NONNULL_END
