import Foundation

struct APIResponse: Decodable {
    let total: Int
    let total_pages: Int
    let results: [APIPhoto]
}
