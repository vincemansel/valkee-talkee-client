//
//  VTPresenceChannelEvents.m
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/20/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//
//  Derived from:
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "VTPresenceChannelEvents.h"

#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "PTPusherAPI.h"
#import "PTPusherConnection.h"
#import "NSMutableURLRequest+BasicAuth.h"
#import "Constants.h"
#import "VTAppDelegate.h"

@interface VTPresenceChannelEvents ()
- (VTAppDelegate *)clientManager;
@end

@implementation VTPresenceChannelEvents

@synthesize pusher = _pusher;
@synthesize currentChannel;

- (VTAppDelegate *)clientManager
{
    return (VTAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)initWithPusher:(PTPusher *)aPusher
{
    self = [super init];
    if (self) {
        // configure the auth URL for private/presence channels
        _pusher = aPusher;
        self.pusher.authorizationURL = [NSURL URLWithString:[AUTH_URL stringByAppendingString: @"/presence/auth"]];
    }
    return self;
}

- (void)dealloc
{    
    if ([self.currentChannel isSubscribed]) {
        // unsubscribe before we go back to the main menu
        [self.currentChannel unsubscribe];
    }
}


#pragma mark - Subscribing

- (void)subscribeToPresenceChannel:(NSString *)channelName
{
    self.currentChannel = [self.pusher subscribeToPresenceChannelNamed:channelName delegate:self];
}

#pragma mark - Actions

- (void)connectClient
{
    PTPusher *client = [[self clientManager] createClientWithAutomaticConnection:YES];
    client.authorizationURL = self.pusher.authorizationURL;
    [client subscribeToPresenceChannelNamed:@"demo"];
}

- (void)disconnectLastClient
{
    [[[self clientManager] lastConnectedClient] disconnect];
}

#pragma mark - Presence channel events

- (void)presenceChannel:(PTPusherPresenceChannel *)channel didSubscribeWithMemberList:(NSArray *)members
{
    NSLog(@"[pusher] Channel members: %@", members);
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAddedWithID:(NSString *)memberID memberInfo:(NSDictionary *)memberInfo
{
    NSLog(@"[pusher] Member joined channel: %@", memberInfo);
    
    // Here, can put this info into local Database and continue signalling
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemovedWithID:(NSString *)memberID atIndex:(NSInteger)index
{
    NSLog(@"[pusher] Member left channel: %@", memberID);
    

}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
    return self.currentChannel.memberCount;
}


//    NSString *memberID = [self.currentChannel.memberIDs objectAtIndex:indexPath.row];
//    NSDictionary *memberInfo = [self.currentChannel infoForMemberWithID:memberID];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"Member: %@", memberID];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"Name: %@ Email: %@", [memberInfo objectForKey:@"name"], [memberInfo objectForKey:@"email"]];
//
//
@end
