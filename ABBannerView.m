//
//  ABBannerView.m
//  ABUserAppIPhone
//
//  Created by apple on 2018/4/10.
//  Copyright © 2018年 an-bang. All rights reserved.
//

#import "ABBannerView.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"

@interface ABBannerView()

@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)UIPageControl *pageC;
@property(nonatomic,assign)NSInteger count;
@property(nonatomic,strong)NSString *imageName;
@property(nonatomic,assign)BOOL animationDriectionIsLeft;
@property(nonatomic,strong)UIImageView *mainImageView;
@end
@implementation ABBannerView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.count = 0;
        self.userInteractionEnabled = true;
        
        [self addSubview:self.mainImageView];
        
    }
    return self;
}
- (void)setImageArr:(NSMutableArray *)imageArr {
    _imageArr = imageArr;
    //添加拖动手势
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.mainImageView addGestureRecognizer:panGR];
    
    //添加定时器
    self.timer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(changeImage) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    //初始化imageview的image
    self.imageName = imageArr[self.count];
    //添加pagecontrol
    self.pageC = [[UIPageControl alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.5 - (imageArr.count * 20*0.5), self.bounds.size.height - 30, imageArr.count * 20, 20)];
    self.pageC.numberOfPages = imageArr.count;
    self.pageC.currentPage = self.count;
    [self addSubview:self.pageC];
}
- (void)changeImage {
    self.animationDriectionIsLeft = false;
    self.count++;
    NSInteger num = self.count%self.imageArr.count;
    if (num == 0) {
        self.count = 0;
    }
    self.imageName = self.imageArr[num];
    
}
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan {
    //获取拖动变化的距离
    CGPoint panPoint = [pan translationInView:self];
    //获取起点位置
    CGFloat stateX = 0;
    //结束拖动位置
    CGFloat endX = 0;
    //删除定时器
    [self.timer invalidate];
    self.timer = nil;
    if (pan.state == UIGestureRecognizerStateEnded) {
        endX = [pan locationInView:self].x;
        
        
        CGFloat width = stateX - panPoint.x;
        if (width >= self.bounds.size.width*0.3) {
            NSLog(@"向右拖动 -- %f",width);
            _count++;
            if (_count >= self.imageArr.count) {
                _count = 0;
            }
            self.animationDriectionIsLeft = false;
            self.imageName = self.imageArr[_count];
        }else if (width <= -self.bounds.size.width * 0.3) {
            NSLog(@"向左拖动 -- %f",width);
            _count--;
            if (_count < 0) {
                _count = self.imageArr.count - 1;
            }
            self.animationDriectionIsLeft = true;
            self.imageName = self.imageArr[_count];
        }
        
        //重新添加定时器
        self.timer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(changeImage) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }else if (pan.state == UIGestureRecognizerStateBegan){
        stateX = [pan translationInView:self].x;
    }else if (pan.state == UIGestureRecognizerStateChanged){
        
    }
    
    
//    CGRect rect = [[self.layer presentationLayer] bounds];
//    CGSize size = [self.layer preferredFrameSize];
    NSLog(@"zhe shi duo");
}
- (void)setImageName:(NSString *)imageName {
    
    self.pageC.currentPage = self.count;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"push";
    if (_animationDriectionIsLeft) {
        transition.subtype = kCATransitionFromLeft;
    }else {
        transition.subtype = kCATransitionFromRight;
    }
    
    [self.mainImageView.layer addAnimation:transition forKey:nil];
    // 占位图片
    UIImage *placeholder = [UIImage imageNamed:@"login-Password"];
    // 从内存\沙盒缓存中获得原图
    
    UIImage *originalImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.imageArr[self.count]];
    if (originalImage) { // 如果内存\沙盒缓存有原图，那么就直接显示原图（不管现在是什么网络状态）
        [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:placeholder];
    } else { // 内存\沙盒缓存没有原图
        AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
        if (mgr.isReachableViaWiFi) { // 在使用Wifi, 下载原图
            [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:placeholder];
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
            
            NSLog(@"zhe shi size -- %@",imageView);
        } else if (mgr.isReachableViaWWAN) { // 在使用手机自带网络
            //     用户的配置项假设利用NSUserDefaults存储到了沙盒中
            //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"alwaysDownloadOriginalImage"];
            //    [[NSUserDefaults standardUserDefaults] synchronize];
//warning 从沙盒中读取用户的配置项：在3G\4G环境是否仍然下载原图
            BOOL alwaysDownloadOriginalImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysDownloadOriginalImage"];
            if (alwaysDownloadOriginalImage) { // 下载原图
                [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:placeholder];
            } else { // 下载小图
                [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:placeholder];
            }
        } else { // 没有网络
            UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageName];
            if (thumbnailImage) { // 内存\沙盒缓存中有小图
                [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:placeholder];
            } else {
                [self.mainImageView sd_setImageWithURL:nil placeholderImage:placeholder];
            }
        }
    }
}
- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.timer invalidate];
    self.timer = nil;
}

- (UIImageView *)mainImageView {
    if (_mainImageView == nil) {
        UIImageView *imagev = [[UIImageView alloc] initWithFrame:self.bounds];
        imagev.userInteractionEnabled = true;
        _mainImageView = imagev;
    }
    return _mainImageView;
}
- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
