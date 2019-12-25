//
//  CompleteToDoViewController.swift
//  ToDo
//
//  Created by MacBook Air on 28.11.2019.
//  Copyright © 2019 MacBook Air. All rights reserved.
//

import UIKit
import CoreData

class CompleteToDoViewController: UIViewController {

    var previousVC = ToDoTableViewController()
    var dayNCD: [DayNCoreData] = []
    
    var selectedToDo: ToDoCoreData?//было нил
    
    @IBOutlet weak var progressFirstPriority: UIProgressView!
    @IBOutlet weak var firstPriorityPercent: UILabel!
    @IBOutlet weak var progressSecondPriority: UIProgressView!
    @IBOutlet weak var secondPriorityPercent: UILabel!
    @IBOutlet weak var progressThirdPriority: UIProgressView!
    @IBOutlet weak var thirdPriorityPercent: UILabel!
    @IBOutlet weak var progressForthPriority: UIProgressView!
    @IBOutlet weak var forthPriorityPercent: UILabel!
    
    
    @IBOutlet weak var doTaskButton: UIButton!
    var doTaskState = ""
    
    @IBAction func doTaskButtonPressed(_ sender: Any) {
        print("Hey. I'm working")
        if(doTaskButton.currentTitle == "Выполнять"){
                        doTaskButton.setTitle("Завершить", for: .normal)
            previousVC.updateBtnState(state: doTaskButton.currentTitle!, selectedToDo: selectedToDo!)
            
            //запоминаем время
            selectedToDo!.startDoTaskTime = Date()
            }
            else if (doTaskButton.currentTitle == "Завершить"){
                 doTaskButton.setTitle("Задание выполнено", for: .normal)
    doTaskButton.setTitleColor(UIColor.gray, for: UIControl.State.selected)
            previousVC.updateBtnState(state: doTaskButton.currentTitle!, selectedToDo: selectedToDo!)
            
            //запоминаем время завершения
            selectedToDo!.endDoTaskTime = Date()
            }
    }

    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        titleLabel.text = selectedToDo?.name
        getDayInfo()
        
        if let selectedToDo = self.selectedToDo {
            
            if var name = selectedToDo.name {
                if (selectedToDo.important) {
                    name = "❗️" + name
                }
                
                titleLabel.text = name
            }
            // когда вид загрузился, достаем из Бд состояние кнопки и изменяем его
            if let selectedToDo = self.selectedToDo{
                if selectedToDo.doTaskButtonState != nil {
                    doTaskState = selectedToDo.doTaskButtonState!
                    doTaskButton.setTitle(doTaskState, for: .normal)
                }
            }
            
        }
        
        //design
        progressFirstPriority.transform = progressFirstPriority.transform.scaledBy(x: 1, y: 3)
        progressFirstPriority.layer.cornerRadius = 2
        progressFirstPriority.clipsToBounds = true
        progressFirstPriority.layer.sublayers![1].cornerRadius = 2
        progressFirstPriority.subviews[1].clipsToBounds = true
        
        progressSecondPriority.transform = progressSecondPriority.transform.scaledBy(x: 1, y: 3)
        progressSecondPriority.layer.cornerRadius = 2
        progressSecondPriority.clipsToBounds = true
        progressSecondPriority.layer.sublayers![1].cornerRadius = 2
        progressSecondPriority.subviews[1].clipsToBounds = true
        
        progressThirdPriority.transform = progressThirdPriority.transform.scaledBy(x: 1, y: 3)
        progressThirdPriority.layer.cornerRadius = 2
        progressThirdPriority.clipsToBounds = true
        progressThirdPriority.layer.sublayers![1].cornerRadius = 2
        progressThirdPriority.subviews[1].clipsToBounds = true
        
        progressForthPriority.transform = progressForthPriority.transform.scaledBy(x: 1, y: 3)
        progressForthPriority.layer.cornerRadius = 2
        progressForthPriority.clipsToBounds = true
        progressForthPriority.layer.sublayers![1].cornerRadius = 2
        progressForthPriority.subviews[1].clipsToBounds = true
        
        let taskCount = previousVC.toDos.count
        let timeInaDay = previousVC.toDos[0].timeLeft
        var firstPriorityTask = 0
        var firstPriorityTime = 0.0
        var secondPriorityTask = 0
        var secondPriorityTime = 0.0
        var thirdPriorityTask = 0
        var thirdPriorityTime = 0.0
        var forthPriorityTask = 0
        var forthPriorityTime = 0.0
        
        
        for element in previousVC.toDos {
            if element.priority == Int64(1){
                firstPriorityTask += 1
                firstPriorityTime += element.timeForTask
                
            }
            else if element.priority == Int64(2){
                secondPriorityTask += 1
                secondPriorityTime += element.timeForTask
            }
            else if element.priority == Int64(3){
                thirdPriorityTask += 1
                thirdPriorityTime += element.timeForTask
            }
            else if element.priority == Int64(4){
                forthPriorityTask += 1
                forthPriorityTime += element.timeForTask
            }
        }
        
        print("time for task \(firstPriorityTime)   all day \(timeInaDay)")
        let valueFirst = Float(Float(firstPriorityTime) / Float(timeInaDay))
        let valueSecond = Float(Float(secondPriorityTime) / Float(timeInaDay))
        let valueThird = Float(Float(thirdPriorityTime) / Float(timeInaDay))
        let valueForth = Float(Float(forthPriorityTime) / Float(timeInaDay))
        progressFirstPriority.progress = valueFirst
        firstPriorityPercent.text = String(format: "%.0f", valueFirst*100) + " %"
        
        progressSecondPriority.progress = valueSecond
        secondPriorityPercent.text = String(format: "%.0f", valueSecond*100) + " %"
        
        progressThirdPriority.progress = valueThird
        thirdPriorityPercent.text = String(format: "%.0f", valueThird*100) + " %"
        
        progressForthPriority.progress = valueForth
        forthPriorityPercent.text = String(format: "%.0f", valueForth*100) + " %"
        
        
        print(Float(firstPriorityTask))
        print(Float(taskCount))
        print(firstPriorityTask)
        print(taskCount)
        
    }
    
    //удаление
    @IBAction func completeTapped(_ sender: Any) {
        
        
//_______________helps_______________
        if let completedToDo = selectedToDo {
            previousVC.completeToDo(toDo: completedToDo)
        }
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
   
        func getDayInfo() {
            if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
                
                do{
                    let dayCoreData = try context.fetch(DayNCoreData.fetchRequest()) as? [DayNCoreData]
                    if let dayCoreData = dayCoreData {
                        dayNCD = dayCoreData
                    
                    }
                    print("I get dayCD")
    //                print(dayNCD)
                }
                catch{
//                    showAlert(message: "Could not retrieve the ToDo items from the database!  Please try again.")
                    print("error")
                    return
                }
            }
        }

    
}
