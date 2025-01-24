//
//  WaterWidgetExtension.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/11/25.
//

import SwiftUI
import WidgetKit

@main
struct WaterWidgetExtension: Widget {
    
    let kind: String = "HydroHabit"
    
    var body: some WidgetConfiguration {

        StaticConfiguration(
            //static because no user configured options for the widget. yes data can update, but configuration options would be like selecting which habits to display in the widget from a habit tracking app. want to allow configure? use IntentConfiguration.
            kind: kind,
            //identifier for the widget
            provider: WaterProvider(),
            //pass in our provider - which handles all our data and timeline update specifications.
            content: { WaterWidgetView(entry: $0) }
            //renders the widget
        )
        .configurationDisplayName("HydroHabit")
        //widget gallery name when user is selecting the widget to use
        .description("Track Water Intake")
        //widget gallery description
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
        //the widget sizes the user can choose from
        
    }
}

#Preview(as: .systemSmall) {
    WaterWidgetExtension()
} timeline: {
    WaterEntry(date: .now, widgetWaterAmount: 1, widgetGoalAmount: 1.0, widgetSelectedUnit: "oz", widgetGoalPercentage: 50)
    WaterEntry(date: .now + 1, widgetWaterAmount: 2,  widgetGoalAmount: 2.0, widgetSelectedUnit: "oz", widgetGoalPercentage: 50)
}

#Preview(as: .systemMedium) {
    WaterWidgetExtension()
} timeline: {
    WaterEntry(date: .now, widgetWaterAmount: 1,  widgetGoalAmount: 1.0, widgetSelectedUnit: "oz", widgetGoalPercentage: 50)
    WaterEntry(date: .now + 1, widgetWaterAmount: 2,  widgetGoalAmount: 2.0, widgetSelectedUnit: "oz", widgetGoalPercentage: 50)
}

#Preview(as: .systemLarge) {
    WaterWidgetExtension()
} timeline: {
    WaterEntry(date: .now, widgetWaterAmount: 1,  widgetGoalAmount: 1.0, widgetSelectedUnit: "oz", widgetGoalPercentage: 50)
    WaterEntry(date: .now + 1, widgetWaterAmount: 2,  widgetGoalAmount: 2.0, widgetSelectedUnit: "oz", widgetGoalPercentage: 50)
}
