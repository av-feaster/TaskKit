//
//  TaskCancellation.swift
//  TaskKit
//
//  Created by Aman Verma on 24/06/25.
//

#if os(iOS) || os(tvOS)
import BackgroundTasks
#endif

@MainActor
@available(iOS 13.0, tvOS 13.0, *)
internal final class TaskCancellation {
#if os(iOS) || os(tvOS)
    func cancelTask(id: String) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: id)
        TaskLogger.log("Cancelled task: \(id)")
    }

    func cancelAll() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        TaskLogger.log("Cancelled all tasks")
    }

    #if DEBUG
    
    func pendingIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            BGTaskScheduler.shared.getPendingTaskRequests { requests in
                Task {
                    continuation.resume(returning: requests.map(\.identifier))
                }
            }
        }
    }
    #endif
#else
    func cancelTask(id: String) {
        TaskLogger.log("BackgroundTasks not available on this platform")
    }
    func cancelAll() {
        TaskLogger.log("BackgroundTasks not available on this platform")
    }
    #if DEBUG
    @MainActor
    func pendingIdentifiers() async -> [String] {
        return []
    }
    #endif
#endif
}
