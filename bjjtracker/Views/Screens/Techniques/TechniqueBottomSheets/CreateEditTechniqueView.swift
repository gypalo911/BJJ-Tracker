//
//  CreateEditTechniqueView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 23.08.2023.
//

import SwiftUI

struct TechniqueModalView: View {
    enum ModalState {
        case editing
        case creating
        case overview
    }
    
    @State var state: ModalState = .overview
    @StateObject var technique: Technique = Technique(name: "", details: "")
    @FocusState private var isFocusedTechniqueName: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch state {
            case .editing:
                CreateEditState()
            case .creating:
                CreateEditState()
            case .overview:
                OverviewState()
            }
        }
        .padding(20)
        .hAlign(.leading)
        .padding(.bottom, 400)
    }
    
    @ViewBuilder
    func CreateEditState() -> some View {
        VStack(spacing: 20) {
            HStack {
                TextField(
                    "Technique name",
                    text: $technique.name,
                    onEditingChanged: { (editingChanged) in
                        if !editingChanged {
                            
                        }
                    }
                )
                .font(.title.weight(.bold))
                .focused($isFocusedTechniqueName)
                
                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            state = .overview
                        }
                    }, label: {
                        ZStack {
                            Circle()
                                .foregroundColor(Color("Green"))
                            Image("checkmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.white)
                        }
                        .frame(width: 35, height: 35)
                    })
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            state = .overview
                        }
                    }, label: {
                        ZStack {
                            Circle()
                                .foregroundColor(Color("RedPink"))
                            Image("close")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.white)
                        }
                        .frame(width: 35, height: 35)
                    })
                }
            }
            CustomTextEditor(text: $technique.details)
                .font(.headline.weight(.regular))
                .font(.headline.weight(.regular))
        }
        .onAppear {
            isFocusedTechniqueName = true
        }
    }
    
    @ViewBuilder
    func OverviewState() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Technique name")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        state = .editing
                    }
                }, label: {
                    ZStack {
                        Circle()
                            .stroke(Color("RedPink"), lineWidth: 1)
                        Image("edit")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("RedPink"))
                    }
                    .frame(width: 35, height: 35)
                })
                
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    Image("star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                })
            }
            
            Text("Add some description here")
                .font(.body)
                .fontWeight(.regular)
                .foregroundColor(Color("Gray"))
        }
    }
}

struct CreateEditTechniqueView_Previews: PreviewProvider {
    struct Container: View {
        @State private var isShowingOverlay: Bool = true
        
        var body: some View {
            NavigationView {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .global).size
                    ZStack {
                        Image("LogoWithText")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(width: frame.width, height: frame.height)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isShowingOverlay = true
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .bottomSheet(isPresented: $isShowingOverlay) {
                    TechniqueModalView()
                }
            }
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
        
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
            .previewDevice(PreviewDevice(rawValue: "iphone 7 ios 15"))
            .previewDisplayName("iphone 7 ios 15")
    }
}

