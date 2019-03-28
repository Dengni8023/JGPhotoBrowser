//
//  JGSPhotoDescriptionView.m
//  JGSPhotoBrowser
//
//  Created by 梅继高 on 2019/3/28.
//  Copyright © 2019 MeiJigao. All rights reserved.
//

#import "JGSPhotoDescriptionView.h"

@interface JGSPhotoDescriptionView ()

@property (nonatomic, strong) UITextView *contentView;

@end

@implementation JGSPhotoDescriptionView

#pragma mark - Life Cycle
- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self initViewElements];
    }
    return self;
}

- (void)initViewElements {
    
    // bg
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];
    
    _contentView = [[UITextView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.editable = NO;
    _contentView.textColor = [UIColor whiteColor];
    _contentView.showsVerticalScrollIndicator = NO;
    _contentView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_contentView];
}

- (void)dealloc {
    //JGSLog(@"<%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - View
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect viewRect = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    viewRect = CGRectInset(viewRect, 8, 6);
    self.contentView.frame = viewRect;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    self.contentView.contentInset = contentInset;
}

- (void)setText:(NSString *)text {
    
    self.contentView.contentOffset = CGPointZero;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.contentView setText:text];
    
    if (text.length > 0) {
        
        // 显示行距问题
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineHeightMultiple = 1.2;
        style.alignment = NSTextAlignmentLeft;
        style.lineBreakMode = NSLineBreakByCharWrapping;
        self.contentView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    }
}

#pragma mark - End

@end
