import Foundation

struct APIPhoto: Decodable {
    let id: String
    let description: String?
    let created_at: String
    let updated_at: String
    let promoted_at: String?
    let width: Int
    let height: Int
    let color: String
    let urls: [String: URL]
}
