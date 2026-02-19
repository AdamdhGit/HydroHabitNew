//
//  WaterOptionsView.swift
//  HydroHabit2
//
//  Created by Adam Heidmann on 2/18/26.
//

import SwiftUI
import WidgetKit

struct WaterOptionsView: View {
    
    @Environment(\.requestReview) var requestReview
    
    @Binding var selectedUnitType: String
    @Binding var waterLogCount: Int
    @Binding var buttonPressed: Bool
    @Binding var waterAmount: Double
    @Binding var customAmount: Double
    @Binding var goalAmount: Double
    @Binding var recentIsSaved: Bool
    @Binding var recentWaterAmountSaved: Double
    @Binding var customAmountSaved: Bool
    
    @AppStorage("customAmountOz") private var customAmountOz: Double = 10
    @AppStorage("customAmountL") private var customAmountL: Double = 0.10
    @AppStorage("customAmountmL") private var customAmountmL: Double = 50
    
    var goalPercent:Double {
        let percent = (Double(waterAmount) / Double(goalAmount)) * Double(100)
        return percent
    }
    
    var quickAddValue1: String {
        if selectedUnitType == "oz"{
            return "8"
        } else if selectedUnitType == "mL" {
            return "250"
        } else if selectedUnitType == "L" {
            return "0.25"
        }
        return "0"
    }
    
    var quickAddValue2: String {
        if selectedUnitType == "oz" {
            return "12"
        } else if selectedUnitType == "mL" {
            return "500"
        } else if selectedUnitType == "L" {
            return "0.5"
        }
        return "0"
    }
    
    var quickAddValue3: String {
        if selectedUnitType == "oz" {
            return "16"
        } else if selectedUnitType == "mL"{
            return "750"
        } else if selectedUnitType == "L" {
            return "0.75"
        }
        return "0"
    }
    
    var body: some View {
        VStack{
   
                //small
                Button {
                    
                    buttonPressed.toggle()
                    waterLogCount += 1
                   
                    waterAmount += Double(quickAddValue1) ?? 0
                    saveAllWidgetData()
                    
                    recentIsSaved = true
                    recentWaterAmountSaved = Double(quickAddValue1) ?? 0
                    
                    
                } label: {
                    
                    ZStack {
                        // Base circle with gradient fill for depth
                        Circle().fill(Color.blue.opacity(0.4))
                            .frame(width: 60, height: 60)
                        
                        VStack {
                            Image(systemName:"cup.and.saucer.fill")
                                .font(.system(size: 24, weight: .bold))
                              
                            
                            Text("\(quickAddValue1)\(displayUnitType())")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
               
               
                
                //medium
                Button {
                    
                    buttonPressed.toggle()
                    waterLogCount += 1
                  
                    waterAmount += Double(quickAddValue2) ?? 0
                    saveAllWidgetData()
                    
                    recentIsSaved = true
                    recentWaterAmountSaved = Double(quickAddValue2) ?? 0
                    
                   
                    
                } label: {
                    
                    ZStack {
                        // Base circle with gradient fill for depth
                        Circle().fill(Color.blue.opacity(0.4))
                               .frame(width: 60, height: 60)

                        VStack {
                            Image(systemName: "mug.fill")
                                .font(.system(size: 24, weight: .bold))
                               
                            
                            Text("\(quickAddValue2)\(displayUnitType())")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
               
              
                
                //large
                Button {
                    
                    buttonPressed.toggle()
                    waterLogCount += 1
                   
                    waterAmount += Double(quickAddValue3) ?? 0
                    
                    saveAllWidgetData()
                    
                    recentIsSaved = true
                    recentWaterAmountSaved = Double(quickAddValue3) ?? 0
                    
                  
                    
                } label: {
                    
                    ZStack {
                        // Base circle with gradient fill for depth
                        Circle().fill(Color.blue.opacity(0.4))
                               .frame(width: 60, height: 60)

                        VStack {
                            Image(systemName: "waterbottle.fill")
                                .font(.system(size: 24, weight: .bold))
                               
                            
                            Text("\(quickAddValue3)\(displayUnitType())")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
              
                
                //custom
                HStack{
                    customAmountSliders.tint(.blue)
                    slidersDisplayedValues
                    logButton
                }
               
            
        }
    }
    
    var customAmountSliders: some View {
        HStack{
            //sliders
            if selectedUnitType == "oz" {
                
                Slider(value: $customAmountOz, in: 1...32, step: 1).frame(width: 150)
                
            } else if selectedUnitType == "L" {
                
                Slider(value: $customAmountL, in: 0.25...2.00, step: 0.25).frame(width: 150)
                    .onChange(of: customAmountL) { _, _ in
                        print(customAmountL)
                        print(displaySliderValues(amount: customAmountL))
                    }
                
            } else if selectedUnitType == "mL" {
                
                Slider(value: $customAmountmL, in: 50...2000, step: 50).frame(width: 150)
                
            }
        }
    }
    
    var slidersDisplayedValues: some View {
        HStack{
            //slider unit type text
            if selectedUnitType == "oz" {
                
                Text("\(displaySliderValues(amount: customAmountOz)) \(displayUnitType())").foregroundStyle(.blue).frame(width: 75)
                
            } else if selectedUnitType == "L" {
                
                Text("\(displaySliderValues(amount: customAmountL)) \(displayUnitType())").foregroundStyle(.blue).frame(width: 75)
                
            } else if selectedUnitType == "mL" {
                
                Text("\(displaySliderValues(amount: customAmountmL)) \(displayUnitType())").foregroundStyle(.blue).frame(width: 75)
                
            }
        }.frame(width:75)
    }
    
    var logButton: some View {
        Button{
            
          logCustomAmount()
            
            
        }label:{
            
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                            Circle()
                                .fill(Color.blue)
                        )
                        .contentShape(Circle())            // makes the tap area circular
            
        }
        .buttonStyle(.plain)
        .onChange(of: waterLogCount) { _, newValue in
                if newValue == 3 || newValue == 30 || newValue == 100  {
                    requestReview()
                }
        }
    }
    
    func logCustomAmount() {
        
        waterLogCount += 1
        
        if selectedUnitType == "oz" {
            customAmount = customAmountOz
        } else if selectedUnitType == "L" {
            customAmount = customAmountL
        } else if selectedUnitType == "mL" {
            customAmount = customAmountmL
        }
        
        customAmountSaved = true
        
        buttonPressed.toggle()
        
        waterAmount += customAmount
        
        saveAllWidgetData()
        
        recentIsSaved = true
        recentWaterAmountSaved = Double(customAmount)
    }
    
    func displaySliderValues(amount: Double) -> String {
        if selectedUnitType == "oz" {
            return String(format: "%.0f", amount)
        } else if selectedUnitType == "L" {
            return String(format: "%.2f", ((amount * 100).rounded() / 100))
        } else if selectedUnitType == "mL" {
            return String(format: "%.0f", amount)
        }
        return ""
    }
    
    func displayUnitType() -> String {
        if selectedUnitType == "oz" {
            return "oz"
        } else if selectedUnitType == "L" {
            return "L"
        } else if selectedUnitType == "mL" {
            return "mL"
        }
        return "oz"
    }
    
    func saveAllWidgetData() {
        guard let defaults = UserDefaults(suiteName: "group.HydroHabit") else { return }
        
        defaults.set(waterAmount, forKey: "widgetWaterAmount")
        defaults.set(goalAmount, forKey: "widgetGoalAmount")
        defaults.set(goalPercent, forKey: "widgetGoalPercentage")
        defaults.set(selectedUnitType, forKey: "widgetSelectedUnit")
        
        DispatchQueue.global(qos: .background).async {
                WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
            }
    }
    
}
