//
//  TodosVM.swift
//  TodoApp
//
//  Created by user on 2022/12/26.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

class TodosVM {
    var disposeBag = DisposeBag()
    
    var page = 1
    
    var todoList = BehaviorRelay<[Todo]>(value: [])
    
    var aTodo: BehaviorRelay<Todo>?
    
    var searchedTodos = BehaviorRelay<[Todo]>(value: [])
    
    var todosCount: Observable<Int>
    
    var searchTerm = BehaviorRelay<String>(value: "")
    
    init() {
        TodosAPI.fetchTodosWithObservable()
            .compactMap{ $0.data }
            .bind(to: self.todoList)
            .disposed(by: disposeBag)
        
        todosCount = todoList.map { $0.count }
        
        searchTerm.filter{ $0.count > 0}
            .debug("검색어길이 > 0")
            .withUnretained(self)
            .subscribe{ owner, searchTerm in
                owner.searchTodos(searchTerm: searchTerm)
            }
            .disposed(by: disposeBag)
         
        searchTerm.filter { $0.count == 0 }
            .withUnretained(self)
            .skip(1)
            .debug("검색어길이 == 0")
            .bind(onNext: { owner, _ in
                owner.fetchInitialTodos()
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func fetchInitialTodos(){
        print(#fileID, #function, #line, "- ")
        TodosAPI.fetchTodosWithObservable()
            .compactMap{ $0.data }
            .bind(to: self.todoList)
            .disposed(by: disposeBag)
    }
    
    func addATodo(title: String) {
        // 새 옵저버블이 생기면
        TodosAPI.addATodoWithObservable(title: title)
            .compactMap{$0.data}
            .withUnretained(self)
            .subscribe { owner, newTodo in
                // todolist맨 앞에 넣어서
                var list = owner.todoList.value
                list.insert(newTodo, at: 0)
                // 새로운 리스트 방출
                owner.todoList.accept(list)
            }
            .disposed(by: disposeBag)
    }
    
    func editATodo(id: Int, title: String) {
        TodosAPI.editTodoWithObservable(id: id, title: title)
            .compactMap{ $0.data }
            .subscribe { editedTodo in
                var list = self.todoList.value
                if let editIndex = list.firstIndex { $0.id == id } {
                    list[editIndex].title = title
                    self.todoList.accept(list)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func deleteATodo(id: Int) {
        TodosAPI.deleteATodoWithObservable(id: id)
            .compactMap{ $0.data }
            .subscribe{ deletedTodo in
                var list = self.todoList.value
                list.removeAll { $0.id == id }
                self.todoList.accept(list)
            }
            .disposed(by: disposeBag)
    }
    
    func fetchATodo(id: Int) {
        TodosAPI.fetchATodoWithObservable(id: id)
            .compactMap { $0.data }
            .subscribe { todo in
                self.aTodo?.accept(todo)
            }
            .disposed(by: disposeBag)
    }
    
    func deleteTodos(todoIds: [Int]) {
        for todoId in todoIds {
            TodosAPI.deleteATodoWithObservable(id: todoId)
                .compactMap{ $0.data }
                .subscribe{ deletedTodo in
                    var list = self.todoList.value
                    list.removeAll { $0.id == todoId }
                    self.todoList.accept(list)
                }
                .disposed(by: disposeBag)
        }
    }
    
    func searchTodos(searchTerm: String) {
        TodosAPI.searchTodosWithObservable(searchTerm: searchTerm)
            .compactMap { $0.data }
            .catchAndReturn([])
            .bind(to: self.todoList)
            .disposed(by: disposeBag)
    }
    
    func fetchNewPage() {
        self.page += 1
        TodosAPI.fetchTodosWithObservable(page: page)
            .compactMap { $0.data }
            .subscribe { newTodos in
                var list = self.todoList.value
                list.append(contentsOf: newTodos)
                self.todoList.accept(list)
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func handleError(_ err: Error) {
        if err is TodosAPI.ApiError {
            let apiError = err as! TodosAPI.ApiError
            print("handleError: \(apiError.info)")
            switch apiError {
            case .noContent:
                print("noContent")
            case .decodingError:
                print("decodingError")
            case .jsonEncoding:
                print("jsonEncoding")
            case .unauthorized:
                print("unauthorized")
            case .notAllowedUrl:
                print("notAllowedUrl")
            case .badStatus(_):
                print("badStatus")
            case .unknown(_):
                print("unknown")
            }
        }
    }
}
