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
    
    let genderTypes = ["Male", "Female"]
    @State var selectedGender: String = "Male"
    
    @State private var selectedTab: Int = 0
    
    @FocusState private var customGoalTextFocused: Bool
    
    var body: some View {
        
        ZStack {
            backgroundColor.ignoresSafeArea()
           
            
            TabView (selection: $selectedTab)  {
                
           
                    
                ZStack{
                  
                    VStack{
                        Spacer()
                        hydroHabitIntroText
                        
                        Image("waterCups")
                            .resizable()
                            .frame(width: 300, height: 300)
                           
                        Spacer()
                        Button("Get Started"){
                            selectedTab = 1
                        }.buttonStyle(.borderedProminent).tint(Color(red: 59/255, green: 89/255, blue: 152/255))
                            .padding(.bottom, 200)
                    }
                    
                }.tag(0).contentShape(Rectangle())
                    .gesture(DragGesture())
                
                ZStack{
                    VStack{
                        HStack{
                            Button{
                                selectedTab = 0
                            }label:{
                                Image(systemName: "chevron.left")
                                    .controlSize(.extraLarge)
                            }.tint(.white.opacity(0.5))
                            Spacer()
                        }.padding(.leading)
                        Spacer()
                    }
                    
                    VStack{
                      
                        Text("Pick your gender").padding(.top, 30)
                        genderPicker.padding()
                        Spacer()
                        Button("Next"){
                            selectedTab = 2
                        }.buttonStyle(.borderedProminent).tint(Color(red: 59/255, green: 89/255, blue: 152/255))
                            .padding(.bottom, 200)
                    }.padding(.top, 70)
                }.tag(1).contentShape(Rectangle())
                    .gesture(DragGesture())
                
                ZStack{
                    
                    VStack{
                        HStack{
                            Button{
                                selectedTab = 1
                            }label:{
                                Image(systemName: "chevron.left")
                                    .controlSize(.extraLarge)
                            }.tint(.white.opacity(0.5))
                            Spacer()
                        }.padding(.leading)
                        Spacer()
                    }
                   
                    
                    VStack{
                        
                        
                        howWouldYouLikeToMeasureText.padding(.horizontal)
                        unitTypePicker.padding(.horizontal)
                        Spacer()
                        Button("Next"){
                            selectedTab = 3
                        }.buttonStyle(.borderedProminent).tint(Color(red: 59/255, green: 89/255, blue: 152/255))
                            .padding(.bottom, 200)
                    }.padding(.top, 70)

                }.tag(2).contentShape(Rectangle())
                    .gesture(DragGesture())
                
                ZStack{
                 
                    VStack{
                        HStack{
                            Button{
                                selectedTab = 2
                            }label:{
                                Image(systemName: "chevron.left")
                                    .controlSize(.extraLarge)
                            }.tint(.white.opacity(0.5))
                            Spacer()
                        }.padding(.leading)
                        Spacer()
                    }
                    
                    VStack{
                        
                        
                        selectIntakeGoalText
                        
                        intakeDisclaimerText.padding(.horizontal).padding(.bottom, 20).padding(.top, 10)
                        
                        intakeGoalPicker.padding(.horizontal)
                        
                        customGoalEntryView
                       
                        
                            
                        
                        Spacer()
                        Button("Next"){
                            selectedTab = 4
                        }.buttonStyle(.borderedProminent).tint(Color(red: 59/255, green: 89/255, blue: 152/255))
                            .padding(.bottom, 200)
                            .disabled(dailyGoal == "Custom Goal" && customGoalAmount.isEmpty)
                    }.padding(.top, 70)

                }.tag(3).contentShape(Rectangle())
                    .gesture(DragGesture())

                   
                ZStack{
                   
                    VStack{
                        HStack{
                            Button{
                                selectedTab = 3
                            }label:{
                                Image(systemName: "chevron.left") .controlSize(.extraLarge)
                                
                            }.tint(.white.opacity(0.5))
                            Spacer()
                        }.padding(.leading)
                        Spacer()
                    }
                    VStack{
                        
                       
                        Spacer()
                        startHydratingButton.buttonStyle(.borderedProminent).tint(Color(red: 59/255, green: 89/255, blue: 152/255))
                            .padding(.bottom, 200)
                        
                    }.padding(.top, 70)

                }.tag(4).contentShape(Rectangle())
                    .gesture(DragGesture())
                    
                 
                    
                 
                    
                
                
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            // hides dots
             
        }
    }
    
    //MARK: Views and Functions
    
    var hydroHabitIntroText: some View {
        Text("Stay hydrated and build the habit - with HydroHabit.").foregroundStyle(.white).fontWeight(.light).font(.title2).padding(.horizontal)
    }
    
    var howWouldYouLikeToMeasureText: some View {
        Text("How would you like to measure your water intake?").padding(.top, 30).foregroundStyle(.white).multilineTextAlignment(.center)
    }
    
    var genderPicker: some View {
        Picker("Gender", selection: $selectedGender) {
            ForEach(genderTypes, id: \.self){i in
                Text(i)
                
            }
        }.pickerStyle(.segmented)
    }
    
    var unitTypePicker: some View {
        Picker("Unit Type", selection: $selectedUnitType) {
            ForEach(unitTypes, id: \.self){i in
                Text(i)
                
            }
        }.pickerStyle(.segmented)
    }
    
    var selectIntakeGoalText: some View {
        Text("Select Your Daily Intake Goal").padding(.top, 30).foregroundStyle(.white)
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
            
            }.pickerStyle(.segmented)
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
                    
                    Text("Enter Your Daily Intake Goal in \(selectedUnitType)").foregroundStyle(.white).padding(.top, 15).font(.callout)
     
                       
                        
                        TextField("Custom Goal Amount in \(selectedUnitType)", text: $customGoalAmount)
                            .focused($customGoalTextFocused)
                            .keyboardType(selectedUnitType == "L" ? .decimalPad : .numberPad).padding().onChange(of: customGoalAmount) { _, newValue in
                            if newValue.count > 5 {
                                customGoalAmount = String(newValue.prefix(5))
                            }
                        }.background{
                            RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.25)).frame(height: 40)
                        }
                        .frame(width: 300)
                        .onAppear {
                            customGoalTextFocused.toggle()
                        }
                        .submitLabel(.done)
                        
                    
                }
            }
        }
        //.transition(.slide)
        .onChange(of: dailyGoal) { oldValue, newValue in
            if newValue == "Custom Goal" {
                
                withAnimation {
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
        Text("General intake estimates based on 'National Academies of Sciences, Engineering, and Medicine. Dietary Reference Intakes for Water, Potassium, Sodium, Chloride, and Sulfate (2005)' - for more specific recommendations, consult your doctor.").foregroundStyle(.white).opacity(0.5).font(.caption).multilineTextAlignment(.center)
    }
    
    var backgroundColor: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.45, blue: 0.95),   // rich blue
                Color(red: 0.10, green: 0.12, blue: 0.35)    // deeper blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
    var startHydratingButton: some View {
        Button("Start Hydrating"){
           saveGoalAmount()
           setupFinished = true
        }.disabled(dailyGoal == "Custom Goal" && customGoalAmount.isEmpty ? true : false)
    }
}

#Preview {
    @Previewable @State var setupFinished = false
    @Previewable @State var selectedUnitType = "oz"
    @Previewable @State  var goalAmount: Double = 100
//**use static properties for live previews instead of constants!
    
    FirstLaunchView(setupFinished: $setupFinished, selectedUnitType: $selectedUnitType, goalAmount: $goalAmount)
}
