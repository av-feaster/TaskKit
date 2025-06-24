//
//  TaskRegistration.swift
//  TaskKit
//
//  Created by Aman Verma on 24/06/25.
//

#if os(iOS) || os(tvOS)
import BackgroundTasks
#endif

@MainActor
internal final class TaskRegistration {
#if os(iOS) || os(tvOS)
    private let taskKit: TaskKit

    init(taskKit: TaskKit) {
        self.taskKit = taskKit
    }

    func registerRefreshTask(_ config: TaskKitConfiguration,
                             handler: @escaping @Sendable (BGTask) async -> Bool) {
        register(taskID: config.identifier + ".refresh", type: .refresh, asyncHandler: handler)
    }

    func registerRefreshTask(_ config: TaskKitConfiguration,
                             perform task: @escaping @Sendable () async -> Bool) {
        registerRefreshTask(config) { _ in await task() }
    }

    func registerProcessingTask(_ config: TaskKitConfiguration,
                                requiresNetwork: Bool = true,
                                requiresExternalPower: Bool = false,
                                handler: @escaping @Sendable (BGTask) async -> Bool) {
        register(taskID: config.identifier + ".processing",
                 type: .processing,
                 requiresNetwork: requiresNetwork,
                 requiresExternalPower: requiresExternalPower,
                 asyncHandler: handler)
    }

    func registerProcessingTask(_ config: TaskKitConfiguration,
                                requiresNetwork: Bool = true,
                                requiresExternalPower: Bool = false,
                                perform task: @escaping @Sendable () async -> Bool) {
        registerProcessingTask(config,
                               requiresNetwork: requiresNetwork,
                               requiresExternalPower: requiresExternalPower) { _ in await task() }
    }

    private func register(taskID: String,
                          type: TaskType,
                          requiresNetwork: Bool = true,
                          requiresExternalPower: Bool = false,
                          asyncHandler: @escaping @Sendable (BGTask) async -> Bool) {
        TaskLogger.log("Registering \(type) task: \(taskID)")
        
        taskKit.handlers[taskID] = { task in
            TaskLogger.log("Executing task: \(taskID)")
            
            task.expirationHandler = {
                TaskLogger.log("Task expired: \(taskID)")
                task.setTaskCompleted(success: false)
            }
            
            Task {
                let success = await asyncHandler(task)
                task.setTaskCompleted(success: success)
                TaskLogger.log("Task \(taskID) completed with success = \(success)")
            }
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskID, using: nil) { task in
            self.taskKit.handlers[taskID]?(task)
        }
    }
#endif
}
