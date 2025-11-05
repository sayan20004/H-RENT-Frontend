import SwiftUI

struct ChatListView: View {
    @State private var conversations: [Conversation] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedConversation: Conversation?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if conversations.isEmpty {
                    Text("No conversations started.")
                        .foregroundColor(.secondary)
                } else {
                    List(conversations) { conversation in
                        NavigationLink(destination: ChatDetailView(conversation: conversation)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(conversation.rental.property.title)
                                    .font(.headline)
                                Text("Chat with \(conversation.participants.first(where: { $0.id != APIService.shared.userId })?.firstName ?? "User")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chats")
            .task {
                await loadConversations()
            }
            .refreshable {
                 await loadConversations()
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
