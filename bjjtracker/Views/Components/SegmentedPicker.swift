//
//  SegmentedPicker.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.04.2023.
//

import SwiftUI

struct SegmentedPickerStyle {
    static let activeSegmentColor: Color = Color(.tertiarySystemBackground)
    static let backgroundColor: Color = Color(.secondarySystemBackground)
    static let shadowColor: Color = Color.black.opacity(0.2)
    static let textColor: Color = Color(.secondaryLabel)
    static let selectedTextColor: Color = Color(.label)

    static let textFont: Font = .system(size: 16)
    static let textFontWeight: Font.Weight = .semibold
    
    static let segmentCornerRadius: CGFloat = 20
    static let shadowRadius: CGFloat = 4
    static let segmentXPadding: CGFloat = 16
    static let segmentYPadding: CGFloat = 8
    static let pickerPadding: CGFloat = 4
    
    static let animationDuration: Double = 0.2
}

struct SegmentedPicker: View {
    
    /// Stores the size of a segment, used to create the active segment rect
    @State private var segmentSize: CGSize = .zero
    /// Rounded rectangle to denote active segment
    private var activeSegmentView: AnyView {
        /// Don't show the active segment until we have initialized the view
        /// This is required for `.animation()` to display properly, otherwise the animation will fire on init
        let isInitialized: Bool = segmentSize != .zero
        if !isInitialized { return EmptyView().eraseToAnyView() }
        return
            RoundedRectangle(cornerRadius: SegmentedPickerStyle.segmentCornerRadius)
                .foregroundColor(SegmentedPickerStyle.activeSegmentColor)
                .shadow(color: SegmentedPickerStyle.shadowColor, radius: SegmentedPickerStyle.shadowRadius)
                .frame(width: self.segmentSize.width, height: self.segmentSize.height)
                .offset(x: self.computeActiveSegmentHorizontalOffset(), y: 0)
                .animation(.linear(duration: SegmentedPickerStyle.animationDuration), value: selection)
                .eraseToAnyView()
    }
    
    @Binding private var selection: Int
    private let items: [String]
    
    var onChanged: ((_ segment: Int) -> Void)?
    
    init(items: [String], selection: Binding<Int>, onChanged: ((_ segment: Int) -> Void)?) {
        self._selection = selection
        self.items = items
        self.onChanged = onChanged
    }
    
    var body: some View {
        /// Align the ZStack to the leading edge to make calculating offset on activeSegmentView easier
        ZStack(alignment: .leading) {
            // activeSegmentView indicates the current selection
            self.activeSegmentView
            HStack {
                ForEach(0..<self.items.count, id: \.self) { index in
                    self.getSegmentView(for: index)
                }
            }
        }
        .padding(SegmentedPickerStyle.pickerPadding)
        .background(SegmentedPickerStyle.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: SegmentedPickerStyle.segmentCornerRadius))
    }

    /// Helper method to compute the offset based on the selected index
    private func computeActiveSegmentHorizontalOffset() -> CGFloat {
        CGFloat(self.selection) * (self.segmentSize.width + SegmentedPickerStyle.segmentXPadding / 2)
    }

    /// Gets text view for the segment
    private func getSegmentView(for index: Int) -> some View {
        guard index < self.items.count else {
            return EmptyView().eraseToAnyView()
        }
        let isSelected = self.selection == index
        return
            Text(self.items[index])
            .font(SegmentedPickerStyle.textFont)
            .fontWeight(SegmentedPickerStyle.textFontWeight)
            .foregroundColor(isSelected ? SegmentedPickerStyle.selectedTextColor: SegmentedPickerStyle.textColor)
            .lineLimit(1)
            .padding(.vertical, SegmentedPickerStyle.segmentYPadding)
            .padding(.horizontal, SegmentedPickerStyle.segmentXPadding)
            .frame(minWidth: 0, maxWidth: .infinity)
            .modifier(SizeAwareViewModifier(viewSize: self.$segmentSize))
            .onTapGesture { self.onItemTap(index: index) }
            .onLongPressGesture { self.onItemTap(index: index) }
            .eraseToAnyView()
    }

    /// On tap to change the selection
    private func onItemTap(index: Int) {
        guard index < self.items.count else {
            return
        }
        self.selection = index
        self.onChanged?(index)
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct BackgroundGeometryReader: View {
    var body: some View {
        GeometryReader { geometry in
            return Color
                    .clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
}

struct SizeAwareViewModifier: ViewModifier {

    @Binding private var viewSize: CGSize

    init(viewSize: Binding<CGSize>) {
        self._viewSize = viewSize
    }

    func body(content: Content) -> some View {
        content
            .background(BackgroundGeometryReader())
            .onPreferenceChange(SizePreferenceKey.self, perform: { if self.viewSize != $0 { self.viewSize = $0 }})
    }
}
