//
//  ContentView.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/11/25.
//

import StoreKit
import SwiftUI
import WidgetKit

//test startup app downloaded as mL and L make sure keeps everything as setup.

struct ContentView: View {
    
    @Environment(\.requestReview) var requestReview
    @AppStorage("waterLogCount") var waterLogCount = 0
    @State var editGoalSheetShowing = false
    @State var animatedProgress = 0.0
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("savedDay") var savedDay:Int?
    //VERY FIRST TIME, STARTS AS CURRENT DAY.
    //every future day gets checked to previous.
    
    @State var returnFromBackgroundAndNewDay = false
    @State var buttonPressed = false
    @State var recentIsSaved = false
    @State var recentWaterAmountSaved:Double = 0
    @State var showDecimalDisclaimer = false
    @State var widgetGoalPercentage: Double = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetGoalPercentage") ?? 0
    @State var widgetSelectedUnit: String = UserDefaults(suiteName: "group.HydroHabit")?.string(forKey: "widgetSelectedUnit") ?? "oz"
    @AppStorage("waterAmount") var waterAmount: Double = 0
    @State var widgetWaterAmount:Double = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetWaterAmount") ?? 0
    @State var widgetGoalAmount:Double = UserDefaults(suiteName: "group.HydroHabit")?.double(forKey: "widgetGoalAmount") ?? 0
    @Binding var goalAmount: Double
    @AppStorage("goalScaleAnimationHasBeenShown") var goalScaleAnimationHasBeenShown = false
    @State var isAnimating = false
    
    var goalPercent:Double {
        let percent = (Double(waterAmount) / Double(goalAmount)) * Double(100)
        return percent
    }
    //99.98 rounds up from format: %.0f AND displays the decimal
    //***to enforce NON rounding formating, use .floor
    //for example it would say 90.1 is 901 then use floor to stop the automatic format: % rounding, and then use the decimal at the divided by 10 place
    
    var formattedGoalPercent: String {
        if goalPercent >= 100 {
            return "100" // Directly show 100% when the value is 99.5 or higher
        } else if goalPercent > 99 && goalPercent < 100 {
            if goalPercent == floor(goalPercent) {
                //if goalPercent has no decimals, show as whole number
                return String(format: "%.0f", goalPercent)
            } else {
                //show with the decimal it has
                return String(format: "%g", goalPercent, floor(goalPercent * 100) / 100)
            }
        } else if goalPercent < 90 {
            return String(format: "%.0f", goalPercent)
        }
        return String(format: "%.0f", goalPercent)
    }
    
    @State private var customAmount: Double = 0
    @AppStorage("customAmountOz") private var customAmountOz: Double = 10
    @AppStorage("customAmountL") private var customAmountL: Double = 0.10
    @AppStorage("customAmountmL") private var customAmountmL: Double = 50
    @Binding var selectedUnitType: String
    @State var enlargeProgress: Bool = false
    @State var entry1Saved: Bool = false
    @State var entry2Saved: Bool = false
    @State var entry3Saved: Bool = false
    @State var customAmountSaved: Bool = false
    @State var disableAllButtons = false

    @State var setNewOpacity = false
    @State var scaleForCompletion = false
    @State var scaleGlowAnimationAmount = 0.0
    @State var scaleEffectForCompletion = false
    @State var displayWellDoneText = false
    
    var waterUnits = ["oz", "L", "mL"]
    
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
            
            ZStack {
                
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    
                    VStack {
                        
                        ZStack {
                            
                            hydroHabitTitleText
                            
                            changeWaterUnitPicker
                            
                        }
                        
                        
                        ZStack {
                            progressCirclesView
                                .onChange(of: buttonPressed) { _,_ in
                                    disableAllButtons = true
                                    animateButtonsAndProgressCircle()
                                    print("\(widgetGoalPercentage)")
                                    
                                }
                                .onAppear{
                                    
                                    resetDataOnNewDay()
                                    setAllDataOnAppear()
                                    animatedProgress = (waterAmount / goalAmount)
                                }
                                .onChange(of: scenePhase) { _, newPhase in
                                    
                                    if newPhase == .inactive || newPhase == .active || newPhase == .background {
                                        
                                        //whether user is leaving app or entering the app or entering the background, data gets reset if new day.
                                        
                                        resetDataOnNewDay()
                                        setAllDataOnAppear()
                                        animatedProgress = (waterAmount / goalAmount)
                                        
                                        showDecimalDisclaimer = false
                                        recentIsSaved = false
                                        
                                    }
                                }
                                .onChange(of: goalAmount) { _, _ in
                                    animatedProgress = (waterAmount / goalAmount)
                                }
                            
                            progressWaterDroplet
                            
                        }.padding(.top, 60).padding(.bottom, 20)
                            .scaleEffect(enlargeProgress ? 1.2 : 1)
                            .offset(y:-20)

                        //Text("Well Done.").foregroundStyle(.cyan).fontWeight(.light).font(.title3).padding(.top, -15)
                        
                        HStack {
                            
                            quickAddText
                            
                            Spacer()
                            
                            if recentIsSaved {
                                
                              undoRecentButton
                                
                            }
                            
                        }.padding(.top, 5)
                        
                        quickAddButtonsView
                        
                        HStack {
                            
                            customAmountText
                            
                            Spacer()
                            
                        }.padding(.top, 20)
                        
                        HStack {
                            
                            Spacer()
                            
                          customAmountSliders
                            
                            Spacer()
                            
                           slidersDisplayedValues
                            
                           logButton
                            
                            Spacer()
                            
                        }.padding(.top, 10)
                        
                        Divider().padding(.top, 20)
                        
                        HStack {
                            
                            progressTodayText
                            
                            Spacer()
                            
                           editGoalButton
                            
                        }.padding(.top, 10).font(.title2)
                        
                        HStack {
                            
                            Text("\(formattedGoalPercent)%")
                            
                            Spacer()
                            
                        }.foregroundStyle(.blue).font(.title).padding(.top, -2)
                        
                        HStack {
                            
                            waterAmountOfGoalText

                            Spacer()
                            
                        }.padding(.top, -7)
                        
                        if showDecimalDisclaimer {
                            
                            decimalDisclaimerText
                            
                        }
                        
                        Spacer()
                        
                    }.preferredColorScheme(.dark)
                        .onChange(of: selectedUnitType, { oldValue, newValue in
                           setDefaultCustomAmountOnUnitChange()
                        })
                        .onChange(of: selectedUnitType, { oldValue, newValue in
                            updateAmountsAfterUnitConversion(oldValue: oldValue, newValue: newValue)
                            saveWaterAmountToWidget()
                        })
                        .sheet(isPresented: $editGoalSheetShowing, content: {
                            ChangeGoalView(selectedUnitType: $selectedUnitType, goalAmount: $goalAmount)
                        })

                        .onChange(of: waterAmount) { oldValue, newValue in
                            widgetWaterAmount = waterAmount
                            saveWaterAmountToWidget()
                        }
                        .onChange(of: goalAmount) { _, _ in
                            widgetGoalAmount = goalAmount
                           
                            saveWidgetGoalAmount()
                        }
                        .onChange(of: goalPercent) { _, _ in
                            widgetGoalPercentage = goalPercent
                            saveWidgetGoalPercentage()
                        }
                        .onChange(of: selectedUnitType) { _, _ in
                            widgetSelectedUnit = selectedUnitType
                            saveWidgetSelectedUnit()
                            recentIsSaved = false
                        }
                        .onChange(of: selectedUnitType) { _, _ in
                                showDecimalDisclaimer = true
                        }
                }
                .padding()
                
            }
        }
    
    //MARK: Views and Functions
    
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
    
    //format the number displayed
    func displayUnitWithPrefixes(amount: Double) -> String {
        if selectedUnitType == "oz" {
            //MARK: DECIMALS ARE OK. **people wont convert constantly in the first place. but if they do, they will get an exact conversion for that day. new day, fresh start at 0, only whole number adds of that unit type.
            let stringOz = String(format: "%g", amount).prefix(6)
            //allows two decimal points, in case first is a zero, to make sense of a 99.99% for example.
            return String(stringOz)
        } else if selectedUnitType == "L" {
            let stringL = String(format: "%g", amount).prefix(6)
            return String(stringL)
        } else if selectedUnitType == "mL" {
            let stringmL = String(format: "%g", amount).prefix(7)
            return String(stringmL)
        }
        return "oz"
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
    
    var backgroundColor: Color {
        Color(red: 0.06, green: 0.06, blue: 0.06)
    }
    
    var hydroHabitTitleText: some View {
        Text("HydroHabit").foregroundStyle(.cyan).fontWeight(.light).font(.title2).opacity(0.9)
    }
    
    var changeWaterUnitPicker: some View {
        HStack{
            
            Spacer()
            
            Menu {
                
                Picker("Water Unit Type", selection: $selectedUnitType, content: {
                    ForEach(waterUnits, id: \.self){i in
                        Text(i)
                        
                    }
                })
            }label:{
                Text(selectedUnitType)
                Image(systemName: "chevron.up.chevron.down")
            }.foregroundStyle(.gray).opacity(0.7)
            
        }
    }
    
    var quickAddText: some View {
        Text("Quick Add").foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.5))
    }
    
    var undoRecentButton: some View {
        Button {
            
            //undo recent
            waterAmount -= recentWaterAmountSaved
            
            saveWaterAmountToWidget()
            
            recentIsSaved = false
            
            withAnimation {
                animatedProgress = (waterAmount / goalAmount)
            }
            
        } label: {
            
            Image(systemName: "arrow.clockwise")
            
            Text("Undo Recent")
            
        }.font(.footnote).foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
        
    }
    
    var customAmountText: some View {
        Text("Custom Amount").foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.5))
    }
    
    var progressTodayText: some View {
        Text("Progress Today").foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4)).bold()
    }
    
    var editGoalButton: some View {
        Button {
            
            editGoalSheetShowing.toggle()
            
        } label: {
            
            Image(systemName: "pencil")
            Text("Edit Goal")
            
        }.font(.footnote).padding(.horizontal).foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
        
    }
    
    var waterAmountOfGoalText: some View {
        Text("\(displayUnitWithPrefixes(amount: waterAmount)) \(displayUnitType()) of \(displayUnitWithPrefixes(amount: goalAmount)) \(displayUnitType())").foregroundStyle(.blue).font(.title2).fontWeight(.light)
    }
    
    var decimalDisclaimerText: some View {
        Text("After switching to a new unit (oz, L, mL) - values may have extended decimals. Decimals will reset on the next day.").foregroundStyle(.blue).font(.caption).opacity(0.5).padding(.top, 3)
    }
    
    func setAllDataOnAppear() {
        //widgetWaterAmount = waterAmount
        //water amount is solely based on change, so not necessary here.
        
        widgetGoalAmount = goalAmount
        //goal doesn't change on appear, in changes during use, so ok to use here.
        
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetGoalAmount, forKey: "widgetGoalAmount")
        
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
        
        widgetSelectedUnit = selectedUnitType
        
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetSelectedUnit, forKey: "widgetSelectedUnit")
        
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
        
        widgetGoalPercentage = goalPercent
        
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetGoalPercentage, forKey: "widgetGoalPercentage")
        
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
        
        
        widgetWaterAmount = waterAmount
        
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetWaterAmount, forKey: "widgetWaterAmount")
        
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
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
        
        saveWaterAmountToWidget()
        
        recentIsSaved = true
        recentWaterAmountSaved = Double(customAmount)
    }
    
    func saveWaterAmountToWidget() {
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetWaterAmount, forKey: "widgetWaterAmount")
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    var quickAddButtonsView: some View {
        HStack(spacing: 50){
            
            Button {
                
                buttonPressed.toggle()
                waterLogCount += 1
                entry1Saved = true
                waterAmount += Double(quickAddValue1) ?? 0
                saveWaterAmountToWidget()
                
                recentIsSaved = true
                recentWaterAmountSaved = Double(quickAddValue1) ?? 0
                
            } label: {
                
                ZStack {
                    
                    Circle().stroke(lineWidth: 1).frame(width: 85, height: 85).foregroundStyle(.blue)
                    
                    VStack {
                        
                        Image(systemName: entry1Saved ? "checkmark" : "plus").padding(.bottom, 2).foregroundStyle(entry2Saved || entry3Saved || customAmountSaved ? .gray : .cyan)
                        Text("\(quickAddValue1)\(displayUnitType())")
                        
                    }
                }
            }
            .disabled(disableAllButtons)
            
            Button {
                
                buttonPressed.toggle()
                waterLogCount += 1
                entry2Saved = true
                waterAmount += Double(quickAddValue2) ?? 0
                saveWaterAmountToWidget()
                
                recentIsSaved = true
                recentWaterAmountSaved = Double(quickAddValue2) ?? 0
                
            } label: {
                
                ZStack {
                    
                    Circle().stroke(lineWidth: 1).frame(width: 85, height: 85).foregroundStyle(.blue)
                    
                    VStack {
                        Image(systemName: entry2Saved ? "checkmark" : "plus").padding(.bottom, 2).foregroundStyle(entry1Saved || entry3Saved || customAmountSaved ? .gray : .cyan)
                        Text("\(quickAddValue2)\(displayUnitType())")
                        
                    }
                }
            }
            .disabled(disableAllButtons)
            
            Button {
                
                buttonPressed.toggle()
                waterLogCount += 1
                entry3Saved = true
                waterAmount += Double(quickAddValue3) ?? 0
                
                saveWaterAmountToWidget()
                
                recentIsSaved = true
                recentWaterAmountSaved = Double(quickAddValue3) ?? 0
                
            } label: {
                
                ZStack {
                    
                    Circle().stroke(lineWidth: 1).frame(width: 85, height: 85).foregroundStyle(.blue)
                    
                    VStack{
                        Image(systemName: entry3Saved ? "checkmark" : "plus").padding(.bottom, 2).foregroundStyle(entry1Saved || entry2Saved || customAmountSaved ? .gray : .cyan)
                        Text("\(quickAddValue3)\(displayUnitType())")
                        
                    }
                }
            }
            .disabled(disableAllButtons)
            
        }.padding(.top, 20)
    }
    
    var logButton: some View {
        Button("Log"){
            
          logCustomAmount()
            
        }.buttonStyle(.borderedProminent).tint(Color(red: 0/255, green: 0/255, blue: 50/255)).foregroundStyle(.cyan).opacity(0.7).frame(width: 100)
            .onChange(of: waterLogCount) { _, newValue in
                if newValue == 25 {
                    requestReview()
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
    
    var progressCirclesView: some View {
        
        VStack{
            ZStack {
                
                Circle().stroke(lineWidth: enlargeProgress ? 10 : 4).foregroundStyle(.gray).frame(width: 140, height: 140).opacity(0.5)
                
                Circle().trim(from: 0.0, to: animatedProgress).stroke(lineWidth: enlargeProgress ? 10 : 4).foregroundStyle(.cyan).frame(width: 140, height: 140).shadow(color: .cyan, radius: 10, x: 0, y: 0).rotationEffect(.degrees(-90))
                    .overlay(
                        Circle().stroke(lineWidth: 4).foregroundStyle(.cyan).frame(width: scaleForCompletion && !goalScaleAnimationHasBeenShown ? 3000 : 140, height: scaleForCompletion && !goalScaleAnimationHasBeenShown ? 3000 : 140).shadow(color: .blue, radius: 10, x: 0, y: 0).rotationEffect(.degrees(-90)).scaleEffect(scaleForCompletion && !goalScaleAnimationHasBeenShown ? 30 : 1).opacity(setNewOpacity ? 0.4 : 0).ignoresSafeArea(.all)
            )
                }
        }
    }
    
    var progressWaterDroplet: some View {
        Image(systemName: "drop").foregroundStyle(.cyan).font(.title).padding(.bottom, 10).bold().shadow(color: .cyan, radius: 10, x: 0, y: 0)
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
    
    func saveWidgetGoalPercentage() {
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetGoalPercentage, forKey: "widgetGoalPercentage")
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func saveWidgetSelectedUnit() {
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetSelectedUnit, forKey: "widgetSelectedUnit")
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func saveWidgetGoalAmount() {
        UserDefaults(suiteName: "group.HydroHabit")?.set(widgetGoalAmount, forKey: "widgetGoalAmount")
        UserDefaults(suiteName: "group.HydroHabit")?.synchronize()
        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    //12:01am log entry, saved day is -1, i close app, i reopen, saved day is still -1, so saved day isn't equal to current day, so resets.
    //bug: if you haven't logged in a day, first entry resets to zero.
    //11:59pm open, but its reset to zero.
    //only on resets is savedData getting saved.
    
    //log entry and save current date.
    //tomorrow, its a new day.
    //as soon as the app appears or comes back to active scene, saved day (yesterday) will compare to new day to reset, before anything gets logged, instantly.
    
    //saved day button save didn't work. breaks widget resets to zero constantly.
    
    //make sure glow works correct on new day.
    
    func resetDataOnNewDay() {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: Date())
        
        if savedDay != currentDay {
            //saved day is never equal to current day on fresh download.
            //therefore every time app opens.. first time on appear, it starts as zero.
            //which i guess is good for immediate first time download.
            //but i didn't have an immediate reloadTimes save.
            //this runs ONLY on appear.
            //but i did have reload on waterAmount change right? yes.
            
            goalScaleAnimationHasBeenShown = false
            
            withAnimation{
                animatedProgress = 0
            }
            
            waterAmount = 0.0
            
            saveWaterAmountToWidget()
            
            savedDay = currentDay
            
            goalScaleAnimationHasBeenShown = false
            
        }
    }
    
    func updateAmountsAfterUnitConversion (oldValue: String, newValue: String) {
        if oldValue == "oz" && newValue == "L" {
            
            self.waterAmount = waterAmount * 0.0295735
            self.goalAmount = goalAmount * 0.0295735
       
        } else if oldValue == "oz" && newValue == "mL" {
            
            self.waterAmount = waterAmount * 29.5735
            self.goalAmount = goalAmount * 29.5735
            
        } else if oldValue == "L" && newValue == "oz" {
           
            self.waterAmount = waterAmount * 33.814
            self.goalAmount = goalAmount * 33.814
       
        } else if oldValue == "L" && newValue == "mL" {
            
            self.waterAmount = waterAmount * 1000
            self.goalAmount = goalAmount * 1000
            
        } else if oldValue == "mL" && newValue == "L" {
            
            self.waterAmount = waterAmount / 1000
            self.goalAmount = goalAmount / 1000
            
        } else if oldValue == "mL" && newValue == "oz" {
            
            self.waterAmount = waterAmount / 29.5735
            self.goalAmount = goalAmount / 29.5735
       
        }
    }
    
    func animateButtonsAndProgressCircle() {
        
        
        withAnimation {
            enlargeProgress = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Code to execute after 2 seconds
            withAnimation{
                animatedProgress = (waterAmount / goalAmount)
            }
        }

            
        if widgetGoalPercentage >= 100 && !goalScaleAnimationHasBeenShown  && !isAnimating {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                setNewOpacity = true
                withAnimation(.easeInOut(duration: 5.0)){
                    scaleForCompletion = true
                }
            }
            
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 2.0)){
                    displayWellDoneText = true
                }
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation(.easeInOut(duration: 1.0)){
                    displayWellDoneText = false
                }
            }
            */
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
                    goalScaleAnimationHasBeenShown = true
                    scaleForCompletion = false
                    setNewOpacity = false
                isAnimating = false
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation{
                enlargeProgress = false
            }
            entry1Saved = false
            entry2Saved = false
            entry3Saved = false
            customAmountSaved = false
            disableAllButtons = false
        }
    }
    
    func setDefaultCustomAmountOnUnitChange() {
        if selectedUnitType == "oz" {
            customAmount = 10
        } else if selectedUnitType == "L" {
            customAmount = 0.10
        } else if selectedUnitType == "mL" {
            customAmount = 50
        }
    }

}

#Preview {
    ContentView(goalAmount: .constant(130), selectedUnitType: .constant("oz"))
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct NoDimButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1) // Maintain full opacity even when disabled
    }
}
