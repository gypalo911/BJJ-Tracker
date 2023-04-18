//
//  AddPromotionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.04.2023.
//

import SwiftUI

struct AddPromotionView: View {
    @StateObject var promotion: Promotion = .init(gradingSystem: .adult, stripes: 0, date: Date(), location: "", notes: "")
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "1. Grading system:")
                                
                                SelectionPanelView<GradingSystem>(
                                    g: geometry,
                                    valuesList: GradingSystem.allCases.map { $0.rawValue },
                                    selectedType: $promotion.gradingSystem,
                                    selectedTypeValue: promotion.gradingSystem.rawValue
                                )
                            }.padding(.top, 10)
                            
                            VStack(alignment: .leading) {
                                let belt = promotion.gradingSystem == .adult ? promotion.adultBelt.rawValue : promotion.juniorBelt.rawValue
                                let newBelt = (belt == "none") ? "" : belt
                                TitleTextView(text: "2. Belt: \(newBelt)")
                                
                                BeltsListView(promotion: promotion)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "3. Number of stripes:")
                                NumberPickerView(selectedNumber: $promotion.stripes)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "4. Select date:")
                                
                                DatePicker("", selection: $promotion.date)
                                    .datePickerStyle(.compact)
                                    .fixedSize()
                                    .offset(x: -2)
                            }
                        }
                        
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Location:")
                                TextField("Location...", text: $promotion.location)
                                    .frame(maxHeight: 50, alignment: .top)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("LightBlue"))
                                    ).padding(.leading, 5)
                            }
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Notes")
                                TextField("Add some details...", text: $promotion.notes)
                                    .frame(minHeight: 150, alignment: .top)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("LightBlue"))
                                    )
                                    .padding(.leading, 5)
                            }
                        }
                    }
                    .hAlign(.leading)
                    .padding(.horizontal, 20)
                    .navigationTitle("Add Promotion")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image("back")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color("Blue"))
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Save")
                                    .fixedSize()
                                    .foregroundColor(Color("Blue"))
                            }
                        }
                    }
                    .vAlign(.top)
                }
            }.onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = .white
                UINavigationBar.appearance().standardAppearance = appearance
            }
        }
    }
}


struct AddPromotionView_Previews: PreviewProvider {
    struct Container: View {
        
        var body: some View {
            AddPromotionView()
        }
    }
    
    static var previews: some View {
        Container()
    }
}

struct NumberPickerView: View {
    let numbers = [0, 1, 2, 3, 4]
    @Binding var selectedNumber: Int
    
    var body: some View {
        Picker(selection: $selectedNumber, label: Text("Select a number")) {
            ForEach(0..<numbers.count, id: \.self) { index in
                Text("\(numbers[index])")
            }
        }
        .pickerStyle(.segmented)
    }
}
