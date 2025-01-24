//
//  WaterEntry.swift
//  HydroHabit2
//
//  Created by Adam Heidmann on 1/11/25.
//

import Foundation
import WidgetKit

struct WaterEntry: TimelineEntry {
    var date: Date
    //required so timeline knows when to use it.
    var widgetWaterAmount: Double
    var widgetGoalAmount: Double
    var widgetSelectedUnit: String
    var widgetGoalPercentage: Double
}
