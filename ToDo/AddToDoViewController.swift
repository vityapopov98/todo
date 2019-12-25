//
//  AddToDoViewController.swift
//  ToDo
//
//  Created by MacBook Air on 28.11.2019.
//  Copyright © 2019 MacBook Air. All rights reserved.
//

import UIKit
import CoreData

class AddToDoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var previousVC = ToDoTableViewController()
    var dayCD: [DayCoreData] = []
    var dayNCD: [DayNCoreData] = []
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var importantSwitch: UISwitch!
    
    @IBOutlet weak var startDayLabelBg: UILabel!
    @IBOutlet weak var endDayLabelBg: UILabel!
    @IBOutlet weak var availableTimeLabelBg: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var startDayTimeField: UITextField!
    @IBOutlet weak var endDayTimeField: UITextField!
    @IBOutlet weak var availableTimeLabel: UILabel!
    
    let startDayTimePicker = UIDatePicker()
    let endDayTimePicker = UIDatePicker()
    var startDayTime = Date()
    var endDayTime = Date()
    var availableTime = ""
    

    
    @IBOutlet weak var timeForTaskField: UITextField!
    let timerPicker = UIDatePicker()
    @IBOutlet weak var priorityField: UITextField!
    var priorityOptions = ["1", "2", "3", "4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startDayLabelBg.layer.masksToBounds = true
        startDayLabelBg.layer.cornerRadius = 14
        endDayLabelBg.layer.masksToBounds = true
        endDayLabelBg.layer.cornerRadius = 14
        availableTimeLabelBg.layer.masksToBounds = true
        availableTimeLabelBg.layer.cornerRadius = 14
        
        addBtn.layer.cornerRadius = addBtn.frame.size.height / 2
        //Достать данные из БД startDay, endDay, availableTime
        
//        loadDefaultVal()
        getDayInfo()
        availableTime = String(dayNCD[0].availableTime)
        //Поместить в виджеты
        
        
        //TimeInterval Picker
        timerPicker.datePickerMode = .countDownTimer
        timeForTaskField.inputView = timerPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolbar.setItems([doneButton], animated: true)
        timeForTaskField.inputAccessoryView = toolbar
        
        //startDayTime Picker
        startDayTimePicker.datePickerMode = .time
        startDayTimeField.inputView = startDayTimePicker
        let toolbarStartDay = UIToolbar()
        toolbarStartDay.sizeToFit()
        let doneButtonStartDay = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionStartDay))
        toolbarStartDay.setItems([doneButtonStartDay], animated: true)
        startDayTimeField.inputAccessoryView = toolbarStartDay
        
        //endDayTime Picker
        endDayTimePicker.datePickerMode = .time
        endDayTimeField.inputView = endDayTimePicker
        let toolbarEndDay = UIToolbar()
        toolbarEndDay.sizeToFit()
        let doneButtonEndDay = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneActionEndDay))
        toolbarEndDay.setItems([doneButtonEndDay], animated: true)
        endDayTimeField.inputAccessoryView = toolbarEndDay
        
        //Priority
        let priorityPickerView = UIPickerView()
        priorityPickerView.delegate = self as? UIPickerViewDelegate
        priorityField.inputView = priorityPickerView
        
    }
    
    //For time for task date picker
    @objc func doneAction(){
        getTimeIntervalForTask()
        view.endEditing(true)
    }
    var trueTimeForTask: TimeInterval = 0.0
    var hours = 0
    var minutes = 0
    func getTimeIntervalForTask() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        trueTimeForTask = Date().timeIntervalSince(timerPicker.date)
//       trueTimeForTask = timerPicker.date.timeIntervalSince(startDayTime)
        print("true Time for task \(trueTimeForTask)")
        print("то что вытаскиваем \(timerPicker.date)")
        var str = formatter.string(from: timerPicker.date)
        var strAr = str.components(separatedBy: ".")
        hours = Int(strAr[0])! * 3600
        minutes = Int(strAr[1])! * 60
    
        timeForTaskField.text = formatter.string(from: timerPicker.date)
    }
    
    @objc func doneActionStartDay(){
        //занести startDay в БД
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        startDayTime = startDayTimePicker.date
        let startDayString = formatter.string(from: startDayTime)
        
        updateDayTime(dayTime: startDayTime, key: "startDay")
        startDayTimeField.text = startDayString
        calculateAvailableTime()
        print("🥳")
        view.endEditing(true)
    }
    @objc func doneActionEndDay(){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        endDayTime = endDayTimePicker.date
        let endDayString = formatter.string(from: endDayTime)
        //Занести endDay в БД
        updateDayTime(dayTime: endDayTime, key: "endDay")
        endDayTimeField.text = endDayString
        
        calculateAvailableTime()
        print("🥳")
        view.endEditing(true)
    }
    
//    var trueAvailableTimeInterval: TimeInterval = 0.0
    
    func calculateAvailableTime(){
        //занести availableTime в БД
        let availableTimeLocal = endDayTime.timeIntervalSince(startDayTime)
//        trueAvailableTimeInterval = endDayTime.timeIntervalSince(startDayTime)
//        print("true available interval : \(trueAvailableTimeInterval)")
        let time = availableTimeLocal / 3600.0
        availableTime = String(format: "%.2f", time)
        updateAvailableTime(time: time)
        availableTimeLabel.text = availableTime
        
        print("🥳interval \(time)")
        print("🥳interval \(availableTime)")

    }
    
    func convertStringToDate(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let date = formatter.date(from: string)
        return date!
    }
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let string = formatter.string(from: date)
        return string
    }
    
    //working with priority Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorityOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorityOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        priorityField.text = priorityOptions[row]
    }
    
    
    
    @IBAction func addTapped(_ sender: Any) {
        let toDo = ToDo()
        if let name = titleTextField.text {
            if name.isEmpty {
                // Show an alert
                let message = "Please enter a title to complete the ToDo."
                showAlert(message: message)
                return
            }
            else {
                toDo.name = name
            }
        }
        toDo.priority = Int(priorityField.text!)!
        print("add priority in object \(toDo.priority)")
        toDo.timeForTask = Double(timeForTaskField.text!)!
        toDo.timeLeft = Double(availableTime)!
        toDo.doTaskButtonState = "Выполнять"
        
        var startTimePl = Date()
//        var endTimePlanning = Date()
        if previousVC.toDos.count == 0 {
            startTimePl = dayNCD[0].startDay!
            toDo.startTimePlanning = startTimePl //starttimePlanning для первой задачи
            toDo.endTimePlanning = Date(timeInterval:  TimeInterval(hours + minutes), since: startTimePl)
        }
        else{//если массив не пустой - задачи уже есть
            let index = previousVC.toDos.count
            startTimePl = previousVC.toDos[index-1].endTimePlanning!
            toDo.startTimePlanning = startTimePl
            toDo.endTimePlanning = Date(timeInterval: TimeInterval(hours + minutes), since: startTimePl)
        }
        
        decreaseAvailableTime()

        
        if true == previousVC.addNewToDo(toDo: toDo) {
            // Return to the prior view controller.
            navigationController?.popViewController(animated: true)
        }
        
        
    }
    func decreaseAvailableTime() {
        //взять текущее доступное (doule) и отнять временой интервал на задачу (double)
        var difference = 0.0
        
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            do{
                let dayCoreData = try context.fetch(DayNCoreData.fetchRequest()) as? [DayNCoreData]
                if let dayCoreData = dayCoreData {
                    dayNCD = dayCoreData
                    difference = dayNCD[0].availableTime - Double(timeForTaskField.text!)!
                    
                }
                print("I updated available")
            }
            catch{
                showAlert(message: "Could not retrieve the ToDo items from the database!  Please try again.")
                return
            }
        }
        
        print("difference \(difference)")
        //обновить доступное время
        updateAvailableTime(time: difference)
//        var avStr: String = String(format: "%.2f", difference)
        availableTimeLabel.text = String(format: "%.2f", difference)
        print("difference long \(String(format: "%.2f", difference))")
        
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "ToDo Title Missing", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //БД
    func getDayInfo() {
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            do{
                let dayCoreData = try context.fetch(DayNCoreData.fetchRequest()) as? [DayNCoreData]
                if let dayCoreData = dayCoreData {
                    dayNCD = dayCoreData
                    //Запихиваем в виджеты
                    endDayTimeField.text = convertDateToString(date: dayNCD[0].endDay!)
                    startDayTimeField.text = convertDateToString(date: dayNCD[0].startDay!)
                    availableTimeLabel.text = String(dayNCD[0].availableTime)
                    endDayTime = dayNCD[0].endDay!
                    startDayTime = dayNCD[0].startDay!
                    availableTime = String(dayNCD[0].availableTime)
                    
                }
                print("I get dayCD")
//                print(dayNCD)
            }
            catch{
                showAlert(message: "Could not retrieve the ToDo items from the database!  Please try again.")
                return
            }
        }
    }
    
    //Не используется
    func loadDefaultVal() {
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            let dayCoreData = DayNCoreData(entity: DayNCoreData.entity(), insertInto: context)
            
            dayCoreData.endDay = Date()
            dayCoreData.startDay = Date()
            dayCoreData.availableTime = 0.0
            
            do{
                 try context.save()
                //Запихиваем в виджеты
                print("place data")
            }
            catch{
                showAlert(message: "Could not retrieve the ToDo items from the database!  Please try again.")
                return
            }
        }
    }
    
    func updateDayTime(dayTime: Date, key: String) {
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            do{
                let dayCoreData = try context.fetch(DayNCoreData.fetchRequest()) as? [DayNCoreData]
                if let dayCoreData = dayCoreData {
                    dayNCD = dayCoreData
                    //Запихиваем в БД
                    dayNCD[0].setValue(dayTime, forKey: key)
                }
                print("I updated")
            }
            catch{
                showAlert(message: "Could not retrieve the ToDo items from the database!  Please try again.")
                return
            }
            do {
                try context.save()
            }
            catch {
                self.showAlert(message: "Data could not be saved!  Please try again.")
            }
        }
    }
    
    func updateAvailableTime(time: Double) {
        if let context = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext) {
            
            do{
                let dayCoreData = try context.fetch(DayNCoreData.fetchRequest()) as? [DayNCoreData]
                if let dayCoreData = dayCoreData {
                    dayNCD = dayCoreData
                    //Запихиваем в БД
                    dayNCD[0].setValue(time, forKey: "availableTime")
                    
                }
                print("I updated available")
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
    }
}
