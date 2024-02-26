//
//  ShareSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 15.02.2024.
//

import SwiftUI
import Charts

enum LayoutType: Int, CaseIterable {
    case one
    case two
    case three
    case four
    case five
}

@available(iOS 16.0, *)
struct Photo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    
    public var image: Image
    public var caption: String
}

@available(iOS 16.0, *)
struct ShareSessionView: View {
    
    private enum ShareViewState {
        case selectImage
        case shareImage
    }
//    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @State private var layoutType: LayoutType = .one
    @State private var selectedImage: UIImage?
    @State private var showSheet: Bool = false
    
    @State private var selectImageState: ShareViewState = .selectImage
    
    let session: Session
    
    var activity: ActivityModel {
        ActivityModel.from(session: session)!
    }
    
    var body: some View {
        let trophyAndDate = imageWithStatisticView(type: layoutType)
            .frame(width: 450, height: 500)
        
        NavigationView {
            VStack {
                if selectImageState == .selectImage {
                    VStack {
                        Spacer()
                        Text("Select image to share with training stats")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(
                                Color("GrayTextColor")
//                                colorScheme == .dark ? Color("GrayTextColor") : Color("DefaultBlue")
                            )
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 220)
                        Spacer()
                        Button {
                            showSheet = true
                        } label: {
                            Image("selectImage")
                                .resizable()
                                .scaledToFit()
                                .padding(30)
                        }
                        .buttonStyle(BouncyButton())
                        Spacer()
                        Text("Share your training results with others!")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(
                                .white
                                //colorScheme == .dark ? .white : Color("DefaultBlue")
                            )
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 220)
                        Spacer()
                    }
                } else {
                    let renderer = createRenderer(view: trophyAndDate)
                    if let image = renderer.uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(LayoutType.allCases, id: \.rawValue) { type in
                                LayoutTypeButtonView(type: type)
                            }
                        }
                        .padding(10)
                        .fixedSize()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
//                colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color("LinearBG1"), Color("LinearBG2")]), startPoint: .top, endPoint: .bottom)
//                : LinearGradient(gradient: Gradient(colors: [Color("generalBG"), Color("lightGreen")]), startPoint: .top, endPoint: .bottom)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("close")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(
                                .white
//                                colorScheme == .dark ? .white : Color("DefaultBlue")
                            )
                    }
                }
                if selectImageState == .shareImage {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        let renderer = createRenderer(view: trophyAndDate)
                        if let image = renderer.uiImage {
                            let photo = Photo(image: Image(uiImage: image), caption: "")
                            ShareLink(
                                item: photo,
                                preview: SharePreview(
                                    "JiuTrack",
                                    image: photo.image)
                            ) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(
                                        .white
//                                        colorScheme == .dark ? .white : Color("DefaultBlue")
                                    )
                            }
                            .simultaneousGesture(TapGesture().onEnded() {
                            })
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSheet) {
            ImagePicker(
                sourceType: .photoLibrary,
                selectedImage: $selectedImage,
                fileName: "avatar",
                callback: {
                    selectImageState = .shareImage
                }
            )
            .ignoresSafeArea()
        }
    }
    
    private func imageWithStatisticView(type: LayoutType) -> some View {
        var image = Image("bjj")
        if let img = selectedImage {
            image = Image(uiImage: img)
        }
        
        return ZStack(alignment: .center) {
            GeometryReader { geometry in
                let size = geometry.frame(in: .global).size
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height, alignment: .center)
                
                layout(type: type, geometry: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func layout(type: LayoutType, geometry: GeometryProxy) -> some View {
        let frame = geometry.frame(in: .global)
        switch type {
        case .one:
            ZStack {
                VStack(alignment: .center) {
                    titleTextView()
                }
                .position(x: frame.width/2, y: frame.height - 90)
                
                HStack(alignment: .center, spacing: 20) {
                    durationTextView()
                    caloriesTextView()
                }
                .position(x: frame.width/2, y: frame.maxY-50)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.3)]), startPoint: .center, endPoint: .bottom)
            )
            
            logoView()
            .padding(10)
            .hAlign(.topLeading)
        case .two:
            ZStack {
                VStack(alignment: .center) {
                    titleTextView()
                }
                .position(x: frame.width/2, y: frame.height - 90)
                
                durationTextView()
                .position(x: frame.width/2, y: frame.maxY-50)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.3)]), startPoint: .center, endPoint: .bottom)
            )
            
            logoView()
            .padding(10)
            .hAlign(.topLeading)
        case .three:
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    titleTextView()
                    dateTimeTextView()
                }
                .padding(15)
            }
            .vAlign(.top)
            .hAlign(.leading)
            .frame(maxHeight: 200)
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.3)]), startPoint: .center, endPoint: .top)
            )
            
            VStack(alignment: .trailing, spacing: 10) {
                durationTextView(alignment: .trailing)
                caloriesTextView(alignment: .trailing)
            }
            .frame(maxWidth: 200)
            .position(x: frame.maxX-60, y: frame.maxY-100)
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.3)]), startPoint: .center, endPoint: .bottom)
            )
            
            logoView()
            .rotationEffect(.degrees(90))
            .position(x: frame.width-15, y: frame.height/5)
        case .four:
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    titleTextView()
                    dateTimeTextView()
                }
                .padding(15)
            }
            .vAlign(.top)
            .hAlign(.leading)
            .frame(maxHeight: 200)
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.3)]), startPoint: .center, endPoint: .top)
            )
            
            logoView()
            .rotationEffect(.degrees(90))
            .position(x: frame.width-15, y: frame.height/5)
        default:
            logoView()
            .rotationEffect(.degrees(90))
            .position(x: frame.width-15, y: frame.height/5)
        }
    }
    
    @MainActor
    @ViewBuilder
    private func LayoutTypeButtonView(type: LayoutType) -> some View {
        Button(action: {
            layoutType = type
        }, label: {
            let view = imageWithStatisticView(type: type)
                .frame(width: 450, height: 500)
            let renderer = createRenderer(view: view)
            if let image = renderer.cgImage {
                Image(image, scale: 1.0, label: Text(""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
        })
        .background(
            Rectangle()
                .foregroundColor(.black)
        )
        .overlay(
            Rectangle()
                .inset(by: 0.01)
                .stroke(type == layoutType ? .blue : .clear, lineWidth: 3)
        )
    }
    
    @ViewBuilder
    private func logoView() -> some View {
        HStack(spacing: 2) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            Text("JiuTrack")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 5)
        .background(Color("LogoColor"))
    }
    
    @ViewBuilder
    private func titleTextView() -> some View {
        Text("\(activity.type.rawValue.localizedString) \(activity.style.rawValue.localizedString)")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func dateTimeTextView() -> some View {
        Text(activity.startDate.toString("dd MMM yyyy HH:mm"))
            .foregroundColor(.white)
            .fontWeight(.semibold)
    }
    
    
    @ViewBuilder
    private func durationTextView(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil
    ) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            Text(activity.duration.minutesToDuration())
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Duration".localizedString)
                .font(.footnote)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
    }
    
    @ViewBuilder
    private func caloriesTextView(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil
    ) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            Text("\(activity.totalEnergy)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Calories".localizedString)
                .font(.footnote)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
    }
    
    @MainActor
    private func createRenderer(view: some View) -> ImageRenderer<some View> {
        let renderer = ImageRenderer(
            content: view
        )
        renderer.scale = 4.0
        return renderer
    }
    
}

@available(iOS 16.0, *)
#Preview {
    if let session = PersistanceManager.preview.fetchSessions().first {
        ShareSessionView(session: session)
    } else {
        Text("No session")
    }
}
