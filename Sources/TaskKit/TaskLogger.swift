//
//  TaskLogger.swift
//  TaskKit
//
//  Created by Aman Verma on 24/06/25.
//

import Foundation

#if DEBUG
public enum TaskLogger {
    @MainActor private static var hasShownSetupTutorial = false
    
    public static func log(_ message: @autoclosure () -> String) {
        print("[TaskKit] \(message())")
    }
    
    public static func warning(_ message: @autoclosure () -> String) {
        print("⚠️  [TaskKit] \(message())")
    }
    
    public static func error(_ message: @autoclosure () -> String) {
        print("❌ [TaskKit] \(message())")
    }
    
    public static func success(_ message: @autoclosure () -> String) {
        print("✅ [TaskKit] \(message())")
    }
    
    public static func nsLog(_ message: @autoclosure () -> NSString) {
        NSLog("[TaskKit] %@", message())
    }
    
    @MainActor public static func showSetupTutorial() {
        guard !hasShownSetupTutorial else { return }
        hasShownSetupTutorial = true
        
        print("📋 [TaskKit] Setup Tutorial")
        print("=" * 50)
        print("To use TaskKit, you need to configure your Info.plist:")
        print("")
        print("1️⃣ Add Background Modes:")
        print("   <key>UIBackgroundModes</key>")
        print("   <array>")
        print("       <string>background-processing</string>")
        print("       <string>background-fetch</string>")
        print("   </array>")
        print("")
        print("2️⃣ Add Task Identifiers:")
        print("   <key>BGTaskSchedulerPermittedIdentifiers</key>")
        print("   <array>")
        print("       <string>com.yourapp.refresh</string>")
        print("       <string>com.yourapp.processing</string>")
        print("   </array>")
        print("")
        print("3️⃣ Replace 'com.yourapp' with your actual bundle identifier")
        print("")
        print("💡 Tip: Use TaskKit.printSetupInstructions() to see this again")
        print("=" * 50)
    }
    
    @MainActor public static func showMissingBackgroundModes(_ missing: [String]) {
        warning("Missing UIBackgroundModes in Info.plist")
        print("   Add these to your Info.plist:")
        print("   <key>UIBackgroundModes</key>")
        print("   <array>")
        missing.forEach { mode in
            print("       <string>\(mode)</string>")
        }
        print("   </array>")
        showSetupTutorial()
    }
    
    @MainActor public static func showMissingTaskIdentifiers() {
        warning("Missing BGTaskSchedulerPermittedIdentifiers in Info.plist")
        print("   Add your task identifiers to Info.plist:")
        print("   <key>BGTaskSchedulerPermittedIdentifiers</key>")
        print("   <array>")
        print("       <string>com.yourapp.refresh</string>")
        print("       <string>com.yourapp.processing</string>")
        print("   </array>")
        showSetupTutorial()
    }
    
    public static func showMissingTaskIdentifier(_ identifier: String) {
        warning("Task identifier '\(identifier)' not found in BGTaskSchedulerPermittedIdentifiers")
        print("   Add this to your Info.plist:")
        print("   <string>\(identifier)</string>")
    }
    
    public static func showHighIntervalWarning(_ interval: TimeInterval) {
        warning("Refresh task interval is high (\(interval) seconds)")
        print("   Consider using shorter intervals (≤ 15 minutes) for better background execution")
    }
    
    public static func showConfigurationSuccess() {
        success("TaskKit configuration validated successfully!")
    }
}

// Helper extension for string repetition
private extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
#else
public enum TaskLogger {
    public static func log(_ message: @autoclosure () -> String) { }
    public static func warning(_ message: @autoclosure () -> String) { }
    public static func error(_ message: @autoclosure () -> String) { }
    public static func success(_ message: @autoclosure () -> String) { }
    public static func showSetupTutorial() { }
    public static func showMissingBackgroundModes(_ missing: [String]) { }
    public static func showMissingTaskIdentifiers() { }
    public static func showMissingTaskIdentifier(_ identifier: String) { }
    public static func showHighIntervalWarning(_ interval: TimeInterval) { }
    public static func showConfigurationSuccess() { }
}
#endif
