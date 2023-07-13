//
//  LinkPreview.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import SwiftUI
import UIKit
import SafariServices
import WebKit

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
    @ObservedObject var viewModel: LinkPreviewViewModel
    
    @State var isPresentedWebView: Bool = false
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 170, maxHeight: 101)
                    .clipped()
                    .cornerRadius(16)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 170, height: 45)
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
                    .frame(width: 170, height: 101)
                    .background(Color("LightBlue"))
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
                    .frame(width: 170, height: 45)
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
                Text(viewModel.title ?? viewModel.previewURL?.relativeString ?? "...")
                    .font(.system(size: 10))
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
            if let url = viewModel.previewURL {
                SafariView(url: url)
            }
        }
        .onTapGesture {
            isPresentedWebView = true
        }
    }
}

struct FileLinkView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                LinkPreview(
                    viewModel: .init("https://bjj-world.com/tom-hardy-promoted-to-purple-belt-in-jiu-jitsu/")
                )
                LinkPreview(
                    viewModel: .init("https://bjj-world.com/tom-hardy-promoted-to-purple-belt-in-jiu-jitsu/")
                )
            }
            HStack(spacing: 10) {
                LinkPreview(
                    viewModel: .init("https://bjj-world.com/tom-hardy-promoted-to-purple-belt-in-jiu-jitsu/")
                )
                LinkPreview(
                    viewModel: .init("https://bjj-world.com/tom-hardy-promoted-to-purple-belt-in-jiu-jitsu/")
                )
            }
        }
    }
}
