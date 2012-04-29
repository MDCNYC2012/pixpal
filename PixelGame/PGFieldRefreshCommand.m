//
//  PGFieldRefreshCommand.m
//  PixelGame
//
//  Created by Nikita Leonov on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PGFieldRefreshCommand.h"

@implementation PGFieldRefreshCommand
@synthesize delegate = _delegate;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<PGFieldRefreshCommandDelegate>)delegate
{
    self = [super init];

    if (self) {
        dataBuffer = [[NSMutableData alloc] init];        

        _delegate = delegate;
        [NSURLConnection connectionWithRequest:request delegate:self];    
    }
    
    return self;
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [dataBuffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{ 
    [_delegate dataReceived:dataBuffer forCommand:self];
}

@end