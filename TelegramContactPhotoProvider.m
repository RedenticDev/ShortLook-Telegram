#import "FolderFinder.h"
#import "TelegramContactPhotoProvider.h"

@interface NCNotificationRequest
-(NSString *)threadIdentifier;
@end

@implementation TelegramContactPhotoProvider

- (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification {
	NCNotificationRequest *request = [notification request];
	NSString *threadIdentifier = [request threadIdentifier];
	NSString *sharedFolder = [FolderFinder findSharedFolder:@"group.ph.telegra.Telegraph"];
	NSLog(@"[TLGM] Starting Telegram Contact Photo search");

	if ([[threadIdentifier lowercaseString] isEqualToString:@"locked"]) { // Telegram is locked!
		NSLog(@"[TLGM] Error: Telegram app is locked, no info provided");
	} else if ([threadIdentifier hasPrefix:@"-"]) { // group/bot -> unsupported
		/*
		Current state for group/bot profile pictures:
		- Local pictures: I know where they are stored, but I cannot find how to get their path from a threadID
		as the "p:" folder technique used below for high-res is only available for standard conversations.
		- Online download: It would probably be only available for public bots. Also, as far as I can see, the public
		API is not available without the private key of the channel (why??) so I can't fetch bot picture online,
		plus I miss at least one element for each technique I can think of.
		- Database: I found nothing interesting in all local databases existing in Telegram folders.
		*/
		NSLog(@"[TLGM] Error: negative threadId (threadId = %@), group or bot -> unsupported", threadIdentifier);
	} else { // casual convo
		NSString *convoFolder = [NSString stringWithFormat:@"%@/telegram-data/accounts-metadata/spotlight/p:%@", sharedFolder, threadIdentifier];
		NSLog(@"[TLGM] Good path found! Path: %@", convoFolder);
		if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/data.json", convoFolder]]) {
			NSLog(@"[TLGM] Looking for High-res profile picture...");
			NSData *jsonData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/data.json", convoFolder]];
			NSError *error = nil;
			NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
			if (!error) {
				NSString *imagePath = [NSString stringWithFormat:@"%@/%@", sharedFolder, parsedData[@"avatarSourcePath"]];
				UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
				NSLog(@"[TLGM] High-res (%.fx%.f) profile picture found! Path: %@", image.size.width * image.scale, image.size.height * image.scale, imagePath);

				return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:imagePath image:image];
			}
			NSLog(@"[TLGM] An error occurred while fetching High-res profile picture (error: %@)", error);
		}
		if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/avatar.png", convoFolder]]) {
			NSString *imagePath = [NSString stringWithFormat:@"%@/avatar.png", convoFolder];
			UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
			NSLog(@"[TLGM] Low-res (%.fx%.f) avatar only found? (This is a rare bad case). Path: %@", image.size.width * image.scale, image.size.height * image.scale, imagePath);

			return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:imagePath image:image];
		}
		NSLog(@"[TLGM] No avatar for this conversation");
	}

	return nil;
}

@end
