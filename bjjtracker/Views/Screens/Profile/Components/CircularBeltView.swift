//
//  CircularBeltView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.05.2023.
//

import SwiftUI

struct CircularBeltView: View {
    let primaryColor: Color
    let secondaryColor: Color?
    var isSelected: Bool = true
    var height: CGFloat = 36
    
    var strokeColor: Color {
        return isSelected ? Color.black : Color.gray
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle()
                        .stroke(strokeColor, lineWidth: 2)
                )
                .frame(width: height, height: height)
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .fill(primaryColor)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .stroke(strokeColor, lineWidth: 2)
                    )
                    .frame(width: height - 8, height: height - 8)
            }
            .rotationEffect(.degrees(-90))
            
            if let secondaryColor = secondaryColor {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .fill(secondaryColor)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: 0.5)
                                .stroke(strokeColor, lineWidth: 2)
                        )
                        .frame(width: height - 8, height: height - 8)
                }
                .rotationEffect(.degrees(90))
            }
            Rectangle()
                .fill(strokeColor)
                .frame(width: 2, height: height - 6)
        }
    }
}

struct CircularBeltView_Previews: PreviewProvider {
    static var previews: some View {
        CircularBeltView(primaryColor: Color.blue, secondaryColor: nil)
    }
}
