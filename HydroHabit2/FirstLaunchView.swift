//
//  FirstLaunchView.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/13/25.
//

import SwiftUI

struct FirstLaunchView: View {
    
    @Binding var setupFinished: Bool
    var unitTypes = ["oz", "L", "mL"]
    @Binding var selectedUnitType: String
    @State var customGoalSelected = false
    @State var dailyGoal:String = "Men (125 oz)"
    var ozGoalTypes:[String] = ["Men (125 oz)", "Women (91 oz)", "Custom Goal"]
    var LGoalTypes = ["Men (3.7 L)", "Women (2.7 L)", "Custom Goal"]
    var mLGoalTypes = ["Men (3700 mL)", "Women (2700 mL)", "Custom Goal"]
    @State var customGoalAmount = ""
    @Binding var goalAmount: Double
    
    var body: some View {
        
        ZStack {
            
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                VStack {
                    
                    hydroHabitIntroText
                    
                    howWouldYouLikeToMeasureText
                    
                    unitTypePicker
                    
                    selectIntakeGoalText

                    intakeGoalPicker

                    customGoalEntryView

                    getStartedButton
                    
                    Divider().padding(.top, 30)
                    
                    intakeDisclaimerText
                    
                    Spacer()
                    
                }.padding(.top, 70).preferredColorScheme(.dark).padding(.horizontal)
                
            }
        }
    }
    
    //MARK: Views and Functions
    
    var hydroHabitIntroText: some View {
        Text("Stay hydrated and build the habit - with HydroHabit.").foregroundStyle(.cyan).fontWeight(.light).font(.title2).padding(.horizontal)
    }
    
    var howWouldYouLikeToMeasureText: some View {
        Text("How would you like to measure your water intake?").padding(.top, 30).foregroundStyle(.gray)
    }
    
    var unitTypePicker: some View {
        Picker("Unit Type", selection: $selectedUnitType) {
            ForEach(unitTypes, id: \.self){i in
                Text(i)
                
            }
        }.pickerStyle(.segmented)
    }
    
    var selectIntakeGoalText: some View {
        Text("Select Your Daily Intake Goal").padding(.top, 30).foregroundStyle(.gray)
    }
    
    var intakeGoalPicker: some View {
        Picker("Goal", selection: $dailyGoal) {
                if selectedUnitType == "oz" {
                    ForEach(ozGoalTypes, id: \.self){j in
                        Text(j)
                    }
                } else if selectedUnitType == "L" {
                    ForEach(LGoalTypes, id: \.self){j in
                        Text(j)
                    }
                } else if selectedUnitType == "mL" {
                    ForEach(mLGoalTypes, id: \.self){j in
                        Text(j)
                    }
            }
            
            }.pickerStyle(.wheel).frame(height: 140)
            .onChange(of: dailyGoal) { oldValue, newValue in
                print(dailyGoal)
            }
            .onChange(of: selectedUnitType) { oldValue, newValue in
                if selectedUnitType == "oz" {
                    dailyGoal = "Men (125 oz)"
                } else if selectedUnitType == "L" {
                    dailyGoal = "Men (3.7 L)"
                } else if selectedUnitType == "mL" {
                    dailyGoal = "Men (3700 mL)"
                }
            }
    }
    
    var customGoalEntryView: some View {
        VStack {
            
            if (dailyGoal == "Custom Goal") && customGoalSelected {
                
                VStack {
                    
                    Text("Enter Your Daily Intake Goal in \(selectedUnitType)").foregroundStyle(.gray)
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundStyle(.cyan)
                        
                        TextField("Custom Goal Amount in \(selectedUnitType)", text: $customGoalAmount).keyboardType(selectedUnitType == "L" ? .decimalPad : .numberPad).padding().onChange(of: customGoalAmount) { _, newValue in
                            if newValue.count > 5 {
                                customGoalAmount = String(newValue.prefix(5))
                            }
                        }
                        
                    }.frame(height: 60)
                    
                }
            }
        }
        .transition(.slide)
        .onChange(of: dailyGoal) { oldValue, newValue in
            if newValue == "Custom Goal" {
                withAnimation{
                    customGoalSelected = true
                }
            } else {
                customGoalSelected = false
            }
        }
    }
    
    func saveGoalAmount() {
        if dailyGoal == "Custom Goal" {
            goalAmount = Double(customGoalAmount) ?? 0
        } else if dailyGoal == "Men (125 oz)" {
            goalAmount = Double(125)
        } else if dailyGoal == "Women (91 oz)" {
            goalAmount = Double(91)
        } else if dailyGoal == "Men (3.7 L)" {
            goalAmount = Double(3.7)
        } else if dailyGoal == "Women (2.7 L)" {
            goalAmount = Double(2.7)
        } else if dailyGoal == "Men (3700 mL)" {
            goalAmount = Double(3700)
        } else if dailyGoal == "Women (2700 mL)" {
            goalAmount = Double(2700)
        }
    }
    
    var intakeDisclaimerText: some View {
        Text("General intake estimates based on 'National Academies of Sciences, Engineering, and Medicine. Dietary Reference Intakes for Water, Potassium, Sodium, Chloride, and Sulfate (2005)' - for more specific recommendations, consult your doctor.").foregroundStyle(.gray).font(.caption).padding(.top, 20)
    }
    
    var backgroundColor: Color {
        Color(red: 0.06, green: 0.06, blue: 0.06)
    }
    
    var getStartedButton: some View {
        Button("Get Started"){
           saveGoalAmount()
           setupFinished = true
        }.buttonStyle(.borderedProminent).tint(.black).opacity(0.7).padding(.top, 15).disabled(dailyGoal == "Custom Goal" && customGoalAmount.isEmpty ? true : false)
    }
}

#Preview {
    @Previewable @State var setupFinished = false
    @Previewable @State var selectedUnitType = "oz"
    @Previewable @State  var goalAmount: Double = 100
//**use static properties for live previews instead of constants!
    
    FirstLaunchView(setupFinished: $setupFinished, selectedUnitType: $selectedUnitType, goalAmount: $goalAmount)
}
