//
//  ToDo.swift
//  ToDo
//
//  Created by MacBook Air on 28.11.2019.
//  Copyright © 2019 MacBook Air. All rights reserved.
//

import UIKit

class ToDo {
    var name = ""
    var important = false
    var priority = 0
    var timeForTask = 0.0
    var timeLeft = 0.0
    
    var startTimePlanning = Date()
    var endTimePlanning = Date()
    
    var doTaskButtonState = ""
    var startDoTaskTime = Date()
    var endDoTaskTime = Date()
}
