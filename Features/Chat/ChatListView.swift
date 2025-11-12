import SwiftUI

struct ChatListView: View {
    @State private var conversations: [Conversation] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedConversation: Conversation?
    
    private let appGreen = Color(red: 104/255, green: 222/255, blue: 122/255)
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            NavigationView {
                VStack {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage = errorMessage {
                        ErrorStateView(message: errorMessage) {
                            Task {
                                await loadConversations()
                            }
                        }
                    } else if conversations.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No Conversations")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Your active chats with owners and tenants will appear here.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(conversations) { conversation in
                            NavigationLink(destination: ChatDetailView(conversation: conversation)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(conversation.rental.property.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Chat with \(conversation.participants.first(where: { $0.id != APIService.shared.userId })?.firstName ?? "User")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .listRowBackground(Color.black)
                        }
                        .listStyle(.plain)
                        .background(Color.black)
                    }
                }
                .background(Color.black)
                .navigationTitle("Chats")
                .task {
                    await loadConversations()
                }
                .refreshable {
                     await loadConversations()
                }
            }
        }
    }
    
    func loadConversations() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.getMyConversations()
            self.conversations = response.conversations
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
