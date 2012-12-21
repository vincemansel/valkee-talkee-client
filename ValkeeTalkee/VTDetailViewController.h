//
//  VTDetailViewController.h
//  ValkeeTalkee
//
//  Created by waveOcean Software on 12/17/12.
//  Copyright (c) 2012 vincemansel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>

@class PTPusher;

@interface VTDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (nonatomic, strong) PTPusher *pusher;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
