//
//  HydroHabit2App.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/11/25.
//

import CoreData
import SwiftUI

@main
struct HydroHabit2App: App {
    
    var dataController = DataController()
    
    @AppStorage("setupFinished") var setupFinished = false
    //gets assigned after launch setup is finished, then immediately saves to private var inside content view.
    @AppStorage("selectedUnitType") var selectedUnitType = "oz"
    @AppStorage("goalAmount") var goalAmount: Double = 0
    
    var body: some Scene {
        WindowGroup {
            if setupFinished {
                ContentView(goalAmountML: $goalAmount, selectedUnitType: $selectedUnitType).preferredColorScheme(.dark).environment(\.managedObjectContext, dataController.container.viewContext)
            } else {
                FirstLaunchView(setupFinished: $setupFinished, selectedUnitType: $selectedUnitType, goalAmount: $goalAmount)
            }
        }
    }
}
