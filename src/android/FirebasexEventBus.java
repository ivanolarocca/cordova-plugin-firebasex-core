package org.apache.cordova.firebasex;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

/**
 * Event bus for inter-plugin communication using LocalBroadcastManager.
 */
public class FirebasexEventBus {

    public static void broadcast(Context context, String action, Bundle extras) {
        if (context == null) return;
        Intent intent = new Intent(action);
        if (extras != null) {
            intent.putExtras(extras);
        }
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }

    public static void register(Context context, String action, BroadcastReceiver receiver) {
        if (context == null) return;
        IntentFilter filter = new IntentFilter(action);
        LocalBroadcastManager.getInstance(context).registerReceiver(receiver, filter);
    }

    public static void unregister(Context context, BroadcastReceiver receiver) {
        if (context == null) return;
        LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver);
    }
}
