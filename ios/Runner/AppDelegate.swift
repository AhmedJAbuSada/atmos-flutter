import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    SystemChannel.register(with: engineBridge.applicationRegistrar.messenger())
  }
}

/// The iOS side of the app's small system channel (ADR-0017): open a web page, and open the
/// app's page in Settings, where iOS shows the app's language.
enum SystemChannel {
  static let name = "dev.ahmedabusada.atmos/system"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "openUrl":
        // Web pages only: the channel never opens another app's deep link.
        guard let text = call.arguments as? String, let url = URL(string: text),
          url.scheme == "https"
        else {
          result(false)
          return
        }
        open(url, result)
      case "openLanguageSettings":
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
          result(false)
          return
        }
        open(url, result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func open(_ url: URL, _ result: @escaping FlutterResult) {
    UIApplication.shared.open(url) { opened in result(opened) }
  }
}
