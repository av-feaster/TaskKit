//
//  TaskScheduler.swift
//  TaskKit
//
//  Created by Aman Verma on 24/06/25.
//

#if os(iOS) || os(tvOS)
import BackgroundTasks
#endif

@MainActor
@available(iOS 13.0, tvOS 13.0, *)
internal final class TaskScheduler {
#if os(iOS) || os(tvOS)
    func scheduleRefreshTask(config: TaskKitConfiguration) {
        let request = BGAppRefreshTaskRequest(identifier: config.identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: config.interval)
        submit(request: request)
    }

    func scheduleProcessingTask(config: TaskKitConfiguration,
                                requiresNetwork: Bool = true,
                                requiresExternalPower: Bool = false) {
        let request = BGProcessingTaskRequest(identifier: config.identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: config.interval)
        request.requiresNetworkConnectivity = requiresNetwork
        request.requiresExternalPower = requiresExternalPower
        submit(request: request)
    }

    private func submit(request: BGTaskRequest) {
        do {
            try BGTaskScheduler.shared.submit(request)
            TaskLogger.log("Scheduled task request: \(request.identifier)")
        } catch {
            TaskLogger.log("Failed to schedule \(request.identifier): \(error)")
        }
    }
#else
    func scheduleRefreshTask(config: TaskKitConfiguration) {
        TaskLogger.log("BackgroundTasks not available on this platform")
    }
    func scheduleProcessingTask(config: TaskKitConfiguration,
                                requiresNetwork: Bool = true,
                                requiresExternalPower: Bool = false) {
        TaskLogger.log("BackgroundTasks not available on this platform")
    }
#endif
}
