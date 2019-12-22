//
//  AppDelegate.swift
//  AppMover-Demo
//
//  Created by Oskar Groth on 2019-12-20.
//  Copyright © 2019 Oskar Groth. All rights reserved.
//

import Cocoa
import AppMover

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        AppMover.moveIfNecessary()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

