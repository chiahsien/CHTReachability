//
//  CHTReachability.h
//
//  Created by Nelson on 2016/8/22.
//  Copyright © 2016年 iCHEF. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, CHTReachabilityStatus) {
    /// Unknown status, the initial status.
    CHTReachabilityStatusUnknown = 0,

    /// Network is not reachable.
    CHTReachabilityStatusNotReachable,

    /// Network is reachable but not knowing if we're online.
    /// For example, the device may connect to a wireless AP via Wi-Fi but the cable is not plugged into the AP.
    /// Or maybe the ping function is broken, so we can't detect if we're really online.
    CHTReachabilityStatusReachable,

    /// Network is reachable and we're online.
    CHTReachabilityStatusOnline
};

NS_ASSUME_NONNULL_BEGIN

@class CHTReachability;

@protocol CHTReachabilityDelegate <NSObject>
@optional
/**
 *  Called when current reachability status is different from previous one.
 *
 *  @param reachability The reachability object that calls this method.
 *  @param status       Current status
 */
- (void)reachability:(CHTReachability *)reachability didChangeToStatus:(CHTReachabilityStatus)status;
/**
 *  Called when the `ping` function gets an error.
 *  When this method is called, the `ping` function will not work anymore.
 *
 *  @param reachability The reachability object that calls this method.
 *  @param error        The error object.
 */
- (void)reachability:(CHTReachability *)reachability didFailWithError:(NSError *)error;
@end

/**
 *  This object tries to detect `real` network reachability status,
 *  it uses the `Reachability` and `SimplePing` sample codes provided by Apple.
 *
 *  - When `Reachability` says network is not reachable, then it is not reachable.
 *  - When `Reachability` says network is reachable, then `SimplePing` is used to detect real network status:
 *    - If fails to ping, then it is reachable but offline.
 *    - If ping successfully, then it is online.
 *
 *  Reachability:
 *  https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html
 *  SimplePing:
 *  https://developer.apple.com/library/prerelease/content/samplecode/SimplePing/Introduction/Intro.html
 */

@interface CHTReachability : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initialise the object to ping the specified host.
 *
 *  The object starts automatically after initialization. If it fails to start, typically because `hostName`
 *  doesn't resolve, you'll get the `- reachability:didFailWithError:` delegate callback and the `ping` function
 *  stops working.
 *  Although `ping` function stops working, the `reachability` function still works. Which means that you'll
 *  know if network status is reachable, but you can't know if it is really online.
 *
 *  @param hostName The DNS name of the host to ping; an IPv4 or IPv6 address in string form will
 *      work here. You can use `CHTReachabilityDefaultPingHostName` if you have no idea which hostname to use.
 *  @param delegate The delegate for this object.
 *
 *  @return The initialised object.
 */
- (instancetype)initWithHostName:(NSString *)hostName delegate:(nullable id<CHTReachabilityDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// The DNS name of the host to ping; an IPv4 or IPv6 address in string form will work here.
@property (nonatomic, copy, readonly) NSString *pingHostName;

/// Pinging time interval in seconds between `CHTReachabilityMinimumPingInterval`
/// and `CHTReachabilityMaximumPingInterval`, default value is `CHTReachabilityDefaultPingInterval`.
@property (nonatomic, assign) NSTimeInterval pingInterval;

/// The delegate for this object.
@property (nonatomic, weak, nullable, readonly) id <CHTReachabilityDelegate> delegate;

/// Current reachability status for this object.
@property (nonatomic, assign, readonly) CHTReachabilityStatus currentStatus;

@end

#pragma mark -

///----------------
/// @name Constants
///----------------

/// Default host name for pinging, which is `www.google.com`.
extern NSString *const CHTReachabilityDefaultPingHostName;

/// Default pinging interval in seconds, which is `90`.
extern NSTimeInterval const CHTReachabilityDefaultPingInterval;

/// Minimum pinging interval in seconds, which is `5`.
extern NSTimeInterval const CHTReachabilityMinimumPingInterval;

/// Maximum pinging interval in seconds, which is `3600`.
extern NSTimeInterval const CHTReachabilityMaximumPingInterval;

NS_ASSUME_NONNULL_END
