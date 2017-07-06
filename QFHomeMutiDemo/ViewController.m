//
//  ViewController.m
//  QFHomeMutiDemo
//
//  Created by QianFan_Ryan on 2017/7/4.
//  Copyright © 2017年 QianFan_Ryan. All rights reserved.
//

#import "ViewController.h"
#import "UIView+move.h"
#import "UIView+frameAdjust.h"
#import "MutiTestViewController.h"

//屏幕尺寸
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
//转换iPhone6尺寸下px值为对应设备值
#define QF_TRANSFER_FORCE(x) rintf((x) * SCREEN_WIDTH / 750)
#define QF_TRANSFER(x) ((SCREEN_WIDTH>320)?((x)/2):rintf((x) * SCREEN_WIDTH / 750))
// 全局左右间距
#define QFMargin QF_TRANSFER(28)

#define QFTitleTagAddtion   100

#define QFEntityViewIntervalX 20
#define QFEntityViewIntervalY 10
#define QFEntityViewHeight       40
#define QFEntityViewHeaderHeight 50
#define QFEntityViewBottomHeight 15

@implementation QFHomeEntityModel

@end

@interface QFHomeEntityView : UIView

@property (nonatomic, strong) QFHomeEntityModel *entity;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, assign) BOOL currentSelected;
@property (nonatomic, strong) NSIndexPath *index;

@end

@implementation QFHomeEntityView

- (instancetype)initWithEntity:(QFHomeEntityModel *)entity atIndex:(NSIndexPath *)index firstSectionCount:(NSInteger)count {
    CGRect frame = [[self class] frameAtIndex:index firstSectionCount:count];
    self = [super initWithFrame:frame];
    if (self) {
        self.entity = entity;
        self.index = index;
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 7.5, frame.size.width, frame.size.height - 7.5)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.text = entity.name;
        self.label.textColor = [UIColor darkGrayColor];
        if (entity.name.length > 4) {
            self.label.font = [UIFont systemFontOfSize:11];
        } else if (entity.name.length == 4) {
            self.label.font = [UIFont systemFontOfSize:12];
        } else if (entity.name.length == 3) {
            self.label.font = [UIFont systemFontOfSize:13];
        } else {
            self.label.font = [UIFont systemFontOfSize:14];
        }
        if (!entity.binding) {
            self.label.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
            self.label.layer.cornerRadius = self.label.height/2;
            self.label.layer.borderColor = [UIColor lightGrayColor].CGColor;
            self.label.layer.borderWidth = 0.5;
            self.label.layer.masksToBounds = YES;
        }
        [self addSubview:self.label];
    }
    return self;
}

- (void)setCurrentSelected:(BOOL)currentSelected {
    _currentSelected = currentSelected;
    if (currentSelected) {
        self.label.textColor = [UIColor redColor];
    } else {
        self.label.textColor = [UIColor darkGrayColor];
    }
}

- (void)setIndex:(NSIndexPath *)index firstSectionCount:(NSInteger)count{
    self.index = index;
    if (index.section == 1) {
        _deleteButton.hidden = YES;
    }
    self.frame = [[self class] frameAtIndex:index firstSectionCount:count];
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _deleteButton.backgroundColor = [UIColor lightGrayColor];
        _deleteButton.hidden = YES;
        [self addSubview:_deleteButton];
    }
    return _deleteButton;
}

+ (CGRect)frameAtIndex:(NSIndexPath *)index firstSectionCount:(NSInteger)count {
    CGFloat origin_y;
    if (index.section == 0) {
        origin_y = QFEntityViewHeaderHeight;
    } else {
        NSInteger rowCount = count/4 + ((count%4>0)?1:0);
        origin_y = (QFEntityViewHeaderHeight * 2) + (QFEntityViewHeight * rowCount) + (QFEntityViewIntervalY * (rowCount - 1)) + QFEntityViewBottomHeight;
    }
    NSInteger column = index.row%4;
    NSInteger row = index.row/4;
    CGFloat itemWidth = (SCREEN_WIDTH - 5*QFEntityViewIntervalX)/4;
    CGRect frame = CGRectMake(QFEntityViewIntervalX + (QFEntityViewIntervalX + itemWidth) * column, origin_y + (QFEntityViewIntervalY + QFEntityViewHeight) * row, itemWidth, QFEntityViewHeight);
    return frame;
}

@end

typedef void(^QFHomeEntityPopViewSelectAction)(QFHomeEntityModel *selectEntity);

@interface QFHomeEntityPopView : UIView <UIViewMoveDelegate>

@property (nonatomic, copy  ) QFHomeEntityPopViewSelectAction selectAction;

@property (nonatomic, assign) NSInteger selectID;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIButton *topButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIView *firstSectionBackView;

@property (nonatomic, strong) NSArray <QFHomeEntityModel *>*topEntities;
@property (nonatomic, assign) NSInteger bindingCount;
@property (nonatomic, strong) NSArray <QFHomeEntityModel *>*downEntities;

@property (nonatomic, assign) CGPoint originCenter;
@property (nonatomic, assign) CGPoint gestureLocationInView;
@property (nonatomic, strong) NSMutableArray <UIView *>*sortedSubViews;
@property (nonatomic, assign) BOOL hasChanged;//是否变更了

@end

@implementation QFHomeEntityPopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.topButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        [self addSubview:self.topButton];
        
        self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
        self.contentView.showsVerticalScrollIndicator = NO;
        self.contentView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.contentView];
        
        self.firstSectionBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        self.firstSectionBackView.backgroundColor = [UIColor cyanColor];
        [self.contentView addSubview:self.firstSectionBackView];
        
        self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, (QFEntityViewHeaderHeight - 20)/2, 45, 20)];
        [self.editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [self.editButton setTitle:@"完成" forState:UIControlStateSelected];
        [self.contentView addSubview:self.editButton];
        
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, (QFEntityViewHeaderHeight - 20)/2, 30, 20)];
        [self.closeButton setTitle:@"-X-" forState:UIControlStateNormal];
        [self.contentView addSubview:self.closeButton];
        
        self.sortedSubViews = [NSMutableArray array];
    }
    return self;
}

- (void)setHighLightIndex:(NSInteger)index {
    for (QFHomeEntityView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[QFHomeEntityView class]]) {
            if (view.index.section == 0) {
                if (view.index.row == index) {
                    view.currentSelected = YES;
                    self.selectID = view.entity.ID;
                } else {
                    view.currentSelected = NO;
                }
            }
        }
    }
}

- (void)setTopEntities:(NSArray<QFHomeEntityModel *> *)topEntities downEntities:(NSArray<QFHomeEntityModel *> *)downEntities{
    _topEntities = topEntities;
    [self.sortedSubViews removeAllObjects];
    __block CGFloat firstSectionHeight = 0;
    __block NSInteger bindingCount = 0;
    [_topEntities enumerateObjectsUsingBlock:^(QFHomeEntityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        QFHomeEntityView *view = [[QFHomeEntityView alloc] initWithEntity:obj atIndex:indexPath firstSectionCount:_topEntities.count];
        [view.deleteButton addTarget:self action:@selector(itemDeleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [view addGestureRecognizer:tap];
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//        [longPress requireGestureRecognizerToFail:tap];
//        [view addGestureRecognizer:longPress];
        if (!view.entity.binding) {
            [self.sortedSubViews addObject:view];
            view.tagId = [self.sortedSubViews indexOfObject:view];
        } else {
            bindingCount++;
        }
        [self.contentView addSubview:view];
        if (idx == (_topEntities.count - 1)) {
            firstSectionHeight = view.tail + QFEntityViewBottomHeight;
        }
    }];
    self.bindingCount = bindingCount;
    self.firstSectionBackView.height = firstSectionHeight;
    _downEntities = downEntities;
    __block CGFloat totalHeight = 0 ;
    [_downEntities enumerateObjectsUsingBlock:^(QFHomeEntityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:1];
        QFHomeEntityView *view = [[QFHomeEntityView alloc] initWithEntity:obj atIndex:indexPath firstSectionCount:_topEntities.count];
        [view.deleteButton addTarget:self action:@selector(itemDeleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [view addGestureRecognizer:tap];
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//        [longPress requireGestureRecognizerToFail:tap];
//        [view addGestureRecognizer:longPress];
        [self.contentView addSubview:view];
        if (idx == (_downEntities.count - 1)) {
            totalHeight = view.tail + QFEntityViewBottomHeight;
        }
    }];
    self.contentView.contentSize = CGSizeMake(SCREEN_WIDTH, totalHeight);
}

- (void)itemDeleteButtonClicked:(UIButton *)sender {
    QFHomeEntityView *view = (QFHomeEntityView *)sender.superview;
    view.currentSelected = NO;
    
    NSInteger oldIndex = [self.sortedSubViews indexOfObject:view];
    [self.sortedSubViews removeObject:view];
    view.moveDelegate = nil;
    NSMutableArray *tempTop = [NSMutableArray arrayWithArray:_topEntities];
    [tempTop removeObject:view.entity];
    _topEntities = tempTop;
    
    NSMutableArray *tempDown = [NSMutableArray arrayWithArray:_downEntities];
    [tempDown addObject:view.entity];
    _downEntities = tempDown;
    
    [UIView animateWithDuration:0.35 animations:^{
        for (QFHomeEntityView *aView in self.contentView.subviews) {
            if (![aView isKindOfClass:[QFHomeEntityView class]]) {
                continue;
            }
            if (aView.index.section == 1) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(aView.index.row + 1) inSection:aView.index.section];
                [aView setIndex:newIndexPath firstSectionCount:_topEntities.count];
            } else if (aView.index.section == 0 && aView.index.row > (oldIndex + 1)) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(aView.index.row - 1) inSection:aView.index.section];
                [aView setIndex:newIndexPath firstSectionCount:_topEntities.count];
            }
        }
        [view setIndex:[NSIndexPath indexPathForRow:0 inSection:1] firstSectionCount:_topEntities.count];
        self.firstSectionBackView.height = view.y - QFEntityViewHeaderHeight;
    }];
    self.hasChanged = YES;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    QFHomeEntityView *view = (QFHomeEntityView *)tap.view;
    if (view.index.section == 1) {//下面的移动到上面
        [self addEntityView:view];
    } else if (!self.editButton.isSelected) {//非编辑模式下 直接选中退出
        if (self.selectAction) {
            self.selectAction(view.entity);
        }
    }
}

- (void)addEntityView:(QFHomeEntityView *)view {
    view.tagId = (_topEntities.count - 1) - self.bindingCount;
    
    NSMutableArray *tempTop = [NSMutableArray arrayWithArray:_topEntities];
    [tempTop addObject:view.entity];
    _topEntities = tempTop;
    [_sortedSubViews addObject:view];
    
    NSMutableArray *tempDown = [NSMutableArray arrayWithArray:_downEntities];
    [tempDown removeObject:view.entity];
    _downEntities = tempDown;
    
    if (_editButton.isSelected) {
        view.moveDelegate = self;
        view.deleteButton.hidden = NO;
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        for (QFHomeEntityView *aView in self.contentView.subviews) {
            if (![aView isKindOfClass:[QFHomeEntityView class]]) {
                continue;
            }
            if (aView.index.section == 1) {
                if (aView.index.row > view.index.row) {
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(aView.index.row - 1) inSection:aView.index.section];
                    [aView setIndex:newIndexPath firstSectionCount:_topEntities.count];
                } else if (aView.index.row < view.index.row) {
                    [aView setIndex:aView.index firstSectionCount:_topEntities.count];
                }
            }
        }
        [view setIndex:[NSIndexPath indexPathForRow:(_topEntities.count - 1) inSection:0] firstSectionCount:_topEntities.count];
        if (view.entity.ID == self.selectID) {
            view.currentSelected = YES;
        }
        self.firstSectionBackView.height = view.tail + QFEntityViewBottomHeight;
    }];
    self.hasChanged = YES;
}

//- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
//    if (self.editButton.isSelected) {
//        return;
//    }
//    QFHomeEntityView *view = (QFHomeEntityView *)longPress.view;
//    if (view.index.section == 0) {
//        [self editAction:self.editButton];
//    }
//}

- (void)editAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {//编辑状态
        for (QFHomeEntityView *view in self.contentView.subviews) {
            if (![view isKindOfClass:[QFHomeEntityView class]]) {
                continue;
            }
            if (view.index.section == 0 && !view.entity.binding) {
                view.moveDelegate = self;
                view.deleteButton.hidden = NO;
            }
        }
    } else {//完成编辑
        for (QFHomeEntityView *view in self.contentView.subviews) {
            if (![view isKindOfClass:[QFHomeEntityView class]]) {
                continue;
            }
            if (view.index.section == 0 && !view.entity.binding) {
                view.moveDelegate = nil;
                view.deleteButton.hidden = YES;
            }
        }
    }
}

- (void)dismissWithCompletion:(void(^)(void))completion {
    self.userInteractionEnabled = NO;
    self.animating = YES;
    //每次消失的时候 需要对推荐的重新排序
    NSMutableArray *sortedTop = [NSMutableArray array];
    for (NSInteger i = 0; i < self.topEntities.count; i++) {//先把置顶的加进去
        QFHomeEntityModel *entity = self.topEntities[i];
        if (entity.binding) {
            [sortedTop addObject:entity];
        } else {
            break;
        }
    }
    //把排序的按顺序加入
    for (NSInteger i = 0; i < self.sortedSubViews.count; i++) {
        QFHomeEntityView *sortedView = (QFHomeEntityView *)self.sortedSubViews[i];
        [sortedTop addObject:sortedView.entity];
    }
    self.topEntities = sortedTop;

    [UIView animateWithDuration:.5f animations:^{
        self.y -= (self.height - 64);
    } completion:^(BOOL finished) {
        if (self.editButton.isSelected) {//取消编辑状态
            [self editAction:self.editButton];
        }
        if (completion) {
            completion();
        }
        self.hidden = YES;
        self.animating = NO;
    }];
}

- (void)showWithCompletion:(void(^)(void))completion {
    self.hidden = NO;
    self.animating = YES;
    [UIView animateWithDuration:.5f animations:^{
        self.y += (self.height - 64);
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
        self.animating = NO;
        if (completion) {
            completion();
        }
    }];
}

#pragma mark -- UIViewMoveDelegate
- (void)view:(UIView *)view beginToMove:(UIPanGestureRecognizer *)gesture {
    _originCenter = view.center;
    [self recoverWithView:nil];
    _gestureLocationInView = [gesture locationInView:self];
    [self bringSubviewToFront:view];
    view.transform = CGAffineTransformMakeScale(1.1, 1.1);
}

- (void)view:(UIView *)view isMoving:(UIPanGestureRecognizer *)gesture {
    CGPoint newPoint = [gesture locationInView:self];
    CGFloat deltaX = newPoint.x - _gestureLocationInView.x;
    CGFloat deltaY = newPoint.y - _gestureLocationInView.y;
    _gestureLocationInView = newPoint;
    view.center = CGPointMake(view.center.x + deltaX, view.center.y + deltaY);
    NSInteger newIndex = [self newIndexOfView:view];

    if (newIndex < 0 || newIndex >= self.sortedSubViews.count) {
        return;
    }
    UIView *targetView = [self.sortedSubViews objectAtIndex:newIndex];
    _originCenter = targetView.originCenter;
    if (newIndex < view.tagId) {
        for (NSUInteger i = view.tagId; i > newIndex; i--) {
            UIView *firstView = [self.sortedSubViews objectAtIndex:(i - 1)];
            UIView *lastView = [self.sortedSubViews objectAtIndex:i];
            [UIView animateWithDuration:0.35 animations:^{
                firstView.center = lastView.originCenter;
            }];
        }
        [self.sortedSubViews removeObject:view];
        [self.sortedSubViews insertObject:view atIndex:newIndex];
        [self recoverWithView:view];
        self.hasChanged = YES;
    } else if (newIndex > view.tagId) {
        for (NSUInteger i = view.tagId; i < newIndex; i++) {
            UIView *firstView = [self.sortedSubViews objectAtIndex:i];
            UIView *lastView = [self.sortedSubViews objectAtIndex:(i + 1)];
            [UIView animateWithDuration:0.35 animations:^{
                lastView.center = firstView.originCenter;
            }];
        }
        [self.sortedSubViews removeObject:view];
        [self.sortedSubViews insertObject:view atIndex:newIndex];
        [self recoverWithView:view];
        self.hasChanged = YES;
    }
}

- (void)view:(UIView *)view endMove:(UIPanGestureRecognizer *)gesture {
    [UIView animateWithDuration:0.35 animations:^{
        view.center = _originCenter;
    }];
    view.transform = CGAffineTransformIdentity;
}

#pragma mark -- help
- (void)recoverWithView:(UIView *)view{
    for (NSUInteger i = 0; i < self.sortedSubViews.count; i++) {
        QFHomeEntityView *aView = (QFHomeEntityView *)[self.sortedSubViews objectAtIndex:i];
        aView.tagId = i;
        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:i+self.bindingCount inSection:0];
        aView.index = newIndex;
        if (aView == view) {
            aView.originCenter = _originCenter;
        } else {
            aView.originCenter = aView.center;
        }
    }
}

- (NSInteger)newIndexOfView:(UIView *)view{
    NSInteger newIndex = -1;
    for (QFHomeEntityView *aView in self.sortedSubViews) {
        if (aView != view) {
            if (CGRectContainsPoint(aView.frame, view.center)) {
                newIndex = aView.tagId;
            }
        }
    }
    return newIndex;
}

@end



@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, assign) QFHomeMutiColumnsType mutiColumnsType;
@property (nonatomic, strong) NSArray <QFHomeEntityModel *>*allEntities;

@property (nonatomic, strong) UIScrollView *tabbarScrollView;
@property (nonatomic, assign) CGFloat itemInterval;//多栏按钮间距

@property (nonatomic, strong) UIButton *editButton;//编辑按钮
@property (nonatomic, strong) QFHomeEntityPopView *editView;//编辑页面

@property (nonatomic, assign) NSInteger recoverCount;//超过多少个vc就进行回收 至少3个
@property (nonatomic, strong) UIScrollView *contentScrollView;

@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutiColumnsType = QFHomeMutiColumnsTypeCommon;
//        self.mutiType = QFHomeMutiTypeLinked;
        self.allEntities = [NSMutableArray new];
        self.itemInterval = 5;
        self.recoverCount = 3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabbarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH - 30, 30)];
    self.tabbarScrollView.backgroundColor = [UIColor whiteColor];
    self.tabbarScrollView.showsVerticalScrollIndicator = NO;
    self.tabbarScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.tabbarScrollView];
    
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, 64, 30, 30)];
    [self.editButton setTitle:@"-+-" forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(beginEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editButton];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.tabbarScrollView.tail, SCREEN_WIDTH, self.view.height - self.tabbarScrollView.tail)];
    self.contentScrollView.backgroundColor = [UIColor whiteColor];
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.delegate = self;
    [self.view addSubview:self.contentScrollView];
    
    self.editView = [[QFHomeEntityPopView alloc] initWithFrame:CGRectMake(0, 64-SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    __weak typeof(self) weakSelf = self;
    self.editView.selectAction = ^(QFHomeEntityModel *selectEntity) {
        [weakSelf endEditWithSelectEntity:selectEntity];
    };
    [self.editView.topButton addTarget:self action:@selector(endEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.editView.closeButton addTarget:self action:@selector(endEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view insertSubview:self.editView belowSubview:self.navigationController.navigationBar];
    
    NSMutableArray *temp = [NSMutableArray array];
    NSArray *names = @[@"推荐",@"信息流",@"板块",@"话题",@"本地圈",@"视频",@"24小时热点",@"今日头条",@"活动",@"好友动态",@"外链",@"本地圈小视频",@"交友"];
    for (NSInteger i = 0; i < names.count; i++) {
        QFHomeEntityModel *model = [QFHomeEntityModel new];
        model.name = names[i];
        model.type = i;
        model.ID = i + 123;
        [temp addObject:model];
        if (i < 2) {
            model.binding = YES;
        }
    }
    self.allEntities = temp;
    
    NSMutableArray *temp1 = [NSMutableArray array];
    NSArray *names1 = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8"];
    for (NSInteger i = 0; i < names1.count; i++) {
        QFHomeEntityModel *model = [QFHomeEntityModel new];
        model.name = names1[i];
        model.type = i;
        model.ID = i + 234;
        [temp1 addObject:model];
    }
    
    [self.editView setTopEntities:self.allEntities downEntities:temp1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

- (void)beginEdit {
    if (self.editView.animating) {
        return;
    }
    NSInteger highLightIndex = 0;
    for (UIButton *button in _tabbarScrollView.subviews) {
        if (button.isSelected) {
            highLightIndex = button.tag - QFTitleTagAddtion;
            break;
        }
    }
    [self.editView setHighLightIndex:highLightIndex];
    [self.editView showWithCompletion:^{
        [self.navigationController.view bringSubviewToFront:self.editView];
    }];
}

- (void)endEdit {
    [self endEditWithSelectEntity:nil];
}

- (void)endEditWithSelectEntity:(QFHomeEntityModel *)entity {
    [self.navigationController.view insertSubview:self.editView belowSubview:self.navigationController.navigationBar];
    [self.editView dismissWithCompletion:^{
        NSInteger current = 0;
        if (entity) {
            for (NSInteger i = 0; i < self.editView.topEntities.count; i++) {
                QFHomeEntityModel *obj = self.editView.topEntities[i];
                if (obj.ID == entity.ID) {
                    current = i;
                    break;
                }
            }
        } else {
            for (QFHomeEntityView *subView in self.editView.contentView.subviews) {
                if ([subView isKindOfClass:[QFHomeEntityView class]]) {
                    if (subView.index.section == 0 && subView.currentSelected) {
                        current = subView.index.row;
                        break;
                    }
                }
            }
        }
        [self resetMutiColumnsWithNewEntities:self.editView.topEntities currentSelectedIndex:current];
    }];
}

#pragma makr -- mutiColumns func
- (void)setAllEntities:(NSArray<QFHomeEntityModel *> *)allEntities {
    [self resetMutiColumnsWithNewEntities:allEntities currentSelectedIndex:0];
}

- (void)resetMutiColumnsWithNewEntities:(NSArray<QFHomeEntityModel *> *)newEntities currentSelectedIndex:(NSInteger)current {
    _allEntities = newEntities;
    [self resetTabbarWithNewEntities:newEntities currentSelectedIndex:current];
    [self updateTabbarSelectedItemPosition];
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.width * newEntities.count, self.contentScrollView.height);
    [self resetContentViewWithNewEntities:newEntities currentSelectedIndex:current];
    [self changeContentViewToIndex:current];
    [_contentScrollView setContentOffset:CGPointMake(self.contentScrollView.width * current, 0) animated:NO];
}

- (void)resetTabbarWithNewEntities:(NSArray<QFHomeEntityModel *> *)newEntities currentSelectedIndex:(NSInteger)current {
    [_tabbarScrollView removeAllSubviews];
    __block CGFloat current_X = self.itemInterval;
    [newEntities enumerateObjectsUsingBlock:^(QFHomeEntityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        titleButton.tag = QFTitleTagAddtion + idx;
        [titleButton setTitle:obj.name forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        titleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        CGSize fixedSize = [titleButton sizeThatFits:CGSizeMake(_tabbarScrollView.width, _tabbarScrollView.height)];
        titleButton.frame = CGRectMake(current_X, 0, fixedSize.width, _tabbarScrollView.height);
        [titleButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_tabbarScrollView addSubview:titleButton];
        current_X = titleButton.right + self.itemInterval;
        if (current == idx) {
            titleButton.selected = YES;
        }
    }];
    [_tabbarScrollView setContentSize:CGSizeMake(current_X, _tabbarScrollView.height)];
}

- (void)resetContentViewWithNewEntities:(NSArray<QFHomeEntityModel *> *)newEntities currentSelectedIndex:(NSInteger)current {
    [self.childViewControllers enumerateObjectsUsingBlock:^(MutiTestViewController *subVC, NSUInteger outerIdx, BOOL * _Nonnull outerStop) {
        __block BOOL isExist = NO;
        [newEntities enumerateObjectsUsingBlock:^(QFHomeEntityModel * _Nonnull obj, NSUInteger inerIdx, BOOL * _Nonnull inerStop) {
            if (obj.ID == subVC.entity.ID) {
                subVC.view.x = _contentScrollView.width * inerIdx;
                isExist = YES;
                *inerStop = YES;
            }
        }];
        if (!isExist) {
            [subVC.view removeFromSuperview];
            [subVC removeFromParentViewController];
        }
    }];
}

- (void)titleButtonClicked:(UIButton *)sender {
    if (sender.isSelected) {
        //是否需要刷新当前页面？
        return;
    }
    for (UIButton *button in _tabbarScrollView.subviews) {
        if (button.isSelected) {
            button.selected = NO;
            break;
        }
    }
    sender.selected = YES;
    NSInteger seletedIndex = sender.tag - QFTitleTagAddtion;
    [self changeContentViewToIndex:seletedIndex];
    [self updateTabbarSelectedItemPosition];
    [_contentScrollView setContentOffset:CGPointMake(self.contentScrollView.width * seletedIndex, 0) animated:NO];
}

- (void)updateTabbarSelectedItemPosition {
    UIButton *currentItem;
    for (UIButton *button in _tabbarScrollView.subviews) {
        if (button.isSelected) {
            currentItem = button;
            break;
        }
    }
    CGFloat contentOffset_x = currentItem.center.x - _tabbarScrollView.width/2;//默认情况下在中心
    if ((contentOffset_x + _tabbarScrollView.width) > _tabbarScrollView.contentSize.width) {//确保不大于contentSize
        contentOffset_x = _tabbarScrollView.contentSize.width - _tabbarScrollView.width;
    }
    contentOffset_x = MAX(0, contentOffset_x);//确保大于0
    [_tabbarScrollView setContentOffset:CGPointMake(contentOffset_x, 0) animated:YES];
}

- (void)changeContentViewToIndex:(NSInteger)index {
    if (index >= self.allEntities.count) {
        return;
    }
    BOOL isExsit = NO;
    QFHomeEntityModel *entity = self.allEntities[index];
    MutiTestViewController *oldVC;
    for (MutiTestViewController *subVC in self.childViewControllers) {
        if (subVC.entity && subVC.entity.ID == entity.ID) {
            oldVC = subVC;
            isExsit = YES;
            break;
        }
    }
    CGFloat right_X = self.contentScrollView.width * index;
    if (!isExsit) {
        MutiTestViewController *newVC = [[MutiTestViewController alloc] initWithEntity:entity];
        [self addChildViewController:newVC];
        [self.contentScrollView addSubview:newVC.view];
        newVC.view.x = right_X;
    } else if (oldVC.view.x != right_X) {
        oldVC.view.x = right_X;
    }
    [self recoverViews];
}

- (void)scrollToIndex:(NSInteger)index {
    BOOL needUpdateItem = NO;
    for (UIButton *button in _tabbarScrollView.subviews) {
        if (button.isSelected) {
            if ((button.tag - QFTitleTagAddtion) != index) {
                needUpdateItem = YES;
                button.selected = NO;
            }
        } else if ((button.tag - QFTitleTagAddtion) == index) {
            needUpdateItem = YES;
            button.selected = YES;
        }
    }
    if (needUpdateItem) {
        [self updateTabbarSelectedItemPosition];
        [self changeContentViewToIndex:index];
    }
}

- (void)recoverViews {
    if (self.childViewControllers.count > self.recoverCount) {
        MutiTestViewController *vc = self.childViewControllers.firstObject;
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    scrollView.scrollEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = rintf(scrollView.contentOffset.x/scrollView.width);
    [self scrollToIndex:currentIndex];
    scrollView.scrollEnabled = YES;
}

@end
