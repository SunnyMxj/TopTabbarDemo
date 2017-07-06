//
//  UIView+frameAdjust.h
//  fenbi
//
//  Created by Tang Qiao on 12-5-31.
//  Copyright (c) 2012年 Fenbi.com . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (frameAdjust)

- (CGPoint)origin;
- (void)setOrigin:(CGPoint) point;

- (CGSize)size;
- (void)setSize:(CGSize) size;

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

- (CGFloat)tail;
- (void)setTail:(CGFloat)tail;

- (CGFloat)bottom;
- (void)setBottom:(CGFloat)bottom;

- (CGFloat)right;
- (void)setRight:(CGFloat)right;

- (UIImage *)snapshotImage;
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;
- (NSData *)snapshotPDF;
- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;
- (void)removeAllSubviews;
@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, readonly) CGFloat visibleAlpha;
- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view;
- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(UIView *)view;
- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view;

@property (nonatomic, copy)void(^completion)(void);
/// 添加引导图片
- (void)addGuideImageView:(NSString *)imageName frame:(CGRect)frame dismissCompletion:(void (^)())completion;

@end
