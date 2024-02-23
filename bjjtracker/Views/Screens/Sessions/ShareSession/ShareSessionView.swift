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
//    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @State var layoutType: LayoutType = .one
    @State var selectedImage: UIImage?
    @State var showSheet: Bool = false
    
    @State var selectImageState: Bool = true
    
    let session: Session
    
    var activity: Activity {
        Activity.from(session: session)!
    }
    
    var body: some View {
        let trophyAndDate = createAwardView(type: layoutType)
            .frame(width: 450, height: 500)
        
        NavigationView {
            VStack {
                if selectImageState {
                    VStack {
                        Spacer()
                        Text("Select image to share with training stats")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(
                                Color("GrayTextColor")
//                                colorScheme == .dark ? Color("GrayTextColor") : Color("Blue")
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
                                //colorScheme == .dark ? .white : Color("Blue")
                            )
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 220)
                        Spacer()
                    }
                } else {
                    let renderer = ImageRenderer(
                        content: trophyAndDate
                    )
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
//                                colorScheme == .dark ? .white : Color("Blue")
                            )
                    }
                }
                if !selectImageState {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        let renderer = ImageRenderer(
                            content: trophyAndDate
                        )
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
//                                        colorScheme == .dark ? .white : Color("Blue")
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
                    selectImageState = false
                }
            )
            .ignoresSafeArea()
        }
    }
    
    private func createAwardView(type: LayoutType) -> some View {
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
                    Text("\(activity.style.rawValue.localizedString) \(activity.type.rawValue.localizedString)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .position(x: frame.width/2, y: frame.height - 110)
                
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .center) {
                        Text(activity.duration.minutesToDuration())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Duration".localizedString)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    VStack(alignment: .center) {
                        Text("\(activity.totalEnergy)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Calories".localizedString)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
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
                    Text("\(activity.style.rawValue.localizedString) \(activity.type.rawValue.localizedString)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .position(x: frame.width/2, y: frame.height - 110)
                
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .center) {
                        Text(activity.duration.minutesToDuration())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Duration".localizedString)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                }
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
                    Text("\(activity.style.rawValue.localizedString) \(activity.type.rawValue.localizedString)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(activity.startDate.formatted())
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
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
                VStack(alignment: .trailing) {
                    Text(activity.duration.minutesToDuration())
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Duration".localizedString)
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                VStack(alignment: .trailing) {
                    Text("\(activity.totalEnergy)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Calories".localizedString)
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: 200)
            .position(x: frame.maxX-80, y: frame.maxY-120)
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.3)]), startPoint: .center, endPoint: .bottom)
            )
            
            logoView()
            .rotationEffect(.degrees(90))
            .position(x: frame.width-20, y: frame.height/5)
        case .four:
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(activity.style.rawValue.localizedString) \(activity.type.rawValue.localizedString)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(activity.startDate.formatted())
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
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
            .position(x: frame.width-20, y: frame.height/5)
        default:
            logoView()
            .rotationEffect(.degrees(90))
            .position(x: frame.width-20, y: frame.height/5)
        }
    }
    
    @MainActor
    @ViewBuilder
    func LayoutTypeButtonView(type: LayoutType) -> some View {
        Button(action: {
            layoutType = type
        }, label: {
            let view = createAwardView(type: type)
                .frame(width: 450, height: 500)
            let renderer = ImageRenderer(content: view)
            if let image = renderer.cgImage {
                Image(image, scale: 1.0, label: Text(""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
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
    func logoView() -> some View {
        HStack {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            Text("JiuTrack")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 5)
        .background(Color("LogoColor"))
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
