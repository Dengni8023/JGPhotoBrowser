//
//  JGSPhoto.h
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface JGSPhoto : NSObject

@property (nonatomic, assign) NSInteger index; // 索引
@property (nonatomic, copy, nullable) NSURL *url; // 图片链接
@property (nonatomic, copy, nullable) NSString *imgDescription; // 图片文字介绍
@property (nonatomic, strong, nullable) UIImage *image; // 完整的图片，GIF图片为SDAnimatedImage

@property (nonatomic, strong, nullable) UIImageView *srcImageView; // 来源view
@property (nonatomic, strong, nullable) UIImage *placeholder; // 默认为srcImageView图片，可单独设置
@property (nonatomic, strong, readonly, nullable) UIImage *capture; // 截图

// 是否已经保存到相册，仅当次有效
@property (nonatomic, assign) BOOL saved;

@end

NS_ASSUME_NONNULL_END
