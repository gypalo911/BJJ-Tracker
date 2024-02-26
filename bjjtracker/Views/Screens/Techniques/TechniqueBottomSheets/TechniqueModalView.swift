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
    
    @Binding var showingCreateTechnique: Bool
    
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @State var state: ModalState = .overview
    @State var name: String = ""
    @State var details: String = ""
    @State var technique: TechniqueModel?
    @FocusState private var focusedField: TechniqueField?
    
    var onUpdate: ((TechniqueModel?) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch state {
            case .modifying:
                CreateEditState()
            case .overview:
                OverviewState()
                    .padding(.bottom, 100)
            }
        }
        .padding(20)
        .animation(.easeInOut(duration: 0.25), value: focusedField)
        .onAppear {
            if let technique = technique {
                name = technique.text ?? ""
                details = technique.details ?? ""
            }
        }
    }
    
    @ViewBuilder
    func CreateEditState() -> some View {
        VStack(spacing: 20) {
            HStack {
                TextField(
                    "Technique name",
                    text: $name,
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
                
                HStack(spacing: 20) {
                    Button(action: {
                        if let technique = technique {
                            persistanceManager.delete(model: technique)
                            onUpdate?(nil)
                        }
                        name = ""
                        details = ""
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingCreateTechnique = false
                        }
                    }, label: {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(name.isEmpty ? Color("DefaultGray") : Color("RedPink"))
                    })
                    .disabled(name.isEmpty)
                    Button(action: {
                        if technique == nil {
                            technique = persistanceManager.createTechnique(
                                name: name,
                                details: details
                            )
                        } else if let technique = technique {
                            persistanceManager.edit(
                                model: technique,
                                name: name,
                                details: details
                            )
                            onUpdate?(technique)
                        }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            state = .overview
                        }
                    }, label: {
                        Text("Done".localizedString)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(name.isEmpty ? Color("DefaultGray") : Color("DefaultBlue"))
                    })
                    .disabled(name.isEmpty)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
            ZStack(alignment: .leading) {
                TextEditor(text: $details)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 0.01)
                            .stroke(Color("DefaultLightGray"), lineWidth: 2)
                    )
                    .padding(.leading, 5)
                    .focused($focusedField, equals: .details)
                if details.isEmpty {
                    VStack {
                        Text("Add some details...".localizedString)
                            .font(.body)
                            .foregroundColor(Color("GrayTextColor"))
                            .padding(20)
                        Spacer()
                    }
                }
            }
            .frame(maxHeight: 200)
            .keyboardAdaptive()
        }
        .onAppear {
            focusedField = .name
        }
    }
    
    @ViewBuilder
    func OverviewState() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Technique")
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("GrayTextColor"))
                    Text("\(name)")
                        .font(.title2.weight(.bold))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        state = .modifying
                    }
                }, label: {
                    Image(systemName: "pencil.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("RedPink"))
                })
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text("Description")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color("GrayTextColor"))
                ScrollView {
                    Text("\(details)")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(Color("DefaultGray"))
                }
                .frame(height: 100)
            }
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
                    TechniqueModalView(
                        showingCreateTechnique: $isShowingOverlay,
                        state: .modifying,
                        onUpdate: { _ in
                            
                        }
                    )
                }
            }
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}

