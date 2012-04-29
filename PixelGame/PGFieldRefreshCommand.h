//
//  PGFieldRefreshCommand.h
//  PixelGame
//
//  Created by Nikita Leonov on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PGFieldRefreshCommand;

@protocol PGFieldRefreshCommandDelegate<NSObject>
- (void)dataReceived:(NSData *)data forCommand:(PGFieldRefreshCommand *)command;
@end

@interface PGFieldRefreshCommand : NSObject<NSURLConnectionDataDelegate> {
    @private
    NSMutableData *dataBuffer;
}

@property (nonatomic, assign) id<PGFieldRefreshCommandDelegate> delegate;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<PGFieldRefreshCommandDelegate>)delegate;

@end
