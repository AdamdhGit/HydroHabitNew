//
//  HydroHabit2App.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/11/25.
//

import SwiftUI

@main
struct HydroHabit2App: App {
    
    @AppStorage("setupFinished") var setupFinished = false
    //gets assigned after launch setup is finished, then immediately saves to private var inside content view.
    @AppStorage("selectedUnitType") var selectedUnitType = "oz"
    @AppStorage("goalAmount") var goalAmount: Double = 0
    
    var body: some Scene {
        WindowGroup {
            if setupFinished {
                ContentView(goalAmount: $goalAmount, selectedUnitType: $selectedUnitType).preferredColorScheme(.dark)
            } else {
                FirstLaunchView(setupFinished: $setupFinished, selectedUnitType: $selectedUnitType, goalAmount: $goalAmount)
            }
        }
    }
}
