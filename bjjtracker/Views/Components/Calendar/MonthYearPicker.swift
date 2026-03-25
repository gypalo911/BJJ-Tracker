//
//  MonthYearPicker.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

struct MonthYearPicker: View {
    enum Localisation {
        static let openDatepicker = "Open datepicker"
    }

    @Binding var selectedDate: Date
    @Binding var isBottomSheetOpen: Bool

//    @State private var selectedMonth: String = Calendar.current.date(
//        from: Calendar.current.dateComponents(
//            [.month], from: Date()
//        )
//    )!.toString("MMMM")
//    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
//
//    private let yearsRange = (Calendar.current.component(.year, from: Date()) - 30)...(Calendar.current.component(.year, from: Date()) + 5)
//
//    private var months: [String] {
//        let formatter = DateFormatter()
//        return formatter.monthSymbols
//    }
//
//    private var years: [Int] {
//        return Array(yearsRange)
//    }
//
//    private var dateFormatter: DateFormatter {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMMM yyyy"
//
//        return dateFormatter
//    }
//
//    init(selectedDate: Binding<Date>, isBottomSheetOpen: Binding<Bool>) {
//        _selectedDate = selectedDate
//        _isBottomSheetOpen = isBottomSheetOpen
//    }
//
//    var body: some View {
//        VStack {
//            HStack(alignment: .center) {
//                Picker(selection: $selectedMonth, label: Text("")) {
//                    ForEach(months, id: \.self) { month in
//                        Text(month).tag(month)
//                    }
//                }
//                .pickerStyle(WheelPickerStyle())
//                .clipped()
//
//                Picker(selection: $selectedYear, label: Text("")) {
//                    ForEach(years, id: \.self) { year in
//                        Text(String(year)).tag(year)
//                    }
//                }
//                .pickerStyle(WheelPickerStyle())
//                .clipped()
//            }
//            .padding(.horizontal, 20)
//
//            Button(action: {
//                let newDate = dateFormatter.date(from: "\(selectedMonth) \(selectedYear)") ?? Date()
//                if !selectedDate.isSame(as: newDate, by: [.month, .year]) {
//                    selectedDate = newDate
//                }
//                isBottomSheetOpen = false
//            }) {
//                Text("Select")
//                    .font(.body)
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: 400)
//                    .padding()
//                    .foregroundColor(.white)
//            }
//            .background(Color("Blue"))
//            .cornerRadius(10)
//        }
//        .padding()
//        .onAppear {
//            self.selectedYear = Calendar.current.component(.year, from: selectedDate)
//            self.selectedMonth = Calendar.current.date(
//                from: Calendar.current.dateComponents(
//                    [.month], from: selectedDate
//                )
//            )!.toString("MMMM")
//        }
//    }
    
    @State private var date = Date()
    
    @State private var showingPopover: Bool = false
    
    @Namespace var animation

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    Text(Localisation.openDatepicker.localizedString)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showingPopover.toggle()
                    }
                }
                .padding(20)
                .background(Color.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
        .bottomSheet(isPresented: $showingPopover) {
            DatePicker(
                "Start Date",
                selection: $date,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .datePickerStyle(.graphical)
            .background(Color.white)
            .padding(20)
        }
        
//        .popover(isPresented: $showingPopover, attachmentAnchor: .point(.bottomTrailing), arrowEdge: .trailing) {
//
//        }
        
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
