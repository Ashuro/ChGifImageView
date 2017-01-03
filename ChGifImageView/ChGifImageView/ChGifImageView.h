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
    /// 默认的会根据【GIF图片的名字】进行缓存。如果需要更新缓存，请主动调用【refCache】的方法。
    GifCacheDefault = 0,
    /// 每次都会刷新图片，如果是有频繁更新需求的话，可以使用此选项
    GifCacheRefresh = 1,
};

/**********初始化方法**********/

/**
 通过frame创建

 @param frame frame
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame;

/**
 通过frame创建，并添加点击回调

 @param frame frame
 @param tap 点击图片回调
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;

/**
 通过图片名称数组创建

 @param frame frame
 @param imgNameArray 图片名称数组
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame
            withImageNameArray:(NSArray*)imgNameArray;

/**
 通过图片名称数组创建，并添加Tap回调

 @param frame frame
 @param imgNameArray 图片名称数组
 @param tap 点击图片回调
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame
            withImageNameArray:(NSArray*)imgNameArray
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;

/**
 通过GIF图片名称创建

 @param frame frame
 @param imgName gif图片名称
 @param cacheType 缓存类型
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame
                 withImageName:(NSString*)imgName
                 withCacheType:(GifCacheType)cacheType;

/**
 通过GIF图片名称创建，并添加Tap回调

 @param frame frame
 @param imgName gif图片名称
 @param cacheType 缓存类型
 @param tap 点击图片回调
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame
                 withImageName:(NSString*)imgName
                 withCacheType:(GifCacheType)cacheType
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;

/**
 通过图片URL创建

 @param frame frame
 @param imgURL 图片完整URL地址
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame
                       withURL:(NSString*)imgURL;

/**
 通过图片URL创建，并添加Tap回调

 @param frame frame
 @param imgURL 图片完整URL地址
 @param tap 点击图片回调
 @return ChGifImageView实例
 */
- (instancetype) initWithFrame:(CGRect)frame
                       withURL:(NSString*)imgURL
                       withTap:(void(^)(ChGifImageView * gifImageView))tap;

/**********可操作属性**********/

/// 播放速度【默认0.1s一张】
@property (nonatomic , assign) CGFloat speedValue;
/// GIF对应的网络地址
@property (nonatomic , strong) NSString * imageURL;
/// 代理
@property (nonatomic , assign) id<ChGifImageViewDelegate> ChGifImageViewDelegate;

/**
 设置播放的图片名称数组

 @param imageNameArray 图片名称数组
 @param imageType 图片类型
 */
- (void) setImageNameArray : (NSArray *) imageNameArray
             withImageType : (NSString *) imageType;

/**
 设置gif图片的名称

 @param imageName Gif图片名称
 @param refreshType 缓存类型
 */
- (void) setImageName : (NSString *) imageName
      withRefreshType : (GifCacheType) refreshType;

/***********辅助方法***********/

/**
 快速循环

 @param count 循环次数
 @param callBack 每次循环回调
 @param complete 结束回调
 */
- (void) speedLoopWithCount : (NSInteger) count
               withCallBack : (void(^)(NSInteger index))callBack
               withComplete : (void(^)(id obj))complete;

/**
 清理全部Gif缓存【注意，如果有播放中的Gif图片，调用次方法，有可能会引起程序Crash，请在图片播放前调用】
 */
+ (void) refCache;

/**
 根据Gif名字清理对应的缓存 【注意，如果有播放中的Gif图片，调用次方法，有可能会引起程序Crash，请在图片播放前调用】

 @param gifName Gif图片名称
 */
+ (void) refCacheWithImageName : (NSString *) gifName;

@end
