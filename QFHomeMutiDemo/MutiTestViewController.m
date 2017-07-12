//
//  MutiTestViewController.m
//  QFHomeMutiDemo
//
//  Created by QianFan_Ryan on 2017/7/4.
//  Copyright © 2017年 QianFan_Ryan. All rights reserved.
//

#import "MutiTestViewController.h"
#import "ViewController.h"
#import "UIView+frameAdjust.h"

@interface MutiTestViewController ()


@end

@implementation MutiTestViewController

- (instancetype)initWithEntity:(QFHomeEntityModel *)entity; {
    self = [super init];
    if (self) {
        self.entity = entity;
    }
    return self;
}

- (void)dealloc {
//    NSLog(@"dealloc with name:%@",_entity.name);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ViewController *parentVC = (ViewController *)self.parentViewController;
    if (parentVC) {
        self.view.height = parentVC.contentHeight;
    }
    
    CGFloat random = arc4random_uniform(100)/100.f;
    CGFloat random1 = arc4random_uniform(100)/100.f;
    CGFloat random2 = arc4random_uniform(100)/100.f;
    UIColor *backColor = [UIColor colorWithRed:random green:random1 blue:random2 alpha:1];
    self.view.backgroundColor = backColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:50];
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
    label.text = self.entity.name;
//    NSLog(@"viewdidload with name:%@",_entity.name);
}



@end
