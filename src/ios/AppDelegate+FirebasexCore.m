#import "AppDelegate+FirebasexCore.h"
#import "FirebasexCorePlugin.h"
#import "FirebasexCoreWrapper.h"
#import <objc/runtime.h>

@import UserNotifications;

#define kApplicationInBackgroundKey @"applicationInBackground"

NSString * const FirebasexAppDidBecomeActive = @"FirebasexAppDidBecomeActive";
NSString * const FirebasexAppDidEnterBackground = @"FirebasexAppDidEnterBackground";
NSString * const FirebasexAppDidFinishLaunching = @"FirebasexAppDidFinishLaunching";
NSString * const FirebasexHandleOpenURL = @"FirebasexHandleOpenURL";

@implementation AppDelegate (FirebasexCore)

static AppDelegate *instance;

+ (AppDelegate *)instance {
    return instance;
}

+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method swizzled = class_getInstanceMethod(self, @selector(application:firebasexCoreDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, swizzled);
}

- (void)setApplicationInBackground:(NSNumber *)applicationInBackground {
    objc_setAssociatedObject(self, kApplicationInBackgroundKey, applicationInBackground, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)applicationInBackground {
    return objc_getAssociatedObject(self, kApplicationInBackgroundKey);
}

- (BOOL)application:(UIApplication *)application firebasexCoreDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Call the original implementation (swizzled)
    [self application:application firebasexCoreDidFinishLaunchingWithOptions:launchOptions];

#if DEBUG
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"/google/firebase/debug_mode"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"/google/measurement/debug_mode"];
#endif

    @try {
        instance = self;

        if (![FIRApp defaultApp]) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
            if (filePath) {
                [FirebasexCorePlugin.sharedInstance _logMessage:@"GoogleService-Info.plist found, setup: [FIRApp configureWithOptions]"];
                FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:filePath];
                [FIRApp configureWithOptions:options];
            } else {
                [FirebasexCorePlugin.sharedInstance _logError:@"GoogleService-Info.plist NOT FOUND, setup: [FIRApp defaultApp]"];
                [FIRApp configure];
            }
        }

        self.applicationInBackground = @(YES);

        // Notify other plugins that Firebase has been initialized
        [[NSNotificationCenter defaultCenter] postNotificationName:FirebasexAppDidFinishLaunching object:nil userInfo:launchOptions];

    } @catch (NSException *exception) {
        [FirebasexCorePlugin.sharedInstance handlePluginExceptionWithoutContext:exception];
    }

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self.applicationInBackground = @(NO);
    @try {
        [FirebasexCorePlugin.sharedInstance _logMessage:@"Enter foreground"];
        [FirebasexCorePlugin.sharedInstance executeGlobalJavascript:@"FirebasexCore._applicationDidBecomeActive()"];
        [[NSNotificationCenter defaultCenter] postNotificationName:FirebasexAppDidBecomeActive object:nil];
    } @catch (NSException *exception) {
        [FirebasexCorePlugin.sharedInstance handlePluginExceptionWithoutContext:exception];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.applicationInBackground = @(YES);
    @try {
        [FirebasexCorePlugin.sharedInstance _logMessage:@"Enter background"];
        [FirebasexCorePlugin.sharedInstance executeGlobalJavascript:@"FirebasexCore._applicationDidEnterBackground()"];
        [[NSNotificationCenter defaultCenter] postNotificationName:FirebasexAppDidEnterBackground object:nil];
    } @catch (NSException *exception) {
        [FirebasexCorePlugin.sharedInstance handlePluginExceptionWithoutContext:exception];
    }
}

- (void)handleOpenURL:(NSNotification *)notification {
    NSURL *url = [notification object];
    [[NSNotificationCenter defaultCenter] postNotificationName:FirebasexHandleOpenURL object:url];
}

@end
