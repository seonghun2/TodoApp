//
//  TodosAPI+Closure.swift
//  TodoApp
//
//  Created by user on 2022/12/27.
//

import Foundation
import MultipartForm

extension TodosAPI {
    //모든 할일 목록 가져오기
    static func fetchTodos(page: Int = 2, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        // make urlRequest
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    let todos = listResponse.data
                    
                    //상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos, !todos.isEmpty else {
                        return completion(.failure(ApiError.noContent))
                    }
                    
                    completion(.success(listResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    //특정 할일 가져오기
    static func fetchATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // make urlRequest
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    //할일 검색하기
    static func searchTodos(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        // make urlRequest
        //let urlString = baseURL + "/todos/search" + "?query=\(searchTerm))" + "%page=\(page)"
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm, "page": "\(page)"])
        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "query", value: searchTerm),
//            URLQueryItem(name: "page", value: "\(page)")
//        ]
        
        guard let url = requestUrl else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    let todos = listResponse.data
                    
                    //상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos, !todos.isEmpty else {
                        return completion(.failure(ApiError.noContent))
                    }
                    
                    completion(.success(listResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    /// 할일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func addATodo(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // make urlRequest
        let urlString = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        print("form.contentType: \(form.contentType)")
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = form.bodyData
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    /// 할일 추가하기 - JSON
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func addATodoJson(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // make urlRequest
        let urlString = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.decodingError))
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    /// 할일 수정하기 - JSON
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func editTodoJson(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // make urlRequest
        let urlString = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.decodingError))
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    /// 할일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func editTodo (id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // make urlRequest
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    /// 할일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답결과
    static func deleteATodo (id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        print(#function, "id = \(id)")
        // make urlRequest
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
            case 204:
                return completion(.failure(ApiError.noContent))
                
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    /// 할일 추가 후 모든 할일 가져오기
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodos(title: String, isDone: Bool = false, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        self.addATodo(title: title) { result in
            switch result {
            case .success(_):
                self.fetchTodos {
                    switch $0 {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    /// 클로저 기반 api 동시 처리
    /// 선택된 할일들 삭제
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 id
    ///   - completion: 실제 삭제가 완료된 id
    static func deleteSelectedTodos(selectedTodoIds: [Int], completion: @escaping ([Int]) -> Void) {
        
        let group = DispatchGroup()
        
        var deletedTodoIds: [Int] = []
        
        selectedTodoIds.forEach { aTodoId in
            
            //디스패치 그룹에 넣음
            group.enter()
            self.deleteATodo(id: aTodoId) { result in
                switch result {
                case .success(let response):
                    //삭제된 아이디를 배열에 넣는다
                    if let todoId = response.data?.id {
                        deletedTodoIds.append(todoId)
                        print("inner deletedATodo - success: \(todoId)")
                    }
                case .failure(let failure):
                    print("inner deletedATodo - failure: \(failure)")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(deletedTodoIds)
        }
    }
    
    /// 클로저 기반 api 동시 처리
    /// 선택된 할일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 id
    ///   - completion: 응답 결과
    static func fetchSelectedTodos(selectedTodoIds: [Int], completion: @escaping (Result<[Todo], ApiError>) -> Void) {
        
        let group = DispatchGroup()
        
        // 가져온 할일들
        var fetchedTodos: [Todo] = [Todo]()
        
        // 에러들
        var apiErrors: [ApiError] = []
        
        // 응답 결과들
        //var apiResults = [Int : Result<BaseResponse<Todo>, ApiError>]()
        
        selectedTodoIds.forEach { aTodoId in
            
            //디스패치 그룹에 넣음
            group.enter()
            
            self.fetchATodo(id: aTodoId) { result in
                switch result {
                case .success(let response):
                    // 가져온 할일을 가져온 할일 배열에 넣는다
                    if let todo = response.data {
                        fetchedTodos.append(todo)
                        print("inner deletedATodo - success: \(todo)")
                    }
                case .failure(let failure):
                    apiErrors.append(failure)
                    print("inner deletedATodo - failure: \(failure)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            
            if !apiErrors.isEmpty {
                if let firstError = apiErrors.first {
                    completion(.failure(firstError))
                    return
                }
            }
            completion(.success(fetchedTodos))
        }
    }
}
