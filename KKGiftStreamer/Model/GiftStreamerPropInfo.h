//
//  GiftStreamerPropInfo.h
//  KKTV_appStore
//
//  Created by 肖乐乐 on 2022/8/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GiftStreamerPropInfo;
@interface GiftStreamerPropModel: NSObject

//@property (nonatomic, strong) NSArray <GiftStreamerPropInfo *>*confList;
@property (nonatomic, copy) NSString *confList;
@property (nonatomic, copy) NSString *desc;

@end

@interface GiftStreamerPropInfo : NSObject
// 道具id（从上层透传下来）
@property (nonatomic, assign) int propId;
// 流光道具等级
@property (nonatomic, assign) int level;
// 单组价值最低值
@property (nonatomic, assign) long long singleMin;
// 单组价值最高值
@property (nonatomic, assign) long long singleMax;
// 连送价值最低值
@property (nonatomic, assign) long long comboMin;
// 连送价值最高值
@property (nonatomic, assign) long long comboMax;
// 背景图片
@property (nonatomic, copy) NSString *background;
// 连送数字颜色
@property (nonatomic, copy) NSString *comboNumColor;
// 连送数字描边颜色
@property (nonatomic, copy) NSString *comboNumBorderColor;
// 连送按钮边框等级进度颜色
@property (nonatomic, copy) NSString *comboBtnBorderLeveColor;
// 连送按钮内部底图
@property (nonatomic, copy) NSString *comboBtnInBackground;
// 连送按钮内部倒计时颜色
@property (nonatomic, copy) NSString *comboBtnInTimeColor;
// 连送组数底图
@property (nonatomic, copy) NSString *comboGroupNumBackground;
// app端连送数字爆炸效果：zip
@property (nonatomic, copy) NSString *appNumCrump;
// 升级动画，zip
@property (nonatomic, copy) NSString *levelupAnimation;

#pragma mark - custome
// 本地存储的解压缩路径(绝对路径)
@property (nonatomic, copy) NSString *upgradeUnZipLocalPath;
@property (nonatomic, copy) NSString *levelUnZipLocalPath;

@property (nonatomic, assign) BOOL isHighestLevel;
// 是否是单次送礼价值匹配到的这个等级, 最高等级不去计算combo价值
@property (nonatomic, assign) BOOL isSingleValueMatch;

// 数字爆炸序列帧
- (NSArray <UIImage *>*)getLevelAnimationImages;
// 升级序列帧列表
- (NSArray <UIImage *>*)getUpgradeAnimationImages;

- (BOOL)isNeedDownloadZipResource;

- (void)formatFullPath:(NSString *)pathPrefix;

@end

NS_ASSUME_NONNULL_END
