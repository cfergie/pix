import Foundation

protocol NetworkingService {
    func perform(request: URLRequest, withCompletion completion: @escaping (Result<Data, Swift.Error>) -> Void)
    func cancel(request: URLRequest)
}

extension NetworkingService {
    func fetch(url: URL, withCompletion completion: @escaping (Result<Data, Swift.Error>) -> Void) -> URLRequest {
        let request = URLRequest(url: url)
        self.perform(request: request, withCompletion: completion)
        return request
    }
}

final class DefaultNetworkingService: NetworkingService {

    private let urlSession: URLSession
    private var requests: [URLRequest: URLSessionDataTask] = [:]

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    convenience init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: config)
        self.init(urlSession: session)
    }

    func perform(request: URLRequest, withCompletion completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            _ = self.requests.removeValue(forKey: request)
            do {
                if let error = error {
                    throw error
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw Error.nonHTTPResponse
                }

                guard httpResponse.statusCode < 400 else {
                    throw Error.httpError(httpResponse.statusCode)
                }

                guard let data = data else {
                    throw Error.noData
                }

                completion(.success(data))

            } catch let error {
                completion(.failure(error))
            }
        }
        dataTask.resume()

        requests[request] = dataTask
    }

    func cancel(request: URLRequest) {
        requests[request]?.cancel()
    }
}

extension DefaultNetworkingService {
    enum Error: Swift.Error {
        case nonHTTPResponse
        case httpError(Int)
        case noData
        case invalidImageData
    }
}
