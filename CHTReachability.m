//
//  CHTReachability.m
//  RealReachability
//
//  Created by Nelson on 2016/8/22.
//  Copyright © 2016年 iCHEF. All rights reserved.
//

#import "CHTReachability.h"
#import "Reachability.h"
#import "SimplePing.h"

NSString *const CHTReachabilityDefaultPingHostName = @"www.google.com";
NSTimeInterval const CHTReachabilityDefaultPingInterval = 90;
NSTimeInterval const CHTReachabilityMinimumPingInterval = 5;
NSTimeInterval const CHTReachabilityMaximumPingInterval = 3600;

@interface CHTReachability () <SimplePingDelegate>
@property (nonatomic, weak, nullable, readwrite) id <CHTReachabilityDelegate> delegate;
@property (nonatomic, assign, readwrite) CHTReachabilityStatus currentStatus;
@property (nonatomic, strong) Reachability *reacher;
@property (nonatomic, strong) SimplePing *pinger;
@property (nonatomic, copy) NSString *pingHostName;
@property (nonatomic, weak) NSTimer *pingTimer;
@property (nonatomic, weak) NSTimer *timeoutTimer;
@end

@implementation CHTReachability

#pragma mark - Properties

- (void)setCurrentStatus:(CHTReachabilityStatus)newStatus {
    if (_currentStatus == newStatus) {
        return;
    }

    _currentStatus = newStatus;
    if ([self.delegate respondsToSelector:@selector(reachability:didChangeToStatus:)]) {
        [self.delegate reachability:self didChangeToStatus:newStatus];
    }

    if (newStatus == CHTReachabilityStatusNotReachable) {
        [self.pingTimer invalidate];
        [self.timeoutTimer invalidate];
    } else if (newStatus == CHTReachabilityStatusReachable) {
        if (self.pinger) {
            [self createPingTimer];
        } else {
            self.pinger = [[SimplePing alloc] initWithHostName:self.pingHostName];
            self.pinger.delegate = self;
            [self.pinger start];
        }
    }
}

- (void)setPingInterval:(NSTimeInterval)newInterval {
    if (_pingInterval == newInterval) {
        return;
    }

    // Make sure MIN <= newInterval <= MAX
    // If newInterval > MAX, use MAX
    // If newInterval < MIN, use MIN
    _pingInterval = MAX(MIN(newInterval, CHTReachabilityMaximumPingInterval), CHTReachabilityMinimumPingInterval);
}

#pragma mark - Public methods

- (void)dealloc {
    [_pingTimer invalidate];
    [_timeoutTimer invalidate];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_reacher stopNotifier];
    _reacher = nil;

    [_pinger stop];
    _pinger = nil;
}

- (instancetype)initWithHostName:(NSString *)hostName delegate:(nullable id<CHTReachabilityDelegate>)delegate {
    NSParameterAssert(hostName.length > 0);

    self = [super init];
    if (!self) {
        return nil;
    }

    self.delegate = delegate;
    self.pingInterval = CHTReachabilityDefaultPingInterval;
    self.pingHostName = hostName;

    self.reacher = [Reachability reachabilityForInternetConnection];
    if ([self.reacher currentReachabilityStatus] == NotReachable) {
        self.currentStatus = CHTReachabilityStatusNotReachable;
    } else {
        self.currentStatus = CHTReachabilityStatusReachable;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChanged:) name:kReachabilityChangedNotification object:nil];
    [self.reacher startNotifier];

    return self;
}

#pragma mark - Private methods

- (void)reachabilityDidChanged:(NSNotification *)note {
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    if (curReach.currentReachabilityStatus == NotReachable) {
        self.currentStatus = CHTReachabilityStatusNotReachable;
    } else {
        if (self.currentStatus == CHTReachabilityStatusNotReachable) {
            self.currentStatus = CHTReachabilityStatusReachable;
        }
    }
}

- (void)createPingTimer {
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:self.pingInterval target:self selector:@selector(pingTimerDidFired:) userInfo:nil repeats:NO];
}

- (void)pingTimerDidFired:(NSTimer *)timer {
    [self.pinger sendPingWithData:nil];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timeoutTimerDidFired:) userInfo:nil repeats:NO];
}

- (void)timeoutTimerDidFired:(NSTimer *)timer {
    [self.pingTimer invalidate];
    self.currentStatus = CHTReachabilityStatusReachable;
    [self createPingTimer];
}

- (void)didReceivePacket {
    [self.timeoutTimer invalidate];
    self.currentStatus = CHTReachabilityStatusOnline;
    [self createPingTimer];
}

#pragma mark - <SimplePingDelegate>

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [self createPingTimer];
}

// Note:
// If this delegate method is called, the pinger will stop automatically.
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(reachability:didFailWithError:)]) {
        [self.delegate reachability:self didFailWithError:error];
    }
    self.pinger = nil;
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    [self didReceivePacket];
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    [self didReceivePacket];
}

@end
