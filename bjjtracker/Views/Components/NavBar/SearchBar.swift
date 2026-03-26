//
//  SearchBar.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 30.08.2023.
//

import SwiftUI

private enum SearchBarLocalisation {
    static let cancel = "Cancel"
    static let techniques = "Techniques"
}

struct SearchBar: View {
    @Binding var isHeaderHidden: Bool
    @Binding var isEditing: Bool
    @Binding var searchText: String
    @Binding var isEmptySearchState: Bool
    
    @FocusState private var isTextFieldFocused: Bool
    
    var onEndEditing: (() -> Void)?
    
    var body: some View {
        HStack {
            TextField(
                "Search by Keyword",
                text: $searchText,
                onEditingChanged: { (editingChanged) in
                    if !editingChanged {
                        onEndEditing?()
                        self.isTextFieldFocused = false
                    }
                }
            )
            .focused($isTextFieldFocused)
            .font(.callout)
            .padding(.leading, 35)
            .overlay(
                HStack {
                    Image("search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(DesignSystem.shared.colors.redPink)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 0)
                    
                    if isEditing && !isEmptySearchState {
                        Button(action: {
                            self.searchText = ""
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundColor(.black)
                                Image("close")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 7, height: 7)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 20, height: 20)
                        }
                    }
                }
            )
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(DesignSystem.shared.colors.lightLightGray)
            .cornerRadius(10)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                    self.isEditing = true
                    self.isTextFieldFocused = true
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isHeaderHidden = true
                }
            }
            .onSubmit {
                withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                    self.isEditing = false
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isHeaderHidden = false
                }
            }
            .onChange(of: searchText) { _, value in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isEmptySearchState = value.isEmpty
                }
            }
            
            if isEditing {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isEditing = false
                        self.isTextFieldFocused = false
                        self.searchText = ""
                        self.onEndEditing?()
                    }
                    withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                        self.isHeaderHidden = false
                    }
                }) {
                    Text(SearchBarLocalisation.cancel.localizedString)
                        .foregroundColor(.black)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .opacity(isEditing ? 1 : 0)
            }
        }
    }
}

struct HeaderView: View {
    var onBack: (() -> Void)?
    var onCreate: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    onBack?()
                }, label: {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(DesignSystem.shared.colors.blue)
                })
                Spacer()
                Button(action: {
                    onCreate?()
                }, label: {
                    Image("createButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(DesignSystem.shared.colors.blue)
                })
            }
            Text(SearchBarLocalisation.techniques.localizedString)
                .font(token: DesignSystem.shared.fonts.title, weight: .bold)
                .foregroundColor(.black)
                .hAlign(.leading)
        }
    }
}


struct SearchBar_Previews: PreviewProvider {
    struct Container: View {
        @State var isHeaderHidden = false
        @State var isEmptySearchStateState = true
        @State var isEditing = false
        @State var searchText = ""
        
        var body: some View {
            VStack {
                HeaderView(onCreate:  {
                    
                })
                SearchBar(
                    isHeaderHidden: $isHeaderHidden,
                    isEditing: $isEditing,
                    searchText: $searchText,
                    isEmptySearchState: $isEmptySearchStateState
                )
            }
            .edgesIgnoringSafeArea(.all)
            .padding(20)
            .vAlign(.top)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
