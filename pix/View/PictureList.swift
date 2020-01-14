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
                                Text("OFFSET: \(self.offset)").background(Color.pink)
                                ScrollView(contentOffset: self.$offset) {
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

struct ScrollView<Content: View>: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat
    let content: Content

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        contentOffset: Binding<CGFloat>,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showIndicators = showsIndicators
        self._contentOffset = contentOffset
        self.content = content()
    }

    private func calculateOffset(inner: GeometryProxy, outer: GeometryProxy) -> CGFloat {
        if self.axes == .horizontal {
            return inner.frame(in: .global).origin.x - outer.frame(in: .global).origin.x
        } else {
            return inner.frame(in: .global).origin.y - outer.frame(in: .global).origin.y
        }
    }

    var body: some View {
        GeometryReader { outerGeometry in
            SwiftUI.ScrollView(
                self.axes,
                showsIndicators: self.showIndicators
            ) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    self.content
                    GeometryReader { innerGeometry in
                        Color
                            .clear
                            .preference(
                                key: Offset.self,
                                value: self.calculateOffset(inner: innerGeometry, outer: outerGeometry)
                        )
                    }.onPreferenceChange(Offset.self) { value in
                        self.contentOffset = value
                    }
                }
            }.background(Color.pink)
        }
    }
}

struct Offset: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
