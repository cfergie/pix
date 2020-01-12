import SwiftUI

struct PictureList: View {

    @ObservedObject private var viewModel: PictureListViewModel = PictureListViewModel()
    @State private var searchText: String = ""
    @State private var offset: CGFloat = 0 {
        didSet {
            print("\(offset)")
        }
    }
    @State private var isGestureActive: Bool = false

    var body: some View {
        VStack {
            TextField(
                "Search images",
                text: self.$searchText,
                onCommit: {
                    self.viewModel.search(for: self.searchText)
            })
                .disableAutocorrection(true)
            GeometryReader { geometry -> AnyView in
                switch self.viewModel.asyncPhotos {
                case .initial:
                    return AnyView(
                        Text("SEARCH FOR SOMETHING")
                            .background(Color.yellow)
                    )
                case .loading:
                    return AnyView(
                        Text("LOADING")
                            .background(Color.green)
                    )
                case .loaded(let result):
                    switch result {
                    case .success(let photos):
                        return AnyView(
                            ScrollView {
                                VStack(alignment: .center, spacing: 0) {
                                    ForEach(photos, id: \.id) { photo in
                                        Picture(photo: photo)
                                            .frame(
                                                width: geometry.size.width,
                                                height: geometry.size.width / photo.aspectRatio,
                                                alignment: .center
                                        )
                                    }
                                }
                                .frame(width: geometry.size.width)
                        })
                    case .failure(let error):
                        return AnyView(
                            Text(String(describing: error))
                                .background(Color.red)
                        )
                    }
                }
            }
        }
    }
}
