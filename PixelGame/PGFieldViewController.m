//
//  PGFieldViewController.m
//  PixelGame
//
//  Created by Nikita Leonov on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PGFieldViewController.h"
#import "PGFieldView.h"
#import <QuartzCore/QuartzCore.h>

@interface PGFieldViewController ()
- (void)setNeedsDisplayFieldView;
- (void)refreshFieldPixels;

- (void)addCommand:(PGFieldRefreshCommand *)command;
@end

@implementation PGFieldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    networkCommands = [NSMutableArray array];
	gameCoreController = [[PGGameCoreController alloc] init];
    [gameCoreController setDelegate:self];
    
    fieldView.delegate = self;
    [self updateZoomState:NO];

    [self refreshFieldPixels];
    
    [self createColorButtons];
    [self createTypeButtons];
}


- (void)createColorButtons {
    NSMutableArray *newColorButtons = [NSMutableArray array];
    for (int i = 0; i < 19; i++) {
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
        newButton.frame = CGRectMake(18 + i*52, 18, 50, 50);
        [newButton addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        newButton.tag = i;
        [bottomBarZoomed addSubview:newButton];
        [newColorButtons addObject:newButton];
    }
    
    colorButtons = [NSArray arrayWithArray:newColorButtons];

    selectedColorButtonIndex = 5;
    [self colorButtonPressed:[colorButtons objectAtIndex:selectedColorButtonIndex]];
}

- (void)createTypeButtons {
    NSMutableArray *newTypeButtons = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *newImage = [UIImage imageNamed:[NSString stringWithFormat:@"elem_hover_%d.png", i+1]];
        newButton.frame = CGRectMake(600 + i*52, 6, newImage.size.width, newImage.size.height);
        [newButton addTarget:self action:@selector(typeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newButton setBackgroundImage:newImage forState:UIControlStateSelected];
        
        
        newButton.tag = i;
        [topBarZoomed addSubview:newButton];
        [newTypeButtons addObject:newButton];
    }
    
    typeButtons = [NSArray arrayWithArray:newTypeButtons];

    selectedTypeButtonIndex = 0;
    [self typeButtonPressed:[typeButtons objectAtIndex:selectedTypeButtonIndex]];
}

- (void)colorButtonPressed:(UIButton *)target {
    UIButton *b = [colorButtons objectAtIndex:selectedColorButtonIndex];
    [b setBackgroundImage:nil forState:UIControlStateNormal];    
    
    selectedColorButtonIndex = target.tag;
    b = [colorButtons objectAtIndex:selectedColorButtonIndex];
    [b setBackgroundImage:[UIImage imageNamed:@"color_selection.png"] forState:UIControlStateNormal];    
    
    fieldView.selectedColor = selectedColorButtonIndex;
}

- (void)typeButtonPressed:(UIButton *)target {
    UIButton *b = [typeButtons objectAtIndex:selectedTypeButtonIndex];
    b.selected = NO;
    
    selectedTypeButtonIndex = target.tag;
    b = [typeButtons objectAtIndex:selectedTypeButtonIndex];
    b.selected =YES;
    
    fieldView.selectedType = selectedTypeButtonIndex;
}


- (void)updateEnergyBar:(int)energy maxEnergy:(int)maxEnergy {
    energyLabel.text = [NSString stringWithFormat:@"ENERGY: %d of %d", energy, maxEnergy];
    energyBarBackground.frame = (CGRect){energyBarBackground.frame.origin, 
        200.0 * energy / maxEnergy, energyBarBackground.frame.size.height};
}


- (void)refreshFieldPixels
{   
    NSURL *url = [NSURL URLWithString:@"http://bmikle.com/pixel_game/pixels?format=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];    

    PGFieldRefreshCommand *command = [[PGFieldRefreshCommand alloc] initWithRequest:request delegate:self];
    [self addCommand:command];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setNeedsDisplayFieldView 
{
    CGRect displayRect = (CGRect){fieldScrollView.contentOffset, fieldScrollView.frame.size};    
    [fieldView.layer setNeedsDisplayInRect:displayRect];
}

- (void)dataReceived:(NSData *)data forCommand:(PGFieldRefreshCommand *)command
{
    struct Field *field = malloc(sizeof(struct Field));
    field->width = ((const char *)[data bytes])[0];
    field->height =  ((const char *)[data bytes])[1];
    
    int fieldSizeHeight = sizeof(struct Pixel*)*field->height;
    field->pixels = malloc(fieldSizeHeight);
    
    int fieldSizeWidth = sizeof(struct Pixel)*field->height;
    for (int y=0; y<field->height; y++) {
        field->pixels[y] = malloc(fieldSizeWidth);
        for (int x=0; x<field->width; x++) {
            const char pixelByte = (const char)((const char *)[data bytes])[2+x+y*field->height];                        
            field->pixels[y][x].type = (pixelByte&0xE0)>>5;
            field->pixels[y][x].color = pixelByte&0x1F;
        }
    }
    
    [fieldView setField:field];
    [fieldScrollView setContentSize:fieldView.contentSize];
    
    splashScreen.hidden = YES;
    
    [self setNeedsDisplayFieldView];    
    [self refreshFieldPixels]; 
    
    @synchronized(networkCommands) {
        [networkCommands removeObject:command];
    }
}

- (void)updateZoomState:(BOOL)newZoomedState {
    if (newZoomedState) {
        if (!fieldView.zoomed) {
            fieldView.zoomed = YES;
            topBarZoomed.hidden = NO;
            bottomBarZoomed.hidden = NO;
            leftBarZoomed.hidden = NO;
            rightBarZoomed.hidden = NO;
            fieldScrollView.frame = CGRectMake(leftBarZoomed.frame.size.width, topBarZoomed.frame.size.height, 1024-rightBarZoomed.frame.size.width-leftBarZoomed.frame.size.width, 748-topBarZoomed.frame.size.height-bottomBarZoomed.frame.size.height);
        }
    } else {
        if (fieldView.zoomed) {
            fieldView.zoomed = NO;
            topBarZoomed.hidden = YES;
            bottomBarZoomed.hidden = YES;
            leftBarZoomed.hidden = YES;
            rightBarZoomed.hidden = YES;
            fieldScrollView.frame = CGRectMake(0, 0, 1024, 748);
        }
    }
}

- (IBAction)pinchGestureSelector:(UIPinchGestureRecognizer *)recognizer {
//    NSLog(@"%f", rно ecognizer.velocity);
    [self updateZoomState:(recognizer.velocity > 0)];
}

- (void)addCommand:(PGFieldRefreshCommand *)command {
    @synchronized(networkCommands) {
        for (PGFieldRefreshCommand *aCommand in networkCommands) {
            [aCommand setDelegate:nil];
        }
        [networkCommands addObject:command];
    }
}

- (void)updateStats 
{
    [self updateEnergyBar:gameCoreController.energy maxEnergy:gameCoreController.maxEnergy];    
}

#pragma mark PGFieldViewDelegate

- (void)pixel:(struct Pixel)pixel updatedForX:(int)x Y:(int)y
{
    [gameCoreController setEnergy:gameCoreController.energy - 1];
    [self updateStats];
    
    unsigned char rawPixel = (((pixel.type)<<5)&0xE0)|pixel.color;
    NSString *urlString = [NSString stringWithFormat:@"http://bmikle.com/pixel_game/set_pixel?x=%i&y=%i&pixel=%i&format=1",x,y, rawPixel];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    PGFieldRefreshCommand *command = [[PGFieldRefreshCommand alloc] initWithRequest:request delegate:self];
    [self addCommand:command];
}

@end
