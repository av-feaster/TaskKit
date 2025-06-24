// The Swift Programming Language
// https://docs.swift.org/swift-book
#if os(iOS) || os(tvOS)
import BackgroundTasks
#endif

@MainActor
public final class TaskKit {
#if os(iOS) || os(tvOS)
    public var handlers: [String: (BGTask) -> Void] = [:]
    private lazy var registrar = TaskRegistration(taskKit: self)
    private let scheduler = TaskScheduler()
    private let canceller = TaskCancellation()
    
    public init() {
        validateInfoPlistConfiguration()
    }
    
    private func validateInfoPlistConfiguration() {
#if DEBUG
        var hasIssues = false
        
        // Check for UIBackgroundModes
        let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String] ?? []
        let requiredBackgroundModes = ["background-processing", "background-fetch"]
        
        let missingBackgroundModes = requiredBackgroundModes.filter { !backgroundModes.contains($0) }
        if !missingBackgroundModes.isEmpty {
            TaskLogger.showMissingBackgroundModes(missingBackgroundModes)
            hasIssues = true
        }
        
        // Check for BGTaskSchedulerPermittedIdentifiers
        let permittedIdentifiers = Bundle.main.infoDictionary?["BGTaskSchedulerPermittedIdentifiers"] as? [String] ?? []
        if permittedIdentifiers.isEmpty {
            TaskLogger.showMissingTaskIdentifiers()
            hasIssues = true
        }
        
        if !hasIssues {
            TaskLogger.showConfigurationSuccess()
        }
    
#endif
    }
    
    // MARK: - Registration
    public func registerRefreshTask(_ config: TaskKitConfiguration,
                                    handler: @escaping @Sendable (BGTask) async -> Bool) {
        validateTaskIdentifier(config.identifier)
        registrar.registerRefreshTask(config, handler: handler)
    }
    
    public func registerRefreshTask(_ config: TaskKitConfiguration,
                                    perform task: @escaping @Sendable () async -> Bool) {
        validateTaskIdentifier(config.identifier)
        registrar.registerRefreshTask(config, perform: task)
    }
    
    public func registerProcessingTask(_ config: TaskKitConfiguration,
                                       requiresNetwork: Bool = true,
                                       requiresExternalPower: Bool = false,
                                       handler: @escaping @Sendable (BGTask) async -> Bool) {
        validateTaskIdentifier(config.identifier)
        registrar.registerProcessingTask(config,
                                         requiresNetwork: requiresNetwork,
                                         requiresExternalPower: requiresExternalPower,
                                         handler: handler)
    }
    
    public func registerProcessingTask(_ config: TaskKitConfiguration,
                                       requiresNetwork: Bool = true,
                                       requiresExternalPower: Bool = false,
                                       perform task: @escaping @Sendable () async -> Bool) {
        validateTaskIdentifier(config.identifier)
        registrar.registerProcessingTask(config,
                                         requiresNetwork: requiresNetwork,
                                         requiresExternalPower: requiresExternalPower,
                                         perform: task)
    }
    
    private func validateTaskIdentifier(_ identifier: String) {
#if DEBUG
        let permittedIdentifiers = Bundle.main.infoDictionary?["BGTaskSchedulerPermittedIdentifiers"] as? [String] ?? []
        if !permittedIdentifiers.contains(identifier) {
            TaskLogger.showMissingTaskIdentifier(identifier)
        }
#endif
    }
    
    // MARK: - Scheduling
    public func scheduleRefreshTask(config: TaskKitConfiguration) {
        scheduler.scheduleRefreshTask(config: config)
    }
    
    public func scheduleProcessingTask(config: TaskKitConfiguration,
                                       requiresNetwork: Bool = true,
                                       requiresExternalPower: Bool = false) {
        scheduler.scheduleProcessingTask(config: config,
                                         requiresNetwork: requiresNetwork,
                                         requiresExternalPower: requiresExternalPower)
    }
    
    // MARK: - Cancellation
    public func cancelTask(id: String) {
        canceller.cancelTask(id: id)
    }
    
    public func cancelAll() {
        canceller.cancelAll()
    }
    
#if DEBUG
    public func pendingRequests() async -> [String] {
        await canceller.pendingIdentifiers()
    }
    
    // MARK: - Developer Helpers
    public static func printSetupInstructions() {
        TaskLogger.showSetupTutorial()
    }
#endif
#else
    // MARK: - macOS/tvOS stub implementation
    public init() {}
    public func registerRefreshTask(_ config: TaskKitConfiguration, handler: Any) {}
    public func registerRefreshTask(_ config: TaskKitConfiguration, perform task: Any) {}
    public func registerProcessingTask(_ config: TaskKitConfiguration, requiresNetwork: Bool = true, requiresExternalPower: Bool = false, handler: Any) {}
    public func registerProcessingTask(_ config: TaskKitConfiguration, requiresNetwork: Bool = true, requiresExternalPower: Bool = false, perform task: Any) {}
    public func scheduleRefreshTask(config: TaskKitConfiguration) {}
    public func scheduleProcessingTask(config: TaskKitConfiguration, requiresNetwork: Bool = true, requiresExternalPower: Bool = false) {}
    public func cancelTask(id: String) {}
    public func cancelAll() {}
#if DEBUG
    public func pendingRequests() async -> [String] { return [] }
    public static func printSetupInstructions() {}
#endif
#endif
}

