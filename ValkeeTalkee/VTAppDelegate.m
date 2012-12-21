//
//  VTAppDelegate.m
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/17/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//

#import "VTAppDelegate.h"
#import "VTDefines.h"

#import "VTMasterViewController.h"

#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "PTPusherConnectionMonitor.h"
#import "NSMutableURLRequest+BasicAuth.h"
#import "Reachability.h"

// Add a Constants.h file with the following information:
//
// static NSString* const PUSHER_API_KEY = @"PUSHER-API-KEY";
// static NSString* const PUSHER_APP_ID = @"PUSHER-APP-ID";
// static NSString* const  PUSHER_API_SECRET = @"PUSHER-API-SECRET";

// static NSString* const AUTH_URL = @"http://yourAuthorizationServer.com/";

#import "Constants.h"

// All events will be logged
#define kLOG_ALL_EVENTS NO

// change this to switch between secure/non-secure connections
#define kUSE_ENCRYPTED_CHANNELS NO

@implementation VTAppDelegate

@synthesize window;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize pusher = _pusher;
@synthesize connectionMonitor;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    VTMasterViewController *controller;
    
    [self userLogin];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        controller = (VTMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        controller = (VTMasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    
    connectedClients = [[NSMutableArray alloc] init];
    clientsAwaitingConnection = [[NSMutableArray alloc] init];
    
    self.connectionMonitor = [[PTPusherConnectionMonitor alloc] init];
    
    // create our primary Pusher client instance
    self.pusher = [self createClientWithAutomaticConnection:YES];
    
    // we want the connection to automatically reconnect if it dies
    self.pusher.reconnectAutomatically = YES;
    
    // log all events received, regardless of which channel they come from
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:self.pusher];
    
    controller.pusher = self.pusher;

    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:PTPusherEventReceivedNotification object:self.pusher];
}

- (void)userLogin {
    // Dummy Login process to establish a unique user name
    
    NSString *deviceName = [[[UIDevice currentDevice] name] stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceName = [deviceName stringByReplacingOccurrencesOfString:@"'" withString:@""];
    deviceName = [deviceName stringByReplacingOccurrencesOfString:@"\u2019" withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceName forKey:USER_LOGIN_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ValkeeTalkee" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ValkeeTalkee.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
#ifdef kLOG_ALL_EVENTS
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
    NSLog(@"[pusher] Received event %@", event);
#endif
}

#pragma mark - Client management

- (PTPusher *)lastConnectedClient
{
    return [connectedClients lastObject];
}

- (PTPusher *)createClientWithAutomaticConnection:(BOOL)connectAutomatically
{
    PTPusher *client = [PTPusher pusherWithKey:PUSHER_API_KEY connectAutomatically:NO encrypted:kUSE_ENCRYPTED_CHANNELS];
    client.delegate = self;
    [self.connectionMonitor startMonitoringClient:client];
    [clientsAwaitingConnection addObject:client];
    if (connectAutomatically) {
        [client connect];
    }
    return client;
}
#pragma mark - PTPusherDelegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"[pusher-%@] Pusher client connected", connection.socketID);
    
    [connectedClients addObject:pusher];
    [clientsAwaitingConnection removeObject:pusher];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    NSLog(@"[pusher-%@] Pusher Connection failed, error: %@", pusher.connection.socketID, error);
    [clientsAwaitingConnection removeObject:pusher];
}

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    NSLog(@"[pusher-%@] Reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    NSLog(@"[pusher-%@] Subscribed to channel %@", pusher.connection.socketID, channel);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    NSLog(@"[pusher-%@] Authorization failed for channel %@", pusher.connection.socketID, channel);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authorization Failed" message:[NSString stringWithFormat:@"Client with socket ID %@ could not be authorized to join channel %@", pusher.connection.socketID, channel.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    if (pusher != self.pusher) {
        [pusher disconnect];
    }
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
    NSLog(@"[pusher-%@] Received error event %@", pusher.connection.socketID, errorEvent);
}

/* The sample app uses HTTP basic authentication.
 
 This demonstrates how we can intercept the authorization request to configure it for our app's
 authentication/authorisation needs.
 */

#define CHANNEL_AUTH_USERNAME @"admin"
#define CHANNEL_AUTH_PASSWORD @"letmein"

- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
{
    NSLog(@"[pusher-%@] Authorizing channel access...", pusher.connection.socketID);
    [request setHTTPBasicAuthUsername:CHANNEL_AUTH_USERNAME password:CHANNEL_AUTH_PASSWORD];
}

@end
