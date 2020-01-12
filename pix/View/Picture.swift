import SwiftUI
import SwiftUIComponents

struct Picture: View {
    private let photo: Photo

    init(photo: Photo) {
        self.photo = photo
    }

    var body: some View {
        GeometryReader { geometry in
            RemoteImage(
                url: self.photo.image(forWidth: geometry.size.width),
                loading: Color(self.photo.color),
                failure: .red,
                imageFetchingService: DependencyManager.shared.imageFetchingService
            )
        }
    }
}

