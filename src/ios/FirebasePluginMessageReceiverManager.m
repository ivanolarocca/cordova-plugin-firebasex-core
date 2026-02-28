#import "FirebasePluginMessageReceiverManager.h"

@implementation FirebasePluginMessageReceiverManager

static NSMutableArray<FirebasePluginMessageReceiver *> *receivers;

+ (void)registerMessageReceiver:(FirebasePluginMessageReceiver *)receiver {
    if (receivers == nil) {
        receivers = [[NSMutableArray alloc] init];
    }
    [receivers addObject:receiver];
}

+ (void)sendNotification:(NSDictionary *)notification {
    if (receivers == nil) return;
    for (FirebasePluginMessageReceiver *receiver in receivers) {
        [receiver sendNotification:notification];
    }
}

@end
