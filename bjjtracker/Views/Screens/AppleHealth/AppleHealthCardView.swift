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

struct AppleHealthCardView_Previews: PreviewProvider {
    static var previews: some View {
        AppleHealthCardView()
    }
}
