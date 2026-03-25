//
//  TechniquesListView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct TechniquesListView: View {
    private enum Localisation {
        static var learnedTechniques: String { "Learned techniques".localizedString }
        static var suggestions: String { "Suggestions".localizedString }
    }
    
    @Binding var updateTags: Bool
    
    @StateObject var viewModel: TechniquesListViewModel
    
    @State private var isEditing: Bool = false
    @State private var isTyping: Bool = false
    @State private var maxViewWidth: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(Localisation.learnedTechniques)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .padding(.horizontal, 10)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.rows, id: \.self) { rows in
                        HStack(spacing: 10) {
                            ForEach(rows) { tag in
                                TagView(
                                    tag: tag,
                                    onDelete: {
                                        viewModel.removeRegularTag(tag)
                                    }, onDetails: {
                                        viewModel.onTechniqueDetails?(tag.technique)
                                    }
                                )
                            }
                        }.hAlign(.leading)
                    }
                    
                    VStack {
                        if isTyping {
                            TagViewWithTextField(
                                tag: $viewModel.creationalTag,
                                isEditing: $isTyping,
                                onSubmit: { tag in
                                    viewModel.add(tag: tag)
                                },
                                maxViewWidth: maxViewWidth
                            )
                            .opacity(isTyping ? 1 : 0)
                            .padding (.bottom, 5)
                        } else {
                            AddMoreTagView()
                                .padding (.horizontal, 1)
                                .padding (.bottom, 5)
                                .opacity(isTyping ? 0 : 1)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        isTyping = true
                                    }
                                }
                        }
                    }
                }
                .padding([.leading, .top], 10)
                .animation(.easeInOut(duration: 0.3), value: viewModel.rows)
            }
            if !viewModel.suggestionTags.isEmpty && isTyping {
                VStack(alignment: .leading, spacing: 5) {
                    Text(Localisation.suggestions)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("GrayTextColor"))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.suggestionTags, id: \.self) { tag in
                                SuggestionTagView(
                                    tag: tag,
                                    onTap: {
                                        viewModel.add(tag: tag)
                                    }
                                )
                            }
                        }
                        .animation(.easeInOut, value: viewModel.suggestionTags)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 2)
                    }
                }
                .padding([.leading], 10)
            }
        }
        .onAppear {
            maxViewWidth = UIScreen.main.bounds.size.width - 80
            viewModel.maxRowWidth = maxViewWidth
            viewModel.fetchTags()
        }
        .onChange(of: updateTags) { _ in
            viewModel.fetchTags()
        }
    }
}

struct TechniquesListView_Previews: PreviewProvider {
    struct Container: View {
        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
        
        @Namespace var namespace
        
        var body: some View {
            let session: Session = sessionsList.map { $0 }.first!
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
