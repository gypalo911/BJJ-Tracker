//
//  TechniquesCardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct TechniquesCardEmptyState: View {
    private enum Localisation {
        static var noTechniquesYet: String { "No techniques yet".localizedString }
        static var startLearningToday: String { "Start learning today".localizedString }
        static var addNew: String { "Add New".localizedString }
    }

    let persistanceManager: PersistanceManager
    
    var body: some View {
        HStack {
            Image("triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 10) {
                Text(Localisation.noTechniquesYet)
                    .font(token: DesignSystem.shared.fonts.footnote, weight: .semibold)
                Text(Localisation.startLearningToday)
                    .font(token: DesignSystem.shared.fonts.caption, weight: .regular)
                    .foregroundColor(DesignSystem.shared.colors.gray)
            }
            Spacer()
            NavigationLink(destination: {
                TechniquesView(viewModel: .init(persistanceManager: persistanceManager))
            }) {
                Text(Localisation.addNew)
                    .font(token: DesignSystem.shared.fonts.footnote, weight: .semibold)
                    .foregroundColor(DesignSystem.shared.colors.blue)
            }
        }
    }
}

struct TechniquesCardFullState: View {
    private enum Localisation {
        static var seeAll: String { "See All".localizedString }
    }
    
    @Environment(\.openURL) var openURL

    let techniques: [TechniqueModel]
    let persistanceManager: PersistanceManager
    
    var technquesText: String {
        var str: String = ""
        switch techniques.count {
        case let n where n < 10:
            str = "Great start! **%@ techniques** learned!"
                .localized(with: ["\(techniques.count)"])
            break
        case let n where n >= 10:
            str = "You have already learned **%@ techniques**!"
                .localized(with: ["\(techniques.count)"])
            break
        case let n where n >= 20:
            str = "Your progress is impressive! It's already **%@ techniques** learned!"
                .localized(with: ["\(techniques.count)"])
            break
        case let n where n >= 30:
            str = "Keep learning and practicing! It's already **%@ techniques** learned!"
                .localized(with: ["\(techniques.count)"])
            break
        case let n where n >= 40:
            str = "Perseverance is a key! You have already learned **%@ techniques**!"
                .localized(with: ["\(techniques.count)"])
            break
        case let n where n >= 50:
            str = "Always pass on what you have learned! You have already learned **%@ techniques**!"
                .localized(with: ["\(techniques.count)"])
            break
        default:
            str = ""
            break
        }
        return str
    }
    
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
                    Text(LocalizedStringKey(technquesText))
                        .font(token: DesignSystem.shared.fonts.caption, weight: .semibold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                        .environment(\.openURL, OpenURLAction { url in
                            if #available(iOS 26.0, *) {
                                openURL(url, prefersInApp: true)
                            } else {
                                openURL(url)
                            }
                            return .handled
                        })
                }
                Spacer()
                HStack(spacing: 5) {
                    Text(Localisation.seeAll)
                        .font(token: DesignSystem.shared.fonts.footnote, weight: .semibold)
                        .foregroundColor(DesignSystem.shared.colors.blue)
                    Image("eye")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundColor(DesignSystem.shared.colors.blue)
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
