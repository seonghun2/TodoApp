//
//  TodosAPI+Rx.swift
//  TodoApp
//
//  Created by user on 2022/12/27.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa

extension TodosAPI {
    
    //모든 할일 목록 가져오기
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        // make urlRequest
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.notAllowedUrl
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    
                    //상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos, !todos.isEmpty else {
                        throw ApiError.noContent
                    }
                    
                    return listResponse
                } catch {
                    throw ApiError.decodingError
                }
            })
    }
    
    //모든 할일 목록 가져오기
    static func fetchTodosWithObservableResult(page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
        // make urlRequest
        let urlString = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseListResponse<Todo>, ApiError> in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                }
                
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    
                    //상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos, !todos.isEmpty else {
                        return .failure(ApiError.noContent)
                    }
                    
                    return .success(listResponse)
                } catch {
                    return .failure(ApiError.decodingError)
                }
            })
    }
    
    //특정 할일 가져오기
    static func fetchATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        // make urlRequest
        let urlString = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                throw ApiError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw ApiError.unauthorized
            case 204:
                throw ApiError.noContent
                
            default :
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw ApiError.badStatus(code: httpResponse.statusCode)
            }
            
            do {
                let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                return baseResponse
            } catch {
                throw ApiError.decodingError
            }
        })
    }
    
    //할일 검색하기
    static func searchTodosWithObservable(searchTerm: String, page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm, "page": "\(page)"])
        
        guard let url = requestUrl else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
               
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    
                    //상태코드는 200인데 파싱한 데이터에 따라서 에러처리
                    guard let todos = todos, !todos.isEmpty else {
                        throw ApiError.noContent
                    }
                    
                    return listResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    /// 할일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func addATodoWithObservable(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        // make urlRequest
        let urlString = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
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
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo>in
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    /// 할일 추가하기 - JSON
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func addATodoJsonWithObservable(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        // make urlRequest
        let urlString = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
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
            return Observable.error(ApiError.decodingError)
        }
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                    
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            })
    }
    
    /// 할일 수정하기 - JSON
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func editTodoJsonWithObservable(id: Int, title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        // make urlRequest
        let urlString = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
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
            return Observable.error(ApiError.decodingError)
        }
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                    
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    /// 할일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 할일 타이틀
    ///   - isDone: 할일 완료여부
    ///   - completion: 응답결과
    static func editTodoWithObservable(id: Int, title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        // make urlRequest
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                    
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    /// 할일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답결과
    static func deleteATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        
        print(#function, "id = \(id)")
        // make urlRequest
        let urlString = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                case 204:
                    throw ApiError.noContent
                    
                default :
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    /// 할일 추가 후 모든 할일 가져오기
    /// - Parameters:
    ///   - title:
    ///   - isDone:
    ///   - completion:
    static func addATodoAndFetchTodosWithObservable(title: String, isDone: Bool = false) -> Observable<[Todo]> {
        
        return self.addATodoWithObservable(title: title)
            .flatMapLatest { _ in
                self.fetchTodosWithObservable()
            }
            .compactMap{ $0.data } // [Todo]
            .catch({ err in
                return Observable.just([])
            })
            .share(replay: 1)
    }
    
    /// 클로저 기반 api 동시 처리 
    /// 선택된 할일들 삭제
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 id
    ///   - completion: 실제 삭제가 완료된 id
    static func deleteSelectedTodosWithObservable(selectedTodoIds: [Int]) -> Observable<[Int]> {
        
        // 1.매개변수 배여 -> Observable 스트림 배열
        
        // 2. 배열로 단일 api들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteATodoWithObservable(id: id)
                .map{ $0.data?.id } // Int?
                .catchAndReturn(nil )
        }
        
        return Observable.zip(apiCallObservables)
            .map { // Observable<[Int?]>
                $0.compactMap{ $0 } // Int
            } // Observable<[Int]>
    }
    
    /// 클로저 기반 api 동시 처리
    /// 선택된 할일들 삭제
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 id
    ///   - completion: 실제 삭제가 완료된 id
    static func deleteSelectedTodosWithObservableMerge(selectedTodoIds: [Int]) -> Observable<Int> {
        
        // 1.매개변수 배여 -> Observable 스트림 배열
        
        // 2. 배열로 단일 api들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteATodoWithObservable(id: id)
                .map{ $0.data?.id } // Int?
                .catchAndReturn(nil )
        }
        
        return Observable.merge(apiCallObservables).compactMap{ $0 }
    }
    
    /// 클로저 기반 api 동시 처리
    /// 선택된 할일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일 id
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithObservable(selectedTodoIds: [Int]) -> Observable<[Todo]> {
        
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Todo?> in
            return self.fetchATodoWithObservable(id: id)
                .map{ $0.data } // Todo?
                .catchAndReturn(nil)
        }
        
        return Observable.zip(apiCallObservables)
            .map { $0.compactMap{ $0 } }
    }
}
