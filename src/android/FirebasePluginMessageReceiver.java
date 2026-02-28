package org.apache.cordova.firebasex;

import android.os.Bundle;

import com.google.firebase.messaging.RemoteMessage;

/**
 * Abstract class for receiving and handling Firebase messages.
 * Subclasses can register themselves to intercept and process incoming
 * FCM messages or notification bundles before they are processed by
 * the messaging plugin.
 */
public abstract class FirebasePluginMessageReceiver {

    public FirebasePluginMessageReceiver() {
        FirebasePluginMessageReceiverManager.register(this);
    }

    public abstract boolean onMessageReceived(RemoteMessage remoteMessage);

    public abstract boolean sendMessage(Bundle bundle);
}
