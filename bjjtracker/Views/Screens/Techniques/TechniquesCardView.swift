//
//  TechniquesCardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct TechniquesCardEmptyState: View {
    let persistanceManager: PersistanceManager
    
    var body: some View {
        HStack {
            Image("triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 10) {
                Text("No techniques yet")
                    .font(.footnote)
                    .fontWeight(.semibold)
                Text("Start learning today")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color("Gray"))
            }
            Spacer()
            NavigationLink(destination: {
                TechniquesView(viewModel: .init(persistanceManager: persistanceManager))
            }) {
                Text("Add New")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Blue"))
            }
        }
    }
}

struct TechniquesCardFullState: View {
    let techniques: [TechniqueModel]
    let persistanceManager: PersistanceManager
    
    var body: some View {
        NavigationLink(destination: {
            TechniquesView(viewModel: .init(persistanceManager: persistanceManager))
        }) {
            HStack {
                HStack(spacing: 10) {
                    Image("triangle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.black)
                        .frame(width: 30, height: 30)
                    Text("You have already learned **\(techniques.count) techniques**")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
                Spacer()
                HStack(spacing: 5) {
                    Text("See All")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("Blue"))
                    Image("eye")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color("Blue"))
                }
            }
        }
    }
}

struct TechniquesCardView<MyContent: View>: View {
    @ViewBuilder let view: MyContent
    var onTap: (() -> Void)?
    
    var body: some View {
        view
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .defaultShadow()
            )
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
    }
}

struct TechniquesCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TechniquesCardView(view: {
                TechniquesCardEmptyState(persistanceManager: PersistanceManager.preview)
            })
            TechniquesCardView(view: {
                TechniquesCardFullState(
                    techniques: PersistanceManager.preview.fetchAllTechniques(),
                    persistanceManager: PersistanceManager.preview)
            })
        }
    }
}
