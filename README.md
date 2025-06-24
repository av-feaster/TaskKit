//
//  README.md
//  TaskKit
//
//  Created by Aman Verma on 24/06/25.
//

# TaskKit

A Swift package for managing iOS background tasks using the BackgroundTasks framework. TaskKit provides a clean, type-safe API for registering, scheduling, and managing background refresh and processing tasks.

## Features

- 🚀 **Simple API**: Easy-to-use methods for background task management
- 🔄 **Background Refresh Tasks**: Schedule app refresh tasks for data updates
- ⚙️ **Background Processing Tasks**: Handle long-running background operations
- 🛡️ **Type Safety**: Fully typed configuration and handlers
- �� **Platform Support**: iOS 13+, tvOS 13+, macOS 10.15+ (with platform-specific features)
- �� **Debug Support**: Built-in logging and debugging utilities
- ⚠️ **Smart Warnings**: Compiler warnings for potentially problematic configurations

## Requirements

- iOS 13.0+ / tvOS 13.0+ / macOS 10.15+
- Swift 6.1+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add TaskKit to your project in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/TaskKit.git", from: "1.0.0")
]
```

## Quick Start

### 1. Initialize TaskKit

```swift
import TaskKit

let taskKit = TaskKit()
```

### 2. Register Background Tasks

```swift
// Register a refresh task
taskKit.registerRefreshTask(
    TaskKitConfiguration(identifier: "com.yourapp.refresh", interval: 15 * 60)
) { task in
    // Your refresh logic here
    await refreshData()
    return true // Return true if successful
}

// Register a processing task
taskKit.registerProcessingTask(
    TaskKitConfiguration(identifier: "com.yourapp.processing", interval: 30 * 60),
    requiresNetwork: true,
    requiresExternalPower: false
) { task in
    // Your processing logic here
    await processData()
    return true
}
```

### 3. Schedule Tasks

```swift
// Schedule the tasks
taskKit.scheduleRefreshTask(config: refreshConfig)
taskKit.scheduleProcessingTask(config: processingConfig)
```

### 4. Handle Task Cancellation

```swift
// Cancel specific task
taskKit.cancelTask(id: "com.yourapp.refresh")

// Cancel all tasks
taskKit.cancelAll()
```

## API Reference

### TaskKitConfiguration

```swift
public struct TaskKitConfiguration {
    public let identifier: String
    public let interval: TimeInterval
    
    public init(identifier: String, interval: TimeInterval = 15 * 60)
}
```

**Parameters:**
- `identifier`: Unique identifier for the background task
- `interval`: Time interval in seconds (default: 15 minutes)

### Main Methods

#### Registration
- `registerRefreshTask(_:handler:)` - Register a refresh task with BGTask handler
- `registerRefreshTask(_:perform:)` - Register a refresh task with simple closure
- `registerProcessingTask(_:requiresNetwork:requiresExternalPower:handler:)` - Register a processing task with BGTask handler
- `registerProcessingTask(_:requiresNetwork:requiresExternalPower:perform:)` - Register a processing task with simple closure

#### Scheduling
- `scheduleRefreshTask(config:)` - Schedule a refresh task
- `scheduleProcessingTask(config:requiresNetwork:requiresExternalPower:)` - Schedule a processing task

#### Cancellation
- `cancelTask(id:)` - Cancel a specific task
- `cancelAll()` - Cancel all scheduled tasks

#### Debug (DEBUG builds only)
- `pendingRequests() async -> [String]` - Get list of pending task identifiers

## Background Tasks Setup

### 1. Add Background Modes

Add the following to your `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
    <string>background-fetch</string>
</array>
```

### 2. Register Background Task Identifiers

Add your task identifiers to `Info.plist`:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.yourapp.refresh</string>
    <string>com.yourapp.processing</string>
</array>
```

### 3. Handle Background Task Launch

In your `AppDelegate` or `SceneDelegate`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // TaskKit handles all BGTaskScheduler registration internally
    // Just initialize your TaskKit instance
    let taskKit = TaskKit()
    
    // Register your tasks
    taskKit.registerRefreshTask(refreshConfig) { task in
        // Your refresh logic here
        return true
    }
    
    return true
}
```

**Note:** TaskKit automatically handles the `BGTaskScheduler.shared.register()` calls for you. You only need to use TaskKit's registration methods.

## Best Practices

### 1. Task Intervals
- Use intervals of 15 minutes or less for refresh tasks
- Longer intervals may be throttled by iOS
- The package includes compiler warnings for intervals > 15 minutes

### 2. Task Duration
- Keep refresh tasks under 30 seconds
- Processing tasks can run longer but should complete within reasonable time
- Always call `task.setTaskCompleted(success:)` when done

### 3. Error Handling
```swift
taskKit.registerRefreshTask(config) { task in
    do {
        try await performRefresh()
        task.setTaskCompleted(success: true)
        return true
    } catch {
        task.setTaskCompleted(success: false)
        return false
    }
}
```

### 4. Network and Power Requirements
- Only set `requiresNetwork: true` if your task actually needs network
- Only set `requiresExternalPower: true` for power-intensive operations
- These requirements affect when iOS will run your tasks

## Platform Support

- **iOS/tvOS**: Full BackgroundTasks framework support
- **macOS**: Stub implementations (BackgroundTasks not available on macOS)

## Debugging

TaskKit includes built-in logging for DEBUG builds:

```swift
// Enable debug logging
#if DEBUG
let pendingTasks = await taskKit.pendingRequests()
print("Pending tasks: \(pendingTasks)")
#endif
```

## Example Usage

```swift
import TaskKit

class AppBackgroundTaskManager {
    private let taskKit = TaskKit()
    
    func setupBackgroundTasks() {
        // Configure refresh task
        let refreshConfig = TaskKitConfiguration(
            identifier: "com.yourapp.data-refresh",
            interval: 15 * 60 // 15 minutes
        )
        
        // Register and schedule refresh task
        taskKit.registerRefreshTask(refreshConfig) { task in
            await self.refreshAppData()
            return true
        }
        taskKit.scheduleRefreshTask(config: refreshConfig)
        
        // Configure processing task
        let processingConfig = TaskKitConfiguration(
            identifier: "com.yourapp.data-processing",
            interval: 30 * 60 // 30 minutes
        )
        
        // Register and schedule processing task
        taskKit.registerProcessingTask(
            processingConfig,
            requiresNetwork: true,
            requiresExternalPower: false
        ) { task in
            await self.processAppData()
            return true
        }
        taskKit.scheduleProcessingTask(config: processingConfig)
    }
    
    private func refreshAppData() async {
        // Implement your refresh logic
    }
    
    private func processAppData() async {
        // Implement your processing logic
    }
}
```

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]

## Support

For support, please open an issue on GitHub or contact [your contact information].
