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
    
    var todo: Todo?
    
    var selectedClosure: ((Int) -> ())?
    
    var editClosure: ((Int) -> ())?
    
    var deleteClosure: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUI(todo: Todo) {
        guard let id = todo.id else {return}
        print(#function, id)
        titleLabel.clipsToBounds = true
        titleLabel.layer.cornerRadius = 5
        titleLabel.text = "No. " + String(describing: id)
        contentLabel.text = todo.title
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton){
        guard let id = todo?.id else { return }
        editClosure?(id)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton){
        guard let id = todo?.id else { return }
        deleteClosure?(id)
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        guard let id = todo?.id else { return }
        selectedClosure?(id)
    }
}
