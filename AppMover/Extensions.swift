//
//  Extensions.swift
//  AppMover
//
//  Created by Oskar Groth on 2019-12-22.
//  Copyright © 2019 Oskar Groth. All rights reserved.
//

import Cocoa
import Foundation

extension URL {
    
    var representsBundle: Bool {
        pathExtension == "app"
    }
    
    var isValid: Bool {
        !path.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var numberOfFilesInDirectory: Int {
        (try? FileManager.default.contentsOfDirectory(atPath: path))?.count ?? 0
    }
    
}

extension Bundle {
    
    var localizedName: String {
        NSRunningApplication.current.localizedName ?? "The App"
    }
    
    var isInstalled: Bool {
        NSSearchPathForDirectoriesInDomains(.applicationDirectory, .allDomainsMask, true).contains(where: { $0.hasPrefix(bundlePath)
        }) || bundlePath.split(separator: "/").contains("Applications")
    }
    
    func copy(to url: URL) throws {
        try FileManager.default.copyItem(at: bundleURL, to: url)
    }
    
}

extension Process {
    
    static func runTask(command: String, arguments: [String] = [], completion: ((Int32) -> Void)? = nil) {
        let task = Process()
        task.launchPath = command
        task.arguments = arguments
        task.terminationHandler = { task in
            completion?(task.terminationStatus)
        }
        task.launch()
    }
    
}
