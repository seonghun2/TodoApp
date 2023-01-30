//
//  DetailTodoVC.swift
//  TodoApp
//
//  Created by user on 2023/01/02.
//

import UIKit

class DetailTodoVC: UIViewController {
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var isDoneLabel: UILabel!
    
    @IBOutlet weak var createDateLabel: UILabel!
    
    @IBOutlet weak var updateDateLabel: UILabel!
    
    var todo: Todo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let todo = todo else { return }
        setUI(todo: todo)
    }
    
    func setUI(todo: Todo) {
        guard let id = todo.id else { return }
        idLabel.text = String(describing: id)
        titleLabel.text = todo.title
        isDoneLabel.text = (todo.isDone ?? false) ? "완료" : "미완료"
        createDateLabel.text = todo.createdAt
        updateDateLabel.text = todo.updatedAt
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
