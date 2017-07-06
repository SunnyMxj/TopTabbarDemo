//
//  ViewController.h
//  QFHomeMutiDemo
//
//  Created by QianFan_Ryan on 2017/7/4.
//  Copyright © 2017年 QianFan_Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,QFHomeMutiColumnsType){
    QFHomeMutiColumnsTypeCommon = 0,   //首页多栏默认样式
    QFHomeMutiColumnsTypeLinked = 1,   //首页多栏连体样式
};

typedef NS_ENUM(NSInteger,QFHomeEntityModelType){
    QFHomeEntityModelTypeRecommend = 0, //推荐
    QFHomeEntityModelTypeInfoFlow,      //信息流
    QFHomeEntityModelTypeForum,         //板块
    QFHomeEntityModelTypeTopic,         //话题
    QFHomeEntityModelTypeLocal,         //本地圈
    QFHomeEntityModelTypeVideo,         //视频
    QFHomeEntityModelTypeHot,           //热点
    QFHomeEntityModelTypeHeadline,      //今日头条
    QFHomeEntityModelTypePromotions,    //活动
    QFHomeEntityModelTypeActivity,      //好友动态
    QFHomeEntityModelTypeOuterLink,     //外链
    QFHomeEntityModelTypeShortVideo,    //小视频
    QFHomeEntityModelTypeFriends,       //交友
};

@interface QFHomeEntityModel : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL binding;
@property (nonatomic, assign) QFHomeEntityModelType type;

@end

@interface ViewController : UIViewController

@end

