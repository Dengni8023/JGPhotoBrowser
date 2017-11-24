//
//  JGPhotoExtraBar.m
//  JGPhotoBrowser
//
//  Created by Mei Jigao on 2017/11/24.
//  Copyright © 2017年 MeiJigao. All rights reserved.
//

#import "JGPhotoExtraBar.h"
#import "JGSourceBase.h"

@interface JGPhotoExtraBar ()

@end

@implementation JGPhotoExtraBar

#pragma mark - init
- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.contentInset = UIEdgeInsetsMake(4, 8, 4, 8);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];
        self.editable = NO;
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc {
    
    JGLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - View
- (void)setText:(NSString *)text {
    
    self.contentOffset = CGPointZero;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 显示行距问题
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.2;
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    self.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:14]}];
}

#pragma mark - End

@end
