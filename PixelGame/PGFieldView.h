//
//  PGFieldView.h
//  PixelGame
//
//  Created by Nikita Leonov on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

static const int kPTypeCount = 8;
static const int kPColorCount = 19;

struct Pixel {
    char color;
    char type;
};

struct Field {
    char width;
    char height;
    struct Pixel **pixels;
};

@protocol PGFieldViewDelegate <NSObject>
- (void)pixel:(struct Pixel)pixel updatedForX:(int)x Y:(int)y;
@end

@interface PGFieldView : UIView
{
    UIImage *pixelStencils[2][kPTypeCount][kPColorCount];
    
    int pixelEdgeLength;
    int borderThickness;    
    
    CGSize contentSize;
    
    int selectedColor;
    int selectedType;
}

@property(nonatomic, assign) id<PGFieldViewDelegate> delegate;

@property(nonatomic, assign) struct Field *field;
@property(nonatomic, assign) BOOL zoomed;

@property(nonatomic, readonly) CGSize contentSize;
@property(nonatomic, assign) CGPoint contentOffset;

@property(nonatomic, assign) int selectedColor;
@property(nonatomic, assign) int selectedType;

@end
