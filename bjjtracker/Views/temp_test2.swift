//
//  temp_test2.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI

struct ContentView2: View {
    
    @State var maxHeight: CGFloat = UIScreen.main.bounds.height / 3
    
    @State var sliderProgress: CGFloat = 0
    @State var sliderHeight: CGFloat = 0
    @State var lastDragValue: CGFloat = 0
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.blue.opacity(0.55))
                Rectangle()
                    .fill(Color.blue.opacity(0.55))
                    .frame(height: sliderHeight)
            }
            .animation(.easeInOut(duration: 0.5))
            .frame(width: 100, height: maxHeight)
            .cornerRadius(20)
            .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                let translation = value.translation
                
                sliderHeight = -translation.height + lastDragValue
                
                sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
                
                sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
                
                let progress = sliderHeight / maxHeight
                sliderProgress = progress <= 1 ? progress : 1
            }).onEnded({ value in
                sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
                
                sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
                
                lastDragValue = sliderHeight
            }))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.darkGray).ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
