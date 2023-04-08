//
//  NewSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 08.04.2023.
//

import SwiftUI

struct NewSessionView: View {
    @StateObject var activity: Activity = .init(type: .session, style: .gi, duration: 0, startDate: Date(), location: "", notes: "")
    
    @State private var selectedDate = Date()
    @State private var isPickerPresented = false
    
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "1. Select type:")
                                
                                SelectionPanelView(
                                    g: geometry,
                                    valuesList: ActivityType.allCases.map { $0.rawValue },
                                    selectedType: $activity.type,
                                    selectedTypeValue: ActivityType.session.rawValue
                                )
                            }.padding(.top, 10)
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "2. Select grappling style:")
                                SelectionPanelView(
                                    g: geometry,
                                    valuesList: GraplingStyle.allCases.map { $0.rawValue },
                                    selectedType: $activity.style,
                                    selectedTypeValue: GraplingStyle.gi.rawValue
                                )
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "3. Select date and time:")
                                DatePicker("", selection: $activity.startDate)
                                    .datePickerStyle(.compact)
                                    .fixedSize()
                                    .offset(x: -2)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "4. Duration:")
                                
                                DurationSelectorView(isPickerPresented: $isPickerPresented, duration: $activity.duration)
                                if isPickerPresented {
                                    DurationPicker(duration: $activity.duration)
                                        .frame(height: 150)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Location:")
                                TextField("Location...", text: $activity.location)
                                    .frame(maxHeight: 50, alignment: .top)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("BlueWithOpacity"))
                                    ).padding(.leading, 5)
                            }
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Notes")
                                TextField("Add some details...", text: $activity.notes)
                                    .frame(minHeight: 150, alignment: .top)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("BlueWithOpacity"))
                                    ).padding(.leading, 5)
                            }
                        }
                    }
                    .hAlign(.leading)
                    .padding(.horizontal, 20)
                    .navigationTitle("Create Session")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Cancel")
                                    .fixedSize()
                                    .foregroundColor(Color("Blue"))
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                print(activity)
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
    }
}

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
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if type == valuesList.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
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
            HStack {
                let hours = duration.formatMinutes().0
                if hours != "0"{
                    HStack(alignment: .bottom, spacing: 2) {
                        Text("\(hours)")
                            .font(.system(size: 20))
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                        Text("h")
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                    }
                }
                let minutes = duration.formatMinutes().1
                HStack(alignment: .bottom, spacing: 2) {
                    Text("\(minutes)")
                        .font(.system(size: 20))
                        .fontWeight(.regular)
                        .foregroundColor(.black)
                    Text("min")
                        .fontWeight(.regular)
                        .foregroundColor(.black)
                }
            }
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


struct NewSessionView_Previews: PreviewProvider {
    struct Container: View {

        var body: some View {
            NewSessionView()
        }
    }
    
    static var previews: some View {
        Container()
    }
}
