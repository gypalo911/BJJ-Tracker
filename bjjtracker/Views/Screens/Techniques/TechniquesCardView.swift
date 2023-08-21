//
//  TechniquesCardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct TechniquesCardEmptyState: View {
    var body: some View {
        HStack {
            Image("triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(alignment: .center, spacing: 10) {
                Text("No techniques yet")
                    .font(.footnote)
                    .fontWeight(.semibold)
                Text("Start learning today")
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color("Gray"))
            }
            Spacer()
            Button(action: {
                
            }, label: {
                Text("Add New")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Blue"))
            })
        }
    }
}

struct TechniquesCardFullState: View {
    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 5) {
                    Image("triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("Top 5 used techniques")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                Spacer()
                HStack(spacing: 5) {
                    Text("See all")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("Blue"))
                    Image("eye")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color("Blue"))
                }
            }
            Text("techniques view here")
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
                TechniquesCardEmptyState()
            })
            TechniquesCardView(view: {
                TechniquesCardFullState()
            })
        }
    }
}
