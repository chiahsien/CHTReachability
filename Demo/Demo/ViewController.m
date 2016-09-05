//
//  ViewController.m
//  Demo
//
//  Created by Nelson on 2016/9/5.
//  Copyright © 2016年 nelson. All rights reserved.
//

#import "ViewController.h"
#import "CHTReachability.h"

@interface ViewController () <CHTReachabilityDelegate>
@property (nonatomic, strong) CHTReachability *reach;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.reach = [[CHTReachability alloc] initWithHostName:CHTReachabilityDefaultPingHostName delegate:self];
  self.reach.pingInterval = 5;
}

#pragma mark - <CHTReachabilityDelegate>

- (void)reachability:(CHTReachability *)reachability didChangeToStatus:(CHTReachabilityStatus)status {
  NSString *statusText;
  switch (status) {
    case CHTReachabilityStatusUnknown: {
      statusText = @"Unknown";
      break;
    }

    case CHTReachabilityStatusNotReachable: {
      statusText = @"Not Reachable";
      break;
    }

    case CHTReachabilityStatusReachable: {
      statusText = @"Reachable";
      break;
    }

    case CHTReachabilityStatusOnline: {
      statusText = @"Online";
      break;
    }
  }
  NSLog(@"Status change to %@", statusText);
}

- (void)reachability:(CHTReachability *)reachability didFailWithError:(NSError *)error {
  NSLog(@"Reachability Error: %@", error);
}

@end
