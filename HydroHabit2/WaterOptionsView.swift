//
//  WaterOptionsView.swift
//  HydroHabit2
//
//  Created by Adam Heidmann on 2/18/26.
//

import CoreData
import SwiftUI
import WidgetKit

struct WaterOptionsView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @Environment(\.requestReview) var requestReview
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedUnitType: String
    @Binding var waterLogCount: Int
    @Binding var buttonPressed: Bool
    @Binding var waterAmountML: Double
    @Binding var goalAmountML: Double
    @Binding var recentWaterAmountSaved: Double
    @Binding var customAmountSaved: Bool
    
    @AppStorage("customAmountOz") private var customAmountOz: Double = 10
    @AppStorage("customAmountL") private var customAmountL: Double = 0.10
    @AppStorage("customAmountmL") private var customAmountmL: Double = 50
    
    var goalPercent:Double {
        let percent = (Double(waterAmountML) / Double(goalAmountML)) * Double(100)
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
        ZStack{

                VStack{
                    HStack{
                        
                        Spacer()
                        
                        Button{
                            
                            dismiss()
                            
                        }label:{
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .contentShape(Rectangle())            // makes the tap area circular
                            
                        }
                        
                    }.padding([.trailing, .top])
                    Spacer()
                }
                
            VStack{
               
                
                HStack(spacing: 15){
                    //small
                    Button {
                        
                        buttonPressed.toggle()
                        waterLogCount += 1
                        
                        let amount = Double(quickAddValue1) ?? 0
                        let amountML = convertToML(amount)
                        waterAmountML += amountML
                        
                        
                        saveAllWidgetData()
                        
                    
                        recentWaterAmountSaved = Double(quickAddValue1) ?? 0
                        
                        let newItem = WaterLog(context: moc)
                        newItem.id = UUID()
                        newItem.waterAmountML = amountML
                        newItem.dateSaved = Date()
               
                        try? moc.save()
                        
                        dismiss()
                    } label: {
                        
                        ZStack {
                            // Base circle with gradient fill for depth
                            Circle().fill(Color.blue.opacity(0.4))
                                .frame(width: 70, height: 70)
                            
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
                        
                        let amount = Double(quickAddValue2) ?? 0
                        let amountML = convertToML(amount)
                        waterAmountML += amountML
                        
                        saveAllWidgetData()
                        
                  
                        recentWaterAmountSaved = Double(quickAddValue2) ?? 0
                        
                        let newItem = WaterLog(context: moc)
                        newItem.id = UUID()
                        newItem.waterAmountML = amountML
                        newItem.dateSaved = Date()
                    
                        try? moc.save()
                        
                        dismiss()
                        
                    } label: {
                        
                        ZStack {
                            // Base circle with gradient fill for depth
                            Circle().fill(Color.blue.opacity(0.4))
                                .frame(width: 70, height: 70)
                            
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
                        
                        let amount = Double(quickAddValue3) ?? 0
                        let amountML = convertToML(amount)
                        waterAmountML += amountML
                        
                        saveAllWidgetData()
                        
                   
                        recentWaterAmountSaved = Double(quickAddValue3) ?? 0
                        
                        let newItem = WaterLog(context: moc)
                        newItem.id = UUID()
                        newItem.waterAmountML = amountML
                        newItem.dateSaved = Date()
              
                        try? moc.save()
                        
                        dismiss()
                        
                        
                        
                    } label: {
                        
                        ZStack {
                            // Base circle with gradient fill for depth
                            Circle().fill(Color.blue.opacity(0.4))
                                .frame(width: 70, height: 70)
                            
                            VStack {
                                Image(systemName: "waterbottle.fill")
                                    .font(.system(size: 24, weight: .bold))
                                
                                
                                Text("\(quickAddValue3)\(displayUnitType())")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                }
                .padding(.bottom, 20)
                
                Divider()
                    
                    //custom
                    HStack{
                        customAmountSliders.tint(.blue)//.colorMultiply(.blue)
                        slidersDisplayedValues
                        logButton
                    }.padding(.top, 20)
                
                
            
                
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
            
          dismiss()
            
        }label:{
            
            Image(systemName: "checkmark")
                .font(.system(size: 24))
                
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                            Circle()
                                .fill(Color.blue.opacity(0.4))
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
        buttonPressed.toggle()
        customAmountSaved = true
        
        // 1️⃣ Determine slider value based on unit
        let valueToLog: Double = {
            switch selectedUnitType {
            case "oz": return customAmountOz
            case "L":  return customAmountL
            default:   return customAmountmL
            }
        }()
        
        // 2️⃣ Convert to mL (single source of truth)
        let amountML = convertToML(valueToLog)
        
        // 3️⃣ Update totals (stored ONLY in mL)
        waterAmountML += amountML
        
        // 4️⃣ Save widget data
        saveAllWidgetData()
        
        // 5️⃣ Save recent amount (store mL, not unit value)
        recentWaterAmountSaved = amountML
        
        // 6️⃣ CoreData log (store mL only)
        let newItem = WaterLog(context: moc)
        newItem.id = UUID()
        newItem.waterAmountML = amountML
        newItem.dateSaved = Date()
        
        try? moc.save()
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
        selectedUnitType
    }
    
    func saveAllWidgetData() {
        guard let defaults = UserDefaults(suiteName: "group.HydroHabit") else { return }
        
        defaults.set(waterAmountML, forKey: "widgetWaterAmount")
        defaults.set(goalAmountML, forKey: "widgetGoalAmount")
        defaults.set(goalPercent, forKey: "widgetGoalPercentage")
        defaults.set(selectedUnitType, forKey: "widgetSelectedUnit")
        
        DispatchQueue.global(qos: .background).async {
                WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
            }
    }
    
    func convertToML(_ amount: Double) -> Double {
        switch selectedUnitType {
        case "oz":
            return amount * 29.5735
        case "L":
            return amount * 1000
        default: // mL
            return amount
        }
    }
    
}
