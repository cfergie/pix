import Foundation

extension NetworkingService {
    func perform<T: Decodable>(request: URLRequest, withCompletion completion: @escaping (Result<T, Swift.Error>) -> Void) {
        self.perform(request: request) {
            completion($0.map {
                try JSONDecoder().decode(T.self, from: $0)
            })
        }
    }
}
