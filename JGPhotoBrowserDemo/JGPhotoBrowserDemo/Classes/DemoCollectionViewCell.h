//
//  DemoCollectionViewCell.h
//  JGPhotoBrowserDemo
//
//  Created by Mei Jigao on 2018/3/19.
//  Copyright © 2018年 MeiJigao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) FLAnimatedImageView *imageView;

@end

NS_ASSUME_NONNULL_END
