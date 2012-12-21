//
//  VTPresenceChannelEvents.h
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/20/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherPresenceChannelDelegate.h"
#import "PTPusherDelegate.h"

@class PTPusher;
@class PTPusherPresenceChannel;

@interface VTPresenceChannelEvents : NSObject <PTPusherDelegate, PTPusherPresenceChannelDelegate> {
    
}
@property (nonatomic) PTPusher *pusher;
@property (nonatomic) PTPusherPresenceChannel *currentChannel;

- (id)initWithPusher:(PTPusher *)aPusher;
- (void)subscribeToPresenceChannel:(NSString *)channelName;
@end

