//
//  AppMover.swift
//  AppMover
//
//  Created by Oskar Groth on 2019-12-20.
//  Copyright © 2019 Oskar Groth. All rights reserved.
//

import AppKit
import Security

public struct AppMover {
    
    public enum AppName {
        /// CFBundleName from Info.plist
        /// This can be useful to prevent propogation of suffixes added by Archive Utility, e.g. "MyApp-1.app"
        case CFBundleName
        /// Name of currently running .app in its current location on disk, e.g. "MyApp.app" or "MyApp-1.app"
        case current
        /// Arbitrary name (excluding ".app" suffix)
        case custom(String)
        
        var string: String {
            switch self {
            case .CFBundleName:
                if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                    return name
                }
                fallthrough
            case .current:
                return (Bundle.main.bundleURL.lastPathComponent as NSString).deletingPathExtension
            case .custom(let name):
                return name
            }
        }
    }
    
    /// Moves the running app bundle into an appropriate "Applications" Folder if necessary.
    ///
    /// If set, `destinationName` specifies the name the app bundle should take when copied.
    public static func moveIfNecessary(destinationName: AppName = .current) {
        let fm = FileManager.default
        guard !Bundle.main.isInstalled,
            let applications = preferredInstallDirectory() else { return }
        
        let destinationUrl = applications.appendingPathComponent(destinationName.string + ".app")
        let needDestAuth = fm.fileExists(atPath: destinationUrl.path) && !fm.isWritableFile(atPath: destinationUrl.path)
        let needAuth = needDestAuth || !fm.isWritableFile(atPath: applications.path)
        
        // Activate app -- work-around for focus issues related to "scary file from
        // internet" OS dialog.
        if !NSApp.isActive {
            NSApp.activate(ignoringOtherApps: true)
        }
        
        let alert = NSAlert()
        alert.messageText = "Move to Applications folder"
        alert.informativeText = "\(Bundle.main.localizedName) needs to move to your Applications folder in order to work properly."
        if needAuth {
            alert.informativeText.append(" You need to authenticate with your administrator password to complete this step.")
        }
        alert.addButton(withTitle: "Move to Applications Folder")
        alert.addButton(withTitle: "Do Not Move")
        guard alert.runModal() == .alertFirstButtonReturn else {
            return
        }
        if needAuth {
            let result = authorizedInstall(from: Bundle.main.bundleURL, to: destinationUrl)
            guard !result.cancelled else { moveIfNecessary(); return }
            guard result.success else {
                NSApplication.shared.terminate(self)
                return
            }
        } else {
            if fm.fileExists(atPath: destinationUrl.path) {
                if AppMover.isApplicationAtUrlRunning(destinationUrl) {
                    NSWorkspace.shared.open(destinationUrl)
                    return
                } else {
                    guard (try? fm.trashItem(at: destinationUrl, resultingItemURL: nil)) != nil else {
                        return
                    }
                }
            }
            guard (try? fm.copyItem(at: Bundle.main.bundleURL, to: destinationUrl)) != nil else {
                return
            }
        }
        
        // Trash the original app
        _ = try? fm.removeItem(at: Bundle.main.bundleURL)
        
        relaunch(at: destinationUrl.path, completionCallback: {
            DispatchQueue.main.async {
                exit(0)
            }
        })
        
    }
    
    static func authorizedInstall(from sourceURL: URL, to destinationURL: URL) -> (cancelled: Bool, success: Bool) {
        guard destinationURL.representsBundle,
            destinationURL.isValid,
            sourceURL.isValid else {
            return (false, false)
        }
        return sourceURL.withUnsafeFileSystemRepresentation({ sourcePath -> (cancelled: Bool, success: Bool) in
            return destinationURL.withUnsafeFileSystemRepresentation({ destinationPath -> (cancelled: Bool, success: Bool) in
                guard let sourcePath = sourcePath, let destinationPath = destinationPath else { return (false, false) }
                let deleteCommand = "/bin/rm -rf '\(String(cString: destinationPath))'"
                let copyCommand = "/bin/cp -pR '\(String(cString: sourcePath))' '\(String(cString: destinationPath))'"
                guard let script = NSAppleScript(source: "do shell script \"\(deleteCommand) && \(copyCommand)\" with administrator privileges") else {
                    return (false, false)
                }
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                return ((error?[NSAppleScript.errorNumber] as? Int16) == -128, error == nil)
            })
        })
    }
    
    static func preferredInstallDirectory() -> URL? {
        let fm = FileManager.default
        let dirs = fm.urls(for: .applicationDirectory, in: .allDomainsMask)
        // Find Applications dir with the most apps that isn't system protected
        return dirs.map({ $0.resolvingSymlinksInPath() }).filter({ url in
            var isDir: ObjCBool = false
            fm.fileExists(atPath: url.path, isDirectory: &isDir)
            return isDir.boolValue && url.path != "/System/Applications"
        }).sorted(by: { left, right in
            return left.numberOfFilesInDirectory < right.numberOfFilesInDirectory
        }).last
    }
    
    static func isApplicationAtUrlRunning(_ url: URL) -> Bool {
        let url = url.standardized
        return NSWorkspace.shared.runningApplications.contains(where: {
            $0.bundleURL?.standardized == url
        })
    }
    
    public static func relaunch(at path: String, completionCallback: @escaping () -> Void) {
        let pid = ProcessInfo.processInfo.processIdentifier
        Process.runTask(command: "/usr/bin/xattr", arguments: ["-d", "-r", "com.apple.quarantine", path], completion: { _ in
            let waitForExitScript = "(while /bin/kill -0 \(pid) >&/dev/null; do /bin/sleep 0.1; done; /usr/bin/open \"\(path)\") &"
            Process.runTask(command: "/bin/sh", arguments: ["-c", waitForExitScript])
            completionCallback()
        })
    }
    
}
