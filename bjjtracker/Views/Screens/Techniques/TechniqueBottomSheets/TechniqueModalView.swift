//
//  TechniqueModalView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 23.08.2023.
//

import SwiftUI

enum TechniqueField: Hashable {
    case name
    case details
}

struct TechniqueModalView: View {
    enum ModalState {
        case modifying
        case overview
    }
    
    @State var state: ModalState = .overview
    @StateObject var technique: Technique = Technique(name: "", details: "")
    @FocusState private var focusedField: TechniqueField?
    
    @State var textFieldHeight: CGFloat = 100.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch state {
            case .modifying:
                CreateEditState()
            case .overview:
                OverviewState()
            }
        }
        .vAlign(.top)
        .hAlign(.leading)
        .padding(20)
        .frame(maxHeight: UIScreen.main.bounds.size.height * (focusedField == .details ? 0.6 : 0.4))
        .animation(.easeInOut(duration: 0.25), value: focusedField)
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
                .font(.title2.weight(.bold))
                .submitLabel(.next)
                .focused($focusedField, equals: .name)
                .onSubmit {
                    focusedField = .details
                }
                
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
            ZStack(alignment: .leading) {
                TextEditor(text: $technique.details)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 0.01)
                            .stroke(Color("LightGray"), lineWidth: 2)
                    )
                    .padding(.leading, 5)
                    .focused($focusedField, equals: .details)
                if technique.details.isEmpty {
                    VStack {
                        Text("Add some details...".localizedString)
                            .font(.body)
                            .foregroundColor(Color("GrayTextColor"))
                            .padding(20)
                        Spacer()
                    }
                }
            }
            .background(GeometryReader { proxy in
                Color.clear
                    .onChange(of: textFieldHeight, perform: { value in
                        if proxy.size.height > textFieldHeight {
                            textFieldHeight = proxy.size.height + 17.0
                        }
                    })
                
            })
            .frame(height: CGFloat(textFieldHeight), alignment: .top)
        }
        .onAppear {
            focusedField = .name
        }
    }
    
    @ViewBuilder
    func OverviewState() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("\(technique.name)")
                    .font(.title2.weight(.bold))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        state = .modifying
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
                
//                Button(action: {
//
//                }, label: {
//                    Image("star")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(.black)
//                })
            }
            
            Text("\(technique.details)")
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
                                    isShowingOverlay.toggle()
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .bottomSheet(isPresented: $isShowingOverlay) {
                    TechniqueModalView(state: .overview)
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

