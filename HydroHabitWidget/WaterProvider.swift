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
        let calendar = Calendar.current
        let now = Date()

        // 1. Fetch saved data
        let savedWaterAmount = defaults?.double(forKey: "widgetWaterAmount") ?? 0
        let savedGoalAmount = defaults?.double(forKey: "widgetGoalAmount") ?? 0
        let savedUnit = defaults?.string(forKey: "widgetSelectedUnit") ?? "oz"
        let savedGoalPercent = defaults?.double(forKey: "widgetGoalPercentage") ?? 0
        let lastSavedDay = defaults?.object(forKey: "savedDay") as? Date ?? Date.distantPast

        // 2. LOGIC: Is the saved data actually from today?
        // If user opens phone at 10am Tuesday, but last log was 5pm Monday, this ensures 'now' shows 0.
        let isDataFromToday = calendar.isDate(now, inSameDayAs: lastSavedDay)
        
        let currentWater = isDataFromToday ? savedWaterAmount : 0
        let currentPercent = isDataFromToday ? savedGoalPercent : 0

        // ENTRY 1: Right Now
        let nowEntry = WaterEntry(
            date: now,
            widgetWaterAmount: currentWater,
            widgetGoalAmount: savedGoalAmount,
            widgetSelectedUnit: savedUnit,
            widgetGoalPercentage: currentPercent
        )

        // ENTRY 2: Exactly at Midnight (The Visual Flip)
        // This is the "Guarantee." iOS swaps the view at 12:00:00 AM without running code.
        
        let nextMidnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        
        let midnightEntry = WaterEntry(
            date: nextMidnight,
            widgetWaterAmount: 0,
            widgetGoalAmount: savedGoalAmount,
            widgetSelectedUnit: savedUnit,
            widgetGoalPercentage: 0
        )
        
        // ENTRY 3: Safety Net (Midnight of the following day)
        // Ensures that even if the user doesn't touch the phone for 48 hours, it stays at 0.
        let dayAfterMidnight = calendar.date(byAdding: .day, value: 1, to: nextMidnight)!
        let safetyEntry = WaterEntry(
            date: dayAfterMidnight,
            widgetWaterAmount: 0,
            widgetGoalAmount: savedGoalAmount,
            widgetSelectedUnit: savedUnit,
            widgetGoalPercentage: 0
        )

        // .atEnd tells iOS to call getTimeline again once it runs out of these entries.
        let timeline = Timeline(entries: [nowEntry, midnightEntry, safetyEntry], policy: .atEnd)
        completion(timeline)
    }

}
