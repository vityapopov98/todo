//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by MacBook Air on 26.11.2019.
//  Copyright © 2019 MacBook Air. All rights reserved.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {

    var toDos: [ToDoCoreData] = []
    var exampleArray = ["3","2","1","6","4","5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        toDos = createToDos()
        getToDos()
        
        //сортируем массив
        //images.sorted(by: { $0.fileID > $1.fileID })
        toDos.sort(by: { $0.startTimePlanning! < $1.startTimePlanning! })
        exampleArray.sort(by: {$0<$1})
        print(exampleArray)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getToDos()
    }
    
    
    func getToDos(){
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            do{
//                let toDo = ToDoCoreData(entity: ToDoCoreData.entity(), insertInto: context)
                let coreDataToDos = try context.fetch(ToDoCoreData.fetchRequest()) as? [ToDoCoreData]
                
                if let coreDataToDos = coreDataToDos {
                    
                    self.toDos = coreDataToDos
                    
                }
                tableView.reloadData()
            }
            catch {
                showAlert(message: "Could not retrieve the ToDo items from the database!  Please try again.")
                return
            }
            
//            if let coreDataToDos = try? context.fetch(ToDoCoreData.fetchRequest()) as? [ToDoCoreData] {// go to core data and bring me all data as an array
//                toDos = coreDataToDos
//            }
            
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDos.count
//        return exampleArray.count
    }
    
    //__________Do not need________
    func createToDos() -> [ToDo] {
        let eggs = ToDo()
        eggs.name = "Buy eggs"
        eggs.important = true
        
        let dog = ToDo()
        dog.name = "walk the dog"
        
        let cheese = ToDo()
        cheese.name = "eat cheese"
        
        return [eggs, dog, cheese ]
    }

    
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let string = formatter.string(from: date)
        return string
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
      //  cell.textLabel?.text = exampleArray[indexPath.row]
        let toDo = toDos[indexPath.row]
    
        
//__________helpers________-
        if var name = toDo.name {
            
            
            cell.textLabel?.text = name
            
            print("priority is \(toDo.priority)")

//___Detail Label___________
            if toDo.endTimePlanning != nil {
                if toDo.doTaskButtonState! == "Завершить" {
                    cell.detailTextLabel?.text = "Время: " + convertDateToString(date: toDo.startTimePlanning!) + "-" + convertDateToString(date: toDo.endTimePlanning!) + " | ⏱"
                }
                else if toDo.doTaskButtonState! == "Задание выполнено" {
                    cell.textLabel?.text = name + " ✅"
                    if toDo.endDoTaskTime != nil && toDo.startDoTaskTime != nil{
                        cell.detailTextLabel?.text = "Время: " + convertDateToString(date: toDo.startTimePlanning!) + "-" + convertDateToString(date: toDo.endTimePlanning!) + " | " + convertDateToString(date: toDo.startDoTaskTime!) + "-" + convertDateToString(date: toDo.endDoTaskTime!)
                    }

                }
                else{
                    cell.detailTextLabel?.text = "Время: " + convertDateToString(date: toDo.startTimePlanning!) + "-" + convertDateToString(date: toDo.endTimePlanning!)
                }
                print("state: \(toDo.doTaskButtonState)")
            }
            else {
                print("unfortunately nil")
            }
            
//iOS 13 priority images
            if #available(iOS 13.0, *) {
                switch toDo.priority {
                case 1:
                    cell.imageView?.image = UIImage(systemName: "1.circle")
                    cell.imageView?.tintColor = .green
                case 2:
                    cell.imageView?.image = UIImage(systemName: "2.circle")
                    cell.imageView?.tintColor = .systemGreen
                case 3:
                    cell.imageView?.image = UIImage(systemName: "3.circle")
                    cell.imageView?.tintColor = .systemOrange
                case 4:
                    cell.imageView?.image = UIImage(systemName: "4.circle")
                    cell.imageView?.tintColor = .systemRed
                default:
                    cell.imageView?.image = UIImage(systemName: "1.circle")
                    cell.imageView?.image?.withTintColor(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))

                }

            } else {
                // Fallback on earlier versions
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let toDo = toDos[indexPath.row]
        performSegue(withIdentifier: "moveToComplete", sender: toDo)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addVC = segue.destination as? AddToDoViewController {
            addVC.previousVC = self
        }
        
        if let completeVC = segue.destination as? CompleteToDoViewController {
            completeVC.previousVC = self

            if let toDo = sender as? ToDoCoreData {
                completeVC.selectedToDo = toDo
            }
            
        }
    }
    
    
    //_____________Helpers__________
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Added the function instead of code directly in other view
    func completeToDo(toDo toRemove: ToDoCoreData) {
        // Using Core Data, all we need to do is remove the item
        // from Core Data.
        if let context  =
            ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            context.delete(toRemove)
            // Update the tableView
            getToDos()
            
            
            //Может нужно сохранить?
            do {
                try context.save()
            }
            catch {
                self.showAlert(message: "Data could not be saved!  Please try again.")
            }
        }
    }
    
    func addNewToDo(toDo: ToDo) -> Bool {
        
        /* Commented out to use Core Data instead
         if let toDo = toDo as ToDo? {
         toDos.append(toDo)
         tableView.reloadData()
         }*/
        
        var success : Bool = true
        
        // Get the managed object context
        if let context  =
            ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            let toDoCoreData = ToDoCoreData(entity: ToDoCoreData.entity(), insertInto: context)
            
            toDoCoreData.name = toDo.name
            toDoCoreData.important = toDo.important
            toDoCoreData.priority = Int64(toDo.priority)
            toDoCoreData.timeForTask = toDo.timeForTask
            toDoCoreData.timeLeft = toDo.timeLeft
            
            toDoCoreData.startTimePlanning = toDo.startTimePlanning
            toDoCoreData.endTimePlanning =  toDo.endTimePlanning
            
            toDoCoreData.doTaskButtonState = toDo.doTaskButtonState
            
            // This can also be handled this way:
            // try? context.save
            // But then there's no handling the failure case...
            // To get the data to "reload" we need to handle
            // viewWillAppear.
            do {
                try context.save()
            }
            catch {
                self.showAlert(message: "Data could not be saved!  Please try again.")
                success = false
            }
        }
        return success
    }
    
    func updateBtnState(state: String, selectedToDo: ToDoCoreData) {
        //вносим изменения
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            do{
                let toDoCoreData = try context.fetch(ToDoCoreData.fetchRequest()) as? [ToDoCoreData]
                if let toDoCoreData = toDoCoreData {
                    
                    
                    for element in toDoCoreData {
                        if selectedToDo.name == element.name && selectedToDo.startTimePlanning == element.startTimePlanning {
                            //идентифицировали выбранную задачу
//                            element.doTaskButtonState = state
                            element.setValue(state, forKey: "doTaskButtonState")
                            print("нашел и сохранил")
                        }
                    }//форин
                    
                    //попробовать включить сортировку сюда
                    
                }
                print("I updated")
            }
            catch{
                showAlert(message: "Could not retrieve the ToDo items from the database!  Please try again.")
                return
            }
            
            //Может нужно сохранить?
            do {
                try context.save()
            }
            catch {
                self.showAlert(message: "Data could not be saved!  Please try again.")
            }
        }
        //_________
    }

}
