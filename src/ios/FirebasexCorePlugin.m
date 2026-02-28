#import "FirebasexCorePlugin.h"
#import "AppDelegate+FirebasexCore.h"
#import "FirebasePluginMessageReceiverManager.h"
#import <Cordova/CDV.h>
@import FirebaseCore;
@import FirebaseInstallations;

@implementation FirebasexCorePlugin

static NSString *const LOG_TAG = @"FirebasexCore[native]";
static FirebasexCorePlugin *sharedInstance;
static BOOL pluginInitialized = NO;
static NSUserDefaults *preferences;
static NSDictionary *googlePlist;
static NSString *currentInstallationId;
static NSMutableArray *pendingGlobalJS = nil;

+ (FirebasexCorePlugin *)sharedInstance {
    return sharedInstance;
}

- (void)pluginInitialize {
    NSLog(@"Starting FirebasexCorePlugin");
    sharedInstance = self;

    @try {
        preferences = [NSUserDefaults standardUserDefaults];
        googlePlist = [NSMutableDictionary
            dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                             pathForResource:@"GoogleService-Info"
                                                      ofType:@"plist"]];

        // Initialize installation ID change listener
        __weak __auto_type weakSelf = self;
        self.installationIDObserver = [[NSNotificationCenter defaultCenter]
            addObserverForName:FIRInstallationIDDidChangeNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *_Nonnull notification) {
                      [weakSelf sendNewInstallationId];
                    }];

        pluginInitialized = YES;
        [self executePendingGlobalJavascript];
    } @catch (NSException *exception) {
        [self handlePluginExceptionWithoutContext:exception];
    }
}

/*************************************************/
#pragma mark - Plugin actions
/*************************************************/

- (void)getId:(CDVInvokedUrlCommand *)command {
    [self getInstallationId:command];
}

- (void)getInstallationId:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            [[FIRInstallations installations]
                installationIDWithCompletion:^(NSString *identifier, NSError *error) {
                    [self handleStringResultWithPotentialError:error
                                                       command:command
                                                        result:identifier];
                }];
        } @catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception:command];
        }
    }];
}

- (void)getInstallationToken:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            [[FIRInstallations installations]
                authTokenForcingRefresh:true
                             completion:^(FIRInstallationsAuthTokenResult *result,
                                          NSError *error) {
                               if (error != nil) {
                                   [self sendPluginErrorWithError:error
                                                          command:command];
                               } else {
                                   [self sendPluginStringResult:[result authToken]
                                                        command:command
                                                     callbackId:command.callbackId];
                               }
                             }];
        } @catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception:command];
        }
    }];
}

- (void)deleteInstallationId:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        @try {
            [[FIRInstallations installations] deleteWithCompletion:^(NSError *error) {
                [self handleEmptyResultWithPotentialError:error command:command];
            }];
        } @catch (NSException *exception) {
            [self handlePluginExceptionWithContext:exception:command];
        }
    }];
}

- (void)sendNewInstallationId {
    [self.commandDelegate runInBackground:^{
        @try {
            [[FIRInstallations installations] installationIDWithCompletion:^(
                                                  NSString *identifier,
                                                  NSError *error) {
                if (error != nil) {
                    [self handlePluginErrorWithoutContext:error];
                } else if (currentInstallationId != identifier) {
                    [self executeGlobalJavascript:
                        [NSString stringWithFormat:@"FirebasexCore._onInstallationIdChangeCallback('%@')",
                                                   identifier]];
                    currentInstallationId = identifier;
                }
            }];
        } @catch (NSException *exception) {
            [self handlePluginExceptionWithoutContext:exception];
        }
    }];
}

/*************************************************/
#pragma mark - Global JS execution
/*************************************************/

- (void)executeGlobalJavascript:(NSString *)jsString {
    if (pluginInitialized) {
        [self doExecuteGlobalJavascript:jsString];
    } else {
        if (pendingGlobalJS == nil) {
            pendingGlobalJS = [[NSMutableArray alloc] init];
        }
        [pendingGlobalJS addObject:jsString];
    }
}

- (void)executePendingGlobalJavascript {
    if (pendingGlobalJS == nil) {
        NSLog(@"%@ No pending global JS calls", LOG_TAG);
        return;
    }
    NSLog(@"%@ Executing %lu pending global JS calls", LOG_TAG,
          (unsigned long)pendingGlobalJS.count);
    for (NSString *jsString in pendingGlobalJS) {
        [self doExecuteGlobalJavascript:jsString];
    }
    pendingGlobalJS = nil;
}

- (void)doExecuteGlobalJavascript:(NSString *)jsString {
    [self.commandDelegate evalJs:jsString];
}

/*************************************************/
#pragma mark - Logging
/*************************************************/

- (void)_logError:(NSString *)msg {
    NSLog(@"%@ ERROR: %@", LOG_TAG, msg);
    NSString *jsString =
        [NSString stringWithFormat:@"console.error(\"%@: %@\")", LOG_TAG,
                                   [self escapeJavascriptString:msg]];
    [self executeGlobalJavascript:jsString];
}

- (void)_logInfo:(NSString *)msg {
    NSLog(@"%@ INFO: %@", LOG_TAG, msg);
    NSString *jsString =
        [NSString stringWithFormat:@"console.info(\"%@: %@\")", LOG_TAG,
                                   [self escapeJavascriptString:msg]];
    [self executeGlobalJavascript:jsString];
}

- (void)_logMessage:(NSString *)msg {
    NSLog(@"%@ LOG: %@", LOG_TAG, msg);
    NSString *jsString =
        [NSString stringWithFormat:@"console.log(\"%@: %@\")", LOG_TAG,
                                   [self escapeJavascriptString:msg]];
    [self executeGlobalJavascript:jsString];
}

/*************************************************/
#pragma mark - Exception handling
/*************************************************/

- (void)handlePluginExceptionWithContext:(NSException *)exception
                                        :(CDVInvokedUrlCommand *)command {
    [self handlePluginExceptionWithoutContext:exception];
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                          messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
}

- (void)handlePluginExceptionWithoutContext:(NSException *)exception {
    [self _logError:[NSString stringWithFormat:@"EXCEPTION: %@", exception.reason]];
}

- (void)handlePluginErrorWithoutContext:(NSError *)error {
    [self _logError:[NSString stringWithFormat:@"ERROR: %@", error.description]];
}

/*************************************************/
#pragma mark - Preferences
/*************************************************/

- (void)setPreferenceFlag:(NSString *)name flag:(BOOL)flag {
    [preferences setBool:flag forKey:name];
    [preferences synchronize];
}

- (BOOL)getPreferenceFlag:(NSString *)name {
    if ([preferences objectForKey:name] == nil) {
        return false;
    }
    return [preferences boolForKey:name];
}

- (BOOL)getGooglePlistFlagWithDefaultValue:(NSString *)name
                              defaultValue:(BOOL)defaultValue {
    if ([googlePlist objectForKey:name] == nil) {
        return defaultValue;
    }
    id value = [googlePlist objectForKey:name];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    } else {
        return [value isEqual:@"true"];
    }
}

/*************************************************/
#pragma mark - Result helpers
/*************************************************/

- (void)sendPluginSuccess:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
              callbackId:command.callbackId];
}

- (void)sendPluginSuccessAndKeepCallback:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginNoResult:(CDVInvokedUrlCommand *)command
                callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginNoResultAndKeepCallback:(CDVInvokedUrlCommand *)command
                               callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginStringResult:(NSString *)result
                       command:(CDVInvokedUrlCommand *)command
                    callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                          messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginStringResultAndKeepCallback:(NSString *)result
                                      command:(CDVInvokedUrlCommand *)command
                                   callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                          messageAsString:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginBoolResult:(BOOL)result
                     command:(CDVInvokedUrlCommand *)command
                  callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                            messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginBoolResultAndKeepCallback:(BOOL)result
                                    command:(CDVInvokedUrlCommand *)command
                                 callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                            messageAsBool:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginDictionaryResult:(NSDictionary *)result
                           command:(CDVInvokedUrlCommand *)command
                        callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                      messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginDictionaryResultAndKeepCallback:(NSDictionary *)result
                                          command:(CDVInvokedUrlCommand *)command
                                       callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                      messageAsDictionary:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginArrayResult:(NSArray *)result
                      command:(CDVInvokedUrlCommand *)command
                   callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsArray:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginArrayResultAndKeepCallback:(NSArray *)result
                                     command:(CDVInvokedUrlCommand *)command
                                  callbackId:(NSString *)callbackId {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                           messageAsArray:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)sendPluginError:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR]
              callbackId:command.callbackId];
}

- (void)sendPluginErrorWithMessage:(NSString *)errorMessage
                                  :(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult =
        [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                          messageAsString:errorMessage];
    [self _logError:errorMessage];
    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:command.callbackId];
}

- (void)sendPluginErrorWithError:(NSError *)error
                         command:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:error.description]
              callbackId:command.callbackId];
}

- (void)handleEmptyResultWithPotentialError:(NSError *)error
                                    command:(CDVInvokedUrlCommand *)command {
    if (error) {
        [self sendPluginErrorWithError:error command:command];
    } else {
        [self sendPluginSuccess:command];
    }
}

- (void)handleStringResultWithPotentialError:(NSError *)error
                                     command:(CDVInvokedUrlCommand *)command
                                      result:(NSString *)result {
    if (error) {
        [self sendPluginErrorWithError:error command:command];
    } else {
        [self sendPluginStringResult:result
                             command:command
                          callbackId:command.callbackId];
    }
}

- (void)handleBoolResultWithPotentialError:(NSError *)error
                                   command:(CDVInvokedUrlCommand *)command
                                    result:(BOOL)result {
    if (error) {
        [self sendPluginErrorWithError:error command:command];
    } else {
        [self sendPluginBoolResult:result
                           command:command
                        callbackId:command.callbackId];
    }
}

/*************************************************/
#pragma mark - Thread helpers
/*************************************************/

- (void)runOnMainThread:(void (^)(void))completeBlock {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            @try {
                completeBlock();
            } @catch (NSException *exception) {
                [self handlePluginExceptionWithoutContext:exception];
            }
        });
    } else {
        @try {
            completeBlock();
        } @catch (NSException *exception) {
            [self handlePluginExceptionWithoutContext:exception];
        }
    }
}

/*************************************************/
#pragma mark - String helpers
/*************************************************/

- (NSString *)escapeJavascriptString:(NSString *)str {
    NSString *result = [str stringByReplacingOccurrencesOfString:@"\\\""
                                                      withString:@"\""];
    result = [result stringByReplacingOccurrencesOfString:@"\""
                                               withString:@"\\\""];
    result = [result stringByReplacingOccurrencesOfString:@"\n"
                                               withString:@"\\\n"];
    return result;
}

@end
