//
//  PGGameCore.h
//  PixelGame
//
//  Created by Nikita Leonov on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGGameCoreController: NSObject

@property (nonatomic) NSString *name;
@property (nonatomic, assign) NSInteger level;

@property (nonatomic, assign) NSInteger maxEnergy;
@property (nonatomic, assign) NSInteger energy;
@property (nonatomic) NSDate *energyUpdateDate;
@property (nonatomic, retain) NSTimer *energyTimer;

@property (nonatomic, assign) NSInteger experience;

@end
