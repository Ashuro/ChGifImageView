//
//  ChGifImageView.h
//  ChGifImageView
//
//  Created by Ashuro on 2016/12/26.
//  Copyright © 2016年 Ashuro. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ChGifImageView;

@protocol ChGifImageViewDelegate <NSObject>
- (void) didTapImageView : (ChGifImageView *) gifImageView;
@end

@interface ChGifImageView : UIView

/************枚举************/

typedef NS_ENUM(NSInteger , GifCacheType) {
    GifCacheDefault = 0, //默认的会根据【GIF图片的名字】进行缓存。如果需要更新缓存，请主动调用【refCache】的方法。
    GifChcheRefresh = 1, //每次都会刷新图片，如果是有频繁更新需求的话，可以使用此选项
};





/**********初始化方法**********/

- (instancetype) initWithFrame:(CGRect)frame;               //通过frame创建

- (instancetype) initWithFrame:(CGRect)frame
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;


- (instancetype) initWithFrame:(CGRect)frame
                withImageNameArray:(NSArray*)imgNameArray;  //通过图片创建

- (instancetype) initWithFrame:(CGRect)frame
            withImageNameArray:(NSArray*)imgNameArray
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;


- (instancetype) initWithFrame:(CGRect)frame
                 withImageName:(NSString*)imgName
                 withCacheType:(GifCacheType)cacheType;     //通过GIF图片创建

- (instancetype) initWithFrame:(CGRect)frame
                 withImageName:(NSString*)imgName
                 withCacheType:(GifCacheType)cacheType
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;


- (instancetype) initWithFrame:(CGRect)frame
                       withURL:(NSString*)imgURL;           //通过URL创建

- (instancetype) initWithFrame:(CGRect)frame
                       withURL:(NSString*)imgURL
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;





/**********可操作属性**********/

@property (nonatomic , assign) CGFloat speedValue;                              //播放速度【默认0.1s一张】
@property (nonatomic , strong) NSString * imageURL;                             //GIF对应的网络地址
@property (nonatomic , assign) id<ChGifImageViewDelegate> ChGifImageViewDelegate; //代理

//设置播放的图片名称数组
- (void) setImageNameArray : (NSArray *) imageNameArray
             withImageType : (NSString *) imageType;


//设置gif图片的名称
- (void) setImageName : (NSString *) imageName
      withRefreshType : (GifCacheType) refreshType;


/***********辅助方法***********/

//快速循环
- (void) speedLoopWithCount : (NSInteger) count
               withCallBack : (void(^)(NSInteger index))callBack
               withComplete : (void(^)(id obj))complete;

//清理全部Gif缓存【注意，如果有播放中的Gif图片，调用次方法，有可能会引起程序Crash，请在图片播放前调用】
+ (void) refCache;
//根据Gif名字清理对应的缓存 【注意，如果有播放中的Gif图片，调用次方法，有可能会引起程序Crash，请在图片播放前调用】
+ (void) refCacheWithImageName : (NSString *) gifName;

@end
