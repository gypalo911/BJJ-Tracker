//
//  SelectionPanelView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.04.2023.
//

import SwiftUI

struct SelectionPanelView<T: RawRepresentable & CaseIterable>: View where T.RawValue == String {
    let g: GeometryProxy
    let valuesList: [String]
    
    @Binding var selectedType: T
    @State var selectedTypeValue: String {
        didSet {
            selectedType = T(rawValue: selectedTypeValue)!
        }
    }

    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        ZStack(alignment: .topLeading) {
            ForEach(valuesList, id: \.self) { type in
                RectangleOption(type: type, selectedType: $selectedTypeValue)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if type == valuesList.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if type == valuesList.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.onChange(of: selectedTypeValue, perform: { val in
            selectedType = T(rawValue: val)!
        })
    }
}

struct RectangleOption: View {
    let type: String
    @Binding var selectedType: String
    
    var body: some View {
        let isSelected = type == selectedType
        
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedType = type
            }
        }, label: {
            Text(type)
                .fontWeight(.regular)
                .foregroundColor(.black)
                .padding(.horizontal, 15)
                .padding(.vertical, 6)
                .background(
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color("Blue") : Color("LightGray"), lineWidth: isSelected ? 2 : 1)
                            .foregroundColor(.white)
                    }
                )
        }).padding(5)
    }
}

struct DurationSelectorView: View {
    @Binding var isPickerPresented: Bool
    @Binding var duration: Int
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isPickerPresented.toggle()
            }
        }, label: {
            let duration = duration.minutesToDuration()
            Text("\(duration)")
                .font(.system(size: 18))
                .fontWeight(.regular)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .background(
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("LightGray").opacity(0.5))
                    }
                )
        })
        .padding(.leading, 5)
    }
}

struct TitleTextView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 18))
            .fontWeight(.medium)
    }
}

struct SelectionPanelView_Previews: PreviewProvider {
    struct Container: View {
        @StateObject var promotion: Promotion = .init(gradingSystem: .adult, adultBelt: .white, stripes: 1, date: Date(), location: "", notes: "")
        
        var body: some View {
            GeometryReader {geometry in
                SelectionPanelView(
                    g: geometry,
                    valuesList: AdultBelts.allCases.filter { $0 != .none }.map { $0.rawValue },
                    selectedType: $promotion.adultBelt,
                    selectedTypeValue: AdultBelts.white.rawValue
                )
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
