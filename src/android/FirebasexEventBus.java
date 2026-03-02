package org.apache.cordova.firebasex;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

/**
 * Lightweight event bus for inter-plugin communication using {@link LocalBroadcastManager}.
 *
 * <p>Since the modular FirebaseX plugin suite splits functionality across separate Cordova plugins,
 * each running in the same process, this event bus allows plugins to communicate without
 * direct compile-time dependencies. For example, the core plugin broadcasts lifecycle events
 * ({@code FirebasexAppDidBecomeActive}, {@code FirebasexAppDidEnterBackground}) that the
 * messaging plugin listens for.
 *
 * <p>All broadcasts are local to the application process and are not visible to other apps.
 *
 * <p>Common event actions:
 * <ul>
 *   <li>{@code "FirebasexAppDidBecomeActive"} - app entered foreground</li>
 *   <li>{@code "FirebasexAppDidEnterBackground"} - app entered background</li>
 * </ul>
 *
 * @see LocalBroadcastManager
 */
public class FirebasexEventBus {

    /**
     * Broadcasts a local event to all registered receivers.
     *
     * @param context the application context (if {@code null}, the broadcast is silently skipped)
     * @param action  the intent action string identifying the event
     * @param extras  optional extras to attach to the intent; may be {@code null}
     */
    public static void broadcast(Context context, String action, Bundle extras) {
        if (context == null) return;
        Intent intent = new Intent(action);
        if (extras != null) {
            intent.putExtras(extras);
        }
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }

    /**
     * Registers a receiver to listen for a specific event action.
     *
     * @param context  the application context (if {@code null}, registration is silently skipped)
     * @param action   the intent action string to listen for
     * @param receiver the broadcast receiver to invoke when the event fires
     */
    public static void register(Context context, String action, BroadcastReceiver receiver) {
        if (context == null) return;
        IntentFilter filter = new IntentFilter(action);
        LocalBroadcastManager.getInstance(context).registerReceiver(receiver, filter);
    }

    /**
     * Unregisters a previously registered receiver.
     *
     * @param context  the application context (if {@code null}, unregistration is silently skipped)
     * @param receiver the broadcast receiver to remove
     */
    public static void unregister(Context context, BroadcastReceiver receiver) {
        if (context == null) return;
        LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver);
    }
}
