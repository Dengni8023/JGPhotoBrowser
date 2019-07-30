//
//  JGSPhotoToolView.h
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSPhotoToolView : UIView

/** 需要显示关闭按钮时，关闭按钮的回调，回调存在则显示关闭按钮，内部回调完成后则置空该回调 */
@property (nonatomic, copy) void (^closeShowAction)(void);

/** 显示保存按钮时，保存按钮的回调，如置空则不显示保存按钮，注意内存循环引用问题 */
@property (nonatomic, copy) void (^saveShowPhotoAction)(NSInteger index);

@property (nonatomic, assign) BOOL showSaveBtn; // 是否显示保存按钮
@property (nonatomic, assign) UIEdgeInsets contentInset;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithPhotosCount:(NSInteger)count index:(NSInteger)curIndex;

/** 更新当前显示序号及是否显示保存按钮 */
- (void)changeCurrentIndex:(NSInteger)toIndex indexSaved:(BOOL)saved;

@end

@interface JGSPhotolToolbar : UIToolbar

@end

@interface JGSPhotoToolClose : UIButton

@end

NS_ASSUME_NONNULL_END
