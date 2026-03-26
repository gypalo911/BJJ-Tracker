//
//  BottomSheetModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 04.08.2023.
//

import SwiftUI

struct BottomSheetModifier<InnerView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @ViewBuilder let view: InnerView
    
    private let blurRadius: CGFloat = 5
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: isPresented ? blurRadius : 0, opaque: false)
            .overlay(alignment: .bottom) {
                if isPresented {
                    GenericBottomSheet(view: view, isBottomSheetOpen: $isPresented)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onChange(of: isPresented) {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

extension View {
    func bottomSheet(isPresented: Binding<Bool>, @ViewBuilder view: @escaping () -> some View) -> some View {
        return modifier(BottomSheetModifier(isPresented: isPresented, view: view))
    }
}

struct SessionDetailsView_Previews2: PreviewProvider {
    struct Container: View {
        //        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
        @EnvironmentObject var persistanceManager: PersistanceManager
        
        @Namespace var namespace
        
        var body: some View {
            let session: Session = persistanceManager.fetchSessions().first!
            SessionDetailsView(namespace: namespace, viewModel: SessionDetailsViewModel(session: session, persistanceManager: PersistanceManager.preview))
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environmentObject(PersistanceManager.preview)
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
