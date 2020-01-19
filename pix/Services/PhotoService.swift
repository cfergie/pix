import Foundation

protocol PhotoService: class {
    func search(for text: String, page: Int, withCompletion completion: @escaping (Result<[Photo], Swift.Error>) -> Void)
}

extension PhotoService {
    func search(for text: String, withCompletion completion: @escaping (Result<[Photo], Swift.Error>) -> Void) {
        self.search(for: text, page: 1, withCompletion: completion)
    }
}

final class Unsplash: PhotoService {

    private let unsplashKey: String
    private let networkingService: NetworkingService

    init(
        unsplashKey: String = Keys.unsplash,
        networkingService: NetworkingService = DependencyManager.shared.networkingService
    ) {
        self.unsplashKey = unsplashKey
        self.networkingService = networkingService
    }

    func search(for text: String, page: Int, withCompletion completion: @escaping (Result<[Photo], Swift.Error>) -> Void) {
        do {
            let urlString = "https://api.unsplash.com/search/photos"
            guard var urlComponents = URLComponents(string: urlString) else {
                throw Error.invalidURLComponents(urlString)
            }
            urlComponents.queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "query", value: text),
                URLQueryItem(name: "client_id", value: unsplashKey)
            ]
            guard let url = urlComponents.url else {
                throw Error.invalidURL(urlComponents)
            }

            self
                .networkingService
                .perform(request: URLRequest(url: url)) { (result: Result<APIResponse, Swift.Error>) in
                    completion(
                        result
                            .map({ $0.results })
                            .map({ $0.compactMap({ Photo(apiPhoto: $0) }) })
                    )
            }

        } catch let error {
            completion(.failure(error))
        }
    }
}

extension Unsplash {
    enum Error: Swift.Error {
        case invalidURLComponents(String)
        case invalidURL(URLComponents)
    }
}

