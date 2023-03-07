//
//  GiftAwardInfo.h
//  KKFramework
//
//  Created by zl on 16/9/22.
//  Copyright © 2016年 melot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftAwardInfo : NSObject
@property (nonatomic, strong) NSString* hitId;
@property (nonatomic, assign) int giftId;
@property (nonatomic, strong) NSString* giftName;
@property (nonatomic, assign) unsigned long long totalMoney;
@property (nonatomic, strong) NSMutableDictionary *giftAwardDic;
@end
