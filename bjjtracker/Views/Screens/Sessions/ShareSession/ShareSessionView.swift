//
//  ShareSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 15.02.2024.
//

import SwiftUI
import Charts

enum LayoutType {
    case one
    case two
    case three
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
    @Environment(\.colorScheme) var colorScheme
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
                                colorScheme == .dark ? Color("GrayTextColor") : Color("Blue")
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
                                colorScheme == .dark ? .white : Color("Blue")
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
                            LayoutTypeButtonView(type: .one)
                            LayoutTypeButtonView(type: .two)
                            LayoutTypeButtonView(type: .three)
                        }
                        .padding(10)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color("LinearBG1"), Color("LinearBG2")]), startPoint: .top, endPoint: .bottom)
                : LinearGradient(gradient: Gradient(colors: [Color("generalBG"), Color("lightGreen")]), startPoint: .top, endPoint: .bottom)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("close")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(colorScheme == .dark ? .white : Color("Blue"))
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
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(
                                        colorScheme == .dark ? .white : Color("Blue")
                                    )
                            }
                            .simultaneousGesture(TapGesture().onEnded() {
                                print("clicked")
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
        switch type {
        case .one:
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
            .position(x: 80, y: 30)
            
            ZStack {
                VStack(alignment: .center) {
                    Text("\(activity.style.rawValue) Class")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .position(x: geometry.size.width/2, y: geometry.size.height - 110)
                
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .center) {
                        Text(activity.duration.minutesToDuration())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Duration")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    if session.status == .finished {
                        VStack(alignment: .center) {
                            Text("**\(activity.totalEnergy) kcal**")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Calories")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                    }
                }
                .position(x: geometry.size.width/2, y: geometry.size.height - 50)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
            )
        case .two:
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
            .rotationEffect(.degrees(90))
            .position(x: geometry.size.width-20, y: geometry.size.height/5)
            
            VStack(alignment: .leading) {
                Text("\(activity.style.rawValue) Class")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(activity.startDate.formatted())
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .position(x: 100, y: 40)
            
            VStack(alignment: .trailing, spacing: 20) {
                VStack(alignment: .trailing) {
                    Text(activity.duration.minutesToDuration())
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Duration")
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                if session.status == .finished {
                    VStack(alignment: .trailing) {
                        Text("**\(activity.totalEnergy) kcal**")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Calories")
                            .font(.title3)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                }
            }
            .position(x: geometry.size.width-80, y: geometry.size.height-120)
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
            )
        case .three:
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
            .rotationEffect(.degrees(90))
            .position(x: geometry.size.width-20, y: geometry.size.height/5)
            
            VStack(alignment: .leading) {
                Text("\(activity.style.rawValue) Class")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(activity.startDate.formatted())
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .position(x: 100, y: 40)
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
    
}

@available(iOS 16.0, *)
#Preview {
    if let session = PersistanceManager.preview.fetchSessions().first {
        ShareSessionView(session: session)
    } else {
        Text("No session")
    }
}
