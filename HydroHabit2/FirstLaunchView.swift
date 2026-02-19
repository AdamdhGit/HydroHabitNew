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
    @State var dailyGoal:String = ""
    var ozGoalTypesMen:[String] = ["125 oz", "Custom Goal"]
    var ozGoalTypesWomen:[String] = ["91 oz", "Custom Goal"]
    var LGoalTypesMen = ["3.7 L", "Custom Goal"]
    var LGoalTypesWomen = ["2.7 L", "Custom Goal"]
    var mLGoalTypesMen = ["3700 mL", "Custom Goal"]
    var mLGoalTypesWomen = ["2700 mL", "Custom Goal"]
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
                        /*
                        Button("Get Started"){
                            selectedTab = 1
                        }.buttonStyle(.borderedProminent).tint(Color(red: 59/255, green: 89/255, blue: 152/255))
                            .padding(.bottom, 150)
                        */
                        Button {
                            selectedTab = 1
                        } label: {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 59/255, green: 89/255, blue: 152/255))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 150)
                    }
                    
                }.tag(0)
                
                ZStack{
                    
                    VStack{
                      
                        Text("Pick your gender").padding(.top, 30)
                        genderPicker.padding()
                        Image(selectedGender == "Male" ? "manWater" : "womanWater")
                            .resizable()
                            .frame(width: 300, height: 300)
                        Spacer()
                        Button {
                            selectedTab = 2
                        } label: {
                            Text("Next")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 59/255, green: 89/255, blue: 152/255))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 150)
                    }.padding(.top, 70)
                }.tag(1)
                
                ZStack{
                   
                    
                    VStack{
                        
                        
                        howWouldYouLikeToMeasureText.padding(.horizontal)
                        unitTypePicker.padding(.horizontal)
                        Image("waterMeasure")
                            .resizable()
                            .frame(width: 300, height: 300)
                           
                        Spacer()
                        Button {
                            selectedTab = 3
                        } label: {
                            Text("Next")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 59/255, green: 89/255, blue: 152/255))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 150)
                    }.padding(.top, 70)

                }.tag(2)
                
                ZStack{
                    
                    VStack{
                        
                        
                        selectIntakeGoalText
                        
                        intakeDisclaimerText.padding(.horizontal).padding(.bottom, 20).padding(.top, 2)
                        
                        intakeGoalPicker.padding(.horizontal)
                        
                        customGoalEntryView
                       
                        
                            
                     
                        
                        Spacer()
                        Image("waterTrophy")
                            .resizable()
                            .frame(width: 150, height: 150)
                        Button {
                            selectedTab = 4
                        } label: {
                            Text("Next")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 59/255, green: 89/255, blue: 152/255))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 150)
                        .disabled(dailyGoal == "Custom Goal" && customGoalAmount.isEmpty)
                    }.padding(.top, 70)

                }.tag(3)

                   
                ZStack{
                   
                    VStack{
                        
                        Text("You’re all set! Your hydration journey starts now.").foregroundStyle(.white).fontWeight(.light).font(.title3)
                        
                        Image("beachChair")
                            .resizable()
                            .frame(width: 350, height: 350)
                       
                        Spacer()
                        
                        Button {
                            saveGoalAmount()
                            setupFinished = true
                        } label: {
                            Text("Start Hydrating")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 59/255, green: 89/255, blue: 152/255))
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 150)
                        .disabled(dailyGoal == "Custom Goal" && customGoalAmount.isEmpty ? true : false)
                        
                    }.padding(.top, 70)

                }.tag(4)
                    
                 
                    
                 
                    
                
                
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            // hides dots
            
            if selectedTab > 0 {
                VStack {
                    HStack {
                        Button {
                            selectedTab -= 1
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(16)                 //expands tap area
                                .contentShape(Rectangle())   //makes padded area tappable
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .transition(.opacity)
            }
             
        }
        .onAppear {
            setDefaultGoalAmount()
        }
        .onChange(of: selectedGender) { _, _ in
            setDefaultGoalAmount()
        }

        .onChange(of: selectedUnitType) { _, _ in
            setDefaultGoalAmount()
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
        Picker("Gender", selection: Binding(
            get: { selectedGender },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedGender = newValue
                }
            }
        )) {
            ForEach(genderTypes, id: \.self) { i in
                Text(i)
            }
        }
        .pickerStyle(.segmented)
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
                    if selectedGender == "Male"{
                        ForEach(ozGoalTypesMen, id: \.self){j in
                            Text(j)
                        }
                    } else {
                        ForEach(ozGoalTypesWomen, id: \.self){j in
                            Text(j)
                        }
                    }
                    
                } else if selectedUnitType == "L" {
                    if selectedGender == "Male"{
                        ForEach(LGoalTypesMen, id: \.self){j in
                            Text(j)
                        }
                    } else {
                        ForEach(LGoalTypesWomen, id: \.self){j in
                            Text(j)
                        }
                    }
                } else if selectedUnitType == "mL" {
                    if selectedGender == "Male"{
                        ForEach(mLGoalTypesMen, id: \.self){j in
                            Text(j)
                        }
                    } else {
                        ForEach(mLGoalTypesWomen, id: \.self){j in
                            Text(j)
                        }
                    }
            }
            
            }.pickerStyle(.segmented)
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
        } else if dailyGoal == "125 oz" {
            goalAmount = Double(125)
        } else if dailyGoal == "91 oz" {
            goalAmount = Double(91)
        } else if dailyGoal == "3.7 L" {
            goalAmount = Double(3.7)
        } else if dailyGoal == "2.7 L" {
            goalAmount = Double(2.7)
        } else if dailyGoal == "3700 mL" {
            goalAmount = Double(3700)
        } else if dailyGoal == "2700 mL" {
            goalAmount = Double(2700)
        }
    }
    
    var intakeDisclaimerText: some View {
        Text("General intake estimates based on 'National Academies of Sciences, Engineering, and Medicine. Dietary Reference Intakes for Water, Potassium, Sodium, Chloride, and Sulfate (2005)' - for personalized recommendations, consult a healthcare professional.").foregroundStyle(.white).opacity(0.5).font(.caption).multilineTextAlignment(.center)
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
    

    
    func setDefaultGoalAmount() {
        switch selectedUnitType {
        case "oz":
            dailyGoal = (selectedGender == "Male") ? "125 oz" : "91 oz"
        case "L":
            dailyGoal = (selectedGender == "Male") ? "3.7 L" : "2.7 L"
        case "mL":
            dailyGoal = (selectedGender == "Male") ? "3700 mL" : "2700 mL"
        default:
            dailyGoal = ""
        }
    }
    
}

#Preview {
    @Previewable @State var setupFinished = false
    @Previewable @State var selectedUnitType = "oz"
    @Previewable @State  var goalAmount: Double = 100
//**use static properties for live previews instead of constants!
    
    FirstLaunchView(setupFinished: $setupFinished, selectedUnitType: $selectedUnitType, goalAmount: $goalAmount)
}
