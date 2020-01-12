import SwiftUI

struct URLImage: View {
    @State private var image: UIImage? = nil
    private let url: URL
    private let urlSession: URLSession

    init(
        url: URL,
        urlSession: URLSession = .longCache
    ) {
        self.url = url
        self.urlSession = urlSession
    }


    var body: some View {
        return ZStack {
            Color.gray.onAppear {
                self
                .urlSession
                .dataTask(with: self.url) { self.image = $0 }
                .resume()
            }
            Inner(image: image)
        }
    }
}


private struct Inner: View {
    private let image: UIImage?

    init(image: UIImage?) {
        self.image = image
    }

    var body: some View {

        return image.map {
            AnyView(Image(uiImage: $0)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .background(Color.pink))
        } ?? AnyView(EmptyView())

    }
}
