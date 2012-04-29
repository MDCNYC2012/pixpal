//
//  PGGameCore.m
//  PixelGame
//
//  Created by Nikita Leonov on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PGGameCoreController.h"

static NSString * const kGCName = @"kGCName";
static NSString * const kGCLevel = @"kGCLevel";
static NSString * const kGCMaxEnergy = @"kGCMaxEnergy";
static NSString * const kGCEnergy = @"kGCEnergy";
static NSString * const kGCEnergyUpdateDate = @"kGCEnergy";
static NSString * const kGCExperience = @"kGCExperience";

@interface PGGameCoreController()
- (void)updateEnergy;
- (void)loadStatsFromCloud;
- (void)saveStatsToCloud;
- (void)updateStatItems:(NSNotification *)notification;
- (void)refreshStats;
@end 

@implementation PGGameCoreController

@synthesize name;
@synthesize level;
@synthesize energy;
@synthesize maxEnergy;
@synthesize energyUpdateDate;
@synthesize energyTimer;
@synthesize experience;
@synthesize delegate;

- (id)init 
{
    self = [super init];
    if (self) {
        [self refreshStats];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCloudItems:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification 
                                                   object:[NSUbiquitousKeyValueStore defaultStore]];

        energyUpdateDate = [NSDate date];        
        energyTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateEnergy) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)updateEnergy
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:energyUpdateDate];
    if (timeInterval >= 5) {
        int newEnergy = energy + (int)(timeInterval / 10);
        if (newEnergy > maxEnergy) {
            newEnergy = maxEnergy;
        }
        
        [self setEnergy:newEnergy];
    }
}

- (void)setEnergy:(NSInteger)newEnergy
{
    energy = newEnergy;
    energyUpdateDate = [NSDate date];
    
    [delegate updateStats];
}
    
- (void)refreshStats
{    
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
    NSNumber *cloudLevel = [kvStore objectForKey:kGCLevel];
    
    if([cloudLevel intValue] == 0) {
        name = @"Player";
        level = 1;
        energy = 20;
        maxEnergy = 20;
        experience = 0;
    
        [self saveStatsToCloud];
    } else {
        [self loadStatsFromCloud];
    }
}

- (void)loadStatsFromCloud 
{
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];

    name = [kvStore objectForKey:kGCName];
    level = [(NSNumber *)[kvStore objectForKey:kGCLevel] intValue];
    energy = [(NSNumber *)[kvStore objectForKey:kGCEnergy] intValue];
    maxEnergy = [(NSNumber *)[kvStore objectForKey:kGCMaxEnergy] intValue];
    energyUpdateDate = [kvStore objectForKey:kGCEnergyUpdateDate];
    energy = [(NSNumber *)[kvStore objectForKey:kGCEnergy] intValue];
    experience = [(NSNumber *)[kvStore objectForKey:kGCExperience] intValue];    
}

- (void)saveStatsToCloud 
{
    NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];

    [kvStore setObject:name forKey:kGCName];
    [kvStore setObject:[NSNumber numberWithInteger:level] forKey:kGCLevel];
    [kvStore setObject:[NSNumber numberWithInteger:energy] forKey:kGCEnergy];
    [kvStore setObject:[NSNumber numberWithInteger:maxEnergy] forKey:kGCMaxEnergy];
    [kvStore setObject:energyUpdateDate forKey:kGCEnergyUpdateDate];
    [kvStore setObject:[NSNumber numberWithInteger:experience] forKey:kGCExperience];    
}

- (void)updateStatItems:(NSNotification *)notification
{
    // We get more information from the notification, by using:
    //  NSUbiquitousKeyValueStoreChangeReasonKey or NSUbiquitousKeyValueStoreChangedKeysKey constants
    // against the notification's useInfo.
	//
    NSDictionary *userInfo = [notification userInfo];
    // get the reason (initial download, external change or quota violation change)
    
    NSNumber* reasonForChange = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    if (reasonForChange)
    {
        // reason was deduced, go ahead and check for the change
        //
        NSInteger reason = [[userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey] integerValue];
        if (reason == NSUbiquitousKeyValueStoreServerChange ||
            // the value changed from the remote server
            reason == NSUbiquitousKeyValueStoreInitialSyncChange)
            // initial syncs happen the first time the device is synced
        {
            NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
            
            NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];            
            for (NSString *changedKey in changedKeys)
            {
                if ([changedKey isEqualToString:kGCName]) {
                    name = [kvStore objectForKey:kGCName]; 
                }
                if ([changedKey isEqualToString:kGCLevel]) {
                    level = [(NSNumber *)[kvStore objectForKey:kGCLevel] intValue];
                }
                if ([changedKey isEqualToString:kGCEnergy]) {
                    energy = [(NSNumber *)[kvStore objectForKey:kGCEnergy] intValue];
                }
                if ([changedKey isEqualToString:kGCMaxEnergy]) {
                    maxEnergy = [(NSNumber *)[kvStore objectForKey:kGCMaxEnergy] intValue];
                }
                if ([changedKey isEqualToString:kGCEnergyUpdateDate]) {
                    energyUpdateDate = [kvStore objectForKey:kGCEnergyUpdateDate];
                }
                if ([changedKey isEqualToString:kGCExperience]) {
                    experience = [(NSNumber *)[kvStore objectForKey:kGCExperience] intValue];    
                }
            }
        }
    }
}

@end
