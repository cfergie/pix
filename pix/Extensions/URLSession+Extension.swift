import Foundation

extension URLSession {
    static let longCache: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let cache = URLCache(memoryCapacity: 100 * 1024, diskCapacity: 100 * 1024)
        config.urlCache = cache
        return URLSession(configuration: config)
    }()
}
