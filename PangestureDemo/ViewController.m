//
//  ViewController.m
//  PangestureDemo
//
//  Created by kyson on 2019/5/8.
//  Copyright © 2019 kyson. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+SPRAddtion.h"
#import <MapKit/MapKit.h>
#import "UIImage+LPDAddition.h"

//在 iPhone X 之前，所有 iPhone 设备的 StatusBar（状态栏）高度都为 20pt，而 iPhone X 的为 44pt，因此我们可以通过获取状态栏的高度判断是否等于 44.0 来检测设备是否为 iPhone X：
#define kIsPhoneXOrLater (([[UIApplication sharedApplication] statusBarFrame].size.height == 44.0) ? (YES) : NO)
#define kHeightStatusBarAndNavigationBar (([[UIApplication sharedApplication] statusBarFrame].size.height == 44.0) ? (44 + 44) : 64)

#define kVisiableHeightTableView 190 //一开始 tableview 露出来的部分
#define kHeightIndicatorForTableViewView 20

#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

#define kOriginYTableView (SCREEN_HEIGHT - kVisiableHeightTableView - kHeightStatusBarAndNavigationBar)


@interface ViewController ()<UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic, assign) CGPoint containerOrigin;

@property (nonatomic, strong) UIView *indicatorForTableViewView; //指示tableview 能滑动的 view

@property (nonatomic, strong) UIView *backgroundAlphaViewForView; //背景的半透明 蒙层

@property (nonatomic, strong) UIImageView *navImageView;
@property (nonatomic, strong) UIImageView *statusBarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //背景图层 位于地图上方，tableview 下方
    self.backgroundAlphaViewForView.frame = UIScreen.mainScreen.bounds;
    [self.view addSubview:self.backgroundAlphaViewForView];
    
    //如果是第一次进入，则将 mapView 添加到 视图即可
    self.mapView.frame = CGRectMake(0, 0, SCREEN_WIDTH,  SCREEN_HEIGHT -  kVisiableHeightTableView);
    [self.view addSubview:self.mapView];
    
    self.indicatorForTableViewView.frame = CGRectMake(0, SCREEN_HEIGHT - kVisiableHeightTableView, SCREEN_WIDTH, kHeightIndicatorForTableViewView);
    [self.view addSubview:self.indicatorForTableViewView];
    
    self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT - kVisiableHeightTableView, SCREEN_WIDTH, kVisiableHeightTableView - kHeightIndicatorForTableViewView);
    [self.view addSubview:self.tableView];
    
    //pan gesture
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    gesture.delegate = self;
    [self.tableView addGestureRecognizer:gesture];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 68;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellTag = @"cellTag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTag];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellTag];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%li",indexPath.row];
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //处理状态栏和导航栏
    {
        //确保只添加一次
        if (nil == self.statusBarView.superview) {
            [self.view addSubview:self.statusBarView];
        }
        
        //导航栏
        //确保只添加一次
        if (nil == self.navImageView.superview) {
            CGFloat statusHeight = kIsPhoneXOrLater ? 44 : 20;
            self.navImageView.frame = CGRectMake(0, statusHeight, SCREEN_WIDTH, 44);
            [self.view addSubview:self.navImageView];
            //重新设置视图层级
            [self resetViewHierarchy];
        }
    }
}


/**
 重置视图层级
 */
- (void) resetViewHierarchy {
    //改变视图层级
    [self.view bringSubviewToFront:self.statusBarView];
    [self.view bringSubviewToFront:self.navImageView];
    [self.view bringSubviewToFront:self.backgroundAlphaViewForView];
    [self.view bringSubviewToFront:self.indicatorForTableViewView];
    [self.view bringSubviewToFront:self.tableView];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:self.view];
    // 1.手势开始时:记录 sourceVC.view 原始的 origin , 必须作为属性记录,移动过程才能顺畅,不然卡顿
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.containerOrigin = recognizer.view.frame.origin;
    }
    // 2.手势移动过程中: 在边界处做判断,其他位置
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if ([recognizer velocityInView:self.view].y > 0 && self.tableView.contentOffset.y > 0) {
            NSLog(@"向下");
        } else {
            CGRect frame = recognizer.view.frame;
            frame.origin.y = self.containerOrigin.y + point.y;
            
            // 上边界
            if (frame.origin.y < kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView) {
                frame.origin.y = kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView;
            }
            // 下边界
            if (frame.origin.y > SCREEN_HEIGHT - kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView) {
                frame.origin.y = SCREEN_HEIGHT - kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView;
            }
            
            //tableview 的 height 就 写死好了，因为在空列表的时候需要展示空的 tableview，如果太小，滑动的时候会露出一部分很难看
            frame.size.height = (SCREEN_HEIGHT - kHeightStatusBarAndNavigationBar - kHeightIndicatorForTableViewView) ;
            //动态设置 tableview 的 frame
            recognizer.view.frame = frame;
            
            //设置 indicatorForTableViewView 的 frame
            CGRect frameOfIndicator = frame;
            frameOfIndicator.origin.y = frame.origin.y - kHeightIndicatorForTableViewView;
            frameOfIndicator.size.height = kHeightIndicatorForTableViewView;
            self.indicatorForTableViewView.frame = frameOfIndicator;
            // 设置 alpha 值 ******
            if (frame.origin.y > 0) {
                CGFloat currentAlpha = - 0.7f / kOriginYTableView * self.tableView.frame.origin.y + 0.7f ;
                
                self.backgroundAlphaViewForView.alpha = currentAlpha > 0 ? currentAlpha : 0;
            } else if (frame.origin.y <= 0) {
                self.backgroundAlphaViewForView.alpha = 0.7;
            }
        }
        
    }
    // 3.手势结束后:有向上趋势,视图直接滑动至上边界, 向下趋势,视图直接滑动至到下边界
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if ([recognizer velocityInView:self.view].y < 0) {
            NSLog(@"向上滑动了===============================");
            [UIView animateWithDuration:0.40 animations:^{
                if (self.tableView.contentOffset.y > 0 && self.tableView.frame.origin.y < 1) {
                    //还在内部滑动中
                } else {
                    CGRect frame = recognizer.view.frame;
                    if (self.tableView.contentSize.height < SCREEN_HEIGHT - kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView) {
                        // do nothing
                    } else {
                        frame.origin.y = kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView;
                    }
                    frame.origin.y = kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView;
                    recognizer.view.frame = frame;
                    
                    CGRect frameOfIndicator = frame;
                    frameOfIndicator.origin.y = frame.origin.y - kHeightIndicatorForTableViewView;
                    frameOfIndicator.size.height = kHeightIndicatorForTableViewView;
                    self.indicatorForTableViewView.frame = frameOfIndicator;
                }
                
            } completion:^(BOOL finished) {
            }];
            
        } else {
            NSLog(@"向下");
            __block BOOL isNeibuhuadong = NO;
            [UIView animateWithDuration:0.40 animations:^{
                //如果当前的tableview在最上面，并且正在滑动中，那么就不做任何处理
                if (self.tableView.contentOffset.y > 0 && self.tableView.frame.origin.y == (kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView) ) {
                    //还在内部滑动中
                    isNeibuhuadong = YES;
                } else {
                    //其他情况，那就滑动tableview
                    CGRect frame = recognizer.view.frame;
                    frame.origin.y =  (SCREEN_HEIGHT - kVisiableHeightTableView) + kHeightIndicatorForTableViewView;
                    
                    recognizer.view.frame = frame;
                    
                    CGRect frameOfIndicator = frame;
                    frameOfIndicator.origin.y = frame.origin.y - kHeightIndicatorForTableViewView;
                    frameOfIndicator.size.height = kHeightIndicatorForTableViewView;
                    self.indicatorForTableViewView.frame = frameOfIndicator;
                    
                    isNeibuhuadong = NO;
                }
                
            } completion:^(BOOL finished) {
                //如果是内部滑动，那就不需要隐藏背景浮层了
                if (!isNeibuhuadong) {
                    self.backgroundAlphaViewForView.alpha = 0;
                }
                
            }];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    UITableView *tabView = self.tableView;
    CGPoint vel = [tabView.panGestureRecognizer velocityInView:self.view];
    if (vel.y > 0) {
        NSLog(@"向下==");
        //下拉过程中，如果他的content offset 大于0 ，说明正在滑动，就可以多手势
        if (tabView.contentOffset.y > 0) {
            return YES;
        }
    } else {
        NSLog(@"向上");
        // 上拉到顶的时候 内部才可以滑动
        if (tabView.frame.origin.y == kHeightStatusBarAndNavigationBar + kHeightIndicatorForTableViewView ) {
            return YES;
        }
        //内部已经在滑动，那就继续滑
        if (tabView.contentOffset.y > 0) {
            return YES;
        }
        
    }
    return NO;
    
}


-(void) hideTableView;
{
    CGRect frame = self.tableView.frame;
    frame.origin.y =  (SCREEN_HEIGHT - kVisiableHeightTableView);
    [UIView animateWithDuration:0.4f animations:^{
        self.tableView.frame = frame;
        self.backgroundAlphaViewForView.alpha = 0;
    }];
}

-(UIView *)backgroundAlphaViewForView
{
    if(!_backgroundAlphaViewForView) {
        _backgroundAlphaViewForView = [[UIView alloc] init];
        _backgroundAlphaViewForView.alpha = 0;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTableView)];
        [_backgroundAlphaViewForView addGestureRecognizer:gesture];
        self.backgroundAlphaViewForView.backgroundColor = UIColor.blackColor;
    }
    return _backgroundAlphaViewForView;
}

-(UIView *)indicatorForTableViewView
{
    if (!_indicatorForTableViewView) {
        _indicatorForTableViewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, kHeightIndicatorForTableViewView)];
        _indicatorForTableViewView.backgroundColor = UIColor.whiteColor;
        //设置上半部分的圆角
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_indicatorForTableViewView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6,6)];
        //创建 layer
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, kHeightIndicatorForTableViewView);
        //赋值
        maskLayer.path = maskPath.CGPath;
        _indicatorForTableViewView.layer.mask = maskLayer;
        
        UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 16 , 8 , 32, 3)];
        indicatorView.backgroundColor = [[UIColor colorWithHexString:@"#D8D8D8"] colorWithAlphaComponent:1.f];
        indicatorView.layer.cornerRadius = 3.f;
        indicatorView.clipsToBounds = YES;
        [_indicatorForTableViewView addSubview:indicatorView];
    }
    return _indicatorForTableViewView;
}

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
    }
    return _mapView;
}


-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColor.whiteColor;
    }
    return _tableView;
}


-(UIImageView *)navImageView {
    if (!_navImageView) {
        //导航栏图片
        UIColor *beginColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
        UIColor *middleColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
        UIColor *endColor = [[UIColor whiteColor] colorWithAlphaComponent:0.f];
        UIImage *navImg = [UIImage gradientImageWithColors:@[beginColor,middleColor,endColor] direction:LPDGradientDirectionTop size:CGSizeMake(SCREEN_WIDTH, 44) ];
        //导航栏
        _navImageView = [[UIImageView alloc] initWithImage:navImg];
        _navImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        _navImageView.userInteractionEnabled = YES;
        
        //标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50, 5, 100, 40)];
        label.text = @"路径规划";
        label.textColor = [UIColor colorWithHexString:@"#333"];
        label.font = [UIFont boldSystemFontOfSize:16.f];
        label.textAlignment = NSTextAlignmentCenter;
        [_navImageView addSubview:label];

        //回退键
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"icon_back_dark"] forState:UIControlStateNormal];
        [_navImageView addSubview:backButton];
        backButton.frame = CGRectMake(15, 5, 30, 30);
    }
    return _navImageView;
}

-(UIImageView *)statusBarView
{
    if (!_statusBarView) {
        CGFloat statusHeight = kIsPhoneXOrLater ? 44 : 20;
        UIImage *statusImg = [UIImage imageWithColor:UIColor.whiteColor size:CGSizeMake(SCREEN_WIDTH, statusHeight)];
        _statusBarView = [[UIImageView alloc] initWithImage:statusImg];
    }
    return _statusBarView;
}



@end
