//
//  ProfileView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI

struct ProfileView: View {
    enum ActionSheetState {
        case none
        case gradingSystem
        case modalSheets
    }
    
    @EnvironmentObject var settings: AppSettings
    
    @ObservedObject var viewModel: ProfileViewViewModel
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut)
    var sessionsList: FetchedResults<Session>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut)
    var promotionModels: FetchedResults<PromotionModel>
    
    @State private var showingGradingActionSheet: Bool = false
    @State private var gradingSystem: GradingSystem = .adult
    
    @State private var showSheet = false
    
    private let isSmallScreen: Bool = UIScreen.main.bounds.size.width < 400
    
    var promotions: [Promotion] {
        promotionModels.map {
            Promotion.from($0)
        }
    }
    
    var lastPromotion: Promotion? {
        let belts = Belt.belts(for: gradingSystem)
        return promotions
            .filter {
                belts.contains($0.belt)
            }
            .sorted(by: {
                $0.belt.rawValue == $1.belt.rawValue ? ($0.stripes < $1.stripes) :
                ($0.belt.rawValue < $1.belt.rawValue)
            }).last
    }
    
    @State private var selectedImage: UIImage?
    
    var profileAvatar: UIImage {
        selectedImage ?? UIImage().loadImageFromDiskWith(fileName: "avatar.png") ?? UIImage(named: "default-avatar")!
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Text("Profile")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .hAlign(.leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 60)
                
                ZStack {
                    Rectangle()
                      .foregroundColor(.white)
                      .frame(height: 230)
                      .frame(maxWidth: isSmallScreen ? 330 : 360)
                      .cornerRadius(20)
                      .padding(.horizontal, 20)
                      .shadow(color: .black.opacity(0.15), radius: 0.5, x: 0, y: 1)
                    
                    VStack(spacing: 20) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 100, height: 100)
                            .background(
                                Image(uiImage: profileAvatar)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            )
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.15), radius: 0.5, x: 0, y: 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .inset(by: 3)
                                    .stroke(.white, lineWidth: 6)
                            )
                            .onTapGesture {
                                showSheet = true
                            }
                        
                        if let lastPromotion = lastPromotion {
                            VStack(spacing: 5) {
                                BeltView(beltColor: lastPromotion.belt.color, stripesCount: lastPromotion.stripes)
                                Text("%@ belt %@ stripes".localized(with: ["\(lastPromotion.belt.title)", "\(Int(lastPromotion.stripes))"]))
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                            }
                            .hAlign(.center)
                        }
                        
                        HStack(alignment: .top, spacing: 74) {
                            VStack(alignment: .center, spacing: 5) {
                                Text("\(sessionsList.count)")
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                Text("Sessions".localizedString)
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                            }
                            VStack(alignment: .center, spacing: 5) {
                                Text("\(totalTime())")
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                Text("Total time".localizedString)
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                            }
                        }
                    }
                    .offset(x: 0, y: -40)
                }
                
                VStack(alignment: .center, spacing: 12) {
                    SettigsCell(
                        icon: Image("language"),
                        text: "Language",
                        valueText: "English",
                        onTap: {
                            
                        }
                    )
                    .padding(.top, 20)
                    SettigsCell(
                        icon: Image("notification"),
                        text: "Notifications",
                        onTap: {}
                    )
                    SettigsCell(
                        icon: Image("issue"),
                        text: "Report an issue",
                        onTap: {}
                    )
                    SettigsCell(
                        icon: Image("rate"),
                        text: "Rate the app",
                        onTap: {}
                    )
                    SettigsCell(
                        icon: Image("share"),
                        text: "Share the app link",
                        onTap: {}
                    )
                    .padding(.bottom, 20)
                }
                .vAlign(.top)
                .background(
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.15), radius: 0.5, x: 0, y: 1)
                )
                .frame(maxWidth: isSmallScreen ? 330 : 360)
                .padding(20)
                .hAlign(.center)
                
            }
            .padding(.bottom, settings.isTabBarHidden ? 50 : 120)
            
            
            
            //                HStack(spacing: 10) {
            //                    StatsView(text: "Sessions".localizedString, value: "\(sessionsList.count)")
            //                    StatsView(text: "Total time".localizedString, value: totalTime())
            //                }.padding(.horizontal, 20)
            //
            //                ScrollView(showsIndicators: false) {
            //                    VStack(spacing: 20) {
            //                        HStack {
            //                            if let lastPromotion = lastPromotion {
            //                                VStack(spacing: 10) {
            //                                    BeltView(beltColor: lastPromotion.belt.color, stripesCount: lastPromotion.stripes)
            //                                    Text("%@ belt %@ stripes".localized(with: ["\(lastPromotion.belt.title)", "\(Int(lastPromotion.stripes))"]))
            //                                        .foregroundColor(.gray)
            //                                        .font(.system(size: 16))
            //                                        .fontWeight(.medium)
            //                                }
            //                                .hAlign(.bottomLeading)
            //                            }
            //                            VStack {
            //                                Button(action: {
            //                                    showingGradingActionSheet = true
            //                                }, label: {
            //                                    HStack(spacing: 10) {
            //                                        Text(gradingSystem.rawValue.localizedString.capitalized)
            //                                            .font(.system(size: 14))
            //                                            .foregroundColor(Color.black)
            //                                        Image(systemName: "chevron.down")
            //                                            .scaledToFit()
            //                                            .frame(width: 15)
            //                                            .foregroundColor(Color.black)
            //                                    }
            //                                    .padding(.vertical, 5)
            //                                    .padding(.horizontal, 15)
            //                                    .background(
            //                                        RoundedRectangle(cornerRadius: 5)
            //                                            .stroke(lineWidth: 1)
            //                                            .fill(Color("LightGray"))
            //                                    )
            //                                })
            //                                .hAlign(.topTrailing)
            //                                Spacer()
            //                            }
            //                        }
            //                    }
            //                    .padding([.leading, .trailing, .top], 20)
            //                    .padding(.bottom, settings.isTabBarHidden ? 50 : 120)
            //                }
        }
        .background(Color("generalBG").ignoresSafeArea())
        .actionSheet(isPresented: $showingGradingActionSheet) {
            let newSystem: GradingSystem = gradingSystem == .adult ? .junior : .adult
            return ActionSheet(title: Text("Select Grading System"), buttons: [
                .default(Text(newSystem.rawValue.localizedString.capitalized), action: {
                    gradingSystem = gradingSystem == .adult ? .junior : .adult
                }),
                .cancel()
            ])
        }
        .sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        .onAppear {
            viewModel.onProfileViewAppeared()
        }
    }
    
    
    func totalTime() -> String {
        return sessionsList.map { Int($0.duration) }.reduce(0, +).minutesToDuration()
    }
    
    func isLocked(belt: Belt, lastPromotion: Promotion?) -> Bool {
        guard let lastPromotion = lastPromotion else {
            return true
        }
        return lastPromotion.belt.rawValue < belt.rawValue
    }
}

extension ProfileView {
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init())
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}

struct SettigsCell: View {
    
    let icon: Image
    let text: String
    let valueText: String?
    
    var onTap: (() -> Void)?
    
    init(icon: Image, text: String, valueText: String? = nil, onTap: (() -> Void)? = nil) {
        self.icon = icon
        self.text = text
        self.valueText = valueText
        self.onTap = onTap
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.96, green: 0.97, blue: 1))
                    .cornerRadius(10)
                icon
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)
            }
            Text("\(text)".localizedString)
                .font(.system(size: 14))
                .fontWeight(.medium)
            Spacer()
            if let valueText = valueText {
                Text("\(valueText)".localizedString)
                    .font(.system(size: 14))
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
            }
            Image.init(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(height: 15)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .onTapGesture {
            onTap?()
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                saveImage(image)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func saveImage(_ image: UIImage) {
            do {
                let furl = try FileManager.default
                    .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("avatar")
                    .appendingPathExtension("png")
                try image.pngData()?.write(to: furl)
            } catch {
                print("could not create imageFile")
            }
        }
    }
}
