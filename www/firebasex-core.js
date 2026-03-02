/**
 * @fileoverview JavaScript interface for the cordova-plugin-firebasex-core Cordova plugin.
 *
 * Provides the core Firebase functionality for the modular FirebaseX plugin suite:
 * - Firebase Installations API (installation ID, token, deletion)
 * - Application lifecycle listeners (foreground/background transitions)
 * - Installation ID change listener
 *
 * This module is a required dependency for all other FirebaseX modular plugins.
 * It is exposed as the global `FirebasexCore` object via the Cordova plugin bridge.
 *
 * @module FirebasexCore
 * @see https://firebase.google.com/docs/projects/manage-installations
 */

var exec = require('cordova/exec');

/**
 * Returns the current Firebase Installation ID (FID).
 *
 * The FID uniquely identifies this app installation and can be used for
 * targeting messages or segmenting analytics. The FID may change if the
 * user reinstalls the app or clears app data.
 *
 * @param {function(string)} success - Called with the installation ID string on success.
 * @param {function(string)} error - Called with an error message string on failure.
 * @see https://firebase.google.com/docs/projects/manage-installations#retrieve_client_identifers
 */
exports.getInstallationId = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "getInstallationId", []);
};

/**
 * Returns a valid Firebase Installation auth token.
 *
 * The token can be used to authenticate this app instance against
 * your own backend services. A fresh token is always requested
 * (force refresh).
 *
 * @param {function(string)} success - Called with the auth token string on success.
 * @param {function(string)} error - Called with an error message string on failure.
 * @see https://firebase.google.com/docs/projects/manage-installations#retrieve_installation_auth_tokens
 */
exports.getInstallationToken = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "getInstallationToken", []);
};

/**
 * Deletes the current Firebase Installation ID and all associated data.
 *
 * After deletion, Firebase will generate a new FID on next access.
 * This can be used to implement user opt-out or data deletion flows.
 *
 * @param {function()} success - Called on successful deletion.
 * @param {function(string)} error - Called with an error message string on failure.
 * @see https://firebase.google.com/docs/projects/manage-installations#delete_a_firebase_installation
 */
exports.deleteInstallationId = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "deleteInstallationId", []);
};

/**
 * Alias for {@link module:FirebasexCore.getInstallationId}.
 *
 * @param {function(string)} success - Called with the installation ID string on success.
 * @param {function(string)} error - Called with an error message string on failure.
 */
exports.getId = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "getInstallationId", []);
};

/**
 * Internal callback invoked from native code when the Firebase Installation ID changes.
 * Forwards the new ID to the registered listener, if any.
 *
 * @param {string} id - The new Firebase Installation ID.
 * @private
 */
exports._onInstallationIdChangeCallback = function (id) {
    if (typeof onInstallationIdChangeCallback === 'function') onInstallationIdChangeCallback(id);
};

/**
 * Internal callback invoked from native code when the app transitions to the foreground.
 * Forwards the event to the registered listener, if any.
 *
 * @private
 */
exports._applicationDidBecomeActive = function () {
    if (typeof onApplicationDidBecomeActiveCallback === 'function') onApplicationDidBecomeActiveCallback();
};

/**
 * Internal callback invoked from native code when the app transitions to the background.
 * Forwards the event to the registered listener, if any.
 *
 * @private
 */
exports._applicationDidEnterBackground = function () {
    if (typeof onApplicationDidEnterBackgroundCallback === 'function') onApplicationDidEnterBackgroundCallback();
};

/** @private Registered listener for installation ID changes. */
var onInstallationIdChangeCallback;
/** @private Registered listener for foreground transitions. */
var onApplicationDidBecomeActiveCallback;
/** @private Registered listener for background transitions. */
var onApplicationDidEnterBackgroundCallback;

/**
 * Registers a listener that is called whenever the Firebase Installation ID changes.
 *
 * The installation ID may change when the app is reinstalled, the user clears data,
 * or Firebase rotates the FID for security reasons.
 *
 * @param {function(string)} fn - Callback invoked with the new installation ID string.
 * @throws {string} If the argument is not a function.
 */
exports.registerInstallationIdChangeListener = function (fn) {
    if (typeof fn !== "function") throw "The specified argument must be a function";
    onInstallationIdChangeCallback = fn;
};

/**
 * Registers a listener that is called when the application transitions to the foreground.
 *
 * This corresponds to the iOS `applicationDidBecomeActive` and Android `onResume` lifecycle events.
 *
 * @param {function()} fn - Callback invoked when the app becomes active.
 * @throws {string} If the argument is not a function.
 */
exports.registerApplicationDidBecomeActiveListener = function (fn) {
    if (typeof fn !== "function") throw "The specified argument must be a function";
    onApplicationDidBecomeActiveCallback = fn;
};

/**
 * Registers a listener that is called when the application transitions to the background.
 *
 * This corresponds to the iOS `applicationDidEnterBackground` and Android `onPause` lifecycle events.
 *
 * @param {function()} fn - Callback invoked when the app enters the background.
 * @throws {string} If the argument is not a function.
 */
exports.registerApplicationDidEnterBackgroundListener = function (fn) {
    if (typeof fn !== "function") throw "The specified argument must be a function";
    onApplicationDidEnterBackgroundCallback = fn;
};
