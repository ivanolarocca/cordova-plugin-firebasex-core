#import "AppDelegate.h"
#import <Cordova/CDV.h>
@import FirebaseCore;
@import FirebaseInstallations;

@interface FirebasexCorePlugin : CDVPlugin

+ (FirebasexCorePlugin *)sharedInstance;

// Installations
- (void)getInstallationId:(CDVInvokedUrlCommand *)command;
- (void)getInstallationToken:(CDVInvokedUrlCommand *)command;
- (void)deleteInstallationId:(CDVInvokedUrlCommand *)command;
- (void)getId:(CDVInvokedUrlCommand *)command;

// Utilities exposed for feature plugins
- (void)executeGlobalJavascript:(NSString *)jsString;
- (void)executePendingGlobalJavascript;
- (void)handlePluginExceptionWithContext:(NSException *)exception :(CDVInvokedUrlCommand *)command;
- (void)handlePluginExceptionWithoutContext:(NSException *)exception;
- (void)handlePluginErrorWithoutContext:(NSError *)error;

// Logging
- (void)_logError:(NSString *)msg;
- (void)_logInfo:(NSString *)msg;
- (void)_logMessage:(NSString *)msg;

// Preferences
- (void)setPreferenceFlag:(NSString *)name flag:(BOOL)flag;
- (BOOL)getPreferenceFlag:(NSString *)name;
- (BOOL)getGooglePlistFlagWithDefaultValue:(NSString *)name defaultValue:(BOOL)defaultValue;

// Result helpers
- (void)sendPluginSuccess:(CDVInvokedUrlCommand *)command;
- (void)sendPluginSuccessAndKeepCallback:(NSString *)callbackId;
- (void)sendPluginNoResult:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginNoResultAndKeepCallback:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginStringResult:(NSString *)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginStringResultAndKeepCallback:(NSString *)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginBoolResult:(BOOL)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginBoolResultAndKeepCallback:(BOOL)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginDictionaryResult:(NSDictionary *)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginDictionaryResultAndKeepCallback:(NSDictionary *)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginArrayResult:(NSArray *)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginArrayResultAndKeepCallback:(NSArray *)result command:(CDVInvokedUrlCommand *)command callbackId:(NSString *)callbackId;
- (void)sendPluginError:(CDVInvokedUrlCommand *)command;
- (void)sendPluginErrorWithMessage:(NSString *)errorMessage :(CDVInvokedUrlCommand *)command;
- (void)sendPluginErrorWithError:(NSError *)error command:(CDVInvokedUrlCommand *)command;
- (void)handleEmptyResultWithPotentialError:(NSError *)error command:(CDVInvokedUrlCommand *)command;
- (void)handleStringResultWithPotentialError:(NSError *)error command:(CDVInvokedUrlCommand *)command result:(NSString *)result;
- (void)handleBoolResultWithPotentialError:(NSError *)error command:(CDVInvokedUrlCommand *)command result:(BOOL)result;

// Thread helpers
- (void)runOnMainThread:(void (^)(void))completeBlock;

// Escape
- (NSString *)escapeJavascriptString:(NSString *)str;

@property(nonatomic, nullable) id<NSObject> installationIDObserver;

@end
