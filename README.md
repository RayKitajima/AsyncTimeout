
# AsyncTimeout

A Swift utility that provides a timeout mechanism for asynchronous operations using the new async/await syntax introduced in Swift 5.5.

## Features:
- Compatibility with iOS 13.0+ and macOS 10.15+
- Uses Swift's new concurrency features such as `actor` and `TaskGroup`
- Throws a `timeout` error if the operation doesn't complete within the specified timeout.

## How to Use:

1. Ensure that you're using Swift 5.5 or later and targeting at least iOS 13.0 or macOS 10.15.
2. Integrate the `AsyncTimeout` structure into your project.
3. Use the static `withTimeout` function to wrap the async operation that you want to time out.

### Example:

```swift
do {
    let result: YourReturnType = try await AsyncTimeout.withTimeout(seconds: 5) {
        return try await someAsyncFunc()
    }
} catch AsyncTimeout.CustomError.timeout {
    print("The operation timed out!")
} catch {
    print("An error occurred: \(error.localizedDescription)")
}
```

## Details:

### Structs & Enums:

- `AsyncTimeout`: The main struct containing the timeout logic.
- `OperationState`: An actor that tracks if the operation has been completed. It's used to safely handle state across potentially concurrent code.
- `CustomError`: An enum that has a `timeout` case, representing a timeout error.

### Main Function:

- `withTimeout(seconds:operation:)`: This function takes a timeout interval (in seconds) and an async operation. If the operation doesn't complete within the given timeout, it throws a timeout error.

## Notes:

- The utility employs a polling mechanism to check if the operation has completed. The current check interval is set at 0.1 seconds. This might lead to a maximum delay of 0.1 seconds more than the specified timeout.

## Disclaimer:

- The function assumes that the provided async operation will complete successfully, i.e., the result is forcefully unwrapped at the end (`result!`). It's essential to ensure the operation doesn't result in a nil value, or it will crash.

