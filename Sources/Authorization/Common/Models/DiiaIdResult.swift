
import Foundation

public enum DiiaIdResult<Success, Failure> where Failure: Error {
    case success(Success)
    case failure(Failure)
    case canceled
    case close
}
