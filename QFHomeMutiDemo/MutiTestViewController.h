//
//  MutiTestViewController.h
//  QFHomeMutiDemo
//
//  Created by QianFan_Ryan on 2017/7/4.
//  Copyright © 2017年 QianFan_Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface MutiTestViewController : UIViewController

@property (nonatomic, strong) QFHomeEntityModel *entity;

- (instancetype)initWithEntity:(QFHomeEntityModel *)entity;

@end
