#import "TGSInitialsPictureGenerator.h"

@implementation TGSInitialsPictureGenerator

// https://github.com/bachonk/UIImageView-Letters/blob/master/UIImageView%2BLetters/UIImageView%2BLetters.m#L137-L187
+ (UIImage *)generatePictureWithFirstLetter:(unichar)firstLetter secondLetter:(unichar)secondLetter {
    // Initial variables
    static NSInteger imageDimension = 300;
    CGFloat fontSize = imageDimension * .5f;

    // Assemble letters
    NSString *content = [NSString stringWithFormat:@"%C%C", firstLetter, secondLetter];
    UIFont *textFont = [UIFont systemFontOfSize:fontSize weight:UIFontWeightBold];
    if (@available(iOS 13.0, *)) { // round the font to look like Telegram
        textFont = [UIFont fontWithDescriptor:[textFont.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded] size:fontSize];
    }
    NSDictionary *attributes = @{
                   NSFontAttributeName : textFont,
        NSForegroundColorAttributeName : [UIColor whiteColor]
    };

    // Generate background
    NSArray<UIColor *> *colors = @[ // official colors from Telegram (https://github.com/TelegramMessenger/Telegram-iOS/blob/master/submodules/LocationResources/Sources/VenueIconResources.swift#L116)
        [UIColor colorWithRed:.9 green:.42 blue:.84 alpha:1.], // Pink
        [UIColor colorWithRed:.97 green:.58 blue:.25 alpha:1.], // Orange
        [UIColor colorWithRed:.6 green:.53 blue:1. alpha:1.], // Magenta
        [UIColor colorWithRed:.27 green:.7 blue:.96 alpha:1.], // Light Blue
        [UIColor colorWithRed:.43 green:.76 blue:.22 alpha:1.], // Green
        [UIColor colorWithRed:1. green:.36 blue:.35 alpha:1.], // Red
        [UIColor colorWithRed:.97 green:.48 blue:.68 alpha:1.], // Another pink
        [UIColor colorWithRed:.43 green:.51 blue:.7 alpha:1.], // Dark blue
        [UIColor colorWithRed:.96 green:.73 blue:.13 alpha:1.] // Yellow
    ];
    CGSize imageSize = CGSizeMake(imageDimension, imageDimension);
    CGRect imageRect = {CGPointZero, imageSize};
    // 1. Image basis
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 2. Circular shape
    CGPathRef path = CGPathCreateWithEllipseInRect(imageRect, NULL);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
    // 3. Fill color
    CGContextSetFillColorWithColor(context, colors[arc4random_uniform(colors.count)].CGColor);
    CGContextFillRect(context, imageRect);

    // Add letters in it
    CGSize textSize = [content sizeWithAttributes:attributes];
    [content drawInRect:CGRectMake(imageSize.width / 2 - textSize.width / 2,
                                   imageSize.height / 2 - textSize.height / 2,
                                   textSize.width,
                                   textSize.height)
             withAttributes:attributes];
    
    // Extract it
    UIImage *generatedPicture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Return it
    return generatedPicture;
}

@end
