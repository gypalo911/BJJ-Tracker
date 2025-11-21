//
//  View+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func offset(
        coordinateSpace: CoordinateSpace,
        completion: @escaping (CGFloat) -> ()
    ) -> some View {
        self
            .overlay(
                GeometryReader { proxy in
                    let minY = proxy.frame(in: coordinateSpace).minY
                    Color.clear
                        .preference(key: OffsetPreferenceKey.self, value: minY)
                        .onPreferenceChange(OffsetPreferenceKey.self) { value in
                            completion(value)
                        }
                }
            )
    }
    
    // for iOS <= 15
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func hAlign(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func defaultShadow() -> some View {
        self.shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 0)
    }
    
    func changeNavBar(_ color: UIColor = .clear) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = color
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    @ViewBuilder
    func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    func defaultPicker() -> some View {
        self
            .pickerStyle(.automatic)
            .padding(.horizontal, 16)
            .accentColor(.black)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("Blue"), lineWidth: 1))
    }
}
