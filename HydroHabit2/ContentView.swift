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
    @AppStorage("savedDay", store: UserDefaults(suiteName: "group.HydroHabit"))
    var savedDay: Date?
    //VERY FIRST TIME, STARTS AS CURRENT DAY.
    //every future day gets checked to previous.
    
    @State var returnFromBackgroundAndNewDay = false
    
    @State var buttonPressed = false
    //used to animate progress circle after pressed
    
    @Binding var goalAmountML: Double
    @State var isAnimating = false
    
    //@AppStorage("goalScaleAnimationHasBeenShown") var goalScaleAnimationHasBeenShown = false
    @State var enlargeProgress: Bool = false
    //@State var scaleForCompletion = false
       
    var goalPercent: Double {
        guard goalAmountML > 0 else { return 0 }
        let percent = (waterAmountML / goalAmountML) * 100
        return max(0, percent)
    }

    var formattedGoalPercent: String {
        if goalPercent >= 100 {
            return "100"
        } else {
            // .floor prevents 99.7 from rounding up to 100.
            // It slices off the decimal, leaving exactly "99".
            return String(format: "%.0f", floor(goalPercent))
        }
    }
    
    @Binding var selectedUnitType: String
    @State var scaleGlowAnimationAmount = 0.0
    @State var scaleEffectForCompletion = false
    @State var displayWellDoneText = false
    
    @State var animatedGoalPercent: String = ""
    
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
                                    animatedGoalPercent = formattedGoalPercent
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
                            RoundedRectangle(cornerRadius: 16).foregroundStyle(
                                Color(red: 0.18, green: 0.45, blue: 0.82)
                            )
                        }
                        
                        HStack {
                            
                            Text("Recent History").font(.title3)
                            
                            Spacer()
                                                        
                        }.padding(.top, 10)
                        
                        VStack{
                           
                            if recentEntries.isEmpty {
                                HStack{
                                    Text("No recent entries today.").foregroundStyle(.white)
                                    Spacer()
                                }.frame(maxWidth: .infinity)
                                    .padding()
                                    .background{
                                        RoundedRectangle(cornerRadius: 16).foregroundStyle(
                                            Color(red: 0.18, green: 0.45, blue: 0.82)
                                        )
                                    }
                            }else {
                                
                          
                                
                                VStack{
                                  
                                    
                                    ForEach(recentEntries.prefix(5), id: \.self) { i in
                                        
                                      
                                            HStack{
                                                Text("\(displayUnitWithPrefixes(amountML: i.waterAmountML)) \(displayUnitType())")
                                                    .frame(maxWidth: .infinity, alignment: .leading).fontWeight(.light)
                                                
                                                Spacer()
                                                
                                                Text(i.dateSaved ?? Date(), format: .dateTime.hour().minute())
                                                .fontWeight(.light).font(.caption)
                                                .frame(width: 70)
                                              
                                                
                                                Button {
                                                    
                                                    
                                                    waterAmountML = max(0, waterAmountML - i.waterAmountML)
                                                    
                                                    
                                                    
                                                    withAnimation {
                                                        animatedProgress = goalAmountML > 0 ? min(waterAmountML / goalAmountML, 1.0) : 0
                                                        animatedGoalPercent = formattedGoalPercent
                                                        
                                                    }
                                           
                                                            moc.delete(i)
                                                            try? moc.save()
                                                            saveAllWidgetData()
                                                        
                                                    
                                                    
                                                    
                                                } label: {
                                                    
                                                    Image(systemName: "arrow.clockwise")
                                                        .font(.system(size: 16))
                                                        .overlay(
                                                                    Rectangle()
                                                                       
                                                                        .frame(width: 26, height: 26) // minimum tap target
                                                                        .opacity(0)                   // invisible
                                                                        .contentShape(Rectangle())
                                                                )
                                                    
                                                }
                                                .foregroundStyle(.white)
                                                .opacity(0.5)
                                                .buttonStyle(.plain)
                                                
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background{
                                                RoundedRectangle(cornerRadius: 16).foregroundStyle(
                                                    Color(red: 0.18, green: 0.45, blue: 0.82)
                                                )
                                                
                                            }
                                            
                                        
                                        
                                    }
                                }.foregroundStyle(.white)
                                
                                   
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
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .contentShape(Circle())
                        }
                        .background(
                            Group {
                                if #available(iOS 26.0, *) {
                                    Circle()
                                        .foregroundStyle(
                                            .clear
                                        )
                                        .glassEffect()
                                } else {
                                    Circle()
                                        .foregroundStyle(
                                            .clear
                                        )
                                        .background(.ultraThinMaterial)
                                }
                            }
                        )
                        .buttonStyle(.plain)
                    
                    
                }
                //button vstack end
                
            }
            .sheet(isPresented: $showWaterOptions) {
                WaterOptionsView(selectedUnitType: $selectedUnitType, waterLogCount: $waterLogCount, buttonPressed: $buttonPressed, waterAmountML: $waterAmountML, goalAmountML: $goalAmountML)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
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
                Color(red: 0.15, green: 0.42, blue: 0.78),  // darker top
                Color(red: 0.08, green: 0.32, blue: 0.65)   // deeper bottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
    var hydroHabitTitleText: some View {
        Text("HydroHabit").foregroundStyle(.white).font(.title2).fontWeight(.light)
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
                    .fontWeight(.light)
                    // This ID forces SwiftUI to "snap" the text change
                    // instead of animating the characters
                    .id(selectedUnitType)
                
                Image(systemName: "chevron.down")
                    
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            //.background(Color.white.opacity(0.001)) // Increases tap area without visual change
            .font(.caption2)
            .frame(width: 60, height: 50)
            .contentShape(Rectangle())
        }
        .tint(.white)
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
                .font(.system(size: 16))
                //.contentShape(Rectangle())
                .frame(width: 30, height: 30)   // tap area
                           .contentShape(Rectangle())      // whole frame tappable
            
        }.font(.footnote).foregroundStyle(.white.opacity(0.5))
            .buttonStyle(.plain)
        
    }
    
    var waterAmountOfGoalText: some View {
        Text("\(displayUnitWithPrefixes(amountML: waterAmountML)) \(displayUnitType()) of \(displayUnitWithPrefixes(amountML: goalAmountML)) \(displayUnitType())").foregroundStyle(.white).font(.title2).fontWeight(.light)
    }
    
    func setAllDataOnAppear() {
        saveAllWidgetData()
    }
    
  
    
    
    
    var progressCirclesView: some View {
        ZStack {
            // Gray background ring
            Circle()
                              .stroke(lineWidth: enlargeProgress ? 10 : 4)
                              .foregroundStyle(.gray)
                              .frame(width: 140, height: 140)
                              .opacity(0.5)
                          
                          Circle().trim(from: 0.0, to: animatedProgress).stroke(lineWidth: enlargeProgress ? 10 : 4).foregroundStyle(.blue).frame(width: 140, height: 140).shadow(color: .blue, radius: 10, x: 0, y: 0).rotationEffect(.degrees(-90))
            /*
                              .overlay(
                                  Circle()
                                      .stroke(lineWidth: 4)
                                      .foregroundStyle(.blue).frame(width: 140, height:140)
                                      .shadow(color: .blue, radius: 10, x: 0, y: 0)
                                      .rotationEffect(.degrees(-90))
                                      .scaleEffect(1)
                                      .opacity(setNewOpacity ? 0.4 : 0)
                                      .ignoresSafeArea(.all)
                              )
             */
        }
    }
    
    var progressPercentageInCircle: some View {
        
        Text("\(animatedGoalPercent)%").foregroundStyle(.white).font(.title).fontWeight(.light).shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: -2)
            .animation(.default, value: goalPercent)
            

    }
    
    func resetDataOnNewDay() {
        let calendar = Calendar.current
        let now = Date()
        
        // Fallback to distantPast if savedDay is nil (first download)
        let lastResetDate = savedDay ?? .distantPast
        
        if !calendar.isDateInToday(lastResetDate) {

            withAnimation{
                animatedProgress = 0
            }
            
            // Efficient Core Data Deletion
                    if !recentEntries.isEmpty {
                        for entry in recentEntries {
                            moc.delete(entry)
                        }
                        // Save ONCE after the loop is done
                        do {
                            try moc.save()
                        } catch {
                            print("Error clearing history: \(error)")
                        }
                    }
            
            waterAmountML = 0.0
            
            savedDay = now
            
            saveAllWidgetData()
            
        
            
        }
    }
    
    func animateButtonsAndProgressCircle() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            withAnimation {
                enlargeProgress = true
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Code to execute after 2 seconds
                withAnimation{
                    animatedProgress = goalAmountML > 0 ? min(waterAmountML / goalAmountML, 1.0) : 0
                    animatedGoalPercent = formattedGoalPercent
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation{
                    enlargeProgress = false
                }
            }
        }
        
    }
    
    func checkForReviewTrigger() {
        if waterLogCount == 3 ||
           waterLogCount == 10 ||
           waterLogCount == 20 {

            requestReview()
        }
    }
    
    func saveAllWidgetData() {
        guard let defaults = UserDefaults(suiteName: "group.HydroHabit") else { return }
        
        let displayPercent = goalPercent >= 100 ? 100.0 : floor(goalPercent)
        
        defaults.set(waterAmountML, forKey: "widgetWaterAmount")
        defaults.set(goalAmountML, forKey: "widgetGoalAmount")
        defaults.set(displayPercent, forKey: "widgetGoalPercentage")
        defaults.set(selectedUnitType, forKey: "widgetSelectedUnit")
        
        // 1. CHANGE THIS KEY: Use "savedDay" instead of "widgetSavedDay"
        // This ensures it updates the same @AppStorage variable used in ContentView
        let today = Calendar.current.startOfDay(for: Date())
        defaults.set(today, forKey: "savedDay")
        
        // 2. REMOVE THIS: defaults.synchronize()
        // It is no longer needed in modern iOS and can slow things down.

        WidgetCenter.shared.reloadTimelines(ofKind: "HydroHabit")
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
