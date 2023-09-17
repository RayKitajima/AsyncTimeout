
import Foundation

@available(iOS 13.0.0, *)
@available(macOS 10.15.0, *)
public struct AsyncTimeout {
    actor OperationState {
        private(set) var isCompleted = false

        func markAsCompleted() {
            isCompleted = true
        }
    }

    enum CustomError: Error {
        case timeout
    }

    static func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        var result: T?
        var capturedError: Error?
        let operationState = OperationState()

        await withTaskGroup(of: (T?, Error?).self) { group in
            group.addTask {
                do {
                    let value = try await operation()
                    await operationState.markAsCompleted()
                    return (value, nil)
                } catch {
                    await operationState.markAsCompleted()
                    return (nil, error)
                }
            }

            group.addTask {
                do {
                    let checkInterval = UInt64(0.1 * Double(NSEC_PER_SEC))
                    let totalChecks = Int(seconds / 0.1)
                    for _ in 0..<totalChecks {
                        if await operationState.isCompleted {
                            // If the operation is completed, return early
                            return (nil, nil)
                        }
                        try await Task.sleep(nanoseconds: checkInterval)
                    }

                    if !(await operationState.isCompleted) {
                        return (nil, CustomError.timeout)
                    } else {
                        return (nil, nil)
                    }
                } catch {
                    return (nil, error)
                }
            }

            for await (completedValue, potentialError) in group {
                if let error = potentialError, result == nil {
                    capturedError = error
                }

                if let value = completedValue, result == nil {
                    result = value
                }
            }
        }

        if let error = capturedError {
            throw error
        }

        return result!
    }
}
