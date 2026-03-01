var exec = require('cordova/exec');

/**
 * Core Firebase plugin - handles initialization, installations, and lifecycle.
 */

exports.getInstallationId = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "getInstallationId", []);
};

exports.getInstallationToken = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "getInstallationToken", []);
};

exports.deleteInstallationId = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "deleteInstallationId", []);
};

exports.getId = function (success, error) {
    exec(success, error, "FirebasexCorePlugin", "getInstallationId", []);
};

// Internal callbacks for native -> JS
exports._onInstallationIdChangeCallback = function (id) {
    if (typeof onInstallationIdChangeCallback === 'function') onInstallationIdChangeCallback(id);
};

exports._applicationDidBecomeActive = function () {
    if (typeof onApplicationDidBecomeActiveCallback === 'function') onApplicationDidBecomeActiveCallback();
};

exports._applicationDidEnterBackground = function () {
    if (typeof onApplicationDidEnterBackgroundCallback === 'function') onApplicationDidEnterBackgroundCallback();
};

var onInstallationIdChangeCallback;
var onApplicationDidBecomeActiveCallback;
var onApplicationDidEnterBackgroundCallback;

exports.registerInstallationIdChangeListener = function (fn) {
    if (typeof fn !== "function") throw "The specified argument must be a function";
    onInstallationIdChangeCallback = fn;
};

exports.registerApplicationDidBecomeActiveListener = function (fn) {
    if (typeof fn !== "function") throw "The specified argument must be a function";
    onApplicationDidBecomeActiveCallback = fn;
};

exports.registerApplicationDidEnterBackgroundListener = function (fn) {
    if (typeof fn !== "function") throw "The specified argument must be a function";
    onApplicationDidEnterBackgroundCallback = fn;
};
