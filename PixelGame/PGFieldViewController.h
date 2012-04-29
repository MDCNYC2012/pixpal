//
//  PGFieldViewController.h
//  PixelGame
//
//  Created by Nikita Leonov on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGFieldView.h"
#import "PGFieldRefreshCommand.h"

@class PGGameCoreController;
@interface PGFieldViewController : UIViewController<PGFieldViewDelegate, PGFieldRefreshCommandDelegate>
{
    @private
    PGGameCoreController *gameCoreController;
    NSMutableArray *networkCommands;
    
    IBOutlet PGFieldView *fieldView;
    IBOutlet UIScrollView *fieldScrollView;

    IBOutlet UIView *topBarZoomed;
    IBOutlet UIView *bottomBarZoomed;
    IBOutlet UIView *leftBarZoomed;
    IBOutlet UIView *rightBarZoomed;
    
    NSArray *colorButtons;
    int selectedColorButtonIndex;

    NSArray *typeButtons;
    int selectedTypeButtonIndex;
}


- (IBAction)pinchGestureSelector:(UIPinchGestureRecognizer *)recognizer;
- (void)updateZoomState:(BOOL)newZoomedState;

@end
