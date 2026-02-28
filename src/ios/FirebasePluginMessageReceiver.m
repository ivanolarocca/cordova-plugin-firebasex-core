#import "FirebasePluginMessageReceiver.h"
#import "FirebasePluginMessageReceiverManager.h"

@implementation FirebasePluginMessageReceiver

- (instancetype)init {
    self = [super init];
    if (self) {
        [FirebasePluginMessageReceiverManager registerMessageReceiver:self];
    }
    return self;
}

- (void)sendNotification:(NSDictionary *)notification {
    // Override in subclass
}

@end
