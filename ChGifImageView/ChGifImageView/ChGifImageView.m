//
//  ChGifImageView.m
//  ChGifImageView
//
//  Created by Ashuro on 2016/12/26.
//  Copyright © 2016年 Ashuro. All rights reserved.
//

#import "ChGifImageView.h"
#import <ImageIO/ImageIO.h>


#define DocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define ChGifCacheDirPath [NSString stringWithFormat:@"%@/ChGifFresh",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]]
#define ImageCacheDirPath(imageName) [NSString stringWithFormat:@"%@/ChGifFresh/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],imageName]
#define ImagePath(imageName,index) [NSString stringWithFormat:@"%@/ChGifFresh/%@/%@_%ld",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject],imageName,imageName,index]

@interface ChGifImageView ()<UIWebViewDelegate> {
    
}

@property (nonatomic,strong) UIImageView *playImageView;    //承载图片的imageView
@property (nonatomic,strong) UIWebView *playWebView;        //承载图片的webView
@property (nonatomic,strong) UIActivityIndicatorView *loadingIndicatorView; //加载网络图片的风火轮
@property (nonatomic,assign) BOOL hiddenImageView;          //隐藏imageView
@property (nonatomic,assign) BOOL hiddenWebView;            //隐藏webView
@property (nonatomic,assign) NSInteger imageCount;          //图片总数
@property (nonatomic,strong) NSArray *imageNameArray;       //保存图片名称的数组
@property (nonatomic,strong) NSString *imageType;           //图片类型
@property (nonatomic,strong) NSString *imageName;           //图片名称
@property (nonatomic,weak) NSTimer *chageImageTimer;        //切换图片的timer
@property (nonatomic,assign) NSInteger chageImageIndex;     //切换图片的下标
@property (nonatomic,assign) GifCacheType cacheType;        //缓存策略

@property (nonatomic,copy) void (^speedLoopCallBackBlock) (NSInteger index);        //快速循环的回调
@property (nonatomic,copy) void (^speedLoopCompleteBlock) (id obj);                 //快速循环完成回调
@property (nonatomic,copy) void (^tapCallBlock) (ChGifImageView * gifImageView);    //点击视图回调

@property (nonatomic,assign) NSInteger speedIndex;          //快速循环的下标



@end

@implementation ChGifImageView

#pragma mark - 初始化方法

- (instancetype) init {
    self = [super init];
    if (self) {
        NSAssert(NO, @"[ChGifImageView-ERROR]：请勿使用'init'初始化【ChGifImageView】");
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame withTap:(void (^)(ChGifImageView *))tap {
    self = [self initWithFrame:frame];
    self.tapCallBlock = tap;
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame withImageNameArray:(NSArray *)imgNameArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageNameArray = imgNameArray;
        self.imageName = nil;
        self.hiddenImageView = NO;
        self.hiddenWebView = YES;
        [self initView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame withImageNameArray:(NSArray *)imgNameArray withTap:(void (^)(ChGifImageView *))tap {
    self = [self initWithFrame:frame withImageNameArray:imgNameArray];
    self.tapCallBlock = tap;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withImageName:(NSString *)imgName withCacheType:(GifCacheType)cacheType{
    self = [super initWithFrame:frame];
    if (self) {
        self.cacheType = cacheType;
        self.imageNameArray = nil;
        self.imageName = imgName;
        self.hiddenImageView = NO;
        self.hiddenWebView = YES;
        self.imageType = @"gif";
        [self getImgNameArrayFromGifData];
        [self initView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame withImageName:(NSString *)imgName withCacheType:(GifCacheType)cacheType withTap:(void (^)(ChGifImageView *))tap {
    self = [self initWithFrame:frame withImageName:imgName withCacheType:cacheType];
    self.tapCallBlock = tap;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withURL:(NSString *)imgURL {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageNameArray = nil;
        self.imageName = nil;
        self.imageURL = imgURL;
        self.hiddenImageView = YES;
        self.hiddenWebView = NO;
        [self initView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame withURL:(NSString *)imgURL withTap:(void (^)(ChGifImageView *))tap {
    self = [self initWithFrame:frame withURL:imgURL];
    self.tapCallBlock = tap;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

#pragma mark - 绘制图层
- (void) initView {
    //将基础图层设置为透明
    self.backgroundColor = [UIColor clearColor];
    //增加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self addGestureRecognizer:tap];
    //初始化缓存位置
    NSLog(@"path:%@",DocumentPath);
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:ChGifCacheDirPath]) {
        bool suc =  [fileManager createDirectoryAtPath:ChGifCacheDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!suc) {
            NSLog(@"[ChGifImageView-ERROR]：缓存文件夹创建失败,请尝试重新创建");
        }
    } else {
    }
    //设置默认播放速度
    self.speedValue = 0.1;
    //初始化imageView
    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.playImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.playImageView];
    self.playImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *playImgTopCos = [NSLayoutConstraint constraintWithItem:self.playImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self addConstraint:playImgTopCos];
    NSLayoutConstraint *playImgBottomCos = [NSLayoutConstraint constraintWithItem:self.playImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraint:playImgBottomCos];
    NSLayoutConstraint *playImgLeftCos = [NSLayoutConstraint constraintWithItem:self.playImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self addConstraint:playImgLeftCos];
    NSLayoutConstraint *playImgRightCos = [NSLayoutConstraint constraintWithItem:self.playImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self addConstraint:playImgRightCos];
    self.playImageView.hidden= self.hiddenImageView;
    //启动播放
    if (self.imageNameArray.count>0 || self.imageName) {
        [self.chageImageTimer fire];
    }
    
    //初始化webView
    self.playWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.playWebView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.playWebView];
    self.playWebView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *playWebTopCos = [NSLayoutConstraint constraintWithItem:self.playWebView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self addConstraint:playWebTopCos];
    NSLayoutConstraint *playWebBottomCos = [NSLayoutConstraint constraintWithItem:self.playWebView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraint:playWebBottomCos];
    NSLayoutConstraint *playWebLeftCos = [NSLayoutConstraint constraintWithItem:self.playWebView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self addConstraint:playWebLeftCos];
    NSLayoutConstraint *playWebRightCos = [NSLayoutConstraint constraintWithItem:self.playWebView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self addConstraint:playWebRightCos];
    self.playWebView.hidden= self.hiddenWebView;
    self.playWebView.scrollView.showsVerticalScrollIndicator = NO;
    self.playWebView.scrollView.showsHorizontalScrollIndicator = NO;
    self.playWebView.opaque = NO;
    self.playWebView.scalesPageToFit = YES;
    self.playWebView.scrollView.scrollEnabled = NO;
    self.playWebView.delegate = self;
    
    self.loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loadingIndicatorView.hidesWhenStopped = YES;
    self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playWebView addSubview:self.loadingIndicatorView];
    NSLayoutConstraint *loadingCenterXCos = [NSLayoutConstraint constraintWithItem:self.loadingIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playWebView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.playWebView addConstraint:loadingCenterXCos];
    NSLayoutConstraint *loadingCenterYCos = [NSLayoutConstraint constraintWithItem:self.loadingIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playWebView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.playWebView addConstraint:loadingCenterYCos];
    [self.loadingIndicatorView startAnimating];
    //加载URL图片
    if(self.imageURL) {
        NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.imageURL]];
        [self.playWebView loadRequest:req];
    }
    self.playWebView.hidden = self.hiddenWebView;
    
}

#pragma mark - 将GIF文件解析成图片名称的数组
- (void) getImgNameArrayFromGifData {
    //检查缓存环境
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:ChGifCacheDirPath]) {
        BOOL suc =  [fileManager createDirectoryAtPath:ChGifCacheDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!suc) {
            NSLog(@"[ChGifImageView-ERROR]：缓存文件夹创建失败,请尝试重新创建");
        }
    } else {
    }
    //处理图片缓存文件夹
    if (self.cacheType == GifChcheRefresh) {
        //刷新图片缓存
        BOOL deleDir = [fileManager removeItemAtPath:ImageCacheDirPath(self.imageName) error:nil];
        if (deleDir) {
        } else {
        }
        //创建图片缓存文件夹
        BOOL makeDir = [fileManager createDirectoryAtPath:ImageCacheDirPath(self.imageName) withIntermediateDirectories:YES attributes:nil error:nil];
        if (!makeDir) {
            NSLog(@"[ChGifImageView-ERROR]：图片缓存文件夹创建失败,请尝试重新调用【- (void) setImageName : (NSArray *) imageNameArray withRefreshType : (GifCacheType) refreshType】");
            return;
        }
    } else {
        //检查缓存内是否存在图片缓存文件夹
        if (![[NSFileManager defaultManager] fileExistsAtPath:ImageCacheDirPath(self.imageName)]) {
            //如果不存则创建图片缓存文件夹
            BOOL makeDir = [fileManager createDirectoryAtPath:ImageCacheDirPath(self.imageName) withIntermediateDirectories:YES attributes:nil error:nil];
            if (!makeDir) {
                NSLog(@"[ChGifImageView-ERROR]：图片缓存文件夹创建失败,请尝试重新调用【- (void) setImageName : (NSArray *) imageNameArray withRefreshType : (GifCacheType) refreshType】");
                return;
            }
        } else {
            //如果存在，则直接读取缓存内容
            self.imageCount = [fileManager contentsOfDirectoryAtPath:ImageCacheDirPath(self.imageName) error:nil].count;
            return;
        }
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.imageName ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGFloat animationTime = 0.f;
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        NSInteger imageNum = 0;
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            if (img) {
                UIImage *image = [UIImage imageWithCGImage:img];
                [UIImagePNGRepresentation(image) writeToFile:ImagePath(self.imageName, imageNum) atomically:YES];
                ++imageNum;
                CGImageRelease(img);
            }
        }
        self.imageCount = imageNum;
        CFRelease(src);
    }
    return;
}


#pragma mark - 快速循环
- (void)speedLoopWithCount:(NSInteger)count withCallBack:(void (^)(NSInteger))callBack withComplete:(void (^)(id))complete {
    self.imageCount = count;
    self.speedLoopCallBackBlock = callBack;
    self.speedLoopCompleteBlock = complete;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.0000000001 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        __weak typeof(self) weakSelf = self;
        weakSelf.speedLoopCallBackBlock(self.speedIndex);
        ++weakSelf.speedIndex;
        if (weakSelf.speedIndex >= weakSelf.imageCount) {
            weakSelf.speedIndex = 0;
            dispatch_cancel(timer);
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                weakSelf.speedLoopCompleteBlock(nil);
            });
        }
    });
    if (self.speedIndex == 0) {
        dispatch_resume(timer);
    }
}


#pragma mark - 切换图片
- (void) chageImage {
    
    if ([self.imageType isEqualToString:@"gif"]) {
        //处理gif图片
        if([[NSFileManager defaultManager] contentsOfDirectoryAtPath:ImageCacheDirPath(self.imageName) error:nil].count>0) {
            //切换图片
            UIImage *img = [UIImage imageWithContentsOfFile:ImagePath(self.imageName,self.chageImageIndex)];
            if (!img) {
                NSLog(@"[ChGifImageView-ERROR]：从缓存内读取图片失败");
                [self.chageImageTimer invalidate];
                self.chageImageTimer = nil;
                return;
            }
            self.playImageView.image = img;
            ++self.chageImageIndex;
            if (self.chageImageIndex>=self.imageCount) {
                self.chageImageIndex = 0;
            }

        } else {
            //缓存内找不到图片，发出警告
            NSLog(@"[ChGifImageView-ERROR]：图片缓存文件夹创建失败,请尝试重新调用【- (void) setImageName : (NSArray *) imageNameArray withRefreshType : (GifCacheType) refreshType】");
            [self.chageImageTimer invalidate];
            self.chageImageTimer = nil;
            return;
        }
    } else {
        //处理常规图片
        if (self.imageNameArray.count<=0) {
            return;
        }
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:self.imageNameArray[self.chageImageIndex] ofType:self.imageType];
        if (imagePath) {
            UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
            self.playImageView.image = img;
            ++self.chageImageIndex;
            if (self.chageImageIndex>=self.imageNameArray.count) {
                self.chageImageIndex = 0;
            }
        } else {
            NSString *errorStr = [NSString stringWithFormat:@"[ChGifImageView-ERROR]：名为的'%@' 格式为'%@' 的图片不存在，请检查相关的资源文件",self.imageNameArray[self.chageImageIndex],self.imageType];
            NSAssert(NO, errorStr);
        }
    }
    
}

#pragma mark - 设置图片
- (void)setImageNameArray:(NSArray *)imageNameArray withImageType:(NSString *)imageType {
    self.hiddenImageView = NO;
    self.hiddenWebView = YES;
    self.playImageView.hidden = self.hiddenImageView;
    self.playWebView.hidden = self.hiddenWebView;
    
    self.imageType = imageType;
    self.imageNameArray = nil;
    self.imageName = nil;
    self.imageNameArray = imageNameArray;
    
    [self.chageImageTimer invalidate];
    self.chageImageTimer = nil;
    [self.chageImageTimer fire];
}

- (void)setImageName:(NSString *)imageName withRefreshType:(GifCacheType)refreshType {
    self.hiddenImageView = NO;
    self.hiddenWebView = YES;
    self.playImageView.hidden = self.hiddenImageView;
    self.playWebView.hidden = self.hiddenWebView;
    
    self.imageType = @"gif";
    self.cacheType = refreshType;
    self.imageNameArray = nil;
    self.imageName = imageName;
    [self getImgNameArrayFromGifData];
    
    [self.chageImageTimer invalidate];
    self.chageImageTimer = nil;
    [self.chageImageTimer fire];
}

#pragma mark - 清理缓存
+ (void)refCache {
    //删除ChGifImageView的缓存文件夹
    BOOL deleDir = [[NSFileManager defaultManager] removeItemAtPath:ChGifCacheDirPath error:nil];
    if (deleDir) {
        NSLog(@"[ChGifImageView]：缓存清理成功");
    } else {
        NSLog(@"[ChGifImageView-ERROR]：缓存清理失败");
    }
}

+ (void)refCacheWithImageName:(NSString *)gifName {
    //删除图片的缓存文件夹
    BOOL deleDir = [[NSFileManager defaultManager] removeItemAtPath:ImageCacheDirPath(gifName) error:nil];
    if (deleDir) {
        NSLog(@"[ChGifImageView]：【%@】缓存清理成功",gifName);
    } else {
        NSLog(@"[ChGifImageView-ERROR]：【%@】缓存清理失败",gifName);
    }
}

#pragma mark - set方法
- (void)setSpeedValue:(CGFloat)speedValue {
    _speedValue = speedValue;
    [self.chageImageTimer invalidate];
    self.chageImageTimer = nil;
    [self.chageImageTimer fire];
}

- (void)setImageURL:(NSString *)imageURL {
    _imageURL = imageURL;
    
    self.hiddenImageView = YES;
    self.hiddenWebView = NO;
    self.playImageView.hidden = self.hiddenImageView;
    self.playWebView.hidden = self.hiddenWebView;
    
    //加载URL图片
    if(_imageURL) {
        NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_imageURL]];
        [self.playWebView loadRequest:req];
    }
    
}

#pragma mark - get方法
- (NSTimer *)chageImageTimer {
    if (!_chageImageTimer) {
        __weak typeof(self) weakSelf = self;
        _chageImageTimer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.speedValue target:weakSelf selector:@selector(chageImage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_chageImageTimer forMode:UITrackingRunLoopMode];
    }
    
    return _chageImageTimer;
}

#pragma mark - 视图点击事件
- (void) tapImage : (UITapGestureRecognizer *) sender {
    __weak typeof(self) weakSelf = self;
    if (self.tapCallBlock) {
        self.tapCallBlock(weakSelf);
    }
    if ([self.ChGifImageViewDelegate respondsToSelector:@selector(didTapImageView:)]) {
        [self.ChGifImageViewDelegate didTapImageView:self];
    }
}

#pragma mark - webView delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingIndicatorView stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"[ChGifImageView-ERROR]：网络图片加载失败-%@",error.localizedDescription);
}

@end
