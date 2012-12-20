//
//  VTMasterViewController.h
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/17/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VTDetailViewController;
@class PTPusher;

#import <CoreData/CoreData.h>

@interface VTMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) VTDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) PTPusher *pusher;

@end
