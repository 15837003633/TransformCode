//
//  GiftStreamerView.m
//  KKFramework
//
//  Created by zl on 16/7/29.
//  Copyright © 2016年 melot. All rights reserved.
//

#define GiftCell_Margin 14
#define GiftCell_Height 40

#import "GiftStreamerView.h"
#import "GiftStreamerPropManager.h"
@interface GiftStreamerView()<GiftStreamerCellDelegate>
{
    __weak id<GiftStreamerViewDelegate> _delegate;
    NSMutableArray *_allGiftArray;
    NSMutableArray *_allGiftCellArray;
    BOOL _isLive;
}
@end

@implementation GiftStreamerView
- (id)initWithFrame:(CGRect)frame delegate:(id)delegate live:(BOOL)isLive
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _delegate = delegate;
        _isLive = isLive;
        _allGiftArray = [[NSMutableArray alloc] initWithCapacity:0];
        _allGiftCellArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self initCellView];
    }
    return self;
}

- (void)initCellView
{
    int cellCount = Screen_Height > 480?2:1;
    for (int i = 0; i < cellCount; i++) {
        GiftStreamerCell *giftCell = [[GiftStreamerCell alloc] initWithFrame:CGRectMake(0, self.frame.size.height - GiftCell_Height - (GiftCell_Height + GiftCell_Margin) * i, self.frame.size.width, GiftCell_Height)];
        giftCell.isLive = _isLive;
        if (_delegate && [_delegate respondsToSelector:@selector(isShowLevelAndUpgradeAnimationView)]) {
            giftCell.levelAndUpgradeHiden = ![_delegate isShowLevelAndUpgradeAnimationView];
        }
        [_allGiftCellArray addObject:giftCell];
    }
}

- (int)getGiftPriority:(unsigned long long)price
{
    if ( price < 1000 )
    {
        return 1;
    }
    else if (price <9400)
    {
        return 2;
    }
    else if (price < 26000)
    {
        return 3;
    }
    else if (price < 52000)
    {
        return 4;
    }
    else if (price < 167200)
    {
        return 5;
    }
    else if (price < 334400)
    {
        return 6;
    }
    else if (price < 1500000)
    {
        return 7;
    }
    else if (price < 9999999)
    {
        return 8;
    }
    else
        return 9;
}

- (void)addGiftMessage:(NSDictionary* )giftMsgInfo icon:(NSString *)iconUrl
{
    NSMutableDictionary* newInfo = [[NSMutableDictionary alloc]initWithDictionary:giftMsgInfo];
    [newInfo setObject:iconUrl forKey:@"iconUrl"];
    if (newInfo[@"hitId"] == nil)
    {
        NSString *hitId = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        [newInfo setObject:hitId forKey:@"hitId"];
    }
    if (newInfo[@"hitTimes"] == nil) {
        [newInfo setObject:[NSNumber numberWithInt:1] forKey:@"hitTimes"];
    }
    LoginUserInfoManager *loginMgr = [LoginUserInfoManager sharedInstance];
    int userId = [[giftMsgInfo objectForKey:@"sUserId"] intValue];
    if (userId == loginMgr.meInfo.userId) {
        [newInfo setObject:[NSNumber numberWithInt:10] forKey:@"priority"];
        if (giftMsgInfo[@"productId"] == nil) {
            [self updateGiftBubbleView:giftMsgInfo];
        }
    }
    else
    {
        unsigned long long sendPrice = [[giftMsgInfo objectForKey:@"sendPrice"] unsignedLongLongValue];
        int nPriority = [self getGiftPriority:sendPrice];
        [newInfo setObject:[NSNumber numberWithInt:nPriority] forKey:@"priority"];
    }
    
    for (GiftStreamerCell * cell in _allGiftCellArray)
    {
        if ([cell.hitId isEqualToString: newInfo[@"hitId"]])
        {
            if (!cell.bHiding && cell.priority == [newInfo[@"priority"] intValue]) {
                if (cell.giftArray.count <= 1)
                {
                    [cell turboWithGiftInfo:newInfo];
                }
                else
                {
                    [cell.giftArray addObject:newInfo];
                }
                return;
            }
            else
            {
                [self updateGiftArray:newInfo];
                return;
            }
        }
        else if (cell.hitId != nil && cell.priority < [newInfo[@"priority"] intValue])
        {
            [self updateGiftArray:newInfo];
            for (NSMutableDictionary *gift in cell.giftArray) {
                if (![cell isGiftDisplaying:gift]) {
                    [self updateGiftArray:gift];
                }
            }
            [cell.giftArray removeAllObjects];
            cell.hitId = newInfo[@"hitId"];
            return;
        }
    }

    [self updateGiftArray:newInfo];
    [self updateCellView];
}

- (void)updateGiftArray:(NSMutableDictionary *)newInfo
{
    int index = 0;
    for (NSMutableDictionary *giftInfo in _allGiftArray) {
        if ([giftInfo[@"priority"] intValue] < [newInfo[@"priority"]intValue]) {
            [_allGiftArray insertObject:newInfo atIndex:index];
            return;
        }
        index ++;
    }
    [_allGiftArray addObject:newInfo];
}

- (void)updateCellView
{
    BOOL needHide = YES;
    for (GiftStreamerCell * giftCell in _allGiftCellArray)
    {
        if (giftCell.hitId != nil) {
            needHide = NO;
            break;
        }
    }
    if (needHide) {
        self.hidden = YES;
    }

    if (_allGiftArray.count <= 0)
        return;
        
    self.hidden = NO;

    NSMutableDictionary *firstGiftInfo = [_allGiftArray objectAtIndex:0];
    NSString *hitId = firstGiftInfo[@"hitId"];
    NSMutableArray* freeCells = [[NSMutableArray alloc]init];
    for (GiftStreamerCell * giftCell in _allGiftCellArray) {

        if(giftCell.superview == nil)
        {
            [giftCell.giftArray removeAllObjects];
            for (NSMutableDictionary *gift in _allGiftArray) {
                if (([gift[@"hitId"] isEqualToString:hitId])) {
                    [giftCell.giftArray addObject:gift];
                }
            }
            NSMutableArray * tmpArray = [_allGiftArray mutableCopy];
            for (NSMutableDictionary *gift in _allGiftArray) {
                if (([gift[@"hitId"] isEqualToString:hitId])) {
                    [tmpArray removeObject:gift];
                }
            }
            _allGiftArray = tmpArray;
            [freeCells addObject:giftCell];
            break;
        }
        else if ([giftCell.hitId isEqualToString:hitId])
        {
            return;
        }
    }
   
    if (freeCells.count == 0)
    {
        return;
    }
    
    int maxFreeCellRow = -1;
    GiftStreamerCell* aCell;
    for (GiftStreamerCell* cell in freeCells)
    {
        if (maxFreeCellRow < cell.row)
        {
            maxFreeCellRow = cell.row;
            aCell = cell;
            aCell.delegate = self;
        }
    }
    [self addSubview:aCell];
    aCell.alpha = 1.0f;
    [aCell updateWithGiftInfo:nil];
}

-(BOOL)compareGiftInfo:(NSDictionary*)giftInfo1 with:(NSDictionary*)giftInfo2
{
    if (![giftInfo1[@"hitId"] isEqualToString:giftInfo2[@"hitId"]])
        return NO;
    return YES;
}

- (void)updateGiftBubbleView:(NSDictionary *)giftInfoDic
{
    CGFloat upgradeProgress = 0.0;
    CGFloat level = 1;
    int giftCount = [[giftInfoDic objectForKey:@"giftCount"] intValue];
    int nHittimes = [[giftInfoDic objectForKey:@"hitTimes"] intValue];
    unsigned long long giftPrice = [[giftInfoDic objectForKey:@"sendPrice"] unsignedLongLongValue];
    int giftStreamerId = [[giftInfoDic objectForKey:@"giftStreamerId"] intValue];
    
    unsigned long long singleValue = giftPrice * giftCount;
    unsigned long long totalValue = singleValue * nHittimes;
    GiftStreamerPropInfo *streamerPropInfo = [[GiftStreamerPropManager sharedInstance] getStreamerPropById:giftStreamerId singleValue:singleValue comboValue:totalValue];
    if (singleValue >= 500000) {
        level = 7;
        upgradeProgress = 1.0;
    }
    else if (singleValue >= 100000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL6_PRICE))
    {
        level = 6;
        upgradeProgress = 1.0;
    }
    else if (singleValue >= 52000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL5_PRICE))
    {
        level = 5;
        CGFloat basePrice = nHittimes > 1?LEVEL5_PRICE:0;
        upgradeProgress = (totalValue - basePrice)* 1.0/(LEVEL6_PRICE - basePrice);
    }
    else if (singleValue >= 26000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL4_PRICE))
    {
        level = 4;
        CGFloat basePrice = nHittimes > 1?LEVEL4_PRICE:0;
        upgradeProgress = (totalValue - basePrice)* 1.0/(LEVEL5_PRICE - basePrice);
    }
    else if (singleValue >= 9400 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL3_PRICE))
    {
       level = 3;
       CGFloat basePrice = nHittimes > 1?LEVEL3_PRICE:0;
       upgradeProgress = (totalValue - basePrice)* 1.0/(LEVEL4_PRICE - basePrice);
    }
    else if(singleValue >= 1000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL2_PRICE))
    {
        level = 2;
        CGFloat basePrice = nHittimes > 1?LEVEL2_PRICE:0;
        upgradeProgress = (totalValue - basePrice)* 1.0/(LEVEL3_PRICE - basePrice);
    }
    else
    {
        level = 1;
        upgradeProgress = totalValue* 1.0/LEVEL2_PRICE;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(refreshGiftBubble:level:streamerPropInfo:)])
        [_delegate refreshGiftBubble:upgradeProgress level:level streamerPropInfo:streamerPropInfo];
}

- (void)addWinType:(int)winType hitId:(NSString *)hitId
{
    for (GiftStreamerCell * giftCell in _allGiftCellArray)
    {
        if ([giftCell.hitId isEqualToString:hitId]) {
            [giftCell addWinType:winType];
            return;
        }
    }
}

#pragma mark - GiftStreamerCellDelegate
- (void)cellCompleteShining
{
    [self updateCellView];
}

- (void)showPersonalInfoCard:(UserInfo*)userInfo
{
    if (_delegate && [_delegate respondsToSelector:@selector(showVideoRoomPersonalInfoCard:)])
        [_delegate showVideoRoomPersonalInfoCard:userInfo];
}
@end
