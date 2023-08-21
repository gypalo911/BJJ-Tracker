//
//  AppleHealthCardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 20.08.2023.
//

import SwiftUI

struct AppleHealthCardView: View {
    var onTap: (() -> Void)?
    
    var body: some View {
        HStack {
            Image("apple-health")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            HStack(alignment: .center, spacing: 4) {
                Text("Connect with")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                Text("Apple Health")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.vertical, 10)
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

struct CommonCardView<CustomImage: View, CustomText: View>: View {
    @ViewBuilder let image: CustomImage
    @ViewBuilder let text: CustomText
    var onTap: (() -> Void)?
    
    var body: some View {
        HStack {
            image
            text
            Spacer()
        }
        .padding(.vertical, 10)
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

struct AppleHealthCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AppleHealthCardView()
            CommonCardView(
                image: {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.red)
                }, text: {
                    Text("**1200 kcal** burned")
                        .font(.footnote)
                        .foregroundColor(.black)
                }
            )
            CommonCardView(
                image: {
                    Image("activities")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.black)
                },
                text: {
                    Text("**4** activities beside BJJ")
                        .font(.footnote)
                        .foregroundColor(.black)
                }
            )
        }
    }
}
