//
//  MonthYearBottomSheetView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI


struct MonthYearBottomSheetView: View {
    @Binding var selectedDate: Date
    @Binding var isBottomSheetOpen: Bool
    
    @State private var bgOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(bgOpacity))
                .ignoresSafeArea()
                .onTapGesture {
                    closeBottomSheet()
                }
            VStack {
                Image("close")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.top, 10)
                    .offset(x: -25, y: 10)
                    .hAlign(.topTrailing)
                .onTapGesture {
                    closeBottomSheet()
                }
                MonthYearPicker(
                    selectedDate: $selectedDate,
                    isBottomSheetOpen: $isBottomSheetOpen
                )
                Spacer()
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 30)
            .background(
                Rectangle()
                    .fill(.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .background(BackgroundClearView())
            )
            .vAlign(.bottom)
            .ignoresSafeArea()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    bgOpacity = 0.4
                }
            }
        }
    }
    
    private func closeBottomSheet() {
        withAnimation(.easeInOut(duration: 0.25)) {
            bgOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isBottomSheetOpen = false
        }
    }
}



struct BackgroundClearView: UIViewRepresentable {
    var color: Color = .clear
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = UIColor(color)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct MonthYearBottomSheetView_Previews: PreviewProvider {
    struct Container: View {
        @State var selectedDate: Date = Date()
        @State var isBottomSheetOpen: Bool = true
        
        var body: some View {
            MonthYearBottomSheetView(selectedDate: $selectedDate, isBottomSheetOpen: $isBottomSheetOpen)
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
