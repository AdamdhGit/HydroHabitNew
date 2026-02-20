//
//  ContentView.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/11/25.
//

import CoreData
import StoreKit
import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\WaterLog.dateSaved, order: .reverse)
        ],
        animation: .default
    )
    private var recentEntries: FetchedResults<WaterLog>

    
    @State var showWaterOptions = false
    
    @AppStorage("waterAmount") var waterAmountML: Double = 0.0
    
    @Environment(\.requestReview) var requestReview
    
    @AppStorage("waterLogCount") var waterLogCount = 0
    //for requestReview purposes
    
    @State var editGoalSheetShowing = false
    @State var animatedProgress = 0.0
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("savedDay") var savedDay:Int?
    //VERY FIRST TIME, STARTS AS CURRENT DAY.
    //every future day gets checked to previous.
    
    @State var returnFromBackgroundAndNewDay = false
    
    @State var buttonPressed = false
    //used to animate progress circle after pressed
    
    @State var recentWaterAmountSaved:Double = 0
    @Binding var goalAmountML: Double
    @AppStorage("goalScaleAnimationHasBeenShown") var goalScaleAnimationHasBeenShown = false
    @State var isAnimating = false
    
    var goalPercent: Double {
        guard goalAmountML > 0 else { return 0 }
        let percent = (waterAmountML / goalAmountML) * 100
        return max(0, percent)
    }
    //99.98 rounds up from format: %.0f AND displays the decimal
    //***to enforce NON rounding formating, use .floor
    //for example it would say 90.1 is 901 then use floor to stop the automatic format: % rounding, and then use the decimal at the divided by 10 place
    
    var formattedGoalPercent: String {
        if goalPercent >= 100 {
            return "100" // Directly show 100% when the value is 99.5 or higher
        }else  {
            return String(format: "%.0f", goalPercent)
        }
    }
    
    @Binding var selectedUnitType: String
    @State var enlargeProgress: Bool = false
    @State var customAmountSaved: Bool = false

    @State var setNewOpacity = false
    @State var scaleForCompletion = false
    @State var scaleGlowAnimationAmount = 0.0
    @State var scaleEffectForCompletion = false
    @State var displayWellDoneText = false
    
    var waterUnits = ["oz", "L", "mL"]

        var body: some View {
            
            ZStack {
                
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    
                    VStack {
                        
                        ZStack {
                            
                            hydroHabitTitleText
                            
                            
                            HStack{
                                Spacer()
                                changeWaterUnitPicker
                            }
                            
                        }
                        
                        
                        ZStack {
                            progressCirclesView
                                .onChange(of: buttonPressed) { _,_ in
                                 
                                    animateButtonsAndProgressCircle()
                                    
                                    
                                }
                                .onAppear{
                                    
                                    resetDataOnNewDay()
                                    setAllDataOnAppear()
                                    animatedProgress = goalAmountML > 0 ? min(waterAmountML / goalAmountML, 1.0) : 0
                                }
                                .onChange(of: scenePhase) { _, newPhase in
                                    
                                    if newPhase == .inactive || newPhase == .active || newPhase == .background {
                                        
                                        //whether user is leaving app or entering the app or entering the background, data gets reset if new day.
                                        
                                        resetDataOnNewDay()
                                        setAllDataOnAppear()
                                        animatedProgress = goalAmountML > 0 ? min(waterAmountML / goalAmountML, 1.0) : 0
                                        
                                    }
                                }
                                .onChange(of: goalAmountML) { _, _ in
                                    animatedProgress = goalAmountML > 0 ? min(waterAmountML / goalAmountML, 1.0) : 0
                                }
                            
                            progressPercentageInCircle
                            
                        }.padding(.top, 60).padding(.bottom, 20)
                            .scaleEffect(enlargeProgress ? 1.2 : 1)
                            .offset(y:-20)
                   
                        HStack {
                            
                            progressTodayText.font(.title3)
                            
                            Spacer()
                                                        
                        }.padding(.top, 10)
                        
                        VStack{
                            
                            HStack {
                                
                                waterAmountOfGoalText
                                
                                Spacer()
                                
                                editGoalButton
                                
                            }
                        }.padding().background{
                            RoundedRectangle(cornerRadius: 16).foregroundStyle(.gray).opacity(0.1)
                        }
                        
                        HStack {
                            
                            Text("Recent History").font(.title3)
                            
                            Spacer()
                                                        
                        }.padding(.top, 10)
                        
                        VStack{
                           
                            if recentEntries.isEmpty {
                                HStack{
                                    Text("No recent entries today.").foregroundStyle(.gray).opacity(0.5)
                                    Spacer()
                                }.frame(maxWidth: .infinity)
                                    .padding()
                                    .background{
                                        RoundedRectangle(cornerRadius: 16).foregroundStyle(.gray).opacity(0.1)
                                    }
                            }else {
                                
                          
                                
                                VStack{
                                  
                                    
                                    ForEach(recentEntries.prefix(5), id: \.self) { i in
                                        
                                      
                                            HStack{
                                                Text("\(displayUnitWithPrefixes(amountML: i.waterAmountML)) \(displayUnitType())")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(i.dateSaved ?? Date(), format: .dateTime.hour().minute())
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Spacer()
                                                
                                                Button {
                                                    
                                                    
                                                    waterAmountML = max(0, waterAmountML - i.waterAmountML)
                                                    
                                                    
                                                    
                                                    withAnimation {
                                                        animatedProgress = goalAmountML > 0 ? min(waterAmountML / goalAmountML, 1.0) : 0
                                                        
                                                    }
                                           
                                                            moc.delete(i)
                                                            try? moc.save()
                                                            saveAllWidgetData()
                                                        
                                                    
                                                    
                                                    
                                                } label: {
                                                    
                                                    Image(systemName: "arrow.clockwise")
                                                        .font(.system(size: 16))
                                                    
                                                }
                                                .foregroundStyle(.gray)
                                                .opacity(0.5)
                                                
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background{
                                                RoundedRectangle(cornerRadius: 16).foregroundStyle(.gray).opacity(0.1)
                                            }
                                            
                                        
                                        
                                    }
                                }.foregroundStyle(.blue)
                                
                                   
                            }
                        }
                        Spacer()
                        
                    }
                    
                    .onChange(of: selectedUnitType) { oldValue, newValue in
                        
                        //setDefaultCustomAmountOnUnitChange()
                        
                        /*
                        updateAmountsAfterUnitConversion(oldValue: oldValue, newValue: newValue)
                        
                        
                        // Update all recent entries
                          for log in recentEntries {
                              updateRecentEntriesAfterUnitConversion(for: log, oldValue: oldValue, newValue: newValue)
                          }
                        
                          // Save context
                          try? moc.save()
                        */
                        
                       
                        
                        
                        
                        saveAllWidgetData()
                    }
                    //
                    
                    .sheet(isPresented: $editGoalSheetShowing, content: {
                        ChangeGoalView(selectedUnitType: $selectedUnitType, goalAmount: $goalAmountML)
                    })
                    
                }.padding(.horizontal)
                
                //MARK: water track button
                VStack{
                    Spacer()
                        Button {
                            showWaterOptions = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .contentShape(Circle())
                        }
                        .background(
                            Group {
                                if #available(iOS 26.0, *) {
                                    Circle()
                                        .glassEffect()
                                } else {
                                    Circle()
                                        .background(.ultraThinMaterial)
                                }
                            }
                        )
                        .buttonStyle(.plain)
                    
                    
                }
                //button vstack end
                
            }
            .sheet(isPresented: $showWaterOptions) {
                WaterOptionsView(selectedUnitType: $selectedUnitType, waterLogCount: $waterLogCount, buttonPressed: $buttonPressed, waterAmountML: $waterAmountML, goalAmountML: $goalAmountML, recentWaterAmountSaved: $recentWaterAmountSaved, customAmountSaved: $customAmountSaved)
                    .presentationDetents([.medium])
            }
        }
    
    //MARK: Views and Functions
    

    /*
    //format the number displayed
    func displayUnitWithPrefixes(amount: Double) -> String {
        switch selectedUnitType {
        case "L":
            // Shows up to 2 decimals for Liters (e.g., 1.75)
            return amount.formatted(.number.precision(.fractionLength(0...2)))
        case "mL":
            // No decimals for mL, with thousands separator (e.g., 1,500)
            return amount.formatted(.number.precision(.fractionLength(0)))
        default: // "oz"
            // Up to 1 decimal for oz to handle conversions cleanly
            return amount.formatted(.number.precision(.fractionLength(0...1)))
        }
    }
    */
    
    //does rounding change the value?
    
    /*
    func displayUnitWithPrefixes(amount: Double) -> String {
        switch selectedUnitType {
            case "L":
                let rounded = (amount * 100).rounded() / 100
                return String(format: "%.2f", rounded)
                
            case "mL":
                return String(format: "%.0f", amount.rounded())
                
            default: // oz
                return String(format: "%.0f", amount.rounded())
            }
    }
     */
    
    func displayUnitWithPrefixes(amountML: Double) -> String {
        
        let safeML = max(0, amountML)   // 👈 prevents negative drift
        
        switch selectedUnitType {

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
    
    var hydroHabitTitleText: some View {
        Text("HydroHabit").foregroundStyle(.white).font(.title2).bold()
    }
    
    var changeWaterUnitPicker: some View {
        Menu {
            Picker("Water Unit Type", selection: $selectedUnitType) {
                ForEach(waterUnits, id: \.self) { i in
                    Text(i).tag(i)
                }
            }
        } label: {
            // Use a fixed-width container for the label
            HStack(spacing: 2) {
                Text(selectedUnitType)
                    .font(.body)
                    .fontWeight(.medium)
                    // This ID forces SwiftUI to "snap" the text change
                    // instead of animating the characters
                    .id(selectedUnitType)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.001)) // Increases tap area without visual change
            .frame(width: 60, alignment: .trailing) // THE FIX: Absolute width
        }
        .tint(.blue)
        // This prevents the "Drawing" animation from stuttering
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    
    var progressTodayText: some View {
        Text("Progress Today").foregroundStyle(.white)
    }
    
    var editGoalButton: some View {
        Button {
            
            editGoalSheetShowing.toggle()
            
        } label: {
            
            Image(systemName: "square.and.pencil")
                .font(.system(size: 20, weight: .bold))
                //.contentShape(Rectangle())
            
        }.font(.footnote).foregroundStyle(.gray.opacity(0.3))
        
    }
    
    var waterAmountOfGoalText: some View {
        Text("\(displayUnitWithPrefixes(amountML: waterAmountML)) \(displayUnitType()) of \(displayUnitWithPrefixes(amountML: goalAmountML)) \(displayUnitType())").foregroundStyle(.blue).font(.title2).fontWeight(.light)
    }
    
    func setAllDataOnAppear() {
        saveAllWidgetData()
    }
    
  
    
    
    
    var progressCirclesView: some View {
        
        VStack{
            ZStack {
                
                Circle()
                    .stroke(lineWidth: enlargeProgress ? 10 : 4)
                    .foregroundStyle(.gray)
                    .frame(width: 140, height: 140)
                    .opacity(0.5)
                
                Circle().trim(from: 0.0, to: animatedProgress).stroke(lineWidth: enlargeProgress ? 10 : 4).foregroundStyle(.blue).frame(width: 140, height: 140).shadow(color: .blue, radius: 10, x: 0, y: 0).rotationEffect(.degrees(-90))
                    .overlay(
                        Circle()
                            .stroke(lineWidth: 4)
                            .foregroundStyle(.blue).frame(width: scaleForCompletion && !goalScaleAnimationHasBeenShown ? 3000 : 140, height: scaleForCompletion && !goalScaleAnimationHasBeenShown ? 3000 : 140)
                            .shadow(color: .blue, radius: 10, x: 0, y: 0)
                            .rotationEffect(.degrees(-90))
                            .scaleEffect(scaleForCompletion && !goalScaleAnimationHasBeenShown ? 30 : 1)
                            .opacity(setNewOpacity ? 0.4 : 0)
                            .ignoresSafeArea(.all)
                    )
            }
        }
    }
    
    var progressPercentageInCircle: some View {
        
        Text("\(formattedGoalPercent)%").foregroundStyle(.blue).font(.title).bold().shadow(color: .blue, radius: 10, x: 0, y: 0)
        
        //Image(systemName: "drop").foregroundStyle(.blue).font(.title).padding(.bottom, 10).bold().shadow(color: .blue, radius: 10, x: 0, y: 0)
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
            
            waterAmountML = 0.0
            
            saveAllWidgetData()
            
            savedDay = currentDay
            
            goalScaleAnimationHasBeenShown = false
            
        }
    }
    
    /*
    
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
    
    func updateRecentEntriesAfterUnitConversion (for log: WaterLog, oldValue: String, newValue: String) {
        if oldValue == "oz" && newValue == "L" {
            
            log.waterAmount = log.waterAmount * 0.0295735
       
        } else if oldValue == "oz" && newValue == "mL" {
            
            log.waterAmount = log.waterAmount * 29.5735
            
        } else if oldValue == "L" && newValue == "oz" {
            
            log.waterAmount = log.waterAmount * 33.814
       
        } else if oldValue == "L" && newValue == "mL" {
            
            log.waterAmount = log.waterAmount  * 1000
            
        } else if oldValue == "mL" && newValue == "L" {
            
            log.waterAmount = log.waterAmount / 1000
            
        } else if oldValue == "mL" && newValue == "oz" {
            
            log.waterAmount = log.waterAmount / 29.5735
       
        }
        
        
    }
    
    */
    
    func animateButtonsAndProgressCircle() {
        
        
        withAnimation {
            enlargeProgress = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Code to execute after 2 seconds
            withAnimation{
                animatedProgress = goalAmountML > 0 ? min(waterAmountML / goalAmountML, 1.0) : 0
            }
        }

            
        if goalPercent >= 100 && !goalScaleAnimationHasBeenShown  && !isAnimating {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                setNewOpacity = true
                withAnimation(.easeInOut(duration: 5.0)){
                    scaleForCompletion = true
                }
            }
            
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
            
            customAmountSaved = false
           
        }
    }
    
    /*
    func setDefaultCustomAmountOnUnitChange() {
        if selectedUnitType == "oz" {
            customAmount = 10
        } else if selectedUnitType == "L" {
            customAmount = 0.10
        } else if selectedUnitType == "mL" {
            customAmount = 50
        }
    }
    */
    
    func checkForReviewTrigger() {
        if waterLogCount == 3 ||
           waterLogCount == 10 ||
           waterLogCount == 20 {

            requestReview()
        }
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
