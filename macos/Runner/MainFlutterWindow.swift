import Cocoa
import FlutterMacOS
import desktop_multi_window

// ✅ هذه هي الـ plugins التي تحتاج تسجيلها يدويًا للنافذة الفرعية
import cloud_firestore
import firebase_core
import shared_preferences_foundation
import path_provider_foundation
import native_dialog_plus
import flutter_platform_alert

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        // ✅ تسجيل الـ plugins للنافذة الرئيسية
        RegisterGeneratedPlugins(registry: flutterViewController)

        // ✅ تسجيل plugins يدويًا عند إنشاء نافذة فرعية
        FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
            FLTFirebaseFirestorePlugin.register(with: controller.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
            FLTFirebaseCorePlugin.register(with: controller.registrar(forPlugin: "FLTFirebaseCorePlugin"))
            SharedPreferencesPlugin.register(with: controller.registrar(forPlugin: "SharedPreferencesPlugin"))
            PathProviderPlugin.register(with: controller.registrar(forPlugin: "PathProviderPlugin"))
            NativeDialogPlusPlugin.register(with: controller.registrar(forPlugin: "NativeDialogPlusPlugin"))
            FlutterPlatformAlertPlugin.register(with: controller.registrar(forPlugin: "FlutterPlatformAlertPlugin"))
        }

        super.awakeFromNib()
    }
}