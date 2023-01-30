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
    
    var selectedTodoIds: [Int] = []
    
    var todosCount: Int = 0
    
    var searchedTodos: [Todo] = []
    
    var refreshControl = UIRefreshControl()
    
    var isLoading: Bool = false
    
    @objc func fetchNewPage() {
        print(#function)
        manager.fetchNewPage()
        refreshControl.endRefreshing()
    }
    
    @IBOutlet weak var selectedTodosLabel: UILabel!
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if selectedTodoIds.count == 0 {
            return
        }
        let alertController = UIAlertController(title: "\(selectedTodoIds.count)개의 할일을 삭제할까요?", message: nil, preferredStyle: .alert)
        
        let deleteTodoAction = UIAlertAction(title: "삭제", style: .default) { _ in
            self.manager.deleteTodos(todoIds: self.selectedTodoIds)
            self.selectedTodoIds.removeAll()
            self.selectedTodosLabel.text = "선택된 할일: \(self.selectedTodoIds)"
        }
        
        alertController.addAction(deleteTodoAction)
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "할일 추가", message: nil, preferredStyle: .alert)
        
        alertController.addTextField()
        alertController.textFields?[0].placeholder = "추가할 할일을 입력해주세요"
        
        let addTodoAction = UIAlertAction(title: "추가", style: .default) { _ in
            guard let todoTitle = alertController.textFields?[0].text else { return }
            self.manager.addATodo(title: todoTitle)
        }
        
        alertController.addAction(addTodoAction)
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.ReuseIdentifier)
        
        myTableView.rowHeight = 110
        myTableView.delegate = self
        myTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchNewPage), for: .valueChanged)
        
        mySearchBar.placeholder = "할일 검색"
        
        setBinding()
        
        navigationController?.navigationBar.topItem?.title = "할일 목록"
    }
    
    func setBinding() {
        print(#function)
        
        mySearchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(800), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: self.manager.searchTerm)
            .disposed(by: disposeBag)
        
        manager.todoList
            .observe(on: MainScheduler.instance)
            .bind(to: self.myTableView.rx.items(cellIdentifier: TodoCell.ReuseIdentifier)) { _, model, cell in
                if let todoCell = cell as? TodoCell {
                    todoCell.setUI(todo: model)
                    todoCell.todo = model
                    
                    todoCell.selectionSwitch.isOn = self.selectedTodoIds.contains(model.id!)
                    todoCell.selectionStyle = .none
                    
                    todoCell.selectedClosure = { selectedTodoId in
                        if self.selectedTodoIds.contains(selectedTodoId) {
                            self.selectedTodoIds.removeAll { $0 == selectedTodoId }
                        } else {
                            self.selectedTodoIds.append(selectedTodoId)
                        }
                        self.selectedTodosLabel.text = "선택된 할일: \(self.selectedTodoIds)"
                    }
                    
                    todoCell.editClosure = { [weak self] id in
                        print("\(id) 수정")
                        self?.manager.editATodo(id: id, title: "editTest")
                    }
                    
                    todoCell.deleteClosure = { [weak self] id in
                        print("\(id) 삭제")
                        self?.manager.deleteATodo(id: id)
                    }
                }
            }.disposed(by: disposeBag)
        
        countDisposable = manager.todosCount.observe(on: MainScheduler.instance).bind(to: self.rx.todosCount)
        
        myTableView.rx.modelSelected(Todo.self)
            .subscribe { item in
                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailTodoVC") as! DetailTodoVC
                detailVC.todo = item.element
                
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
    }
}

extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset
        
        if !isLoading {
            if distanceFromBottom + 100 < height {
                isLoading = true
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.isLoading = false
                }
                print("paging")
            
                manager.fetchNewPage()
            }
        }
    }
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
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        //let detailVC = DetailTodoVC()
    //        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailTodoVC") as! DetailTodoVC
    //
    //        if mySearchBar.text?.isEmpty ?? true {
    //            detailVC.todo = todos[indexPath.row]
    //        } else {
    //            detailVC.todo = todos.filter{ $0.title?.lowercased().contains(mySearchBar.text!.lowercased()) ?? false }[indexPath.row]
    //        }
    //
    //        navigationController?.pushViewController(detailVC, animated: false)
    //    }
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
