import SwiftUI

enum AuthState {
    case welcome
    case login
    case register
}

enum Tab {
    case browse
    case myProperties
    case requests
    case myRentals
    case chat
    case profile
}

struct ContentView: View {
    @State private var loggedInUser: User? = nil
    @State private var authState: AuthState = .welcome
    @State private var isLoading: Bool = true
    
    @State private var selectedTab: Tab = .browse
    
    private let appGreen = Color(red: 104/255, green: 222/255, blue: 122/255)

    var body: some View {
        Group { 
            if isLoading {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .task {
                            await checkInitialAuth()
                        }
                }
                .preferredColorScheme(.dark)
            }
            else if let user = loggedInUser {
                ZStack(alignment: .bottom) {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                    
                    currentView(for: user)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    customTabBar(for: user)
                }
                .preferredColorScheme(.dark)
            } else {
                switch authState {
                case .welcome:
                    WelcomeView(authState: $authState)
                case .login:
                    LoginView(loggedInUser: $loggedInUser, authState: $authState)
                case .register:
                    RegisterView(loggedInUser: $loggedInUser, authState: $authState)
                }
            }
        }
        
        .onChange(of: loggedInUser?.id, { oldValue, newValue in
            
            if let user = loggedInUser {
                if user.userType == .owner {
                    selectedTab = .myProperties
                } else {
                    selectedTab = .browse
                }
            }
        })
    }
    
    @ViewBuilder
    func currentView(for user: User) -> some View {
        switch selectedTab {
        case .browse:
            HomeView(loggedInUser: $loggedInUser)
        case .myProperties:
            OwnerDashboardView(loggedInUser: $loggedInUser)
        case .requests:
            IncomingRentalsView()
        case .myRentals:
            MyRentalsView()
        case .chat:
            ChatListView()
        case .profile:
            ProfileSettingsView(loggedInUser: $loggedInUser)
        }
    }
    
    @ViewBuilder
    func customTabBar(for user: User) -> some View {
        HStack(spacing: 0) {
            
            // --- EDIT: This tab only appears for non-owners ---
            if user.userType != .owner {
                TabButton(
                    icon: "magnifyingglass",
                    text: "Browse",
                    isSelected: selectedTab == .browse
                ) { selectedTab = .browse }
            }
            
            if user.userType == .owner {
                TabButton(
                    icon: "list.bullet",
                    text: "My Properties",
                    isSelected: selectedTab == .myProperties
                ) { selectedTab = .myProperties }
                
                TabButton(
                    icon: "bell.fill",
                    text: "Requests",
                    isSelected: selectedTab == .requests
                ) { selectedTab = .requests }
            } else {
                TabButton(
                    icon: "key.fill",
                    text: "My Rentals",
                    isSelected: selectedTab == .myRentals
                ) { selectedTab = .myRentals }
            }
            
            TabButton(
                icon: "message.fill",
                text: "Chat",
                isSelected: selectedTab == .chat
            ) { selectedTab = .chat }
            
            TabButton(
                icon: "person.fill",
                text: "Profile",
                isSelected: selectedTab == .profile
            ) { selectedTab = .profile }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(white: 0.15).opacity(0.8))
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
    
    func checkInitialAuth() async {
        if let token = APIService.shared.authToken {
            do {
                let response = try await APIService.shared.getUserProfile()
                self.loggedInUser = response.user
            } catch {
                APIService.shared.authToken = nil
                self.loggedInUser = nil
            }
        }
        self.isLoading = false
    }
}

struct TabButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    private let appGreen = Color(red: 104/255, green: 222/255, blue: 122/255)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(appGreen.opacity(0.2))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(appGreen)
                    }
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color.gray)
                        .frame(width: 38, height: 38)
                }
                
                Text(text)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? appGreen : Color.gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
