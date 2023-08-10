//
//  DurationPicker.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 08.04.2023.
//

import SwiftUI

struct DurationPicker: View {
    
    @Binding var duration: Int
    
    @State private var hours = 0
    @State private var minutes = 0
    
    var totalDurationInMinutes: Int {
        return hours * 60 + minutes
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Picker("Hours", selection: $hours) {
                    ForEach(0..<24) { hour in
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("\(hour)")
                                .font(.title3)
                            Text("hours")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: geometry.size.width / 2)
                .clipped()
                .onChange(of: hours) { _ in
                    duration = totalDurationInMinutes
                }
                
                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60) { minute in
                        HStack(alignment: .bottom, spacing: 3) {
                            Text("\(minute)")
                                .font(.title3)
                            Text("min")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: geometry.size.width / 2)
                .clipped()
                .onChange(of: minutes) { _ in
                    duration = totalDurationInMinutes
                }
            }
        }
        .frame(height: 150)
    }
}

struct DurationPickerPreviewProvider_Previews: PreviewProvider {
    struct Content: View {
        @State var duration: Int = 0
        
        var body: some View {
            DurationPicker(duration: $duration)
        }
    }
    
    static var previews: some View {
        Content()
    }
}
