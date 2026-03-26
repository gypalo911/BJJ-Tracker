//
//  DurationPicker.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 08.04.2023.
//

import SwiftUI

struct DurationPicker: View {
    enum Localisation {
        static let hours = "hours"
        static let minutes = "min"
    }
    
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
                            Text(verbatim: "\(hour)")
                                .font(token: DesignSystem.shared.fonts.title3)
                            Text(Localisation.hours.localizedString)
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: geometry.size.width / 2)
                .clipped()
                .onChange(of: hours) {
                    duration = totalDurationInMinutes
                }
                
                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60) { minute in
                        HStack(alignment: .bottom, spacing: 3) {
                            Text(verbatim: "\(minute)")
                                .font(token: DesignSystem.shared.fonts.title3)
                            Text(Localisation.minutes.localizedString)
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: geometry.size.width / 2)
                .clipped()
                .onChange(of: minutes) {
                    duration = totalDurationInMinutes
                }
            }
        }
        .frame(height: 150)
        .onAppear {
            hours = Int(duration / 60)
            minutes = Int(duration % 60)
        }
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
