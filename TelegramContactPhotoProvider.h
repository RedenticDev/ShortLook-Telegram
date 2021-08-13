#import "ShortLook-API/ShortLook-API.h"
#import "TGSFolderFinder.h"
#import "TGSInitialsPictureGenerator.h"

@interface TelegramContactPhotoProvider : NSObject <DDNotificationContactPhotoProviding>
- (DDNotificationContactPhotoPromiseOffer *)contactPhotoPromiseOfferForNotification:(DDUserNotification *)notification;
@end
