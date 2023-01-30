// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let todosResponse = try? newJSONDecoder().decode(TodosResponse.self, from: jsonData)

import Foundation

// MARK: - TodosResponse
struct TodosResponse: Codable {
    let data: [Todo]?
    let meta: Meta?
    let message: String?
}

struct BaseListResponse<T: Codable>: Codable {
    let data: [T]?
    let meta: Meta?
    let message: String?
}

var data1 = BaseListResponse<Todo>.init(data: [Todo.init(id: 1,title: "titleTest", isDone: true, createdAt: nil, updatedAt: nil)], meta: nil, message: nil)

struct BaseResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
}

// MARK: - Datum
struct Todo: Codable {
    let id: Int?
    var title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}
