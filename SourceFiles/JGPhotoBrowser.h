//
//  JGPhotoBrowser.h
//  JGPhotoBrowser
//
//  Created by 梅继高 on 2017/6/29.
//  Copyright © 2017年 Jigao Mei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JGPhoto.h"

@interface JGPhotoBrowser : NSObject <UIScrollViewDelegate>

// 所有的图片对象
@property (nonatomic, strong) NSArray<JGPhoto *> *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
// 保存按钮
@property (nonatomic, assign) NSUInteger showSaveBtn;

// 显示
- (void)show;

@end
