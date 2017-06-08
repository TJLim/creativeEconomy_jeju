//
//  AppDelegate.swift
//  creative_beaconApp_IOS_legacy
//
//  Created by 안치홍 on 2017. 4. 4..
//  Copyright © 2017년 안치홍. All rights reserved.
//

import UIKit
import Tamra
//import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    var bluetoothState: Bool = false
    
    /* 운영 */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let config = TamraConfig(
            appKey: "68a2479343b54d6b9af8fbe2b5314a92",
            profile: .PRODUCTION,
            logLevel: .Debug,
            simulation: false)
        
        Tamra.configure(config)
        
        sleep(3)
        
        return true
    }
    
    
//    /* 개발 */
//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        
//        let config = TamraConfig(
//            appKey: "5fce91eb8bf14075a54d2303503274f1",
//            profile: .TEST,
//            logLevel: .Debug,
//            simulation: true)
//        
//        Tamra.configure(config)
//        
//        sleep(3)
//        
//        return true
//    }
    

//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        return true
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

