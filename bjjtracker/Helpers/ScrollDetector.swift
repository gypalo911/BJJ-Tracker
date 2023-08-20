//
//  ScrollDetector.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 20.08.2023.
//

import SwiftUI

struct ScrollDetector: UIViewRepresentable {
    typealias UIViewType = UIView
    var onScroll: (CGFloat) -> ()
    // Offset, velocity
    var onDraggingEnded: (CGFloat, CGFloat) -> ()
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView,
               !context.coordinator.isDelegateAdded
            {
                scrollView.delegate = context.coordinator
                context.coordinator.isDelegateAdded = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ScrollDetector
        var isDelegateAdded: Bool = false
        
        init(parent: ScrollDetector) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.onScroll(scrollView.contentOffset.y)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            parent.onDraggingEnded(targetContentOffset.pointee.y, velocity.y)
        }
    }
}

