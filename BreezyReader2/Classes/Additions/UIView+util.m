//
//  UIView+ImageRefecltion.m
//  eManual
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIView+util.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (util)

CGImageRef AEViewCreateGradientImage (int pixelsWide,
									  int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
    CGContextRef gradientBitmapContext = NULL;
    CGColorSpaceRef colorSpace;
	CGGradientRef grayScaleGradient;
	CGPoint gradientStartPoint, gradientEndPoint;
	
	// Our gradient is always black-white and the mask
	// must be in the gray colorspace
    colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
    gradientBitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh,
												   8, 0, colorSpace, kCGImageAlphaNone);
	
	if (gradientBitmapContext != NULL) {
		// define the start and end grayscale values (with the alpha, even though
		// our bitmap context doesn't support alpha the gradient requires it)
		CGFloat colors[] = {0.0, 1.0,1.0, 1.0,};
		
		// create the CGGradient and then release the gray color space
		grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
		
		// create the start and end points for the gradient vector (straight down)
		gradientStartPoint = CGPointZero;
		gradientEndPoint = CGPointMake(0,pixelsHigh);
		
		// draw the gradient into the gray bitmap context
		CGContextDrawLinearGradient (gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
		
		// clean up the gradient
		CGGradientRelease(grayScaleGradient);
		
		// convert the context into a CGImageRef and release the
		// context
		theCGImage=CGBitmapContextCreateImage(gradientBitmapContext);
		CGContextRelease(gradientBitmapContext);
		
	}
	
	// clean up the colorspace
	CGColorSpaceRelease(colorSpace);
	
	// return the imageref containing the gradient
    return theCGImage;
}

- (UIImage *)reflectedImageRepresentationWithHeight:(NSUInteger)height
{
	CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create a bitmap graphics context the size of the image
    mainViewContentContext = CGBitmapContextCreate (NULL, self.bounds.size.width,height, 8,0, colorSpace, kCGImageAlphaPremultipliedLast);
	
	// free the rgb colorspace
    CGColorSpaceRelease(colorSpace);	
	
	if (mainViewContentContext==NULL)
		return NULL;
	
	// offset the context. This is necessary because, by default, the  layer created by a view for
	// caching its content is flipped. But when you actually access the layer content and have
	// it rendered it is inverted. Since we're only creating a context the size of our 
	// reflection view (a fraction of the size of the main view) we have to translate the context the
	// delta in size, render it, and then translate back (we could have saved/restored the graphics 
	// state
	
	CGFloat translateVertical=self.bounds.size.height-height;
	CGContextTranslateCTM(mainViewContentContext,0,-translateVertical);
	
	// render the layer into the bitmap context
	[self.layer renderInContext:mainViewContentContext];
	
	// translate the context back
	CGContextTranslateCTM(mainViewContentContext,0,translateVertical);
	
	// Create CGImageRef of the main view bitmap content, and then
	// release that bitmap context
	CGImageRef mainViewContentBitmapContext=CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide
	// gradient
	CGImageRef gradientMaskImage=AEViewCreateGradientImage(1,height);
	
	// Create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGImageRef reflectionImage=CGImageCreateWithMask(mainViewContentBitmapContext,gradientMaskImage);
	CGImageRelease(mainViewContentBitmapContext);
	CGImageRelease(gradientMaskImage);
	
	// convert the finished reflection image to a UIImage 
	UIImage *theImage=[UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can 
	// release the original
	CGImageRelease(reflectionImage);
	
	// return the image
	return theImage;
}

-(UIImage*)snapshot{
    
    BOOL opaque = YES;
    UIColor* color = self.backgroundColor;
    CGFloat alpha;
    [color getWhite:NULL alpha:&alpha];
    if (alpha != 1 || color == [UIColor clearColor]){
        opaque = NO;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
