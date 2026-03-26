//
//  TabBarViewV3.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.03.2026.
//

import SwiftUI

// Liquid Glass style tabbar
struct TabBarViewV3ItemView<TabItemView: View>: UIViewRepresentable {
    var size: CGSize
    var activeTint: Color = .blue
    var barTint: Color = .gray.opacity(0.15)
    @Binding var activeTab: CustomTab
    @ViewBuilder var tabItemView: (CustomTab) -> TabItemView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let items = CustomTab.allCases.map(\.rawValue)
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0

        /// Converting Tab Item View into an image!
        for (index, tab) in CustomTab.allCases.enumerated() {
            let renderer = ImageRenderer(content: tabItemView(tab))
            
            /// 2 is enough, but you can change it as per your wish!
            renderer.scale = 2
            
            let image = renderer.uiImage
            control.setImage(image, forSegmentAt: index)
        }

        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                    subview.alpha = 0
                }
            }
        }

        control.selectedSegmentTintColor = UIColor(barTint)
        control.setTitleTextAttributes(
            [
                .foregroundColor: UIColor(activeTint)
            ],
            for: .selected
        )

        control.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.tabSelected(_:)),
            for: .valueChanged
        )

        return control
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIViewType, context: Context) -> CGSize? {
        size
    }
    
    class Coordinator: NSObject {
        var parent: TabBarViewV3ItemView
        init(parent: TabBarViewV3ItemView) {
            self.parent = parent
        }
        
        @objc func tabSelected(_ control: UISegmentedControl) {
            parent.activeTab = CustomTab.allCases[control.selectedSegmentIndex]
        }
    }
}

@available(iOS 26, *)
struct TabBarViewV3: View {
    @Binding var activeTab: CustomTab
    
    let onCreateAction: (() -> Void)

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                GeometryReader {
                    TabBarViewV3ItemView(size: $0.size, activeTab: $activeTab) { tab in
                        VStack(spacing: 3) {
                            (activeTab == tab ? tab.selectedImage : tab.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            
                            
                            Text(tab.rawValue)
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                        }
                    }
                    .glassEffect(.regular.interactive(), in: .capsule)
                }
                
                Button(action: onCreateAction) {
                    Image("plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 55, height: 55)
                .buttonStyle(.plain)
                .contentShape(.capsule)
                .glassEffect(.regular.interactive(), in: .capsule)
            }
            .frame(height: 55)
        }
        .padding(.horizontal, 20)
    }
}

@available(iOS 26, *)
#Preview {
    VStack {
        Spacer()
        Text("")
            
        Spacer()
    }.safeAreaInset(edge: .bottom, spacing: 0) {
        TabBarViewV3(activeTab: .constant(.dashboard), onCreateAction: {
            debugPrint("++")
        })
    }
}
