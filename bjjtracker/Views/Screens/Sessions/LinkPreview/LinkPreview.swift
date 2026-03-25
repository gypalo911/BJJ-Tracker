//
//  LinkPreview.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import SwiftUI
import UIKit
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {}
}

struct LinkPreview: View {
    var previewModel: LinkPreviewModel
    
    @State var isPresentedWebView: Bool = false
    
    var onTap: ((String) -> Void)?
    
    var body: some View {
        ZStack {
            if let image = previewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 170)
                    .frame(height: 101)
                    .clipped()
                    .cornerRadius(16)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: 170, maxHeight: 45)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.18, green: 0.18, blue: 0.18), location: 0.00),
                                Gradient.Stop(color: .black.opacity(0), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 1),
                            endPoint: UnitPoint(x: 0.5, y: 0)
                        )
                    )
                    .cornerRadius(10)
                    .vAlign(.bottom)
            } else {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: 170)
                    .frame(height: 101)
                    .background(DesignSystem.shared.colors.lightBlue)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                Image("link")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.white)
                    .vAlign(.top)
                    .padding(.top, 15)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: 170, maxHeight: 45)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.35, green: 0.57, blue: 1), location: 0.00),
                                Gradient.Stop(color: Color(red: 0.35, green: 0.57, blue: 1).opacity(0), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 1),
                            endPoint: UnitPoint(x: 0.5, y: 0)
                        )
                    )
                    .cornerRadius(10)
                    .vAlign(.bottom)
            }
            VStack(alignment: .leading, spacing: 1, content: {
                Text(previewModel.title ?? previewModel.previewURL.relativeString)
                    .font(token: DesignSystem.shared.fonts.caption2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            })
            .vAlign(.bottom)
            .padding(.bottom, 5)
            .padding(.horizontal, 5)
            .transition(.slide.animation(.easeInOut))
        }
        .frame(maxWidth: 170, maxHeight: 100)
        .fullScreenCover(isPresented: $isPresentedWebView) {
            SafariView(url: previewModel.previewURL)
                .ignoresSafeArea()
        }
        .onTapGesture {
            isPresentedWebView = true
            let stringURL = previewModel.previewURL.absoluteString
            onTap?(stringURL)
        }
    }
}

//struct FileLinkView_Previews: PreviewProvider {
//    static var previews: some View {
//        LinkPreview(
//            viewModel: .init("https://bjj-world.com/tom-hardy-promoted-to-purple-belt-in-jiu-jitsu/"),
//            onTap: { _ in }
//        )
//    }
//}
