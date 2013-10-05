//
//  ViewController.m
//  BlueDash
//
//  Created by Steven Spencer on 10/4/13.
//  Copyright (c) 2013 PlayNetwork. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kPlayNetworkInnovationUUID @"882BB0B8-730C-4C2E-8037-C5CD73535DF2"
#define kPlayNetworkInnovationID   @"com.playnetwork.innovation.location"
#define kPlayNetworkInnovationMajor 20
#define kPlayNetworkInnovationMinor 13

@interface ViewController () <CBPeripheralManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSDictionary *peripheralData;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Init Beacon
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kPlayNetworkInnovationUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:kPlayNetworkInnovationMajor
                                                                minor:kPlayNetworkInnovationMinor
                                                           identifier:kPlayNetworkInnovationID];

    // Transmit Beacon
    self.peripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self updateStatus:@"CBPeripheralManagerStatePoweredOn"];
            NSLog(@"Start Advertising");
            [self.peripheralManager startAdvertising:self.peripheralData];
            break;
        case CBPeripheralManagerStatePoweredOff:
            [self updateStatus:@"CBPeripheralManagerStatePoweredOff"];
            NSLog(@"Stop Advertising");
            [self.peripheralManager stopAdvertising];
            break;
        case CBPeripheralManagerStateUnauthorized: [self updateStatus:@"CBPeripheralManagerStateUnauthorized"]; break;
        case CBPeripheralManagerStateUnsupported:  [self updateStatus:@"CBPeripheralManagerStateUnsupported"]; break;
        case CBPeripheralManagerStateResetting:    [self updateStatus:@"CBPeripheralManagerStateResetting"]; break;
        case CBPeripheralManagerStateUnknown:      [self updateStatus:@"CBPeripheralManagerStateUnknown"]; break;
        default: [self updateStatus:@"??"]; break;
    }
}

- (void)updateStatus:(NSString *)status
{
    NSLog(@"Status: %@", status);
    self.statusLabel.text = status;
}
@end
