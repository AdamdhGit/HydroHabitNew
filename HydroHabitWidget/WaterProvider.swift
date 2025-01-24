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
        //Context handles widget rendering for me, and Timeline<WaterEntry> will return a Timeline of the data type WaterEntry

        //MARK: maybe issue, but this gets filled as soon as entries are saved.
        //entries contains all our entries the timeline will receive.
        
        //in placeholder, waterAmount was just called for that. here, we are grabbing waterAmount to apply it to what is actually shown via the timeline. then adding it to our array of entries.
        //this grabs the updated value from our apps ContentView, because the data has been updated and stored in the UserDefaults AppGroup key we access here.
        
        
        let widgetWaterAmount = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetWaterAmount") ?? 0
        let widgetGoalAmount = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetGoalAmount") ?? 0
        let widgetSelectedUnit = UserDefaults(suiteName: "group.HydroHabit")?.string(forKey: "widgetSelectedUnit") ?? "oz"
        let widgetGoalPercentage = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetGoalPercentage") ?? 0
        
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        
        let entry = WaterEntry(date: Date(), widgetWaterAmount: widgetWaterAmount, widgetGoalAmount: widgetGoalAmount, widgetSelectedUnit: widgetSelectedUnit, widgetGoalPercentage: widgetGoalPercentage)
        
        //when the day changes, this one starts. if you always set to start at current day start, then it will always reflect the current day.
        let nextEntry = WaterEntry(date: endOfDay, widgetWaterAmount: 0, widgetGoalAmount: widgetGoalAmount, widgetSelectedUnit: widgetSelectedUnit, widgetGoalPercentage: 0)
        //timeline starts at 12:00AM, available to start taking data value changes made by user immediately.

            // Set the policy to refresh immediately after updating
        let timeline = Timeline(entries: [entry, nextEntry], policy: .after(endOfDay))
        //the one, WHOLE timeline starts at Date() - now. and ends at end of day (midnight).
        //therefore, the NEW ENTRY (timeline refreshed) captures Date() again - the new current day, after the end of the day.
            completion(timeline)
            //entry constantly updates as values change. there will be an additional refresh over night when new day takes place. the policy is what can happen WITHOUT a value change.
        
            //in other words, a 24 hour timeline, from midnight to midnight!
        
        
        //in a completion function, you run async code, and then at the end you specify how the result of that async code will be used. then you call the function which runs the async code, and then you use {parameter.. to use the result of the async code in the function. you can use any word for the parameter when calling the function.
    }
    //getTimeline calls the timeline from the Provider.

}
