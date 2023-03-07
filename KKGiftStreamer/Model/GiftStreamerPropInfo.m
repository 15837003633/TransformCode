//
//  GiftStreamerPropInfo.m
//  KKTV_appStore
//
//  Created by 肖乐乐 on 2022/8/10.
//

#import "GiftStreamerPropInfo.h"

@implementation GiftStreamerPropModel

//+ (NSDictionary<NSString *, NSString *> *)arrayPropertyItemClasses {
//    return @{@"confList" :@"GiftStreamerPropInfo"};
//}

@end

@interface GiftStreamerPropInfo()
{
    NSArray <UIImage *>*_cachedUpgradeImages;
    NSArray <UIImage *>*_cachedLevelImages;
}

@end

@implementation GiftStreamerPropInfo

- (BOOL)isNeedDownloadZipResource {
    BOOL needDownloadPropUpgradeZip = (![KKTVTools isEmptyObject:self.appNumCrump] && self.levelUnZipLocalPath.length == 0);
    BOOL needDownloadPropLevelZip = (![KKTVTools isEmptyObject:self.levelupAnimation] && self.upgradeUnZipLocalPath.length == 0);
    return needDownloadPropUpgradeZip || needDownloadPropLevelZip;
}

- (void)formatFullPath:(NSString *)pathPrefix {
    if (!pathPrefix || pathPrefix.length <= 0) {
        return;
    }
    if (self.background != nil && !([self.background hasPrefix:@"http://"] || [self.background hasPrefix:@"https://"])) {
         self.background = [pathPrefix stringByAppendingString:self.background];
    }
    if (self.comboBtnInBackground && !([self.comboBtnInBackground hasPrefix:@"http://"] || [self.comboBtnInBackground hasPrefix:@"https://"])) {
        self.comboBtnInBackground = [pathPrefix stringByAppendingString:self.comboBtnInBackground];
    }
    if (self.comboGroupNumBackground && !([self.comboGroupNumBackground hasPrefix:@"http://"] || [self.comboGroupNumBackground hasPrefix:@"https://"])) {
        self.comboGroupNumBackground = [pathPrefix stringByAppendingString:self.comboGroupNumBackground];
    }
    if (self.appNumCrump && !([self.appNumCrump hasPrefix:@"http://"] || [self.appNumCrump hasPrefix:@"https://"])) {
        self.appNumCrump = [pathPrefix stringByAppendingString:self.appNumCrump];
    }
    if (self.levelupAnimation && !([self.levelupAnimation hasPrefix:@"http://"] || [self.levelupAnimation hasPrefix:@"https://"])) {
        self.levelupAnimation = [pathPrefix stringByAppendingString:self.levelupAnimation];
    }
}

- (NSArray<UIImage *> *)getUpgradeAnimationImages {
    if (_cachedUpgradeImages.count > 0 ) {
        return _cachedUpgradeImages;
    }
    NSArray *filePaths = [[NSFileManager defaultManager] subpathsAtPath:self.upgradeUnZipLocalPath];
    NSArray *sortedPaths = [filePaths sortedArrayUsingComparator:^NSComparisonResult(NSString *firstPath, NSString *secondPath) {
        int firstIndex = [[firstPath componentsSeparatedByString:@"."].firstObject intValue];
        int secondIndex = [[secondPath componentsSeparatedByString:@"."].firstObject intValue];
        return firstIndex > secondIndex;
    }];
    NSMutableArray *upgradeImages = [NSMutableArray array];
    for (NSString *fileName in sortedPaths) {
        UIImage *image = [UIImage kk_imageWithContentsOfFile:[self.upgradeUnZipLocalPath stringByAppendingPathComponent:fileName]];
        if (image) {
            [upgradeImages addObject:image];
        }
    }
    _cachedUpgradeImages = [upgradeImages copy];
    return _cachedUpgradeImages;
//    NSMutableArray *upgradeImages = [NSMutableArray array];
//    NSString *fileName = nil;
//    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.upgradeUnZipLocalPath];
//    while((fileName = [enumerator nextObject]) != nil) {
//        UIImage *image = [UIImage kk_imageWithContentsOfFile:[self.upgradeUnZipLocalPath stringByAppendingPathComponent:fileName]];
//        if (image) {
//            [upgradeImages addObject:image];
//        }
//    }
//    _cachedUpgradeImages = [upgradeImages copy];
//    return _cachedUpgradeImages;
}

- (NSArray<UIImage *> *)getLevelAnimationImages {
    if (_cachedLevelImages.count > 0 ) {
        return _cachedLevelImages;
    }
    NSArray *filePaths = [[NSFileManager defaultManager] subpathsAtPath:self.levelUnZipLocalPath];
    NSArray *sortedPaths = [filePaths sortedArrayUsingComparator:^NSComparisonResult(NSString *firstPath, NSString *secondPath) {
        int firstIndex = [[firstPath componentsSeparatedByString:@"."].firstObject intValue];
        int secondIndex = [[secondPath componentsSeparatedByString:@"."].firstObject intValue];
        return firstIndex > secondIndex;
    }];
    NSMutableArray *levelImages = [NSMutableArray array];
    for (NSString *fileName in sortedPaths) {
        UIImage *image = [UIImage kk_imageWithContentsOfFile:[self.levelUnZipLocalPath stringByAppendingPathComponent:fileName]];
        if (image) {
            [levelImages addObject:image];
        }
    }
    _cachedLevelImages = [levelImages copy];
    return _cachedLevelImages;
//    NSMutableArray *levelImages = [NSMutableArray array];
//    NSString *fileName = nil;
//    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.levelUnZipLocalPath];
//    while((fileName = [enumerator nextObject]) != nil) {
//        UIImage *image = [UIImage kk_imageWithContentsOfFile:[self.levelUnZipLocalPath stringByAppendingPathComponent:fileName]];
//        if (image) {
//            [levelImages addObject:image];
//        }
//    }
//    _cachedLevelImages = [levelImages copy];
//    return _cachedLevelImages;
}

@end
