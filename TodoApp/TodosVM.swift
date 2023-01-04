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
    
    var subjectTodos = PublishSubject<BaseListResponse<Todo>>()
    
    var todoList = BehaviorRelay<[Todo]>(value: [])
    
    var aTodo: BehaviorRelay<Todo>?
    
    var searchedTodos = BehaviorRelay<[Todo]>(value: [])
    
    var todosCount: Observable<Int>
    
    init() {
        TodosAPI.fetchTodosWithObservable().compactMap{ $0.data }.bind(to: self.todoList).disposed(by: disposeBag)
        
        todosCount = todoList.map { $0.count }
    }
    
    func subjectTest() {
        print(#fileID ,#function)
        subjectTodos.onNext(data1)
    }
    
    func addATodo(title: String) {
        // 새 옵저버블이 생기면
        TodosAPI.addATodoWithObservable(title: title).compactMap{$0.data}.withUnretained(self).subscribe { owner, newTodo in
            // todolist맨 앞에 넣어서
            var list = owner.todoList.value
            list.insert(newTodo, at: 0)
            // 새로운 리스트 방출
            owner.todoList.accept(list)
        }
    }
    
    func editATodo(id: Int, title: String) {
        TodosAPI.editTodoWithObservable(id: id, title: title)
            .compactMap{ $0.data }
            .subscribe { editedTodo in
                var list = self.todoList.value
                //map, filter 등 고차함수 써서
                //list.map{ $0.id == id ? $0.title = title : $0 }
                if let editIndex = list.firstIndex { $0.id == id } {
                    list[editIndex].title = title
                    self.todoList.accept(list)
                }
            }
    }
    
    func deleteATodo(id: Int) {
        TodosAPI.deleteATodoWithObservable(id: id)
            .compactMap{ $0.data }
            .subscribe{ deletedTodo in
                var list = self.todoList.value
                list.removeAll { $0.id == id }
                self.todoList.accept(list)
            }
    }
    
    func fetchATodo(id: Int) {
        TodosAPI.fetchATodoWithObservable(id: id)
            .compactMap { $0.data }
            .subscribe { todo in
                self.aTodo?.accept(todo)
            }
    }
    
    func searchTodos(_ text: String) {
        searchedTodos.accept(todoList.value.filter { $0.title?.contains(text) ?? true })
        print(#function,searchedTodos.value)
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
