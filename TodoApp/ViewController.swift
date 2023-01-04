//
//  ViewController.swift
//  TodoApp
//
//  Created by user on 2022/12/25.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var myTableView: UITableView!

    @IBOutlet weak var mySearchBar: UISearchBar!
    
    let manager = TodosVM()
    
    var todos: [Todo] = []
    
    let disposeBag = DisposeBag()
    
    var countDisposable: Disposable? = nil
    
    var selectedTodoId: Int?
    
    var todosCount: Int = 0
    
    var searchedTodos: [Todo] = []
    
    @IBAction func addButtonTapped(_ sender: Any) {
        //manager.deleteATodo(id: 1917)
        manager.addATodo(title: "addATodoTest")
        //manager.editATodo(id: 1917, title: "EditTodo Test!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.ReuseIdentifier)
        //myTableView.dataSource = self
        myTableView.delegate = self
        
        myTableView.rowHeight = 110
        
        mySearchBar.delegate = self
        
        setBinding()
        
        navigationController?.navigationBar.topItem?.title = "Todos"
    }
     
//    mySearchBar.rx.text.orEmpty
//        .map { text in
//            self.todos.filter { todo in
//                if text.isEmpty || todo.title?.lowercased().contains(text.lowercased()) ?? true {
//                    return true
//                } else {
//                    return false
//                }
//            }
//        }
//        .bind(to: myTableView.rx.items(cellIdentifier: TodoCell.ReuseIdentifier)) { _, model, cell in
//            if let todoCell = cell as? TodoCell {
//                todoCell.setUI(todo: model)
//                todoCell.todo = model
//                print(self.todos.count)
//            }
//        }
//        .disposed(by: disposeBag)
    func setBinding() {
        print(#function)
        
        manager.todoList
            .observe(on: MainScheduler.instance)
            .debug("debug!!!!!!")
            .subscribe { todos in
                self.todos = todos
                print("todos count: \(todos.count)")
            }.disposed(by: disposeBag)
        
        countDisposable = manager.todosCount.observe(on: MainScheduler.instance).bind(to: self.rx.todosCount)
        
        mySearchBar.rx.text.orEmpty            .debounce(RxTimeInterval.milliseconds(1300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { text in
                self.manager.todoList.value.filter { todo in
                    if text.isEmpty || todo.title?.lowercased().contains(text.lowercased()) ?? true {
                        return true
                    } else {
                        return false
                    }
                }
            }
            .bind(to: myTableView.rx.items(cellIdentifier: TodoCell.ReuseIdentifier)) { _, model, cell in
                if let todoCell = cell as? TodoCell {
                    todoCell.setUI(todo: model)
                    todoCell.todo = model
                    print(self.todos.count)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return todos.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.ReuseIdentifier, for: indexPath) as? TodoCell else { return UITableViewCell() }
//
//        cell.todo = todos[indexPath.row]
//
////        cell.selectedTodo.bind { selectedTodoid in
////            self.selectedTodoId = selectedTodoid
////            print(#function, self.selectedTodoId)
////        }.disposed(by: disposeBag)
//
//        cell.setUI(todo: todos[indexPath.row])
//
//        return cell
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let detailVC = DetailTodoVC()
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailTodoVC") as! DetailTodoVC
        
        if mySearchBar.text?.isEmpty ?? true {
            detailVC.todo = todos[indexPath.row]
        } else {
            detailVC.todo = todos.filter{$0.title?.lowercased().contains(mySearchBar.text!.lowercased()) ?? false }[indexPath.row]
        }
        
        navigationController?.pushViewController(detailVC, animated: false)
    }
    
}

protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell: Nibbed { }

protocol ReuseIdentifiable {
    static var ReuseIdentifier: String { get }
}

extension Nibbed {
    static var ReuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable { }
