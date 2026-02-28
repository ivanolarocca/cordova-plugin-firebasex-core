#import <Foundation/Foundation.h>
#import "FirebasePluginMessageReceiver.h"

@interface FirebasePluginMessageReceiverManager : NSObject

+ (void)registerMessageReceiver:(FirebasePluginMessageReceiver *)receiver;
+ (void)sendNotification:(NSDictionary *)notification;

@end
