//
//  AppDelegate.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/13.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import IQKeyboardManagerSwift

let GMSAPIKey:String = "AIzaSyBKViS7HDsxSgBCEBQB288EopoUDq3-rxU"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey(GMSAPIKey)
        GMSPlacesClient.provideAPIKey(GMSAPIKey)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
//        if let window = self.window {
//            window.backgroundColor = UIColor.white
//
//            let nav = UINavigationController()
//            let mainView = TimeLineVIewController()
//            nav.viewControllers = [mainView]
//            window.rootViewController = nav
//            window.makeKeyAndVisible()
//        }
        
        //textを入力する時キーボードを上に押し上げる
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

