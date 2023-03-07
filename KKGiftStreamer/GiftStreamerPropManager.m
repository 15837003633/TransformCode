//
//  GiftStreamerPropManager.m
//  KKTV_appStore
//
//  Created by 肖乐乐 on 2022/8/10.
//

#import "GiftStreamerPropManager.h"
#import "SSZipArchive.h"

@interface GiftStreamerPropManager()
{
    YYCache *cache;
}

@end

@implementation GiftStreamerPropManager
static GiftStreamerPropManager *instance_ = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[[self class] alloc] init];
    });
    return instance_;
}

- (instancetype)init {
    if (self = [super init]) {
        cache = [[YYCache alloc]initWithName:@"streamerFolderPathMap"];
    }
    return self;
}

- (void)removeAllPathCache {
    [cache removeAllObjects];
}


- (void)downloadStreamerPropResourceLocalPath:(GiftStreamerPropInfo *)streamerPropInfo {
    NSString *levelZipUrl = streamerPropInfo.appNumCrump;
    if (levelZipUrl && levelZipUrl.length > 0) {
        NSString *resultPath = [self getStreamerZipFolderPathByRemoteUrl:levelZipUrl];
        if (resultPath && [[NSFileManager defaultManager] fileExistsAtPath:resultPath]) {
            streamerPropInfo.levelUnZipLocalPath = resultPath;
        } else {
            [KKNetworkManager downloadDataWithURL:levelZipUrl directoryName:KK_Streamer_Prop_DIR fileName:levelZipUrl.lastPathComponent progressBlock:^(CGFloat percent) {
                NSLog(@"download percent=%f",percent);
            } completionHandle:^(NSString * _Nullable zipPath, NSError * _Nullable error) {
                NSString *path = [zipPath stringByDeletingPathExtension];
                BOOL isFolder = NO;
                BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
                if (isExist || isFolder) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    NSLog(@"remove exist directory");
                }
                if ([SSZipArchive unzipFileAtPath:zipPath toDestination:path]) {
                    [cache setObject:[path lastPathComponent] forKey:levelZipUrl];
                    streamerPropInfo.levelUnZipLocalPath = path;
                }
            }];
        }
    }
    
    NSString *upgradeZipUrl = streamerPropInfo.levelupAnimation;
    if (upgradeZipUrl && upgradeZipUrl.length > 0) {
        NSString *resultPath = [self getStreamerZipFolderPathByRemoteUrl:upgradeZipUrl];
        if (resultPath && [[NSFileManager defaultManager] fileExistsAtPath:resultPath]) {
            streamerPropInfo.upgradeUnZipLocalPath = resultPath;
        } else {
            [KKNetworkManager downloadDataWithURL:upgradeZipUrl directoryName:KK_Streamer_Prop_DIR fileName:upgradeZipUrl.lastPathComponent progressBlock:^(CGFloat percent) {
                NSLog(@"download percent=%f",percent);
            } completionHandle:^(NSString * _Nullable zipPath, NSError * _Nullable error) {
                NSString *path = [zipPath stringByDeletingPathExtension];
                BOOL isFolder = NO;
                BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
                if (isExist || isFolder) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    NSLog(@"remove exist directory");
                }
                if ([SSZipArchive unzipFileAtPath:zipPath toDestination:path]) {
                    [cache setObject:[path lastPathComponent] forKey:upgradeZipUrl];
                    streamerPropInfo.upgradeUnZipLocalPath = path;
                }
            }];
        }
    }
}

- (void)downloadAllStreamerPropResourceLocalPath
{
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    opQueue.maxConcurrentOperationCount = 2;
    
    for (GiftStreamerPropInfo *info in [self.streamerPropArray mutableCopy]) {
        NSBlockOperation *levelOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSString *levelZipUrl = info.appNumCrump;
            if (!levelZipUrl || levelZipUrl.length == 0) {
                return;
            }
            NSString *resultPath = [self getStreamerZipFolderPathByRemoteUrl:levelZipUrl];
            if (resultPath && [[NSFileManager defaultManager] fileExistsAtPath:resultPath]) {
                info.levelUnZipLocalPath = resultPath;
            } else {
                NSString *zipPath = [KKNetworkManager sync_downloadDataWithURL:levelZipUrl directoryName:KK_Streamer_Prop_DIR fileName:levelZipUrl.lastPathComponent progressBlock:^(CGFloat percent) {
                    NSLog(@"download percent=%f",percent);
                }];
                NSString *path = [zipPath stringByDeletingPathExtension];
                BOOL isFolder = NO;
                BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
                if (isExist || isFolder) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    NSLog(@"remove exist directory");
                }
                if ([SSZipArchive unzipFileAtPath:zipPath toDestination:path]) {
                    [cache setObject:[path lastPathComponent] forKey:levelZipUrl];
                    info.levelUnZipLocalPath = path;
                }
            }
        }];
        [opQueue addOperation:levelOperation];
        
        NSBlockOperation *upgradeOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSString *upgradeZipUrl = info.levelupAnimation;
            if (!upgradeZipUrl || upgradeZipUrl.length == 0) {
                return;
            }
            NSString *resultPath = [self getStreamerZipFolderPathByRemoteUrl:upgradeZipUrl];
            if (resultPath && [[NSFileManager defaultManager] fileExistsAtPath:resultPath]) {
                info.upgradeUnZipLocalPath = resultPath;
            } else {
                NSString *zipPath = [KKNetworkManager sync_downloadDataWithURL:upgradeZipUrl directoryName:KK_Streamer_Prop_DIR fileName:upgradeZipUrl.lastPathComponent progressBlock:^(CGFloat percent) {
                    NSLog(@"download percent=%f",percent);
                }];
                NSString *path = [zipPath stringByDeletingPathExtension];
                BOOL isFolder = NO;
                BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFolder];
                if (isExist || isFolder) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    NSLog(@"remove exist directory");
                }
                if ([SSZipArchive unzipFileAtPath:zipPath toDestination:path]) {
                    [cache setObject:[path lastPathComponent] forKey:upgradeZipUrl];
                    info.upgradeUnZipLocalPath = path;
                }
            }
        }];
        [opQueue addOperation:upgradeOperation];
    }
}

- (GiftStreamerPropInfo *)getStreamerPropById:(int)giftStreamerId
                                  singleValue:(unsigned long long)singleValue
                                   comboValue:(unsigned long long)comboValue {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(GiftStreamerPropInfo * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return (evaluatedObject.propId == giftStreamerId);
    }];
    NSArray *filterArray = [self.streamerPropArray filteredArrayUsingPredicate:predicate];
    if (filterArray.count == 0) {
        return nil;
    }
    NSPredicate *predicate1 = [NSPredicate predicateWithBlock:^BOOL(GiftStreamerPropInfo * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ((singleValue >= evaluatedObject.singleMin && singleValue < evaluatedObject.singleMax) ||
                (comboValue >= evaluatedObject.comboMin && comboValue < evaluatedObject.comboMax));
    }];
    NSArray *resultArray = [filterArray filteredArrayUsingPredicate:predicate1];
    if (resultArray.count == 0) {
        return nil;
    }
    GiftStreamerPropInfo *info = resultArray.lastObject;
    info.isHighestLevel = [filterArray.lastObject isEqual:info];
    info.isSingleValueMatch = (singleValue >= info.singleMin && singleValue < info.singleMax);
    return info;
}

- (GiftStreamerPropInfo *)getLastLevelStreamerPropById:(int)giftStreamerId
                                           singleValue:(unsigned long long)singleValue
                                            comboValue:(unsigned long long)comboValue
                                          currentLevel:(int)currentLevel {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(GiftStreamerPropInfo * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return (evaluatedObject.propId == giftStreamerId) &&
                ((singleValue >= evaluatedObject.singleMin && singleValue < evaluatedObject.singleMax) ||
                (comboValue >= evaluatedObject.comboMin && comboValue < evaluatedObject.comboMax)) &&
                (evaluatedObject.level < currentLevel);
    }];
    NSArray *filterArray = [self.streamerPropArray filteredArrayUsingPredicate:predicate];
    if (filterArray.count == 0) {
        return nil;
    }
    return filterArray.lastObject;
}

- (NSString *)getStreamerZipFolderPathByRemoteUrl:(NSString *)resourceZipUrl
{
    if (!resourceZipUrl || resourceZipUrl.length == 0) {
        return nil;
    }
    NSString *releativePath = [cache objectForKey:resourceZipUrl];
    if (releativePath == nil) {
        return nil;
    }
    NSString * streamerPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:KK_Streamer_Prop_DIR];
    NSString *folderPath = [streamerPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", releativePath]];
    return folderPath;
}

- (void)requestGiftStreamerPropInfo:(void (^)(void))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        HttpRequestAllPropListParam *request = [[HttpRequestAllPropListParam alloc] init];
        request.propType = 101; // 流光道具类型
        NSString * result = [HttpSyncRequest requestWithPostObject:request];
        if (result != nil)
        {
            NSDictionary *dic = [result JSONValue];
            int tagCode = [[dic objectForKey:@"TagCode"] intValue];
            if (dic != nil && tagCode == 0)
            {
                NSString *pathPrefix = [dic objectForKey:@"pathPrefix"];
                NSArray* propList = [dic objectForKey:@"propList"];
                NSArray <PrivilegePropInfo *>*propInfoList = [PrivilegePropInfo objectArrayWithArray:propList];
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PrivilegePropInfo * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return evaluatedObject.type == StreamerPropType;
                }];
                NSArray *filterArray = [propInfoList filteredArrayUsingPredicate:predicate];
                NSMutableArray *tempStreamerArray = [NSMutableArray arrayWithCapacity:filterArray.count];
                for (PrivilegePropInfo *propInfo in filterArray) {
                    GiftStreamerPropModel *model = [GiftStreamerPropModel objectWithJsonString:propInfo.extendProperties];
                    NSArray *confList = [GiftStreamerPropInfo objectArrayWithArray:[model.confList JSONValue]];
                    for (GiftStreamerPropInfo *info in confList) {
                        [info formatFullPath:pathPrefix];
                        info.propId = propInfo.id;
                        [tempStreamerArray addObject:info];
                    }
                }
                self.streamerPropArray = [tempStreamerArray copy];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}

@end
