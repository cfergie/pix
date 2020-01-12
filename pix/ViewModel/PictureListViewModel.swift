import Foundation
import FoundationUtils

final class PictureListViewModel: ObservableObject {
    @Published var asyncPhotos: Async<Result<[Photo], Swift.Error>> = .initial

    private let photoService: PhotoService

    init(
        photoService: PhotoService = DependencyManager.shared.photoService
    ) {
        self.photoService = photoService
    }

    func search(for text: String) {
        self.photoService.search(for: text) { (result) in
            DispatchQueue
                .main
                .async {
                    self.asyncPhotos = .loaded(result)
            }
        }
    }
}
