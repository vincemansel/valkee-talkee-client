//
//  VTMasterViewController.h
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/17/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class VTDetailViewController;
@class PTPusher;
@class PTPusherChannel;
@class PTPusherAPI;

@protocol PusherEventsDelegate
- (void)sendEventWithMessage:(NSString *)message;
@end

@interface VTMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, PusherEventsDelegate>

@property (strong, nonatomic) VTDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) PTPusher *pusher;
@property (nonatomic) PTPusherAPI *pusherAPI;
@property (nonatomic) PTPusherChannel *currentChannel;
@property (nonatomic, readonly) NSMutableArray *eventsReceived;


@end
