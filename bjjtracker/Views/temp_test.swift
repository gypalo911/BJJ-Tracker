//
//  temp_test.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI

struct ContentView1: View {
    @State private var currentIndex: Int = 0
    
    let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 5", "Item 5", "Item 5", "Item 5"]
    
    @State var time = Timer.publish(every: 0.1, on: .current, in: .tracking).autoconnect()
    
    @State private var show: Bool = false
    
    @State private var globalY: CGFloat = 0
    @State private var globalPadding: Int = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            
            if self.show {
                TopView().zIndex(1)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                        GeometryReader { gr in
                            
                            Rectangle()
                                .fill(.orange)
                                .offset(y: gr.frame(in: .global).minY > 0 ? -gr.frame(in: .global).minY : 0)
                                .frame(height: gr.frame(in: .global).minY > 0 ? UIScreen.main.bounds.height / 2.2 + gr.frame(in: .global).minY : UIScreen.main.bounds.height / 2.2)
                                .onReceive(self.time) { (_) in
                                    let y = gr.frame(in: .global).minY
                                    
                                    globalY = y
                                    
                                    let padd = Int(((UIScreen.main.bounds.height / 2.2) / -globalY))
                                    if padd < 10 && padd > -10 {
                                        globalPadding = padd
                                    }
                                    
                                    if -y > (UIScreen.main.bounds.height / 2.2) - 100 {
                                        self.show = true
                                    } else {
                                        self.show = false
                                    }
                                }
                            HStack(alignment: .center) {
                                VStack(alignment: .center) {
                                    ForEach(1..<5) { item in
                                        HStack {
                                            ForEach(1..<5) { item in
                                                Text("\(item)").padding(10)
                                            }
                                        }.padding(20)
                                    }
                                }
                            }.hAlign(.center)
                        }.frame(height: UIScreen.main.bounds.height / 2.2)
                    VStack {
                        ForEach(0..<items.count, id: \.self) { index in
                            VStack {
                                Text(items[index])
                                    .font(.largeTitle)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .id(index)
                                
                                Divider()
                            }.padding()
                        }
                    }
                }
            }.zIndex(0)
        }.edgesIgnoringSafeArea(.top)
    }
}

struct TopView: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("some text")
                }
                
                Text("2222")
            }.padding(.top, 30)
        }.frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.red)
            .foregroundColor(Color.blue)
//            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top == 0 ?
//                     15 : (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 5)
//            .padding(.horizontal)
//            .padding(.bottom)
//            .ignoresSafeArea()
    }
}

struct ContentView1_Previews: PreviewProvider {
    static var previews: some View {
        ContentView1()
    }
}
