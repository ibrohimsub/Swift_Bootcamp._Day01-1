import Foundation
print("Enter a code:")
if let input = readLine(), let number = Int(input), number > 0 {
    let result = getResponseType(number)
    switch result {
    case .success(let message):
        print("Success: \(input), Message: \(message)")
    case .error(let code, let title, let description, let type):
        print(type)
        print("   Code: \(code)")
        print("   Title: \(title)")
        print("   Descriprion: \(description)")
    }
} else {
    print("Couldn't parse a code. Please, try again")
}

enum ResponseType {
    case success(String)
    case error(Int, String, String, String)
}

enum ErrorCode: Int {
    case notFound = 404
    case unIdentifiedUser = 1000
    case expiredSession = 1001
    case noConnection = 1002
    case verificationFailed = 1003
}

func getResponseType(_ statusCode: Int) -> ResponseType {
    switch statusCode {
    case 200, 201:
        return .success("The request processed successfully")
    case 400...599:
        if ErrorCode.notFound.rawValue == 404 {
            return .error(ErrorCode.notFound.rawValue, "not found", "Page not found", "NotFoundError")
        } else {
            return .error(statusCode, "Error code: \(statusCode)", "Unknown error. Please, try again later", "Error")
        }
    case 1000...1003:
        switch statusCode {
        case ErrorCode.unIdentifiedUser.rawValue:
            return .error(ErrorCode.unIdentifiedUser.rawValue, "The user is not identified", "The user is not identified. Try later", "NoUserError")
        case ErrorCode.expiredSession.rawValue:
            return .error(ErrorCode.expiredSession.rawValue, "The session is expired", "The session is expired. Try later", "ExpiredError")
        case ErrorCode.noConnection.rawValue:
            return .error(ErrorCode.noConnection.rawValue, "No connection", "There is no internet connection. Try later.", "NoConnectionError")
        default:
            return .error(ErrorCode.verificationFailed.rawValue, "The device has failed the verification", "The device has failed the verification. Try later", "NoVerificationError")
        }
    default:
        return .error(statusCode, "Error code: \(statusCode)", "Unknown error. Please, try again later", "Error")
    }
}
