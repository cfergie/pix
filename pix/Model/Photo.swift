import Foundation
import UIKit.UIScreen
import UIKit.UIColor
import UIColor_Hex_Swift

struct Photo: Equatable {
    let id: String
    let description: String?
    let color: UIColor
    private let width: Int
    private let height: Int
    private let imageComponents: URLComponents

    var aspectRatio: CGFloat {
        return CGFloat(width) / CGFloat(height)
    }

    init?(apiPhoto: APIPhoto) {
        guard
            let raw = apiPhoto.urls[PhotoSize.raw.rawValue],
            let imageComponents = URLComponents(string: raw.absoluteString) else {
                return nil
        }

        self.id = apiPhoto.id
        self.description = apiPhoto.description
        self.color = UIColor(apiPhoto.color)
        self.imageComponents = imageComponents
        self.width = apiPhoto.width
        self.height = apiPhoto.height
    }

    func image(
        forWidth width: CGFloat,
        scale: CGFloat = UIScreen.main.scale
    ) -> URL {
        // Docs: https://unsplash.com/documentation#example-image-use
        return self
            .imageComponents
            .adding(queryItem: URLQueryItem(name: "w", value: String(Int(width))))
            .adding(queryItem: URLQueryItem(name: "dpi", value: String(Int(scale))))
            .url!
    }
}


extension Dictionary {
    func setting(key: Key, to value: Value) -> [Key: Value] {
        var mutable = self
        mutable[key] = value
        return mutable
    }
}

enum PhotoSize: String {
    case full, regular, small, thumb, raw
}
