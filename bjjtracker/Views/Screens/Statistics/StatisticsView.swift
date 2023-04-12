//
//  StatisticsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.04.2023.
//

import SwiftUI

struct StatisticsView: View {
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSegment = 0
    
    private var segments = ["Week", "Month", "Year"]
    
    var body: some View {
        VStack {
            SegmentedPicker(items: segments, selection: $selectedSegment)
                .padding()
            ScrollView {
                
            }
        }
        .vAlign(.top)
        .navigationBarBackButtonHidden(true)
        .customToolBar(
            dismissAction: {
                settings.isTabBarHidden = false
                presentationMode.wrappedValue.dismiss()
            },
            mainAction: {
                
            })
        .onAppear {
            settings.isTabBarHidden = true
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatisticsView()
        }
    }
}

private extension View {
    func customToolBar(
        dismissAction: @escaping (() -> ()),
        mainAction: @escaping (() -> ())
    ) -> some View {
        return self.toolbar {
            ToolbarItem(placement: .principal) {
                Text("7-14 September 2023")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color("Blue"))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    mainAction()
                } label: {
                    Image("calendar")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color("Blue"))
                }
            }
        }
    }
}
