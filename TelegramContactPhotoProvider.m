#import "TelegramContactPhotoProvider.h"

@interface NCNotificationRequest
- (NSString *)threadIdentifier;
@end

@implementation TelegramContactPhotoProvider

- (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification {
	NSString *threadIdentifier = [[notification request] threadIdentifier];
	NSString *sharedFolder = [TGSFolderFinder findSharedFolder:@"group.ph.telegra.Telegraph"];
	NSLog(@"Starting Telegram Contact Photo search");

	if ([[threadIdentifier lowercaseString] isEqualToString:@"locked"]) { // Telegram is locked!
		NSLog(@"Error: Telegram app is locked, no info provided");
	} else if ([[threadIdentifier lowercaseString] isEqualToString:@"secret"]) { // Secret conversation
		NSLog(@"Error: Secret conversation, cannot read info");
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
		NSLog(@"Error: negative threadId (threadId = %@), group or bot -> unsupported", threadIdentifier);
	} else { // casual convo
		NSString *firstName;
		NSString *lastName;

		NSString *convoFolder = [NSString stringWithFormat:@"%@/telegram-data/accounts-metadata/spotlight/p:%@", sharedFolder, threadIdentifier];
		NSLog(@"Good path found! Path: %@", convoFolder);

		// HD Profile Picture
		NSString *dataJsonPath = [convoFolder stringByAppendingString:@"/data.json"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:dataJsonPath]) {
			NSLog(@"Looking for High-res profile picture...");
			NSError *error = nil;
			NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataJsonPath] options:kNilOptions error:&error];
			if (!error) {
				if (parsedData[@"avatarSourcePath"]) {
					NSString *imagePath = [NSString stringWithFormat:@"%@/%@", sharedFolder, parsedData[@"avatarSourcePath"]];
					UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
					NSLog(@"High-res (%.fx%.f) profile picture found! Path: %@", image.size.width * image.scale, image.size.height * image.scale, imagePath);

					return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:threadIdentifier image:image];
				} else {
					firstName = parsedData[@"firstName"];
					lastName = parsedData[@"lastName"];
				}
			}
			NSLog(@"An error occurred while fetching High-res profile picture (error: %@)", error);
		}

		// SD Profile Picture
		NSString *avatarPngPath = [convoFolder stringByAppendingString:@"/avatar.png"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:avatarPngPath]) {
			UIImage *image = [UIImage imageWithContentsOfFile:avatarPngPath];
			NSLog(@"Low-res (%.fx%.f) avatar only found? (This is a rare bad case). Path: %@", image.size.width * image.scale, image.size.height * image.scale, avatarPngPath);

			return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:threadIdentifier image:image];
		}

		// Custom initials Profile Picture
		if (firstName && firstName.length > 0) { // last name can be missing
			UIImage *generatedImage = [TGSInitialsPictureGenerator generatePictureWithFirstLetter:[[firstName uppercaseString] characterAtIndex:0]
																					 secondLetter:lastName && lastName.length > 0 ? [[lastName uppercaseString] characterAtIndex:0] : '\0'];
			return [NSClassFromString(@"DDNotificationContactPhotoPromiseOffer") offerInstantlyResolvingPromiseWithPhotoIdentifier:threadIdentifier image:generatedImage];
		}

		NSLog(@"No avatar available for this conversation");
	}

	return nil;
}

@end
