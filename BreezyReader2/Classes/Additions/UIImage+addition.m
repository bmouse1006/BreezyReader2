//
//  UIImage+clip.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+clip.h"

@implementation UIImage (clip)

-(UIImage*)clippedThumbnailWithSize:(CGSize)size{
    CGSize clipSize = CGSizeMake(size.width*[UIScreen mainScreen].scale, size.height*[UIScreen mainScreen].scale);
    CGSize imageSize = self.size;
    
    CGFloat scale = clipSize.width/imageSize.width;
    if (scale < clipSize.height/imageSize.height){
        scale = clipSize.height/imageSize.height;
    }
    
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    imageRect = CGRectApplyAffineTransform(imageRect, CGAffineTransformMakeScale(scale, scale));
    
    UIGraphicsBeginImageContext(imageRect.size);
    
    [self drawInRect:imageRect];
    
    UIImage* tmpImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGRect clipRect = CGRectMake((imageRect.size.width-clipSize.width)/2, (imageRect.size.height-clipSize.height)/2, clipSize.width, clipSize.height);
    
    CGImageRef cgImage = CGImageCreateWithImageInRect(tmpImage.CGImage, clipRect);
    UIImage* clipedImage = [UIImage imageWithCGImage:cgImage];
    if (cgImage){
        CFRelease(cgImage);
    }
    
    return clipedImage;
}

@end
