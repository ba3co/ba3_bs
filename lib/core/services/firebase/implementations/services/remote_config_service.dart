import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0),
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }

  static String get whatsappAccessToken => _remoteConfig.getString('whatsapp_access_token');

  static bool get isAppEnabled => _remoteConfig.getBool('app_enabled');
}
