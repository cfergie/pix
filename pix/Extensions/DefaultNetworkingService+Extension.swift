import Foundation
import SwiftUIComponents
import UIKit.UIImage

extension DefaultNetworkingService: ImageFetchingService {
    func perform(request: URLRequest, withCompletion completion: @escaping (Result<UIImage, Swift.Error>) -> Void) {
        self.perform(request: request) { (result: Result<Data, Swift.Error>) in
            completion(result.map { data in

                guard let image = UIImage(data: data) else {
                    throw Error.invalidImageData
                }

                return image
            })
        }
    }
}
