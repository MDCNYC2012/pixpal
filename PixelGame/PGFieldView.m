//
//  PGFieldView.m
//  PixelGame
//
//  Created by Nikita Leonov on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PGFieldView.h"
#import "UIImage_Hue.h"
#import <QuartzCore/QuartzCore.h>


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

const static int kBorderThiknessNotZoomed = 1;
const static int kBorderThiknessZoomed = 2;

const static int kImageEdgeLengthZoomed = 50;
const static int kImageEdgeLengthNotZoomed = 9;

const static int kFieldSize = 101;

@interface PGFieldView()
- (void)generatePixels;
@end

@implementation PGFieldView
@synthesize delegate;
@synthesize field;
@synthesize zoomed;
@synthesize contentOffset;

@synthesize selectedColor, selectedType;

+ (Class)layerClass
{
	return [CATiledLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self generatePixels];
        self.zoomed = NO;
    }
    
    return self;
}

- (void)setZoomed:(BOOL)isZoomed {
    zoomed = isZoomed;
    
    if (zoomed) {
        pixelEdgeLength = kImageEdgeLengthZoomed;
        borderThickness = kBorderThiknessZoomed;
        [(CATiledLayer*)self.layer setTileSize:CGSizeMake((kImageEdgeLengthZoomed+kBorderThiknessZoomed)*5, 
                                                          (kImageEdgeLengthZoomed+kBorderThiknessZoomed)*5)];
    } else {
        pixelEdgeLength = kImageEdgeLengthNotZoomed;
        borderThickness = kBorderThiknessNotZoomed;            
        [(CATiledLayer*)self.layer setTileSize:CGSizeMake((kImageEdgeLengthNotZoomed+kBorderThiknessNotZoomed)*kFieldSize, 
                                                          (kImageEdgeLengthNotZoomed+kBorderThiknessNotZoomed)*kFieldSize)];
    }
    
    contentSize = CGSizeMake(borderThickness+(borderThickness+pixelEdgeLength)*kFieldSize, borderThickness+(borderThickness+pixelEdgeLength)*kFieldSize);
    [self setFrame:(CGRect){0,0,contentSize}];
    [self.layer setNeedsDisplay];
}

- (CGSize)contentSize 
{
    return contentSize;
}

- (void)generatePixels 
{
    NSArray *stencilNames[2] = {[NSArray arrayWithObjects:@"square.png",@"romb.png",@"distorted.png",@"chevron.png",@"triangle.png",@"pill.png",@"circle_ful.png",@"circle.png", nil], [NSArray arrayWithObjects:@"square50.png",@"romb50.png",@"distorted50.png",@"chevron50.png",@"triangle50.png",@"pill50.png",@"circle_ful50.png",@"circle50.png", nil]};

    
    NSArray *stencilColors = [NSArray arrayWithObjects:
                              UIColorFromRGB(0x000000),UIColorFromRGB(0xFFFFFF),UIColorFromRGB(0xC0C0C0),UIColorFromRGB(0x808080),
                              UIColorFromRGB(0x800000),UIColorFromRGB(0xFF0000),UIColorFromRGB(0x008000),UIColorFromRGB(0x00FF00),
                              UIColorFromRGB(0x808000),UIColorFromRGB(0xFFFF00),UIColorFromRGB(0xff6600),UIColorFromRGB(0x000033),
                              UIColorFromRGB(0x000080),UIColorFromRGB(0x0000FF),UIColorFromRGB(0x330033),UIColorFromRGB(0x800080),
                              UIColorFromRGB(0xFF00FF),UIColorFromRGB(0x008080),UIColorFromRGB(0x00FFFF),
                              nil];

    for (int zoomRate = 0; zoomRate < 2; zoomRate++) {
        for (int typeId = 0; typeId < kPTypeCount; typeId++) {
            UIImage *pixelStencil = [UIImage imageNamed:[stencilNames[zoomRate] objectAtIndex:typeId]];        
            for (int colorId = 0; colorId < kPColorCount; colorId++) {
                pixelStencils[zoomRate][typeId][colorId] = [pixelStencil huedImageWithColor:[stencilColors objectAtIndex:colorId]];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    int x = touchPoint.x / (borderThickness+pixelEdgeLength);
    int y = touchPoint.y / (borderThickness+pixelEdgeLength);

    field->pixels[y][x].type = (char)selectedType;
    field->pixels[y][x].color = (char)selectedColor;

    [delegate pixel:field->pixels[y][x] updatedForX:x Y:y];

    CGRect updateRect = CGRectMake(borderThickness+(borderThickness+pixelEdgeLength)*x, borderThickness+(borderThickness+pixelEdgeLength)*y, pixelEdgeLength, pixelEdgeLength);    
    [self.layer setNeedsDisplayInRect:updateRect];  
}

#pragma mark Tiled layer delegate methods

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    if (!field) return;
    
	// Fetch clip box in *view* space; context's CTM is preconfigured for view space->tile space transform
	CGRect box = CGContextGetClipBoundingBox(context);
	
	// Calculate tile index
    //	CGFloat contentsScale = [layer respondsToSelector:@selector(contentsScale)]?[layer contentsScale]:1.0;
    //	CGSize tileSize = [(CATiledLayer*)layer tileSize];
    //	CGFloat x = box.origin.x * contentsScale / tileSize.width;
    //	CGFloat y = box.origin.y * contentsScale / tileSize.height;
	
	// Clear background
	CGContextSetFillColorWithColor(context, [[UIColor darkGrayColor] CGColor]);
	CGContextFillRect(context, box);
    
    int fullCellSize = borderThickness+pixelEdgeLength;
    
    int startX = (int)(box.origin.x / fullCellSize);
    int startY = (int)(box.origin.y / fullCellSize);

    int endX = (int)((box.origin.x+box.size.width-borderThickness-1) / fullCellSize);
    int endY = (int)((box.origin.y+box.size.height-borderThickness-1) / fullCellSize);
        
//    NSLog(@"box %f, %f, %f, %f, count x: %d, count y: %d, start: %d, %d", box.origin.x, box.origin.y, box.size.width, box.size.height, endX-startX+1, endY-startY+1, startX, startY);
        
    UIGraphicsPushContext(context);
    for (int x = startX; x <= endX; x++) {
        for (int y = startY; y <= endY; y++) {
            struct Pixel pixel = field->pixels[y][x];
            CGPoint origPoint = CGPointMake(borderThickness + fullCellSize*x, borderThickness + fullCellSize*y);
            //NSLog(@"Drawing image (%d, %d) at point: %f, %f", x, y, origPoint.x, origPoint.y);
            [pixelStencils[zoomed][pixel.type][pixel.color] drawAtPoint:origPoint];
        }
    }
}

@end