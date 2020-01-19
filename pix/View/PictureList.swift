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
                case .loading(let partialResult):
                    switch partialResult {
                    case .none:
                        return AnyView(Text("LOADING. NO DATA").background(Color.purple))
                    case .some(let result):
                        switch result {
                        case .failure:
                            return AnyView(Text("LOADING. PREVIOUS DATA FAILED").background(Color.red))
                        case .success(let partial):
                            return AnyView(
                                VStack {
                                    Text("LOADING.... ! HEIGHT: \(self.contentSize.height) OFFSET: \(self.offset)").background(Color.green)
                                    List(photos: partial, itemWidth: geometry.size.width, offset: self.$offset, contentSize: self.$contentSize)
                                }

                            )
                        }
                    }
                case .loaded(let result):
                    switch result {
                    case .success(let photos):
                        return AnyView(
                            VStack {
                                Text("LOADED! HEIGHT: \(self.contentSize.height) OFFSET: \(self.offset). VIEW HEIGHT: \(geometry.size.height)").background(Color.pink)
                                Fetch(offset: self.offset, height: self.contentSize.height) {
                                    self.viewModel.fetchMore()
                                }
                                List(photos: photos, itemWidth: geometry.size.width, offset: self.$offset, contentSize: self.$contentSize)
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

struct List: View {
    let photos: [Photo]
    let itemWidth: CGFloat
    @Binding var offset: CGFloat
    @Binding var contentSize: CGSize

    var body: some View {
        ScrollView(contentOffset: self.$offset) {
            Measure(contentSize: self.$contentSize) {
                VStack(alignment: .center, spacing: 0) {
                    ForEach(self.photos, id: \.id) { photo in
                        Picture(photo: photo)
                            .frame(
                                width: self.itemWidth,
                                height: self.itemWidth / photo.aspectRatio,
                                alignment: .center
                        )
                    }
                }
            }
        }
    }
}

struct Fetch: View {

    init(offset: CGFloat, height: CGFloat, fetchMore: () -> Void) {
        if abs(offset) / height > 0.7 {
            fetchMore()
        }
    }

    var body: some View {
        return EmptyView()
    }
}
