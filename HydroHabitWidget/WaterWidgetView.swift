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
        // Since saveAllWidgetData already floored the value,
        // we just display it as a whole number.
        String(format: "%.0f", entry.widgetGoalPercentage)
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
                    
                case .systemSmall: Text("\(displayUnitWithPrefixes(amountML: entry.widgetWaterAmount)) \(entry.widgetSelectedUnit) of \(displayUnitWithPrefixes(amountML: entry.widgetGoalAmount)) \(entry.widgetSelectedUnit)")
                        .foregroundStyle(.cyan).font(.caption)
                    
                default: Text("\(displayUnitWithPrefixes(amountML: entry.widgetWaterAmount)) \(entry.widgetSelectedUnit) of \(displayUnitWithPrefixes(amountML: entry.widgetGoalAmount)) \(entry.widgetSelectedUnit)")
                    .foregroundStyle(.cyan).font(.title3)}
                
                Spacer()
                
            }
        }
        .background(Color.clear)
        .containerBackground(for: .widget){
             Color(red: 0.1, green: 0.1, blue: 0.1)
            
        }
    }
    
    func displayUnitWithPrefixes(amountML: Double) -> String {
        // 👈 prevents negative drift in the widget display
        let safeML = max(0, amountML)
        
        switch entry.widgetSelectedUnit {
        case "L":
            let liters = safeML / 1000
            return String(format: "%.2f", liters)
        case "oz":
            let ounces = safeML / 29.5735
            return String(format: "%.0f", ounces.rounded())
        default: // mL
            return String(format: "%.0f", safeML.rounded())
        }
    }

}
