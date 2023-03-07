//
//  GiftStreamerView.h
//  KKFramework
//
//  Created by zl on 16/7/29.
//  Copyright © 2016年 melot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiftStreamerCell.h"
#import "KKVideoRoomViewProtocol.h"
#import "GiftStreamerPropInfo.h"

@protocol GiftStreamerViewDelegate <KKVideoRoomViewProtocol>

- (void)refreshGiftBubble:(CGFloat)upgradeProgress level:(int)level streamerPropInfo:(GiftStreamerPropInfo *)streamerPropInfo;
- (UIView*)getGiftStreamerViewContainer;

@optional
- (BOOL)isShowLevelAndUpgradeAnimationView;

@end

@interface GiftStreamerView : UIView
- (id)initWithFrame:(CGRect)frame delegate:(id)delegate live:(BOOL)isLive;
- (void)addGiftMessage:(NSDictionary* )giftMsgInfo icon:(NSString *)iconUrl;
- (void)addWinType:(int)winType hitId:(NSString *)hitId;
@end
