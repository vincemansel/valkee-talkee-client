//
//  VTAppDelegate.h
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/17/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherDelegate.h"

@class PusherExampleMenuViewController;
@class PTPusher;
@class PTPusherConnectionMonitor;

@interface VTAppDelegate : UIResponder <UIApplicationDelegate, PTPusherDelegate>
{
    NSMutableArray *connectedClients;
    NSMutableArray *clientsAwaitingConnection;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) PTPusher *pusher;
@property (nonatomic, strong) PTPusherConnectionMonitor *connectionMonitor;

- (PTPusher *)lastConnectedClient;
- (PTPusher *)createClientWithAutomaticConnection:(BOOL)connectAutomatically;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
