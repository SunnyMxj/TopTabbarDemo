//
//  UIView+move.m
//  QFMoveView
//
//  Created by QianFan_Ryan on 16/8/23.
//  Copyright © 2016年 QianFan. All rights reserved.
//

#import "UIView+move.h"
#import <objc/runtime.h>

@interface UIView()

@property (nonatomic, strong, readwrite)UILongPressGestureRecognizer *longPressGesture;

@end

@implementation UIView (move)

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if ([self.moveDelegate respondsToSelector:@selector(view:beginToMove:)]) {
                [self.moveDelegate view:self beginToMove:gesture];
            }
            break;
        case UIGestureRecognizerStateChanged:
            if ([self.moveDelegate respondsToSelector:@selector(view:isMoving:)]) {
                [self.moveDelegate view:self isMoving:gesture];
            }
            break;
        case UIGestureRecognizerStateEnded:
            if ([self.moveDelegate respondsToSelector:@selector(view:endMove:)]) {
                [self.moveDelegate view:self endMove:gesture];
            }
            break;
        default:
            break;
    }
}



- (id<UIViewMoveDelegate>)moveDelegate{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMoveDelegate:(id<UIViewMoveDelegate>)moveDelegate{
    if (!self.longPressGesture) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureAction:)];
        [self addGestureRecognizer:longPressGesture];
        self.longPressGesture = longPressGesture;
    }
    objc_setAssociatedObject(self, @selector(moveDelegate), moveDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (UILongPressGestureRecognizer *)longPressGesture{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture{
    objc_setAssociatedObject(self, @selector(longPressGesture), longPressGesture, OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)tagId{
    return  ((NSNumber *)objc_getAssociatedObject(self, _cmd)).integerValue;
}

- (void)setTagId:(NSInteger)tagId{
    objc_setAssociatedObject(self, @selector(tagId), @(tagId), OBJC_ASSOCIATION_ASSIGN);
}

- (CGPoint)originCenter{
    NSNumber *originCenterX = objc_getAssociatedObject(self, @"originCenterX");
    NSNumber *originCenterY = objc_getAssociatedObject(self, @"originCenterY");
    return CGPointMake(originCenterX.floatValue, originCenterY.floatValue);
}

- (void)setOriginCenter:(CGPoint)originCenter{
    objc_setAssociatedObject(self, @"originCenterX", [NSNumber numberWithFloat:originCenter.x], OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, @"originCenterY", [NSNumber numberWithFloat:originCenter.y], OBJC_ASSOCIATION_COPY);
}

@end
