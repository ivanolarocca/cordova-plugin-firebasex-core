var fs = require("fs");
var path = require("path");
var utilities = require("../lib/utilities");
var xcode = require("xcode");
var plist = require('plist');

var versionRegex = /\d+\.\d+\.\d+[^'"]*/,
    firebasePodRegex = /pod 'Firebase([^']+)', '(\d+\.\d+\.\d+[^'"]*)'/g,
    iosDeploymentTargetPodRegEx = /platform :ios, '(\d+\.\d+\.?\d*)'/;

function ensureUrlSchemeInPlist(urlScheme, appPlist){
    var appPlistModified = false;
    if(!appPlist['CFBundleURLTypes']) appPlist['CFBundleURLTypes'] = [];
    var entry, entryIndex, i, j, alreadyExists = false;

    for(i=0; i<appPlist['CFBundleURLTypes'].length; i++){
        var thisEntry = appPlist['CFBundleURLTypes'][i];
        if(thisEntry['CFBundleURLSchemes']){
            for(j=0; j<thisEntry['CFBundleURLSchemes'].length; j++){
                if(thisEntry['CFBundleURLSchemes'][j] === urlScheme){
                    alreadyExists = true;
                    break;
                }
            }
        }
        if(thisEntry['CFBundleTypeRole'] === 'Editor'){
            entry = thisEntry;
            entryIndex = i;
        }
    }
    if(!alreadyExists){
        if(!entry) entry = {};
        if(!entry['CFBundleTypeRole']) entry['CFBundleTypeRole'] = 'Editor';
        if(!entry['CFBundleURLSchemes']) entry['CFBundleURLSchemes'] = [];
        entry['CFBundleURLSchemes'].push(urlScheme)
        if(typeof entryIndex === "undefined") entryIndex = i;
        appPlist['CFBundleURLTypes'][entryIndex] = entry;
        appPlistModified = true;
        utilities.log('Added URL scheme "'+urlScheme+'"');
    }

    return {plist: appPlist, modified: appPlistModified}
}

module.exports = {
    getXcodeProjectPath: function () {
        var appName = utilities.getAppName();
        var oldPath = path.join("platforms", "ios", appName + ".xcodeproj", "project.pbxproj");
        var newPath = path.join("platforms", "ios", "App.xcodeproj", "project.pbxproj");
        if (fs.existsSync(newPath)) {
            return newPath;
        }
        return oldPath;
    },

    ensureRunpathSearchPath: function(context, xcodeProjectPath){
        function addRunpathSearchBuildProperty(proj, build) {
            let LD_RUNPATH_SEARCH_PATHS = proj.getBuildProperty("LD_RUNPATH_SEARCH_PATHS", build);
            if (!Array.isArray(LD_RUNPATH_SEARCH_PATHS)) {
                LD_RUNPATH_SEARCH_PATHS = [LD_RUNPATH_SEARCH_PATHS];
            }
            LD_RUNPATH_SEARCH_PATHS.forEach(LD_RUNPATH_SEARCH_PATH => {
                if (!LD_RUNPATH_SEARCH_PATH) {
                    proj.addBuildProperty("LD_RUNPATH_SEARCH_PATHS", "\"$(inherited) @executable_path/Frameworks\"", build);
                }
                if (LD_RUNPATH_SEARCH_PATH.indexOf("@executable_path/Frameworks") == -1) {
                    var newValue = LD_RUNPATH_SEARCH_PATH.substr(0, LD_RUNPATH_SEARCH_PATH.length - 1);
                    newValue += ' @executable_path/Frameworks\"';
                    proj.updateBuildProperty("LD_RUNPATH_SEARCH_PATHS", newValue, build);
                }
                if (LD_RUNPATH_SEARCH_PATH.indexOf("$(inherited)") == -1) {
                    var newValue = LD_RUNPATH_SEARCH_PATH.substr(0, LD_RUNPATH_SEARCH_PATH.length - 1);
                    newValue += ' $(inherited)\"';
                    proj.updateBuildProperty("LD_RUNPATH_SEARCH_PATHS", newValue, build);
                }
            });
        }

        var xcodeProject = xcode.project(xcodeProjectPath);
        xcodeProject.parseSync();
        addRunpathSearchBuildProperty(xcodeProject, "Debug");
        addRunpathSearchBuildProperty(xcodeProject, "Release");
        fs.writeFileSync(path.resolve(xcodeProjectPath), xcodeProject.writeSync());
    },

    applyPodsPostInstall: function(pluginVariables, iosPlatform){
        var podFileModified = false,
            podFilePath = path.resolve(iosPlatform.podFile);

        if(!fs.existsSync(podFilePath)){
            utilities.warn('Podfile not found at ' + podFilePath);
            return false;
        }

        var podFile = fs.readFileSync(podFilePath).toString(),
            DEBUG_INFORMATION_FORMAT = pluginVariables['IOS_STRIP_DEBUG'] && pluginVariables['IOS_STRIP_DEBUG'] === 'true' ? 'dwarf' : 'dwarf-with-dsym',
            iosDeploymentTargetMatch = podFile.match(iosDeploymentTargetPodRegEx),
            IPHONEOS_DEPLOYMENT_TARGET = iosDeploymentTargetMatch ? iosDeploymentTargetMatch[1] : null;

        if(!podFile.match('post_install')){
            podFile += "\npost_install do |installer|\n" +
                "    installer.pods_project.targets.each do |target|\n" +
                "        target.build_configurations.each do |config|\n" +
                "            config.build_settings['DEBUG_INFORMATION_FORMAT'] = '" + DEBUG_INFORMATION_FORMAT + "'\n" +
                (IPHONEOS_DEPLOYMENT_TARGET ? "            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '" + IPHONEOS_DEPLOYMENT_TARGET + "'\n" : "") +
                "            if target.respond_to?(:product_type) and target.product_type == \"com.apple.product-type.bundle\"\n" +
                "                config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'\n" +
                "            end\n" +
                "        end\n" +
                "    end\n" +
                "end\n";
            fs.writeFileSync(path.resolve(podFilePath), podFile);
            utilities.log('Applied post install block to Podfile');
            podFileModified = true;
        }
        return podFileModified;
    },

    applyPluginVarsToPlists: function(pluginVariables, iosPlatform){
        var googlePlistPath = path.resolve(iosPlatform.dest);
        if(!fs.existsSync(googlePlistPath)){
            utilities.warn('Google plist not found at ' + googlePlistPath);
            return;
        }

        var appPlistPath = path.resolve(iosPlatform.appPlist);
        if(!fs.existsSync(appPlistPath)){
            utilities.warn('App plist not found at ' + appPlistPath);
            return;
        }

        var entitlementsDebugPlistPath = path.resolve(iosPlatform.entitlementsDebugPlist);
        if(!fs.existsSync(entitlementsDebugPlistPath)){
            utilities.warn('Entitlements debug plist not found at ' + entitlementsDebugPlistPath);
            return;
        }

        var entitlementsReleasePlistPath = path.resolve(iosPlatform.entitlementsReleasePlist);
        if(!fs.existsSync(entitlementsReleasePlistPath)){
            utilities.warn('Entitlements release plist not found at ' + entitlementsReleasePlistPath);
            return;
        }

        var googlePlist = plist.parse(fs.readFileSync(googlePlistPath, 'utf8')),
            appPlist = plist.parse(fs.readFileSync(appPlistPath, 'utf8')),
            googlePlistModified = false,
            appPlistModified = false;

        if(typeof pluginVariables['IOS_SHOULD_ESTABLISH_DIRECT_CHANNEL'] !== 'undefined'){
            appPlist["shouldEstablishDirectChannel"] = (pluginVariables['IOS_SHOULD_ESTABLISH_DIRECT_CHANNEL'] === "true");
            appPlistModified = true;
        }

        if(googlePlistModified) fs.writeFileSync(path.resolve(iosPlatform.dest), plist.build(googlePlist));
        if(appPlistModified) fs.writeFileSync(path.resolve(iosPlatform.appPlist), plist.build(appPlist));
    },

    applyPluginVarsToPodfile: function(pluginVariables, iosPlatform){
        var podFilePath = path.resolve(iosPlatform.podFile);
        if(!fs.existsSync(podFilePath)){
            utilities.warn('Podfile not found at ' + podFilePath);
            return false;
        }

        var podFileContents = fs.readFileSync(podFilePath, 'utf8'),
            podFileModified = false;

        if(pluginVariables['IOS_FIREBASE_SDK_VERSION']){
            if(pluginVariables['IOS_FIREBASE_SDK_VERSION'].match(versionRegex)){
                var matches = podFileContents.match(firebasePodRegex);
                if(matches){
                    matches.forEach(function(match){
                        var currentVersion = match.match(versionRegex)[0];
                        if(!match.match(pluginVariables['IOS_FIREBASE_SDK_VERSION'])){
                            podFileContents = podFileContents.replace(match, match.replace(currentVersion, pluginVariables['IOS_FIREBASE_SDK_VERSION']));
                            podFileModified = true;
                        }
                    });
                }
                if(podFileModified) utilities.log("Firebase iOS SDK version set to v"+pluginVariables['IOS_FIREBASE_SDK_VERSION']+" in Podfile");
            }else{
                throw new Error("The value \""+pluginVariables['IOS_FIREBASE_SDK_VERSION']+"\" for IOS_FIREBASE_SDK_VERSION is not a valid semantic version format");
            }
        }

        if(podFileModified) {
            fs.writeFileSync(path.resolve(iosPlatform.podFile), podFileContents);
        }

        return podFileModified;
    },

    ensureEncodedAppIdInUrlSchemes: function(iosPlatform){
        var googlePlistPath = path.resolve(iosPlatform.dest);
        if(!fs.existsSync(googlePlistPath)){
            utilities.warn('Google plist not found at ' + googlePlistPath);
            return;
        }

        var appPlistPath = path.resolve(iosPlatform.appPlist);
        if(!fs.existsSync(appPlistPath)){
            utilities.warn('App plist not found at ' + appPlistPath);
            return;
        }

        var googlePlist = plist.parse(fs.readFileSync(googlePlistPath, 'utf8')),
            appPlist = plist.parse(fs.readFileSync(appPlistPath, 'utf8')),
            googleAppId = googlePlist["GOOGLE_APP_ID"];

        if(!googleAppId){
            utilities.warn("Google App ID not found in Google plist");
            return;
        }

        var encodedAppId = 'app-'+googleAppId.replace(/:/g,'-');
        var result = ensureUrlSchemeInPlist(encodedAppId, appPlist);
        if(result.modified){
            fs.writeFileSync(path.resolve(iosPlatform.appPlist), plist.build(result.plist));
        }
    },

    ensureUrlSchemeInPlist: ensureUrlSchemeInPlist
};
