//
//  TodoCell.swift
//  TodoApp
//
//  Created by user on 2022/12/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TodoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    var selectedTodo = BehaviorRelay<Int>(value: 0)
    
    var disposeBag = DisposeBag()
    
    var todo: Todo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUI(todo: Todo) {
        guard let id = todo.id else {return}
        titleLabel.text = String(describing: id)
        contentLabel.text = todo.title
        selectionSwitch.isOn = false
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton){
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton){
        
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        selectionSwitch.rx.isOn.bind { isOn in
            switch isOn {
            case true:
                guard let todo = self.todo,
                      let id = todo.id else { return }
                print(id)
                self.selectedTodo.accept(id)
                print(#function, self.selectedTodo.value)
            case false:
                print(isOn)
            }
        }
    }
}
