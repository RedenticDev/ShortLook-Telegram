#import <Foundation/Foundation.h>

@interface TGSFolderFinder : NSObject
+ (NSString *)findSharedFolder:(NSString *)appName;
+ (NSString *)findFolder:(NSString *)appName folder:(NSString *)dir;
@end
