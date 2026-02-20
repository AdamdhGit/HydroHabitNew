//
//  WaterProvider.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/11/25.
//

import Foundation
import WidgetKit

struct WaterProvider: TimelineProvider {
    //TimelineProvider provides data to the timeline. The timeline is when updates of the widget should take place. overall manages the widget data.
    
    private var placeholderEntry:WaterEntry {
        let widgetWaterAmount = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetWaterAmount") ?? 0
        let widgetGoalAmount = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetGoalAmount") ?? 0
        let widgetSelectedUnit = UserDefaults(suiteName: "group.HydroHabit")?.string(forKey: "widgetSelectedUnit") ?? "oz"
        let widgetGoalPercentage = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetGoalPercentage") ?? 0
        
        let entry = WaterEntry(date: Date(), widgetWaterAmount: widgetWaterAmount, widgetGoalAmount: widgetGoalAmount, widgetSelectedUnit: widgetSelectedUnit, widgetGoalPercentage: widgetGoalPercentage)
        return entry
    }
    //placeholder before data passing begins.
    
    func placeholder(in context: Context) -> WaterEntry {
        return placeholderEntry
    }
    //gives to the timeline an entry of a generic visual representation of widget before data loads first time. first thing timeline will show.THIS HAS THE DATA ALWAYS! ISSUE LIES AFTER THIS. APP IS SENDING THE DATA PROPERLY!
    
    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> ()) {
        completion(placeholderEntry)
    }
    //gives a snapshot to the widget gallery (where users select the widget to use) featuring generic data.
    //Context just automatically generates for us.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void) {

        let defaults = UserDefaults(suiteName: "group.HydroHabit")

        let savedWaterAmount = defaults?.double(forKey: "widgetWaterAmount") ?? 0
        let savedGoalAmount = defaults?.double(forKey: "widgetGoalAmount") ?? 0
        let savedUnit = defaults?.string(forKey: "widgetSelectedUnit") ?? "oz"
        let savedGoalPercent = defaults?.double(forKey: "widgetGoalPercentage") ?? 0
        let lastSavedDay = defaults?.object(forKey: "widgetSavedDay") as? Date ?? Date()

        let today = Calendar.current.startOfDay(for: Date())

        // ✅ Reset if lastSavedDay is not today
        let currentWaterAmount: Double
        let currentGoalPercent: Double
        if Calendar.current.isDate(today, inSameDayAs: lastSavedDay) {
            currentWaterAmount = savedWaterAmount
            currentGoalPercent = savedGoalPercent
        } else {
            currentWaterAmount = 0
            currentGoalPercent = 0
        }

        let nowEntry = WaterEntry(
            date: Date(),
            widgetWaterAmount: currentWaterAmount,
            widgetGoalAmount: savedGoalAmount,
            widgetSelectedUnit: savedUnit,
            widgetGoalPercentage: currentGoalPercent
        )

        // Next midnight entry
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let midnightEntry = WaterEntry(
            date: nextMidnight,
            widgetWaterAmount: 0,
            widgetGoalAmount: savedGoalAmount,
            widgetSelectedUnit: savedUnit,
            widgetGoalPercentage: 0
        )

        let timeline = Timeline(entries: [nowEntry, midnightEntry], policy: .atEnd)
        completion(timeline)
    }

}
