#import <Foundation/Foundation.h>

@interface FirebasePluginMessageReceiver : NSObject

- (void)sendNotification:(NSDictionary *)notification;

@end
