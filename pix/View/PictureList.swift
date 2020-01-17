import SwiftUI
import struct SwiftUIComponents.ScrollView
import class UIKit.UIScrollView

struct PictureList: View {

    @ObservedObject private var viewModel: PictureListViewModel = PictureListViewModel()
    @State private var searchText: String = ""
    @State private var offset: CGFloat = 0
    @State private var contentSize: CGSize = .zero

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
                            .onAppear {
                                self.viewModel.search(for: "disco")
                        }
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
                            VStack {
                                Text("HEIGHT: \(self.contentSize.height) OFFSET: \(self.offset)").background(Color.pink).onAppear {
                                    print("APPEAR")
                                }
                                ScrollView(contentOffset: self.$offset) {
                                    Measure(contentSize: self.$contentSize) {
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
                                    }
                                }
                            }

                        )
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
