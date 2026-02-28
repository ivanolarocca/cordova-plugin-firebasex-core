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
exports._onInstallationIdChangeCallback = function (id) {};

exports._applicationDidBecomeActive = function () {};

exports._applicationDidEnterBackground = function () {};
