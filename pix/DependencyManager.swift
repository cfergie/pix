import Foundation
import SwiftUIComponents

final class DependencyManager {

    static let shared: DependencyManager = DependencyManager()

    let networkingService: NetworkingService
    let imageFetchingService: ImageFetchingService
    let photoService: PhotoService

    init(
        networkingService: NetworkingService,
        imageFetchingService: ImageFetchingService,
        photoService: PhotoService
    ) {
        self.networkingService = networkingService
        self.imageFetchingService = imageFetchingService
        self.photoService = photoService
    }

    convenience init() {
        let defaultNetworkingService = DefaultNetworkingService()
        self.init(
            networkingService: defaultNetworkingService,
            imageFetchingService: defaultNetworkingService,
            photoService: Unsplash(networkingService: defaultNetworkingService)
        )
    }
}
