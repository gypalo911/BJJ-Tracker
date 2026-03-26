//
//  ProfileView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI
import StoreKit

struct ProfileView: View {
    enum ActionSheetState {
        case none
        case gradingSystem
        case modalSheets
    }

    enum Localisation {
        static let profile = "Profile"
        static let beltWithStripes = "%@ belt %@ stripes"
        static let yetNoPromotions = "Yet no promotions"
        static let newPromotion = "New Promotion"
        static let sessions = "Sessions"
        static let totalTime = "Total time"
        static let viewAllAppleHealthData = "View all Apple Health data"
        static let appleHealthPermissions = "Apple Health integration requires permissions to be granted in **Settings -> Privacy -> Health -> JiuTrack**"
        static let supportTheProject = "Support the project"
    }
    
    enum Settings {
        case language
        case notifications
    }
    
    //    @Environment(\.requestReview) var requestReview
    @Environment(\.openURL) var openURL
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @StateObject var viewModel: ProfileViewViewModel
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut)
    var sessionsList: FetchedResults<Session>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut)
    var promotionModels: FetchedResults<PromotionModel>
    
    @State private var showingGradingActionSheet: Bool = false
    
    @State private var showSheet = false
    
    @State private var showingPromotionsView: Bool = false
    @State private var showingBottomSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var selectedSettingsView: Settings? = nil {
        didSet {
            showingBottomSheet.toggle()
        }
    }
    @State private var isConnectAHPresented: Bool = false
    
    private let isSmallScreen: Bool = UIScreen.main.bounds.size.width < 400
    
    var promotions: [Promotion] {
        promotionModels.map {
            Promotion.from($0)
        }
    }
    
    var lastPromotion: Promotion? {
        let adultBelts = Belt.belts(for: .adult)
        let adult = promotions
            .filter {
                adultBelts.contains($0.belt)
            }
            .sorted(by: {
                $0.belt.rawValue == $1.belt.rawValue ? ($0.stripes < $1.stripes) :
                ($0.belt.rawValue < $1.belt.rawValue)
            }).last
        if adult != nil {
            return adult
        } else {
            let juniorBelts = Belt.belts(for: .junior)
            let junior = promotions
                .filter {
                    juniorBelts.contains($0.belt)
                }
                .sorted(by: {
                    $0.belt.rawValue == $1.belt.rawValue ? ($0.stripes < $1.stripes) :
                    ($0.belt.rawValue < $1.belt.rawValue)
                }).last
            
            return junior
        }
    }
    
    @State private var selectedImage: UIImage?
    
    var profileAvatar: UIImage {
        selectedImage ?? UIImage().loadImageFromDiskWith(fileName: "avatar.png") ?? UIImage(named: "default-avatar")!
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 0) {
                        HStack {
                            Text(Localisation.profile.localizedString)
                                .font(token: DesignSystem.shared.fonts.title, weight: .bold)
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
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.25)) {
                                                    showingPromotionsView = true
                                                }
                                            }
                                        Text(Localisation.beltWithStripes.localized(with: ["\(lastPromotion.belt.title)", "\(Int(lastPromotion.stripes))"]))
                                            .foregroundColor(.gray)
                                            .font(.callout)
                                            .fontWeight(.medium)
                                    }
                                    .hAlign(.center)
                                } else {
                                    VStack {
                                        BeltView(beltColor: Belt.black.color, stripesCount: 2)
                                            .overlay {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(DesignSystem.shared.colors.lightGray)
                                                        .opacity(0.8)
                                                    Text(Localisation.yetNoPromotions.localizedString)
                                                        .foregroundColor(.white)
                                                        .font(token: DesignSystem.shared.fonts.caption, weight: .regular)
                                                }
                                            }
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                settings.selectedSheet = .promotion
                                            }
                                        }, label: {
                                            Text(Localisation.newPromotion.localizedString)
                                                .font(.callout)
                                                .fontWeight(.regular)
                                        }).padding(5)
                                    }
                                }
                                
                                HStack(alignment: .top, spacing: 74) {
                                    VStack(alignment: .center, spacing: 5) {
                                        Text(verbatim: "\(sessionsList.count)")
                                            .font(token: DesignSystem.shared.fonts.body, weight: .semibold)
                                        Text(Localisation.sessions.localizedString)
                                            .font(token: DesignSystem.shared.fonts.footnote, weight: .medium)
                                    }
                                    VStack(alignment: .center, spacing: 5) {
                                        Text(verbatim: totalTime())
                                            .font(token: DesignSystem.shared.fonts.body, weight: .semibold)
                                        Text(Localisation.totalTime.localizedString)
                                            .font(token: DesignSystem.shared.fonts.footnote, weight: .medium)
                                    }
                                }
                            }
                            .offset(x: 0, y: -40)
                        }
                        
                        VStack {
                            if viewModel.techniques.isEmpty {
                                TechniquesCardView(view: {
                                    TechniquesCardEmptyState(persistanceManager: persistanceManager)
                                })
                            } else {
                                TechniquesCardView(view: {
                                    TechniquesCardFullState(
                                        techniques: viewModel.techniques,
                                        persistanceManager: persistanceManager
                                    )
                                })
                            }
                            if !settings.healthKitService.isDataAuthorized {
                                AppleHealthCardView {
                                    isConnectAHPresented = true
                                }
                            } else {
                                CommonCardView(image: {
                                    Image("apple-health")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                }, text: {
                                    Text(Localisation.viewAllAppleHealthData.localizedString)
                                        .font(token: DesignSystem.shared.fonts.footnote, weight: .semibold)
                                        .foregroundColor(.black)
                                }) {
                                    openHealthApp()
                                }
                            }
                            Text(Localisation.appleHealthPermissions.localizedString)
                                .font(token: DesignSystem.shared.fonts.footnote, weight: .regular)
                                .multilineTextAlignment(.center)
                                .foregroundColor(DesignSystem.shared.colors.gray)
                                .padding(.horizontal, 20)
                                .padding(.top, 5)
                        }
                        .padding(.top, 10)
                        
                        VStack(alignment: .center, spacing: 12) {
                            SettigsCell(
                                icon: Image("language"),
                                text: "Language",
                                onTap: {
                                    openSettings()
                                }
                            )
                            .padding(.top, 20)
                            //                            SettigsCell(
                            //                                icon: Image("notification"),
                            //                                text: "Notifications",
                            //                                onTap: {
                            //                                    selectedSettingsView = .notifications
                            //                                }
                            //                            )
                            SettigsCell(
                                icon: Image("issue"),
                                text: "Report an issue",
                                onTap: {
                                    EmailController.shared.sendEmail(
                                        subject: "Found an issue in JiuTrack app".localizedString,
                                        body: "".localizedString,
                                        to: "wthotcode@gmail.com"
                                    )
                                }
                            )
                            SettigsCell(
                                icon: Image("rate"),
                                text: "Rate the app",
                                onTap: {
                                    if let scene = UIApplication.shared.connectedScenes
                                        .first(where: { $0.activationState == .foregroundActive })
                                        as? UIWindowScene {
                                        SKStoreReviewController.requestReview(in: scene)
                                    }
                                    
                                }
                            )
                            SettigsCell(
                                icon: Image("share"),
                                text: "Share the app",
                                onTap: {
                                    showShareSheet = true
                                }
                            )
                            .padding(.bottom, 20)
                            
//                            SupportTheProjectView()
                        }
                        .vAlign(.top)
                        .background(
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .shadow(color: .black.opacity(0.15), radius: 0.5, x: 0, y: 1)
                        )
                        .frame(maxWidth: isSmallScreen ? 330 : 360)
                        .padding([.top, .bottom], 20)
                        .hAlign(.center)
                        
                    }
                    .padding(.bottom, settings.isTabBarHidden ? 50 : 120)
                }
                .background(DesignSystem.shared.colors.generalBackground.ignoresSafeArea())
                .sheet(isPresented: $showSheet) {
                    ProfileImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, fileName: "avatar")
                }
                .sheet(isPresented: $showShareSheet) {
                    ActivityViewController(activityItems: [Locale.current.language.languageCode?.identifier == "uk" ? "https://apps.apple.com/ua/app/jiutrack/id6449996572" : "https://apps.apple.com/ua/app/jiutrack/id6449996572?l=uk"])
                }
                .onAppear {
                    settings.isTabBarHidden = false
                    viewModel.onAppear()
                    NotificationManager.shared.requestAuthorization { _ in }
                }
                .backport.hiddenToolbar(true)
            }
        }
        .blurredPopup(isPresented: $showingPromotionsView) {
            PromotionsView(
                isViewOpen: $showingPromotionsView,
                gradingSystem: lastPromotion?.beltType ?? .adult
            )
        }
        .bottomSheet(isPresented: $showingBottomSheet) {
            if selectedSettingsView == .language {
                LanguageSettingsView()
            } else if selectedSettingsView == .notifications {
                NotificationSettingsView()
            }
        }
        .bottomSheet(isPresented: $isConnectAHPresented, view: {
            ConnectAppleHealthView(onConnect: {
                DefaultHealthKitService().authorizeHealthKitIfNeeded { _ in
                    isConnectAHPresented = false
                }
            })
        })
        .onChange(of: isConnectAHPresented) { value in
            settings.isTabBarHidden = value
        }
        .onChange(of: showingPromotionsView) { value in
            if value {
                settings.isTabBarHidden = true
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    settings.isTabBarHidden = false
                }
            }
        }
        .onChange(of: showingBottomSheet) { value in
            if value {
                settings.isTabBarHidden = true
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    settings.isTabBarHidden = false
                }
            }
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
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
    
    private func openHealthApp() {
        if let url = URL(string: "x-apple-health://") {
            openURL(url)
        }
    }
    
    @ViewBuilder
    func SupportTheProjectView()  -> some View {
        VStack {
            Text(Localisation.supportTheProject.localizedString)
                .font(token: DesignSystem.shared.fonts.caption, weight: .regular)
                .foregroundColor(DesignSystem.shared.colors.gray)
            
            HStack {
                Link(destination: URL(string: AppConstants.Links.patreon.rawValue)!) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 40)
                            .background(DesignSystem.shared.colors.lightLightGray)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.5)
                                    .stroke(.black, lineWidth: 1)
                            )
                        
                        Image("patreon")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(maxHeight: 20)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                
                Link(destination: URL(string: AppConstants.Links.buymeacoffee.rawValue)!) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 40)
                            .background(DesignSystem.shared.colors.yellow)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.5)
                                    .stroke(.black, lineWidth: 1)
                            )
                        
                        Image("buymeacoffee")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(maxHeight: 20)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .padding(.bottom, 20)
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
            Text(text.localizedString)
                .font(token: DesignSystem.shared.fonts.footnote, weight: .semibold)
            Spacer()
            if let valueText = valueText {
                Text(valueText.localizedString)
                    .font(token: DesignSystem.shared.fonts.footnote, weight: .regular)
                    .foregroundColor(.gray)
            }
            Image.init(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(height: 15)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            viewModel: .init(
                persistanceManager: PersistanceManager.preview
            )
        )
        .environmentObject(AppSettings())
        .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}



struct ActivityViewController: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems,
                                                  applicationActivities: nil)
        
        controller.excludedActivityTypes = excludedActivityTypes
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
