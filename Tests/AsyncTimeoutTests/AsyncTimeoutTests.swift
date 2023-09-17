import XCTest
@testable import AsyncTimeout

final class AsyncTimeoutTests: XCTestCase {

    // Test: Operation completing within the timeout
    func testOperationWithinTimeout() async throws {
        let result = try await AsyncTimeout.withTimeout(seconds: 2) {
            return "Success"
        }
        XCTAssertEqual(result, "Success")
    }

    // Test: Operation exceeding the timeout
    func testOperationExceedsTimeout() async {
        do {
            _ = try await AsyncTimeout.withTimeout(seconds: 2) {
                try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
                return "Failed"
            }
            XCTFail("Expected a timeout error but got none.")
        } catch AsyncTimeout.CustomError.timeout {
            // Expected timeout error.
        } catch {
            XCTFail("Received unexpected error: \(error).")
        }
    }

    // Test: Propagation of operation's error
    func testOperationErrorPropagation() async {
        do {
            _ = try await AsyncTimeout.withTimeout(seconds: 2) {
                throw NSError(domain: "TestError", code: 1, userInfo: nil)
            }
            XCTFail("Expected an NSError but got none.")
        } catch let error as NSError where error.domain == "TestError" && error.code == 1 {
            // Expected error.
        } catch {
            XCTFail("Received unexpected error: \(error).")
        }
    }
}
