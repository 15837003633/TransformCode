//
//  GiftStreamerCell.m
//  KKFramework
//
//  Created by zl on 16/7/29.
//  Copyright © 2016年 melot. All rights reserved.
//
#define Cell_With 310
#define Cell_Height 40
#define StreamerPropLevel 1000
#import "GiftStreamerCell.h"
#import "KKExternalIconManager.h"
#import "KKTVConstant.h"
#import "KKDynamicImageView.h"
#import "GiftStreamerPropManager.h"
@interface KKTVStrokeLabel : UILabel
@property (nonatomic, strong) UIColor *strokeColor;
@end

@implementation KKTVStrokeLabel

- (void)drawTextInRect:(CGRect)rect
{
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = _strokeColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0.0f, 0.0f);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
}

@end

@interface KKTVTurboView : UIView
@end

@implementation KKTVTurboView

- (void)turboAnimation
{
    self.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.03 animations:^{
        self.transform = CGAffineTransformMakeScale(2.5f, 2.5f);
    } completion:^(BOOL finished) {
        if (finished)
        {
            [UIView animateWithDuration:0.12 animations:^{
                self.transform = CGAffineTransformMakeScale(0.8f,0.8f);
            } completion:^(BOOL finished) {
                if (finished)
                {
                    [UIView animateWithDuration:0.24 animations:^{
                        self.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                    } completion:^(BOOL finished) {
                        if (finished)
                        {
                            [UIView animateWithDuration:0.12 animations:^{
                                self.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
                            } completion:^(BOOL finished) {
                                if (finished)
                                {
                                    [UIView animateWithDuration:0.12 animations:^{
                                        self.transform = CGAffineTransformIdentity;
                                    } completion:^(BOOL finished) {

                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

@end


@interface GiftStreamerCell()
{
    UIImageView *_bgImageView;
    UIImageView *_headImageView;
    UIView *_titleView;
    UIView *_medalView;
    UILabel *_nickNameLabel;
    UILabel *_giftInfoLabel;
    UIImageView *_giftImageView;
    UIImageView *_giftLevelAnimationView;
    UIImageView *_giftUpgradeAnimationView;
    UIImageView *_giftAwardImageView;
    KKDynamicImageView *_headPropImageView;
    UILabel *_winTypeLabel;
    UIView *_turboBgView;
    KKTVTurboView *_turboView;
    UILabel *_giftCountLabel;
    KKTVStrokeLabel *_sendLabel;
    KKTVStrokeLabel *_hitTimesLabel;
    UIImageView *_productBoardImgView; //实物商品icon边框
    NSMutableDictionary* _giftInfo;
    int _numFigures;//数字位数
    NSTimer *_autoTimer;
    NSMutableArray* _levelAnimationImages;
    NSMutableArray* _upgradeAnimationImages;
    int _currentLevel;
    int _lastWinType;
    BOOL _lastWinTypeBg;
}
@end

@implementation GiftStreamerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _giftArray = [[NSMutableArray alloc] init];
        _levelAnimationImages = [[NSMutableArray alloc] init];
        _upgradeAnimationImages = [[NSMutableArray alloc] init];
        _currentLevel = 1;
        _lastWinType = 0;
        _lastWinTypeBg = 0;
        
        _bgImageView = [[UIImageView alloc] init];
        [self addSubview:_bgImageView];
        _bgImageView.image = IMG(@"gift_streamer_bg1");
        [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(Cell_Height);
            make.width.mas_equalTo(Cell_With);
        }];
        
        _headImageView = [[UIImageView alloc] init];
        [_headImageView.layer setMasksToBounds:YES];
        _headImageView.layer.cornerRadius = 40 / 2.0f;
        _headImageView.layer.borderColor = RGBFromHexadecimal(0xfeec27).CGColor;
        _headImageView.layer.borderWidth = 1.f;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_headImageView];
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.centerY.equalTo(self);
            make.height.equalTo(@40.f);
            make.width.equalTo(@40.f);
        }];
        
        _headPropImageView = [[KKDynamicImageView alloc] init];
        [self addSubview:_headPropImageView];
        [_headPropImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_headImageView);
            make.centerY.equalTo(_headImageView).offset(1.5);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(57);
        }];
        [_headPropImageView setHidden:YES];
        
        _titleView = [[UIView alloc] init];
//        _titleView.backgroundColor = [UIColor redColor];
        [self addSubview:_titleView];
        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headImageView.mas_right).offset(4);
            make.height.mas_equalTo(14);
            make.top.mas_equalTo(5);
//            make.width.equalTo(@130);
        }];
        
        _medalView = [[UIView alloc] init];
        [_titleView addSubview:_medalView];
        [_medalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.height.equalTo(_titleView);
            make.width.mas_equalTo(0);
        }];
        
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.textColor = KK_COLOR_WHITE;
        _nickNameLabel.backgroundColor = [UIColor clearColor];
        _nickNameLabel.font = FONTSIZE_BOLD(12) /*FONTSIZE_TINY3*/;
        [_titleView addSubview:_nickNameLabel];
        [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_medalView.mas_right);
            make.top.height.right.equalTo(_titleView);
        }];
        
        _giftInfoLabel = [[UILabel alloc] init];
        _giftInfoLabel.textColor = KK_COLOR_WHITE;
        _giftInfoLabel.backgroundColor = [UIColor clearColor];
        _giftInfoLabel.font = FONTSIZE_TINY;
        [self addSubview:_giftInfoLabel];
        [_giftInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nickNameLabel.mas_bottom).offset(6);
            make.left.equalTo(_headImageView.mas_right).offset(4);
            make.height.equalTo(@12.f);
//            make.width.equalTo(@130);
        }];
        
        _giftImageView = [[UIImageView alloc] init];
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_giftImageView.layer setMasksToBounds:YES];
        [self addSubview:_giftImageView];
        [_giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleView.mas_right).offset(4);
            make.centerY.equalTo(self).offset(5);
            make.height.equalTo(@45.f);
            make.width.equalTo(@45.f);
        }];
        
        _productBoardImgView = [[UIImageView alloc] init];
        _productBoardImgView.image = IMG(@"gift_streamer_pro_board");
        _productBoardImgView.hidden = true;
        [self addSubview:_productBoardImgView];
        [_productBoardImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(_giftImageView);
            make.height.width.mas_equalTo(53);
        }];
        
        _giftCountLabel = [[UILabel alloc] init];
        _giftCountLabel.textColor = KK_COLOR_WHITE;
        _giftCountLabel.shadowColor = RGBFromHexadecimal_Alpha(0x000000, 0.3);
        _giftCountLabel.shadowOffset = CGSizeMake(1, 0);
        _giftCountLabel.backgroundColor = [UIColor clearColor];
        _giftCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:17];
        [self addSubview:_giftCountLabel];
        [_giftCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_giftImageView.mas_right).offset(2);
            make.top.mas_equalTo(2);
            make.height.equalTo(@18.f);
            make.width.lessThanOrEqualTo(@50);
        }];
        
        _sendLabel = [[KKTVStrokeLabel alloc] init];
        _sendLabel.text = LS(@"连送X");
        _sendLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:14];
        [self addSubview:_sendLabel];
        [_sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_giftCountLabel.mas_left);
            make.top.equalTo(_giftCountLabel.mas_bottom).offset(4);
            make.height.equalTo(@15.f);
            make.width.equalTo(@43);
        }];
        
        _turboBgView = [[UIView alloc] init];
        [self addSubview:_turboBgView];
        [_turboBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.left.equalTo(_sendLabel.mas_right).offset(-10);
            make.height.equalTo(@31.f);
            if (Screen_Width == 320) {
                make.right.lessThanOrEqualTo(self);
            }
        }];
        _turboView = [[KKTVTurboView alloc] init];
        [_turboBgView addSubview:_turboView];
        [_turboView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.height.width.equalTo(_turboBgView);
        }];
        
        _hitTimesLabel = [[KKTVStrokeLabel alloc] init];
        _hitTimesLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:30];
        [_turboView addSubview:_hitTimesLabel];
        [_hitTimesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.height.equalTo(@31.f);
        }];
        
        _giftLevelAnimationView = [[UIImageView alloc] init];
        [self addSubview:_giftLevelAnimationView];
        
        _giftUpgradeAnimationView = [[UIImageView alloc] init];
        _giftUpgradeAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_giftUpgradeAnimationView];
        [_giftUpgradeAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.centerY.equalTo(self);
            // 286 * 143
            make.width.mas_equalTo(375);
            make.height.mas_equalTo(140);
        }];
        
        _giftAwardImageView = [[UIImageView alloc] init];
        [self addSubview:_giftAwardImageView];
        _giftAwardImageView.alpha = 0.f;
        
        _winTypeLabel = [[UILabel alloc] init];
        _winTypeLabel.textColor = KK_COLOR_WHITE;
        _winTypeLabel.backgroundColor = [UIColor clearColor];
        _winTypeLabel.font = FONTSIZE_TINY;
        [_giftAwardImageView addSubview:_winTypeLabel];
        [_winTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(25);
            make.centerY.equalTo(_giftAwardImageView).offset(4);
            make.height.equalTo(@14.f);
        }];

    }
    return self;
}

- (void)processExternalInfo:(NSMutableDictionary *)giftInfoDic complete:(void(^)(UIImage* externalNobalImage, ExternalGiftInfo * externalGiftInfo))complete;
{
    int openPlatform = [[giftInfoDic objectForKey:@"openPlatform"] intValue];
    int externalNobalLevel = -1;
    int giftId = [[giftInfoDic objectForKey:@"giftId"] intValue];
    if (giftId < 0 && openPlatform > 0) {
        if ([giftInfoDic objectForKey:@"sExternalNobalLevel"] != nil)
        {
            externalNobalLevel = [[giftInfoDic objectForKey:@"sExternalNobalLevel"] intValue];
        }        
        [KKExternalIconManager requestExternalGiftInfo:openPlatform giftId:giftId completion:^(ExternalGiftInfo * _Nonnull giftInfo) {
            if (externalNobalLevel > 0) {
                [KKTVIconManager getExternalNobalLevelIcon:openPlatform level:externalNobalLevel complete:^(UIImage *image) {
                    complete(image, giftInfo);
                }];
            }
            else {
                 complete(nil, giftInfo);
            }
        }];
       
    }
    else {
        complete(nil, nil);
    }
}

- (void)setCellWithExtendGiftInfo:(NSMutableDictionary *)giftInfoDic externalNobalImage:(UIImage *)externalNobalImage externalGiftInfo:(ExternalGiftInfo *)externalGiftInfo
{
    self.priority = [[giftInfoDic objectForKey:@"priority"] intValue];
    self.hitId = [giftInfoDic objectForKey:@"hitId"];
    NSString *headUrl = [giftInfoDic objectForKey:@"sPortrait"];
    BOOL isMys = [[giftInfoDic objectForKey:@"sIsMys"] boolValue];
    int sXmanType = [[giftInfoDic objectForKey:@"sXmanType"] intValue];
    int gender = [[giftInfoDic objectForKey:@"sGender"] intValue];
    int giftStreamerId = [[giftInfoDic objectForKey:@"giftStreamerId"] intValue];
    int giftCount = [[giftInfoDic objectForKey:@"giftCount"] intValue];
    int hitTimes = [[giftInfoDic objectForKey:@"hitTimes"] intValue];
    GiftInfo *giftInfo = [GiftInfo objectWithDictionary:giftInfoDic];
    
    // 判断有没有道具模型
    unsigned long long singleValue = giftInfo.sendPrice * giftCount;
    unsigned long long comboValue = singleValue * hitTimes;
    GiftStreamerPropInfo *streamerPropInfo = [[GiftStreamerPropManager sharedInstance] getStreamerPropById:giftStreamerId singleValue:singleValue comboValue:comboValue];
    
    if (headUrl.length <= 0 && isMys) {
        _headImageView.image = sXmanType == 0 ? IMG(@"yinshen_head"):IMG(@"yinshen_head_x");
    }
    else
    {
        if (headUrl.length >0 && ![headUrl hasPrefix:@"http"]) {
            headUrl = [KKPathPrefix stringByAppendingString:headUrl];
        }
        UIImage *placeholderImage = [UIImage imageOfHeadIcon:gender];
        
        if (giftInfo.openPlatform == OpenPlatform_EH && giftInfo.giftId < 0) {
            placeholderImage = gender >= 1 ? IMG(@"eh_man") : IMG(@"eh_woman");
        }
        [_headImageView kk_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:placeholderImage];
    }
    
    [_headPropImageView setHidden:YES];
    NSArray * PrivilegePropsArray = [giftInfoDic objectForKey:@"sUserPropList"];
    if (PrivilegePropsArray) {
        NSMutableArray * propsArray = [[NSMutableArray alloc] init];
        for (NSDictionary *obj in PrivilegePropsArray) {
            PrivilegePropInfo *propInfo = [PrivilegePropInfo objectWithDictionary:obj];
            [propInfo formatFullPath:KKPathPrefix];
            [propsArray addObject:propInfo];
        }
        PrivilegePropInfo *decorateProp = nil;
        for (PrivilegePropInfo *info in propsArray) {
            if (info.type == PrivilegePropPendant && info.isLight && !info.isExpired && info.level > decorateProp.level) {
                decorateProp = info;
            }
        }
        if (decorateProp != nil && streamerPropInfo == nil) { // 流光道具不显示动态头像框
            [_headPropImageView setupViewWithImageUrl:decorateProp.appLargeUrl imgType:decorateProp.imgType];
            [_headPropImageView setHidden:NO];
        }
    }
    
    NSArray *medalInfoList = [giftInfoDic objectForKey:@"sUserMedalList"];
    
    for (UIView *subView in _medalView.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat xWidth = 0;
    if (isMys)
    {
        UIImage *img = IMG(@"shenmiren");
        CGFloat w = 14;
        if (sXmanType == 1) {
            img = IMG(@"shenmiren_x");
            w = 17;
        }
        UIImageView *medalImageView = [[UIImageView alloc] init];
        medalImageView.image = img;
        [_medalView addSubview:medalImageView];
        [medalImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(_medalView.mas_centerY);
            make.width.mas_equalTo(w);
            make.height.mas_equalTo(14);
        }];
        xWidth = w+4;
    }
    else if (externalNobalImage != nil)
    {
        UIImageView *medalImageView = [[UIImageView alloc] init];
        medalImageView.image = externalNobalImage;
        [_medalView addSubview:medalImageView];
        CGFloat imageHeight = 14.0;
        CGFloat imageWidth = externalNobalImage.size.width * (14 / externalNobalImage.size.height);
        [medalImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(_medalView.mas_centerY);
            make.width.mas_equalTo(imageWidth);
            make.height.mas_equalTo(imageHeight);
        }];
        
        [_medalView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(imageWidth + 4);
        }];
    }
    else
    {
        UIImageView *lastImgView = nil;
        CGFloat xMargin = 4;
        
        for (id info in medalInfoList)
        {
            if ([info isKindOfClass:[NSDictionary class]])
            {
                RankMedalInfo *medalInfo = [[RankMedalInfo alloc] init];
                [info setJSONObjectValue:medalInfo];
                
                if (medalInfo.medalMedalUrl)
                {
                    NSDictionary *imageDic = [medalInfo.medalMedalUrl JSONValue];
                    medalInfo.smallIcon = [imageDic objectForKey:@"phone_small"];
                    CGFloat iconWidth = 16;
                    CGFloat iconHeight = 0;
                    if (medalInfo.smallIcon && [medalInfo isValid])
                    {
                        UIImageView *medalImageView = [[UIImageView alloc] init];
                        [medalImageView kk_setImageWithURL:[NSURL URLWithString:medalInfo.smallIcon] placeholderImage:nil];
                        [_medalView addSubview:medalImageView];
                        iconHeight = (medalInfo.medalType == 2) ? 14 : 16;
                        if (medalImageView.image) {
                            iconWidth = medalImageView.image.size.width * (iconHeight/medalImageView.image.size.height);
                        }
                        [medalImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            
                            if (lastImgView) {
                                make.left.mas_equalTo(lastImgView.mas_right).offset(xMargin);
                            }
                            else{
                                make.left.mas_equalTo(0);
                            }
                            
                            make.centerY.mas_equalTo(_medalView.mas_centerY);
                            make.width.mas_equalTo(iconWidth);
                            make.height.mas_equalTo(iconHeight);
                        }];
                        
                        lastImgView = medalImageView;
                    }
                    xWidth += iconWidth + xMargin;
                }
            }
        }
    }
    
    [_medalView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(xWidth);
    }];
    
    _nickNameLabel.text = [giftInfoDic objectForKey:@"sNickname"];
    
    NSString *dNickName = [giftInfoDic objectForKey:@"dNickname"];
    int dUserId = [[giftInfoDic objectForKey:@"dUserId"] intValue];
    int roomId = [[giftInfoDic objectForKey:@"roomId"] intValue];
    if (dNickName != nil && dUserId != roomId) {
        if (dNickName.length > 6) {
            dNickName = [[dNickName substringToIndex:5] stringByAppendingString:@"..."];
        }
        _giftInfoLabel.text = [NSString stringWithFormat:LS(@"送给%@%@"),dNickName, giftInfo.giftName];
    }
    else
    {
        _giftInfoLabel.text = [NSString stringWithFormat:LS(@"送出%@"), giftInfo.giftName];
    }
    
    CGFloat titleViewWidth = [_nickNameLabel sizeThatFits:_nickNameLabel.size].width + xWidth;
    CGFloat giftNameWidth = [_giftInfoLabel sizeThatFits:_giftInfoLabel.size].width;
    [_giftImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (titleViewWidth >= giftNameWidth) {
            make.left.equalTo(_titleView.mas_right).offset(4);
        } else {
            make.left.equalTo(_giftInfoLabel.mas_right).offset(4);
        }
    }];
    
    if (giftCount > 1) {
        _giftCountLabel.hidden = NO;
        NSMutableAttributedString * attriGiftCountText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LS(@"X %d") ,giftCount]];
        [attriGiftCountText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:10] range:NSMakeRange(0,1)];
        _giftCountLabel.attributedText = attriGiftCountText;
    }
    else
    {
        _giftCountLabel.hidden = YES;
    }

    if (externalGiftInfo != nil && giftInfo.openPlatform > 0 && giftInfo.giftId < 0) {
        
         [_giftImageView setYy_imageURL:[NSURL URLWithString:externalGiftInfo.giftIcon]];
    }
    else
    {
         [_giftImageView setYy_imageURL:[NSURL URLWithString:giftInfo.iconUrl]];
    }
    [self updateWithHittimes:hitTimes price:giftInfo.sendPrice count:giftCount isProduct: (giftInfoDic[@"productId"]!=nil) streamerPropInfo:streamerPropInfo];
}

- (void)setCellInfoWithGift:(NSMutableDictionary *)giftInfoDic
{
    [self processExternalInfo:giftInfoDic complete:^(UIImage *externalNobalImage, ExternalGiftInfo *externalGiftInfo) {
        [self setCellWithExtendGiftInfo:giftInfoDic externalNobalImage:externalNobalImage externalGiftInfo:externalGiftInfo];
    }];
}

- (void)updateWithGiftInfo:(NSMutableDictionary *)giftInfoDic
{
    if (giftInfoDic == nil) {
        if (self.giftArray.count > 0) {
            giftInfoDic = [self.giftArray objectAtIndex:0];
        }
        else
        {
            return;
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    _giftInfo = giftInfoDic;
    [self setCellInfoWithGift:giftInfoDic];
    self.frame = CGRectMake(-Cell_With, self.frame.origin.y, Cell_With, self.frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(8.0f, self.frame.origin.y, Cell_With, self.frame.size.height);
    } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.1 animations:^{
            self.frame = CGRectMake(-5.0f, self.frame.origin.y, Cell_With, self.frame.size.height);
        } completion:^(BOOL finished) {
            self.frame = CGRectMake(0.0f, self.frame.origin.y, Cell_With, self.frame.size.height);
            [self performAnimation];
            [self refreshGiftStream];
        }];
    }];
}

- (BOOL)isGiftDisplaying:(NSMutableDictionary *)giftMsgInfo
{
    if (_giftInfo == giftMsgInfo) {
        return YES;
    }
    return NO;
}

- (void)performAnimation
{
    [_turboView turboAnimation];
    if (_currentLevel >= 2) {
        [_giftLevelAnimationView startAnimating];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    if (_bHiding == NO)
    {
        [self performSelector:@selector(hide) withObject:nil afterDelay:1.17 inModes:@[NSRunLoopCommonModes]];
    }
}

- (void)hide
{
    _bHiding = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [UIView animateWithDuration:0.45 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self completeShining];
        self.alpha = 1.0f;
        _bHiding = NO;
    }];
}

- (void)completeShining
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self.giftArray removeAllObjects];
    self.hitId = nil;
    self.priority = -1;
    [self removeFromSuperview];
    if (_delegate && [_delegate respondsToSelector:@selector(cellCompleteShining)]) {
        [_delegate cellCompleteShining];
    }
}

- (void)turboWithGiftInfo:(NSMutableDictionary *)giftMsgInfo
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self setCellInfoWithGift:giftMsgInfo];
    [self performAnimation];
}

- (void)refreshGiftStream
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(completeShining) object:nil];

    [self.giftArray removeObject:_giftInfo];
    for (NSMutableDictionary *giftMsgInfo in self.giftArray) {
        if (self.bHiding) {
            [self updateWithGiftInfo:giftMsgInfo];
            break;
        }
        else
        {
            _giftInfo = giftMsgInfo;
            [self turboWithGiftInfo:giftMsgInfo];
            break;
        }
    }
    if (self.giftArray.count <= 0) {
        [_autoTimer invalidate];
        _autoTimer = nil;
    }
    else
    {
        _autoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshGiftStream) userInfo:nil repeats:NO];
    }
}

- (void)removeFromSuperview
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [super removeFromSuperview];
}

- (void)updateWithHittimes:(int)nHittimes price:(unsigned long long)giftPrice count:(int)giftCount isProduct:(BOOL)isProduct streamerPropInfo:(GiftStreamerPropInfo *)streamerPropInfo
{
    if (nHittimes <= 1) {
        _currentLevel = 1;
    }
//    int showCount = nHittimes>9999?9999:nHittimes;
    _hitTimesLabel.text = [NSString stringWithFormat:@" %d",nHittimes];
//    CGRect frame = CGRectMake(22, 0, 140, 33);
    int nFigures = 1;
    if (nHittimes > 999)
    {
        nFigures = 4;
    }
    else if (nHittimes > 99)
    {
        nFigures = 3;
    }
    else if (nHittimes > 9)
    {
        nFigures = 2;
    }
    if (nFigures != _numFigures)
    {
        [_turboBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(30 * nFigures);
        }];
        _numFigures = nFigures;
    }
    int level;
    unsigned long long singleValue = giftPrice * giftCount;
    if (singleValue >= 500000) {
        _bgImageView.image = IMG(@"gift_streamer_bg6");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0xf1478d).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0xff3161);
        _sendLabel.strokeColor = RGBFromHexadecimal(0xffeba7);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0xff3161);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0xffeba7);
        level = 7;
    }
    else if (singleValue >= 100000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL6_PRICE))
    {
        _bgImageView.image = IMG(@"gift_streamer_bg6");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0xf1478d).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0xff3161);
        _sendLabel.strokeColor = RGBFromHexadecimal(0xffeba7);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0xff3161);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0xffeba7);
        level = 6;
    }
    else if (singleValue >= 52000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL5_PRICE))
    {
        _bgImageView.image = IMG(@"gift_streamer_bg5");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0xffa192).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0xfe5d38);
        _sendLabel.strokeColor = RGBFromHexadecimal(0xffddc6);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0xfe5d38);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0xffddc6);
        level = 5;
    }
    else if (singleValue >= 26000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL4_PRICE))
    {
        _bgImageView.image = IMG(@"gift_streamer_bg4");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0xecd698).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0xff8921);
        _sendLabel.strokeColor = RGBFromHexadecimal(0xffe49c);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0xff8921);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0xffe49c);
         level = 4;
    }
    else if (singleValue >= 9400 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL3_PRICE))
    {
        _bgImageView.image = IMG(@"gift_streamer_bg3");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0x51f1ff).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0x23aaff);
        _sendLabel.strokeColor = RGBFromHexadecimal(0xa8fffc);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0x23aaff);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0xa8fffc);
         level = 3;
    }
    else if(singleValue >= 1000 || (nHittimes > 1 && singleValue * nHittimes >= LEVEL2_PRICE))
    {
        _bgImageView.image = IMG(@"gift_streamer_bg2");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0x8dffc4).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0x00e29f);
        _sendLabel.strokeColor = RGBFromHexadecimal(0xd7fff4);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0x00e29f);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0xd7fff4);
         level = 2;
    }
    else
    {
        _bgImageView.image = IMG(@"gift_streamer_bg1");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0xfeec27).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0xffd200);
        _sendLabel.strokeColor = RGBFromHexadecimal(0x564d24);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0xffd200);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0x564d24);
        level = 1;
    }
    
    if (isProduct) {
        _productBoardImgView.hidden = false;
        _bgImageView.image = IMG(@"gift_streamer_product");
        _headImageView.layer.borderColor = RGBFromHexadecimal(0x19fefc).CGColor;
        _sendLabel.textColor = RGBFromHexadecimal(0x9726fd);
        _sendLabel.strokeColor = RGBFromHexadecimal(0xFBAEFF);
        _hitTimesLabel.textColor = RGBFromHexadecimal(0x9726fd);
        _hitTimesLabel.strokeColor = RGBFromHexadecimal(0xFBAEFF);
        [_giftImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(0);
        }];
        [_giftCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_giftImageView.mas_right).offset(6);
        }];
    } else {
        _productBoardImgView.hidden = true;
        [_giftImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(5);
        }];
        [_giftCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_giftImageView.mas_right).offset(2);
        }];
    }
    
    if (streamerPropInfo) {
        [_bgImageView kk_setImageWithURL:[NSURL URLWithString:streamerPropInfo.background]];
        [_bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(375);
            make.height.mas_equalTo(70);
            make.left.equalTo(@1);
        }];
        // 头像需要在背景后面
        [self sendSubviewToBack:_headImageView];
        
        _hitTimesLabel.textColor = [UIColor colorWithHexString:streamerPropInfo.comboNumColor];
        _sendLabel.textColor = [UIColor colorWithHexString:streamerPropInfo.comboNumColor];
        _hitTimesLabel.strokeColor = [UIColor colorWithHexString:streamerPropInfo.comboNumBorderColor];
        _sendLabel.strokeColor = [UIColor colorWithHexString:streamerPropInfo.comboNumBorderColor];
        [_hitTimesLabel setNeedsDisplay];
        [_sendLabel setNeedsDisplay];
        // 首次先下载
        if ([streamerPropInfo isNeedDownloadZipResource]) {
            [[GiftStreamerPropManager sharedInstance] downloadStreamerPropResourceLocalPath:streamerPropInfo];
        }
        if (![streamerPropInfo isNeedDownloadZipResource]) { // 本地已下载完成
            level = streamerPropInfo.level + StreamerPropLevel;
        } else { // 第一次下载直接return
            return;
        }
    } else {
        // 头像需要在背景前面
        [self bringSubviewToFront:_headImageView];
        [self bringSubviewToFront:_headPropImageView];
        
        [_bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(Cell_Height);
            make.width.mas_equalTo(Cell_With);
            make.left.equalTo(@16);
        }];
    }
    
    if (_currentLevel != level) {
        NSLog(@"_currentLevel = %d, level = %d", _currentLevel, level);
        _currentLevel = level;
        [_giftLevelAnimationView stopAnimating];
        [_giftUpgradeAnimationView stopAnimating];
        _giftLevelAnimationView.animationImages = nil;
        _giftUpgradeAnimationView.animationImages = nil;
        [_upgradeAnimationImages removeAllObjects];
        [_levelAnimationImages removeAllObjects];
        if (_currentLevel >= 2 && !_isLive) {
            [self showAnimationWithUpgradeLevel:_currentLevel singleValue:singleValue comboValue:(singleValue * nHittimes) streamerPropInfo:streamerPropInfo];
        }
    }
}

- (void)showAnimationWithUpgradeLevel:(int)level singleValue:(unsigned long long)singleValue comboValue:(unsigned long long)comboValue streamerPropInfo:(GiftStreamerPropInfo *)streamerPropInfo
{
//     CGRect frame = [self convertRect:self.frame toView:GETAPPWINDOW];
    switch (level) {
        case 2:
        {
            for (int i = 0; i <= 9; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftLevel_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                     [_levelAnimationImages addObject:image];
                }
            }
            for (int i = 0; i <= 17; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftUpgrade_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                     [_upgradeAnimationImages addObject:image];
                }
            }
            [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_turboBgView).offset(-5);
                make.centerY.equalTo(_turboBgView);
                make.width.mas_equalTo(112);
                make.height.mas_equalTo(111);
            }];
        }
            break;
        case 3:
        {
            for (int i = 0; i <= 9; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftLevel_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                    [_levelAnimationImages addObject:image];
                }
            }
            for (int i = 0; i <= 17; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftUpgrade_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image)
                {
                  [_upgradeAnimationImages addObject:image];
                }
            }
            [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_turboBgView).offset(-5);
                make.centerY.equalTo(_turboBgView);
                make.width.mas_equalTo(112);
                make.height.mas_equalTo(110);
            }];
        }
            break;
        case 4:
        {
            for (int i = 0; i <= 8; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftLevel_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                      [_levelAnimationImages addObject:image];
                }
            }
            for (int i = 0; i <= 19; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftUpgrade_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                    [_upgradeAnimationImages addObject:image];
                }
            }
            [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_turboBgView).offset(-10);
                make.centerY.equalTo(_turboBgView);
                make.width.mas_equalTo(112);
                make.height.mas_equalTo(110);
            }];
        }
            break;
        case 5:
        {
            for (int i = 0; i <= 11; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftLevel_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image)
                {
                     [_levelAnimationImages addObject:image];
                }
            }
            for (int i = 0; i <= 17; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftUpgrade_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                    [_upgradeAnimationImages addObject:image];
                }
            }
            [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_turboBgView).offset(-10);
                make.centerY.equalTo(_turboBgView);
                make.width.mas_equalTo(275);
                make.height.mas_equalTo(270);
            }];
        }
            break;
        case 6:
        {
            for (int i = 0; i <= 11; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftLevel_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image)
                {
                    [_levelAnimationImages addObject:image];
                }
            }
            for (int i = 0; i <= 17; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftUpgrade_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                    [_upgradeAnimationImages addObject:image];
                }
            }
            [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_turboBgView).offset(-5);
                make.centerY.equalTo(_turboBgView);
                make.width.mas_equalTo(275);
                make.height.mas_equalTo(270);
            }];
        }
            break;
        case 7:
        {
            for (int i = 0; i <= 19; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftLevel_%d_%d", level, i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image)
                {
                    [_levelAnimationImages addObject:image];
                }
            }
            for (int i = 0; i <= 17; i++)
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"giftUpgrade_6_%d", i] ofType:@"png"];
                UIImage *image = [UIImage kk_imageWithContentsOfFile:path];
                if (image) {
                    [_upgradeAnimationImages addObject:image];
                }
            }
            CGRect frame = [self convertRect:self.frame toView:GETAPPWINDOW];
            CGFloat xOffset = (Screen_Width - Cell_With)/2;
            CGFloat yOffset = Screen_Height/2 - frame.origin.y - 40;
            [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(0).offset(xOffset);
                make.centerY.mas_equalTo(0).offset(yOffset);
                make.width.mas_equalTo(Screen_Width);
                make.height.mas_equalTo(Screen_Height);
            }];
        }
            break;
            
        default:
            break;
    }
    
    // 流光道具特效如果没有下载完成需要走默认的逻辑
    if (streamerPropInfo) {
        if (![streamerPropInfo isNeedDownloadZipResource]) {
            if (streamerPropInfo.isHighestLevel && streamerPropInfo.isSingleValueMatch) { // 最高等级且为非combo价值触发
                CGRect frame = [self convertRect:self.frame toView:GETAPPWINDOW];
                CGFloat xOffset = (Screen_Width - Cell_With)/2;
                CGFloat yOffset = Screen_Height/2 - frame.origin.y;
                [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(0).offset(xOffset);
                    make.centerY.mas_equalTo(0).offset(yOffset);
                    make.width.mas_equalTo(Screen_Width);
                    make.height.mas_equalTo(Screen_Height);
                }];
            } else {
                [_giftLevelAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(_turboBgView).offset(-5);
                    make.centerY.equalTo(_turboBgView);
                    make.width.mas_equalTo(275);
                    make.height.mas_equalTo(275);
                }];
            }
            _giftUpgradeAnimationView.animationImages = [streamerPropInfo getUpgradeAnimationImages];
            
            if (streamerPropInfo.isHighestLevel && !streamerPropInfo.isSingleValueMatch) { //获取上一级样式
                GiftStreamerPropInfo *lastInfo = [[GiftStreamerPropManager sharedInstance] getLastLevelStreamerPropById:streamerPropInfo.propId singleValue:singleValue comboValue:comboValue currentLevel:streamerPropInfo.level];
                _giftLevelAnimationView.animationImages = [lastInfo getLevelAnimationImages];
            } else {
                _giftLevelAnimationView.animationImages = [streamerPropInfo getLevelAnimationImages];
            }
            _giftUpgradeAnimationView.animationDuration = _giftUpgradeAnimationView.animationImages.count * 0.05;
            _giftLevelAnimationView.animationDuration = _giftLevelAnimationView.animationImages.count * 0.05;
        }
    } else {
        _giftUpgradeAnimationView.animationImages = _upgradeAnimationImages;
        _giftLevelAnimationView.animationImages = _levelAnimationImages;
        _giftUpgradeAnimationView.animationDuration = 1;
        _giftLevelAnimationView.animationDuration = 0.5;
    }
    
    _giftUpgradeAnimationView.animationRepeatCount = 1;
    [_giftUpgradeAnimationView startAnimating];
    
    _giftLevelAnimationView.animationRepeatCount = 1;
 }

- (void)addWinType:(int)winType
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAwardImageView) object:nil];
    if (winType != 500 && winType != 1000 && winType != 1500) {
        NSMutableString * winText = [NSMutableString stringWithFormat:LS(@"%d倍奖励"), winType];
        NSMutableAttributedString * attriWinTex = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:LS(@"%d倍奖励") ,winType]];
        [attriWinTex addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12] range:[winText rangeOfString:[NSString stringWithFormat:LS(@"%d倍") ,winType]]];
        _winTypeLabel.attributedText = attriWinTex;
        UIEdgeInsets edge = UIEdgeInsetsMake(14, 37.5, 14, 37.5);
        if (winType == _lastWinType) {
            UIImage *image = _lastWinTypeBg == 0?IMG(@"winbg1"):IMG(@"winbg2");
            _giftAwardImageView.image = [image resizableImageWithCapInsets:edge resizingMode: UIImageResizingModeStretch];
            _lastWinTypeBg = !_lastWinTypeBg;
        }
        else
        {
            _giftAwardImageView.image = [IMG(@"winbg2") resizableImageWithCapInsets:edge resizingMode: UIImageResizingModeStretch];
        }
        _lastWinType = winType;
        [_giftAwardImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(22);
            make.centerX.equalTo(_titleView);
            make.width.mas_equalTo(attriWinTex.size.width + 30);
            make.height.mas_equalTo(29.5);
        }];
        [_winTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(attriWinTex.size.width + 4);
        }];
    }
    else
    {
        switch (winType) {
            case 500:
                _giftAwardImageView.image = IMG(@"win500");
                break;
            case 1000:
                _giftAwardImageView.image = IMG(@"win1000");
                break;
            case 1500:
                _giftAwardImageView.image = IMG(@"win1500");
                break;
            default:
                break;
        }
        [_giftAwardImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(_titleView);
            make.width.mas_equalTo(122);
            make.height.mas_equalTo(92);
        }];
        _winTypeLabel.text = nil;
        
    }
    _giftAwardImageView.alpha = 1.f;
    [self performSelector:@selector(hideAwardImageView) withObject:nil afterDelay:2 inModes:@[NSRunLoopCommonModes]];
}

- (void)hideAwardImageView {
    [UIView animateWithDuration:0.15 animations:^{
        _giftAwardImageView.alpha = 0.f;
    } completion:^(BOOL finished) {
    }];
}

#pragma  mark - setter
- (void)setLevelAndUpgradeHiden:(BOOL)levelAndUpgradeHiden {
    _levelAndUpgradeHiden = levelAndUpgradeHiden;
    _giftLevelAnimationView.hidden = levelAndUpgradeHiden;
    _giftUpgradeAnimationView.hidden = levelAndUpgradeHiden;
}

#pragma mark - touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int sUserId = [[_giftInfo objectForKey:@"sUserId"] intValue];
    UserInfo *userinfo = [[UserInfo alloc] init];
    userinfo.userId = sUserId;
    userinfo.nickname = [_giftInfo objectForKey:@"sNickname"];
    userinfo.isMys = [[_giftInfo objectForKey:@"sIsMys"] intValue];
    
    if (_delegate && [_delegate respondsToSelector:@selector(showPersonalInfoCard:)]) {
        [_delegate showPersonalInfoCard:userinfo];
    }

}
@end
