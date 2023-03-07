//
//  GiftStreamerPropManager.h
//  KKTV_appStore
//
//  Created by 肖乐乐 on 2022/8/10.
//

#import <Foundation/Foundation.h>
#import "GiftStreamerPropInfo.h"

#define KK_Streamer_Prop_DIR @"KK_Streamer_Prop_DIR"
#define StreamerPropType 101

NS_ASSUME_NONNULL_BEGIN

@interface GiftStreamerPropManager : NSObject

+ (instancetype)sharedInstance;
- (void)removeAllPathCache;

- (void)requestGiftStreamerPropInfo:(void (^)(void))completion;
- (void)downloadAllStreamerPropResourceLocalPath;
- (void)downloadStreamerPropResourceLocalPath:(GiftStreamerPropInfo *)streamerPropInfo;

@property (nonatomic, strong) NSArray *streamerPropArray;

- (GiftStreamerPropInfo *)getStreamerPropById:(int)giftStreamerId
                                  singleValue:(unsigned long long)singleValue
                                   comboValue:(unsigned long long)comboValue;

- (GiftStreamerPropInfo *)getLastLevelStreamerPropById:(int)giftStreamerId
                                           singleValue:(unsigned long long)singleValue
                                            comboValue:(unsigned long long)comboValue
                                          currentLevel:(int)currentLevel;

@end

NS_ASSUME_NONNULL_END
