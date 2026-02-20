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
                  
                    ScrollView{
                        VStack{
                            Spacer()
                            hydroHabitIntroText.offset(y: -40)
                            
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
                            
                            Spacer().frame(height: 300)
                        }.frame(minHeight: UIScreen.main.bounds.height).padding(.top, 70)
                    }.scrollDisabled(true)
                }.tag(0)
                
                ZStack{
                    
                    ScrollView{
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
                           
                            Spacer()
                                .frame(height: 300)
                            
                        }.frame(minHeight: UIScreen.main.bounds.height).padding(.top, 70)
                    }.scrollDisabled(true)
                }.tag(1)
                
                ZStack{
                   
                    ScrollView{
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
                            Spacer()
                                .frame(height: 300)
                        }.frame(minHeight: UIScreen.main.bounds.height).padding(.top, 70)
                    }.scrollDisabled(true)
                }.tag(2)
                
                ZStack{
                    
                    ScrollView{
                        VStack{
                            
                            
                            selectIntakeGoalText
                            
                            intakeDisclaimerText.padding(.horizontal).padding(.bottom, 20).padding(.top, 2)
                            
                            intakeGoalPicker.padding(.horizontal)
                            
               
                                customGoalEntryView.frame(height: 100)
                           
                            
                            Spacer()
                            Image("waterTrophy")
                                .resizable()
                                .frame(width: 150, height: 150)
                           
                            Button {
                                customGoalTextFocused = false
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
                            .disabled(isCustomGoalInvalid)
                            
                            Spacer()
                                .frame(height: 300)
                            
                        }.frame(minHeight: UIScreen.main.bounds.height).padding(.top, 70)
                    }.scrollIndicators(.hidden)
                }.tag(3)

                   
                ZStack{
                   
                    ScrollView{
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
                            
                            Spacer()
                                .frame(height: 300)
                            
                        }.frame(minHeight: UIScreen.main.bounds.height).padding(.top, 100)
                    }.scrollDisabled(true)
                }.tag(4)
                    
                 
                    
                 
                    
                
                
            }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .ignoresSafeArea(.keyboard)
            // hides dots
            
            if selectedTab > 0 {
                VStack {
                    HStack {
                        Button {
                            
                            customGoalTextFocused = false
                            
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
            
            Text("Enter Your Daily Intake Goal in \(selectedUnitType)").foregroundStyle(.white).padding(.top, 15).font(.callout)
            
            TextField("Custom Goal Amount in \(selectedUnitType)", text: $customGoalAmount)
                .focused($customGoalTextFocused)
                
                .padding()
                .onChange(of: customGoalAmount) { _, newValue in
                    if newValue.count > 5 {
                        customGoalAmount = String(newValue.prefix(5))
                    }
                }.background{
                    RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.25)).frame(height: 40)
                }
                .frame(width: 300)
                .submitLabel(.done)
                .keyboardType(selectedUnitType == "L" ? .decimalPad : .numberPad)
                .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                customGoalTextFocused = false
                                saveGoalAmount() // optional
                            }
                        }
                    }
            
            
        }
        .onChange(of: customGoalSelected) { oldValue, newValue in
            // Only focus if the custom goal entry is actually visible
            if newValue {
                customGoalTextFocused = true
            } else {
                customGoalTextFocused = false
            }
        }
        .opacity(customGoalSelected ? 1 : 0)      // Fade in/out
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
        
        let rawValue: Double
        
        if dailyGoal == "Custom Goal" {
            rawValue = Double(customGoalAmount) ?? 0
        } else {
            rawValue = Double(dailyGoal.components(separatedBy: " ").first ?? "") ?? 0
        }
        
        // Convert to mL before storing
        switch selectedUnitType {
        case "oz":
            goalAmount = rawValue * 29.5735
        case "L":
            goalAmount = rawValue * 1000
        default: // mL
            goalAmount = rawValue
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
    
    var isCustomGoalInvalid: Bool {
        // Only check if "Custom Goal" is selected
        guard dailyGoal == "Custom Goal" else { return false }

        // Must not be empty
        guard !customGoalAmount.trimmingCharacters(in: .whitespaces).isEmpty else { return true }

        // Must parse as Double; 01 for example parses into 1.0
        guard let value = Double(customGoalAmount) else { return true }

        // Must be strictly > 0
        return value <= 0
    }
    
}

#Preview {
    @Previewable @State var setupFinished = false
    @Previewable @State var selectedUnitType = "oz"
    @Previewable @State  var goalAmount: Double = 100
//**use static properties for live previews instead of constants!
    
    FirstLaunchView(setupFinished: $setupFinished, selectedUnitType: $selectedUnitType, goalAmount: $goalAmount)
}
