//
//  TechniquesView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct TechniquesView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isHeaderHidden = false
    @State private var isSuggestionViewHidden = true
    @State private var isEditing = false
    @State private var searchText = ""
    @State private var offsetY: CGFloat = .zero
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack {
                    if !isHeaderHidden {
                        HeaderView()
                            .offset(y: -offsetY)
                            .zIndex(2)
                    }
                    SearchBar()
                        .offset(y: -offsetY)
                        .zIndex(1)
                    
                    if !isSuggestionViewHidden {
                        SuggestionsView()
                            .offset(y: -offsetY)
                            .opacity(isSuggestionViewHidden ? 0 : 1)
                    }
                    Text("Learned techniques:")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .offset(y: -offsetY)
                        .hAlign(.leading)
                        .padding(.top, 10)
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)
                .background(
                    Rectangle()
                        .fill(.white)
                        .frame(width: .infinity, height: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .offset(y: -offsetY)
                )
                .zIndex(2)
                
                VStack(alignment: .leading) {
                    ForEach(0..<10) { item in
                        VStack(spacing: 15) {
                            TechbiquesListCell()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .hAlign(.leading)
            }
            .offset(coordinateSpace: .named("scroll")) { offset in
                offsetY = offset
            }
        }
        .coordinateSpace(name: "scroll")
        .ignoresSafeArea()
        .onAppear {
            settings.isTabBarHidden = true
        }
        .onChange(of: searchText) { value in
            withAnimation(.easeInOut(duration: 0.3)) {
                isSuggestionViewHidden = value.isEmpty
            }
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("Blue"))
                })
                Spacer()
                Button(action: {
                    
                }, label: {
                    Image("createButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color("Blue"))
                })
            }
            Text("Techniques")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .hAlign(.leading)
        }
    }
    
    @ViewBuilder
    func SearchBar() -> some View {
        HStack {
            TextField("Search by Keyword", text: $searchText)
                .font(.callout)
                .padding(.leading, 35)
                .overlay(
                    HStack {
                        Image("search")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("RedPink"))
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 0)
                        
                        if isEditing {
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
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                        self.isEditing = true
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isHeaderHidden = true
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Color("LightLightGray"))
                .cornerRadius(10)
            
            if isEditing {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isEditing = false
                        self.searchText = ""
                    }
                    withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                        self.isHeaderHidden = false
                    }
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .opacity(isEditing ? 1 : 0)
            }
        }
    }
    
    @ViewBuilder
    func SuggestionsView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Suggestions")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(Color("GrayTextColor"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1..<5) { tag in
                        SuggestionTagView(
                            tag: Tag(text: "tag-\(tag)"),
                            onTap: {
//                                        viewModel.add(tag: tag)
                            }
                        )
                    }
                }
                .animation(.easeInOut, value: isEditing)
                .padding(.vertical, 5)
                .padding(.horizontal, 2)
            }
        }
        .padding([.leading], 10)
    }
    
    @ViewBuilder
    func TechbiquesListCell() -> some View {
        HStack {
            HStack(alignment: .center, spacing: 4) {
                Text(.init("Delariva"))
                    .font(.footnote)
                    .fontWeight(.regular)
                    .foregroundColor(Color("Blue"))
            }
            Spacer()
            Image("chevronRight")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(Color("Blue"))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .defaultShadow()
        )
        .contentShape(Rectangle())
        .onTapGesture {
//                        onTap?()
        }
    }
}

struct TechniquesView_Previews: PreviewProvider {
    static var previews: some View {
        TechniquesView()
            .environmentObject(AppSettings())
    }
}
