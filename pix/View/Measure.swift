import Foundation
import SwiftUI

struct Measure<Content: View>: View {
    @Binding var contentSize: CGSize
    let content: () -> Content

    var body: some View {
        self.content().modifier(Modifier(contentSize: self.$contentSize))
    }
}


private struct Modifier: ViewModifier {
    @Binding var contentSize: CGSize

    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color
                .clear
                .onAppear {
                    self.contentSize = proxy.size
            }
        })
    }
}


