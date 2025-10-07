import Flutter
import UIKit
import GoogleMaps
import awesome_notifications
import awesome_notifications_fcm
import flutter_secure_storage
import flutter_sharing_intent

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback {
            registry in SwiftAwesomeNotificationsPlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
            FlutterSecureStoragePlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.fluttersecurestorage.FlutterSecureStoragePlugin")!)
        }
        
        SwiftAwesomeNotificationsFcmPlugin.setPluginRegistrantCallback {
            registry in SwiftAwesomeNotificationsPlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
            FlutterSecureStoragePlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.fluttersecurestorage.FlutterSecureStoragePlugin")!)
        }
        
        GMSServices.provideAPIKey("<My api key>")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let sharingIntent = SwiftFlutterSharingIntentPlugin.instance
        
        if sharingIntent.hasSameSchemePrefix(url: url) {
            return sharingIntent.application(app, open: url, options: options)
        }
        
        return super.application(app, open: url, options:options)
    }
}
