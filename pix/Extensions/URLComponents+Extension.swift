import Foundation

extension URLComponents {
    func adding(queryItem: URLQueryItem) -> URLComponents {
        var mutable = self
        let existing = mutable.queryItems ?? []
        mutable.queryItems = existing.appending(queryItem)

        return mutable
    }
}


