//
//  ViewController.m
//  BlueListen
//
//  Created by Steven Spencer on 10/4/13.
//  Copyright (c) 2013 PlayNetwork. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// http://www.devfright.com/ibeacons-tutorial-ios-7-clbeaconregion-clbeacon/

#define kPlayNetworkInnovationUUID @"882BB0B8-730C-4C2E-8037-C5CD73535DF2"
#define kPlayNetworkInnovationID   @"com.playnetwork.innovation.location"

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *rssiLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // init region
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kPlayNetworkInnovationUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kPlayNetworkInnovationID];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    self.statusLabel.text = @"Listening";
    //[self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Did Start monitoring region");
    self.statusLabel.text = @"Listening";
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    self.nameLabel.text = @"Inside";
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion...");
    self.nameLabel.text = @"Outside";
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];

    if ([region.identifier isEqualToString:kPlayNetworkInnovationID]) {
        self.statusLabel.text = @"...";
        self.nameLabel.text = @"...";
        self.distanceLabel.text = @"...";
        self.versionLabel.text = @"...";
        self.rssiLabel.text = @"...";
        NSLog(@"*** exited region");
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //NSLog(@"didRangeBeacons...");
    if ([beacons count] > 0) {
        // donut shop: Show Receipt

        CLBeacon *nearest = [beacons objectAtIndex:0];

        self.statusLabel.text = @"In Range";
        self.rssiLabel.text = [NSString stringWithFormat:@"%ld", (long)nearest.rssi];

        if (CLProximityImmediate == nearest.proximity) {
            self.distanceLabel.text = @"Close";
            self.versionLabel.text = [NSString stringWithFormat:@"%@:%@", nearest.major, nearest.minor];
        } else if (CLProximityNear == nearest.proximity) {
            self.distanceLabel.text = @"Nearby";
            self.versionLabel.text = [NSString stringWithFormat:@"%@:%@", nearest.major, nearest.minor];
        } else if (CLProximityFar == nearest.proximity) {
            self.distanceLabel.text = @"Far";
            self.versionLabel.text = [NSString stringWithFormat:@"%@:%@", nearest.major, nearest.minor];
        } else {
            self.nameLabel.text = @"---";
            self.distanceLabel.text = @"---";
            self.versionLabel.text = @"---";
        }
    } else {
        self.statusLabel.text = @"No beacons";
        // donut shop: Hide Receipt
    }
}

@end
