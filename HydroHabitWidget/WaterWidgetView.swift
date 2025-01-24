//
//  WaterWidgetView.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/11/25.
//

import SwiftUI
import WidgetKit


struct WaterWidgetView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    var entry: WaterEntry
    var formattedGoalPercent: String {
        if entry.widgetGoalPercentage >= 100 {
            return "100" // Directly show 100% when the value is 99.5 or higher
        } else if entry.widgetGoalPercentage > 99 && entry.widgetGoalPercentage < 100 {
            if entry.widgetGoalPercentage == floor(entry.widgetGoalPercentage) {
                //if goalPercent has no decimals, show as whole number
                return String(format: "%.0f", entry.widgetGoalPercentage)
            } else {
                //show with the decimal it has
                return String(format: "%g", entry.widgetGoalPercentage, floor(entry.widgetGoalPercentage * 100) / 100) 
            }
        } else if entry.widgetGoalPercentage < 90 {
            return String(format: "%.0f", entry.widgetGoalPercentage)
        }
        return String(format: "%.0f", entry.widgetGoalPercentage)
    }
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Image(systemName: "drop").foregroundStyle(.cyan).font(.title).padding(.bottom, 10).bold()
                
                Spacer()
                
            }
            
            HStack {
                
                switch widgetFamily {
                    
                case .systemSmall: Text("\(formattedGoalPercent)%").font(.title3).foregroundStyle(.cyan)
                    
                default: Text("\(formattedGoalPercent)%").font(.title).foregroundStyle(.cyan)
                    
                }

                Spacer()
                
            }
            
            HStack {
                
                switch widgetFamily {
                    
                case .systemSmall: Text("\(displayUnitWithPrefixes(amount: entry.widgetWaterAmount)) \(entry.widgetSelectedUnit) of \(displayUnitWithPrefixes(amount: entry.widgetGoalAmount)) \(entry.widgetSelectedUnit)")
                        .foregroundStyle(.cyan).font(.caption)
                    
                default: Text("\(displayUnitWithPrefixes(amount: entry.widgetWaterAmount)) \(entry.widgetSelectedUnit) of \(displayUnitWithPrefixes(amount: entry.widgetGoalAmount)) \(entry.widgetSelectedUnit)")
                    .foregroundStyle(.cyan).font(.title3)}
                
                Spacer()
                
            }
        }
        .background(Color.clear)
        .containerBackground(for: .widget){
             Color(red: 0.1, green: 0.1, blue: 0.1)
            
        }
    }
    
    func displayUnitWithPrefixes(amount: Double) -> String {
        if entry.widgetSelectedUnit == "oz" {
            let stringOz = String(format: "%g", amount).prefix(6)
            return String(stringOz)
        } else if entry.widgetSelectedUnit == "L" {
            let stringL = String(format: "%g", amount).prefix(6)
            return String(stringL)
        } else if entry.widgetSelectedUnit == "mL" {
            let stringmL = String(format: "%g", amount).prefix(7)
            return String(stringmL)
        }
        return "oz"
    }

}
