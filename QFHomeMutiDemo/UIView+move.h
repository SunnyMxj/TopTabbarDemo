//
//  UIView+move.h
//  QFMoveView
//
//  Created by QianFan_Ryan on 16/8/23.
//  Copyright © 2016年 QianFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIViewMoveDelegate <NSObject>

- (void)view:(UIView *)view beginToMove:(UIPanGestureRecognizer *)gesture;
- (void)view:(UIView *)view isMoving:(UIPanGestureRecognizer *)gesture;
- (void)view:(UIView *)view endMove:(UIPanGestureRecognizer *)gesture;

@end

@interface UIView (move)

@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, assign) CGPoint originCenter;
@property (nonatomic, weak) id <UIViewMoveDelegate> moveDelegate;

@end
