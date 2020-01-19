import Foundation
//import FoundationUtils

public enum Async<Value> {
    case initial
    case loading(Value? = nil)
    case loaded(Value)
}

extension Async: Equatable where Value: Equatable {
}


final class PictureListViewModel: ObservableObject {
    @Published var asyncPhotos: Async<Result<[Photo], Swift.Error>> = .initial

    private let photoService: PhotoService
    private var latestRequest: Request?

    init(
        photoService: PhotoService = DependencyManager.shared.photoService
    ) {
        self.photoService = photoService
    }

    func search(for text: String) {
        self.asyncPhotos = .loading()
        self.photoService.search(for: text) { result in
            self.latestRequest = Request(text: text)
            DispatchQueue
                .main
                .async {
                    self.asyncPhotos = .loaded(result)
            }
        }
    }

    func fetchMore() {
        switch asyncPhotos {
        case .initial, .loading:
            return

        case .loaded(let old):
            guard let latestRequest = self.latestRequest else {
                return
            }
            let next = latestRequest.next
            asyncPhotos = .loading(old)
            self.photoService.search(for: next.text, page: next.page) { newResult in
                self.latestRequest = next
                DispatchQueue
                    .main
                    .async {
                        let combined = old.map({ oldPhotos in
                            return newResult
                                .map({ newPhotos in
                                    oldPhotos + newPhotos
                                })
                                .default(to: oldPhotos)
                        })
                        self.asyncPhotos = .loaded(combined)
                }
            }
        }
    }
}

extension PictureListViewModel {
    private struct Request {
        let text: String
        let page: Int

        var next: Request {
            return Request(text: text, page: page + 1)
        }

        init(text: String, page: Int = 1) {
            self.text = text
            self.page = page
        }
    }
}
