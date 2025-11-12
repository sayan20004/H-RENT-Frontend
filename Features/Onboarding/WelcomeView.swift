import SwiftUI

private struct OnboardingPageInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

private let onboardingPages: [OnboardingPageInfo] = [
    .init(title: "We will take care", description: "of tickets, transfers and a cool place to stay", imageName: "suitcase.rolling.fill", color: Color(red: 255/255, green: 221/255, blue: 89/255)),
    .init(title: "Relax & enjoy", description: "Sunbathe, swim, eat and drink deliciously", imageName: "sun.max.fill", color: Color(red: 121/255, green: 222/255, blue: 232/255)),
    .init(title: "Flexible payment", description: "credit card and transfer, cryptocurrency", imageName: "creditcard.fill", color: Color(red: 253/255, green: 211/255, blue: 220/255))
]

struct WelcomeView: View {
    @Binding var authState: AuthState
    @State private var selection: Int = 0

    private let pageCount = onboardingPages.count + 1

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    OnboardingPageView(page: onboardingPages[index])
                        .tag(index)
                }
                
                LoginRegisterView(authState: $authState)
                    .tag(onboardingPages.count)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: selection)
            .edgesIgnoringSafeArea(.all)
            
            if selection < onboardingPages.count {
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            withAnimation {
                                selection = onboardingPages.count
                            }
                        }
                        .padding()
                        .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    HStack {
                        
                        PageIndicator(
                            count: pageCount,
                            currentIndex: $selection
                        )
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                selection += 1
                            }
                        } label: {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20, weight: .semibold))
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPageInfo
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.imageName)
                .font(.system(size: 150))
                .foregroundColor(.white)
                .padding(.bottom, 50)
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(page.description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 150)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(page.color)
    }
}

private struct LoginRegisterView: View {
    @Binding var authState: AuthState


    private let backgroundColor = Color(red: 44/255, green: 30/255, blue: 24/255)
    private let buttonColor = Color(red: 219/255, green: 173/255, blue: 147/255)
    private let lightTextColor = Color.white.opacity(0.9)
    // ---

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image("welcome-image-1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .rotationEffect(.degrees(-10))
                    .offset(x: -30, y: 10)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)

                Image("welcome-image-2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .rotationEffect(.degrees(10))
                    .offset(x: 40, y: 70)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            }
            .padding(.top, 100)
            .padding(.bottom, 40)
            
            Spacer()

            VStack(spacing: 12) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(lightTextColor)
                
                Text("Sign In or Register")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(lightTextColor.opacity(0.9))
                
                Text("Create an account in minutes to access exclusive features, track your activity, and stay updated.")
                    .font(.subheadline)
                    .foregroundColor(lightTextColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button {
                    authState = .register
                } label: {
                    Text("Registration")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .foregroundColor(backgroundColor)
                        .cornerRadius(100)
                }
                
                Button {
                    authState = .login
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .foregroundColor(backgroundColor)
                        .cornerRadius(100)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom)
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
    }
}

private struct PageIndicator: View {
    let count: Int
    @Binding var currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.black : Color.black.opacity(0.1))
                    .frame(width: index == currentIndex ? 20 : 8, height: 8)
                    .animation(.easeInOut, value: currentIndex)
            }
        }
    }
}
