import Foundation

struct APIResponse<Value: Sendable>: Sendable {

    let value: Value
    let statusCode: Int

    let headers: [String: String]
    func header(_ field: String) -> String? {
        headers[field.lowercased()]
    }
}
