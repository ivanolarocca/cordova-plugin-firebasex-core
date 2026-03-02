package org.apache.cordova.firebasex;

import android.content.Context;
import android.content.SharedPreferences;

import static android.content.Context.MODE_PRIVATE;

/**
 * Persistent key-value store for sharing state between modular FirebaseX plugins.
 *
 * <p>Uses Android {@link SharedPreferences} to persist data across plugin boundaries.
 * This is useful when one plugin needs to read state set by another plugin
 * (e.g., the messaging plugin checking if analytics collection is enabled).
 *
 * <p>All data is stored in a single SharedPreferences file named {@value #PREFS_NAME}
 * in {@link Context#MODE_PRIVATE}.
 */
public class FirebasexSharedState {
    /** SharedPreferences file name used for all inter-plugin shared state. */
    private static final String PREFS_NAME = "cordova_firebasex";

    /**
     * Stores a string value.
     *
     * @param ctx   the application context
     * @param key   the preference key
     * @param value the string value to store
     */
    public static void set(Context ctx, String key, String value) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        prefs.edit().putString(key, value).apply();
    }

    /**
     * Retrieves a string value.
     *
     * @param ctx the application context
     * @param key the preference key
     * @return the stored string value, or {@code null} if not set
     */
    public static String get(Context ctx, String key) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        return prefs.getString(key, null);
    }

    /**
     * Stores a boolean value.
     *
     * @param ctx   the application context
     * @param key   the preference key
     * @param value the boolean value to store
     */
    public static void setBoolean(Context ctx, String key, boolean value) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        prefs.edit().putBoolean(key, value).apply();
    }

    /**
     * Retrieves a boolean value.
     *
     * @param ctx          the application context
     * @param key          the preference key
     * @param defaultValue the value to return if the key is not set
     * @return the stored boolean value, or {@code defaultValue} if not set
     */
    public static boolean getBoolean(Context ctx, String key, boolean defaultValue) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        return prefs.getBoolean(key, defaultValue);
    }
}
