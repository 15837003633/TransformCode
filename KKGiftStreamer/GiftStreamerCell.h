//
//  GiftStreamerCell.h
//  KKFramework
//
//  Created by zl on 16/7/29.
//  Copyright © 2016年 melot. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LEVEL1_PRICE 0
#define LEVEL2_PRICE 9400
#define LEVEL3_PRICE 26000
#define LEVEL4_PRICE 52000
#define LEVEL5_PRICE 167200
#define LEVEL6_PRICE 334400
@protocol GiftStreamerCellDelegate <NSObject>
- (void)cellCompleteShining;
- (void)showPersonalInfoCard:(UserInfo *)userInfo;
@end

@interface GiftStreamerCell : UIView
@property (nonatomic, assign) BOOL bHiding;
@property (nonatomic, assign) BOOL levelAndUpgradeHiden;
@property (nonatomic, strong) NSString * hitId;
@property (nonatomic, assign) int row;
@property (nonatomic, assign) int priority;
@property (nonatomic, assign) BOOL isLive;

// 流光道具
@property (nonatomic, strong, nullable) NSObject *streamerPropInfo;

@property (nonatomic, weak) id<GiftStreamerCellDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *giftArray;
- (void)updateWithGiftInfo:(NSMutableDictionary *)giftInfo;
- (void)turboWithGiftInfo:(NSMutableDictionary *)giftMsgInfo;
- (BOOL)isGiftDisplaying:(NSMutableDictionary *)giftInfo;
- (void)addWinType:(int)winType;
@end
