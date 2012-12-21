//
//  VTDetailViewController.m
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/17/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//

#import "VTDetailViewController.h"
#import "VTPresenceChannelEvents.h"
#import "PTPusher.h"


@interface VTDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) VTPresenceChannelEvents *signallingPresence;

- (void)configureView;
@end

@implementation VTDetailViewController

@synthesize pusher;
@synthesize signallingPresence = _signallingPresence;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        NSString *calledUserName = [self.detailItem valueForKey:@"client"];
        self.detailDescriptionLabel.text
          = [@"Calling " stringByAppendingString:calledUserName ];
        [self setupSignallingPresenceChannel:calledUserName];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupSignallingPresenceChannel:(id)channelName
{
    if (! self.signallingPresence) {
        _signallingPresence = [[VTPresenceChannelEvents alloc] initWithPusher:self.pusher];
    }
    [self.signallingPresence subscribeToPresenceChannel:channelName];
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
