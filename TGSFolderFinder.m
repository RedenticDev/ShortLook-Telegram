// Credit: u/Mordred666
// Source: https://reddit.com/r/jailbreakdevelopers/comments/5wb3tv/application_appgroup_path/

#import "TGSFolderFinder.h"

@implementation TGSFolderFinder

+ (NSString *)findSharedFolder:(NSString *)appName {
	return [self findFolder:appName folder:@"/var/mobile/Containers/Shared/AppGroup/"];
}

+ (NSString *)findFolder:(NSString *)appName folder:(NSString *)dir {
	NSFileManager *manager = [NSFileManager defaultManager];

	NSError *error = nil;
	NSArray *folders = [manager contentsOfDirectoryAtPath:dir error:&error];

	if (!error) {
		for (NSString *folder in folders) {
			NSString *folderPath = [dir stringByAppendingString:folder];
			NSArray *items = [manager contentsOfDirectoryAtPath:folderPath error:&error];

			for (NSString *itemPath in items) {
				if ([itemPath rangeOfString:@".com.apple.mobile_container_manager.metadata.plist"].location != NSNotFound) {
					NSString *fullpath = [NSString stringWithFormat:@"%@/%@", folderPath, itemPath];
					NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:fullpath];

					NSString *mcmmetadata = dict[@"MCMMetadataIdentifier"];
					if (mcmmetadata && [mcmmetadata.lowercaseString isEqualToString:appName.lowercaseString]) {
						return folderPath;
					}
				}
			}
		}
	}
	return nil;
}

@end
