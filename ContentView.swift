import SwiftUI

enum AuthState {
    case welcome
    case login
    case register
}

struct ContentView: View {
    @State private var loggedInUser: User? = nil
    @State private var authState: AuthState = .welcome
    @State private var isLoading: Bool = true
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)

    var body: some View {
        if isLoading {
            ProgressView()
                .task {
                    await checkInitialAuth()
                }
        }
        else if let user = loggedInUser {
            TabView {
                if user.userType == .owner {
                    OwnerDashboardView(loggedInUser: $loggedInUser)
                        .tabItem {
                            Label("My Properties", systemImage: "list.bullet")
                        }
                    
                    IncomingRentalsView()
                        .tabItem {
                            Label("Requests", systemImage: "bell.fill")
                        }
                    
                } else {
                    HomeView(loggedInUser: $loggedInUser)
                        .tabItem {
                            Label("Browse", systemImage: "magnifyingglass")
                        }
                    
                    MyRentalsView()
                        .tabItem {
                            Label("My Rentals", systemImage: "key.fill")
                        }
                }
                
                ProfileSettingsView(loggedInUser: $loggedInUser)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
            .tint(appGreen)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
