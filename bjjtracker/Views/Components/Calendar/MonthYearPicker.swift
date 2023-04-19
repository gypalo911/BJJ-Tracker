//
//  MonthYearPicker.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @Binding var isBottomSheetOpen: Bool

    @State private var selectedMonth: String = Calendar.current.date(
        from: Calendar.current.dateComponents(
            [.month], from: Date()
        )
    )!.toString("MMMM")
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    private let yearsRange = (Calendar.current.component(.year, from: Date()) - 30)...(Calendar.current.component(.year, from: Date()) + 5)
    
    private var months: [String] {
        let formatter = DateFormatter()
        return formatter.monthSymbols
    }
    
    private var years: [Int] {
        return Array(yearsRange)
    }
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        return dateFormatter
    }
    
    init(selectedDate: Binding<Date>, isBottomSheetOpen: Binding<Bool>) {
        _selectedDate = selectedDate
        _isBottomSheetOpen = isBottomSheetOpen
    }

    var body: some View {
        VStack {
            HStack {
                Picker(selection: $selectedMonth, label: Text("")) {
                    ForEach(months, id: \.self) { month in
                        Text(month).tag(month)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                
                Picker(selection: $selectedYear, label: Text("")) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
            }
            
            Button(action: {
                let newDate = dateFormatter.date(from: "\(selectedMonth) \(selectedYear)") ?? Date()
                let newMonth = Calendar.current.dateComponents([.month, .year], from: newDate)
                let currentMonth = Calendar.current.dateComponents([.month, .year], from: selectedDate)
                if newMonth != currentMonth {
                    selectedDate = newDate
                }
                isBottomSheetOpen = false
            }) {
                Text("Select")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: 400)
            }
            .background(Color("Blue"))
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            self.selectedYear = Calendar.current.component(.year, from: selectedDate)
            self.selectedMonth = Calendar.current.date(
                from: Calendar.current.dateComponents(
                    [.month], from: selectedDate
                )
            )!.toString("MMMM")
        }
    }
}

struct MonthYearPicker_Previews: PreviewProvider {
    struct Container: View {
        @State var selectedDate: Date = Date()
        @State var isBottomSheetOpen: Bool = false
        
        var body: some View {
            MonthYearPicker(selectedDate: $selectedDate, isBottomSheetOpen: $isBottomSheetOpen)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
