//
//  TodosAPI.swift
//  TodoApp
//
//  Created by user on 2022/12/26.
//

import Foundation
import MultipartForm

enum TodosAPI {
    static let version = "v1"
    
    #if DEBUG // 디버그
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
    #else // 릴리즈
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version
    #endif
    
    enum ApiError: Error {
        case noContent
        case decodingError
        case jsonEncoding
        case unauthorized
        case notAllowedUrl
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        
        var info: String {
            switch self {
            case .noContent: return "데이터가 없습니다"
            case .decodingError: return "디코딩 에러"
            case .jsonEncoding: return "유효한 json형식이 아닙니다"
            case .unauthorized: return "인증오류"
            case .notAllowedUrl: return "올바른 url형식이 아닙니다."
            case let .badStatus(code): return "에러 상태코드: \(code)"
            case let .unknown(err): return "알 수 없는 에러 \(err)"
            }
        }
    }
    
    
}
