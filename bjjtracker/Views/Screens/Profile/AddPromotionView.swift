//
//  AddPromotionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.04.2023.
//

import SwiftUI

struct AddPromotionView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @ObservedObject var viewModel: AddPromotionViewViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @Environment (\.managedObjectContext) var managedObjContext
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "1. Grading system:".localizedString)
                                
                                SelectionPanelView<GradingSystem>(
                                    valuesList: GradingSystem.allCases.map { $0.rawValue },
                                    selectedType: $viewModel.promotion.gradingSystem,
                                    selectedTypeValue: viewModel.promotion.gradingSystem.rawValue
                                )
                            }.padding(.top, 10)
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "2. Belt: %@".localized(with: ["\(viewModel.promotion.belt.title)"]))
                                
                                BeltsListView(promotion: viewModel.promotion)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "3. Number of stripes:".localizedString)
                                NumberPickerView(selectedNumber: $viewModel.promotion.stripes)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "4. Select date:".localizedString)
                                
                                DatePicker("", selection: $viewModel.promotion.date)
                                    .datePickerStyle(.compact)
                                    .fixedSize()
                                    .offset(x: -2)
                            }
                        }
                    }
                    .hAlign(.leading)
                    .padding(.horizontal, 20)
                    .navigationTitle("Add Promotion".localizedString)
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
                                save()
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
            }
        }
        .onAppear {
            viewModel.promotion.date = settings.selectedCalendarDate
        }
    }
    
    func save() {
        persistanceManager.createPromotion(from: viewModel.promotion, context: managedObjContext)
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

struct AddPromotionView_Previews: PreviewProvider {
    struct Container: View {
        
        var body: some View {
            AddPromotionView(viewModel: .init())
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
