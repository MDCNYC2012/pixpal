//
//  UIImage_Hue.h
//  PixelGame
//
//  Created by Nikita Leonov on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Hue)

- (UIImage *)huedImageWithColor:(UIColor *)color;

@end

@implementation UIImage (Hue)

- (UIImage *)huedImageWithColor:(UIColor *)color;
{
	// begin a graphics context of sufficient size
	UIGraphicsBeginImageContext(self.size);
    
	// draw original image into the context
	[self drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
	// set stroking color and draw circle
    [color setFill];
    
    CGRect imageRect = {0,0,self.size.width,self.size.height};    
    CGContextFillRect(ctx, imageRect);
        
    [self drawAtPoint:CGPointZero];
     
	// make image out of bitmap context
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return result;
}

@end
