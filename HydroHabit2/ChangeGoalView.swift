//
//  ChangeGoalView.swift
//  HydroHabit
//
//  Created by Adam Heidmann on 1/13/25.
//

import SwiftUI

struct ChangeGoalView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedUnitType: String
    @Binding var goalAmount: Double
    @State var customGoalAmount = ""
    
    var body: some View {

        NavigationStack {
            
            ZStack {
                
                backgroundColor .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                   enterANewGoalText
                    
                    goalTextField
                    
                    Button("Save"){
                        
                       saveNewGoal()
                        
                    }.buttonStyle(.borderedProminent).tint(.black).padding(.top, 20)
                    
                    Spacer()
                    
                }.preferredColorScheme(.dark).padding(.top, 150)
                
            }.toolbar {
                
                ToolbarItem {
                    
                    cancelButton
                    
                }
            }
        }
    }
    
    var backgroundColor: Color {
        Color(red: 0.06, green: 0.06, blue: 0.06)
    }
    
    var enterANewGoalText: some View {
        Text("Enter A New Daily Intake Goal In \(selectedUnitType)").foregroundStyle(.gray)
    }
    
    var goalTextField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundStyle(.cyan)
            
            TextField("Custom Goal Amount in \(selectedUnitType)", text: $customGoalAmount).keyboardType(selectedUnitType == "L" ? .decimalPad : .numberPad).padding().onChange(of: customGoalAmount) { _, newValue in
                if newValue.count > 5 {
                    customGoalAmount = String(newValue.prefix(5))
                }
            }
        }.padding(.top, 10).frame(height: 60).padding(.horizontal)
    }
    
    func saveNewGoal() {
        goalAmount = Double(customGoalAmount) ?? 0
        dismiss()
    }
    
    var cancelButton: some View {
        Button("Cancel"){
            dismiss()
        }
    }
    
}

#Preview {
    ChangeGoalView(selectedUnitType: .constant("oz"), goalAmount: .constant(100))
}
