#import "AppDelegate.h"
@import UserNotifications;

// NSNotification names broadcast by the core plugin
extern NSString * const FirebasexAppDidBecomeActive;
extern NSString * const FirebasexAppDidEnterBackground;
extern NSString * const FirebasexAppDidFinishLaunching;
extern NSString * const FirebasexHandleOpenURL;

@interface AppDelegate (FirebasexCore) <UIApplicationDelegate>
+ (AppDelegate * _Nonnull)instance;
@property (nonatomic, strong) NSNumber * _Nonnull applicationInBackground;
@end
