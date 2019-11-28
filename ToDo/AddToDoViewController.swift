//
//  AddToDoViewController.swift
//  ToDo
//
//  Created by MacBook Air on 28.11.2019.
//  Copyright © 2019 MacBook Air. All rights reserved.
//

import UIKit

class AddToDoViewController: UIViewController {

    var previousVC = ToDoTableViewController()
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var importantSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        let toDo = ToDo()
//        toDo.name = titleTextField.text!
        if let titleUnwrapped = titleTextField.text {
            toDo.name = titleUnwrapped
            toDo.important = importantSwitch.isOn
            
            previousVC.toDos.append(toDo)
            previousVC.tableView.reloadData()
            
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    
    
    

}
