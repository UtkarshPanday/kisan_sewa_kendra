import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum UpdateType { none, optional, force }

class UpdateService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // Set defaults
      await _remoteConfig.setDefaults({
        'latest_version': '1.0.0',
        'min_required_version': '1.0.0',
        'force_update': false,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint("Remote Config Error: $e");
    }
  }

  static Future<UpdateType> checkUpdateStatus() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final remoteLatestVersion = _remoteConfig.getString('latest_version');
      final remoteMinVersion = _remoteConfig.getString('min_required_version');
      final isForceUpdateEnabled = _remoteConfig.getBool('force_update');

      // 1. Check for Force Update first
      if (isForceUpdateEnabled && _isVersionGreaterThan(remoteMinVersion, currentVersion)) {
        return UpdateType.force;
      }

      // 2. Check for Optional Update
      if (_isVersionGreaterThan(remoteLatestVersion, currentVersion)) {
        return UpdateType.optional;
      }
    } catch (e) {
      debugPrint("Update Check Error: $e");
    }
    return UpdateType.none;
  }

  /// Returns true if [remote] version is strictly greater than [current] version.
  static bool _isVersionGreaterThan(String remote, String current) {
    if (remote.isEmpty) return false;
    
    try {
      List<int> remoteParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      int length = remoteParts.length > currentParts.length ? remoteParts.length : currentParts.length;

      for (int i = 0; i < length; i++) {
        int r = i < remoteParts.length ? remoteParts[i] : 0;
        int c = i < currentParts.length ? currentParts[i] : 0;
        if (r > c) return true;
        if (r < c) return false;
      }
    } catch (e) {
      debugPrint("Version parsing error: $e");
    }
    return false;
  }

  static void showUpdateDialog(BuildContext context, UpdateType type) {
    bool isForce = type == UpdateType.force;
    
    showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (context) {
        return PopScope(
          canPop: !isForce,
          onPopInvokedWithResult: (didPop, result) {
            if (isForce && !didPop) {
              // Optionally show a toast that update is required
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF26842C).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isForce ? Icons.system_update_rounded : Icons.update_rounded, 
                      size: 40, 
                      color: const Color(0xFF26842C)
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isForce ? AppLocalizations.of(context)!.updateRequired : AppLocalizations.of(context)!.updateAvailable,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isForce 
                      ? AppLocalizations.of(context)!.forceUpdateMsg
                      : AppLocalizations.of(context)!.optionalUpdateMsg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (!isForce)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF26842C)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.later,
                                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF26842C)),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _launchStore(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF26842C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.updateNow,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _launchStore() async {
    const String appId = "com.snss.ebs.kisan_sewa_kendra";
    final String url = Platform.isAndroid
        ? "market://details?id=$appId"
        : "https://apps.apple.com/app/id$appId"; // Add iOS ID when available

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web URL
        final String webUrl = "https://play.google.com/store/apps/details?id=$appId";
        await launchUrlString(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch store: $e");
    }
  }
}
