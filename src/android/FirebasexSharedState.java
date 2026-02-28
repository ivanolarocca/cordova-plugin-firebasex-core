package org.apache.cordova.firebasex;

import android.content.Context;
import android.content.SharedPreferences;

import static android.content.Context.MODE_PRIVATE;

/**
 * Shared state store for inter-plugin data sharing via SharedPreferences.
 */
public class FirebasexSharedState {
    private static final String PREFS_NAME = "cordova_firebasex";

    public static void set(Context ctx, String key, String value) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        prefs.edit().putString(key, value).apply();
    }

    public static String get(Context ctx, String key) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        return prefs.getString(key, null);
    }

    public static void setBoolean(Context ctx, String key, boolean value) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        prefs.edit().putBoolean(key, value).apply();
    }

    public static boolean getBoolean(Context ctx, String key, boolean defaultValue) {
        SharedPreferences prefs = ctx.getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        return prefs.getBoolean(key, defaultValue);
    }
}
