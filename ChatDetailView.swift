import SwiftUI

struct ChatDetailView: View {
    let conversation: Conversation
    @State private var messages: [Message] = []
    @State private var newMessageText: String = ""
    @State private var errorMessage: String?
    
    @State private var messageToEdit: Message?
    @State private var textForEditing: String = ""
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach($messages) { $message in
                            MessageBubble(message: $message, onAction: { action in
                                handle(action: action, for: $message)
                            })
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await loadMessages(scrollToBottom: false)
                }
                .onChange(of: messages) {
                    if messages.count > 0 {
                        proxy.scrollTo(messages[messages.count - 1].id, anchor: .bottom)
                    }
                }
            }
            
            if let messageToEdit = messageToEdit {
                EditMessageView(
                    text: $textForEditing,
                    onCancel: {
                        self.messageToEdit = nil
                        self.textForEditing = ""
                    },
                    onSave: {
                        saveEditedMessage()
                    }
                )
            }
            
            Divider()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 12) {
                TextField("Type a message...", text: $newMessageText)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(appGreen)
                }
                .disabled(newMessageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(conversation.rental.property.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadMessages(scrollToBottom: true)
        }
    }
    
    func handle(action: MessageAction, for message: Binding<Message>) {
        switch action {
        case .react(let emoji):
            reactTo(message: message, emoji: emoji)
        case .edit:
            self.messageToEdit = message.wrappedValue
            self.textForEditing = message.wrappedValue.text
        }
    }
    
    func loadMessages(scrollToBottom: Bool) async {
        do {
            let response = try await APIService.shared.getMessages(conversationId: conversation.id)
            if scrollToBottom {
                self.messages = response.messages
            } else {
                withAnimation {
                    self.messages = response.messages
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        let textToSend = newMessageText
        self.newMessageText = ""
        
        Task {
            do {
                let response = try await APIService.shared.sendMessage(
                    conversationId: conversation.id,
                    text: textToSend
                )
                self.messages.append(response.message)
            } catch {
                self.errorMessage = error.localizedDescription
                self.newMessageText = textToSend
            }
        }
    }
    
    func saveEditedMessage() {
        guard let messageToEdit = messageToEdit else { return }
        let newText = textForEditing
        
        self.messageToEdit = nil
        self.textForEditing = ""
        
        Task {
            do {
                let response = try await APIService.shared.editMessage(
                    messageId: messageToEdit.id,
                    text: newText
                )
                if let index = messages.firstIndex(where: { $0.id == response.message.id }) {
                    messages[index] = response.message
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func reactTo(message: Binding<Message>, emoji: String) {
        Task {
            do {
                let response = try await APIService.shared.reactToMessage(
                    messageId: message.id,
                    emoji: emoji
                )
                message.wrappedValue = response.message
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

enum MessageAction {
    case react(emoji: String)
    case edit
}

struct MessageBubble: View {
    @Binding var message: Message
    var onAction: (MessageAction) -> Void
    
    private var isFromMe: Bool { message.sender.id == APIService.shared.userId }
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    private let emojiReactions = ["👍", "❤️", "😂", "😢", "😠"]

    var body: some View {
        HStack {
            if isFromMe {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                    if message.isEdited == true {
                        Text("(edited)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(12)
                .background(appGreen)
                .foregroundColor(.white)
                .cornerRadius(16, corners: [.topLeft, .bottomLeft, .bottomRight])
                .contextMenu {
                    if message.canBeEdited {
                        Button {
                            onAction(.edit)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                    if message.isEdited == true {
                        Text("(edited)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16, corners: [.topRight, .bottomLeft, .bottomRight])
                .contextMenu {
                    ControlGroup {
                        ForEach(emojiReactions, id: \.self) { emoji in
                            Button {
                                onAction(.react(emoji: emoji))
                            } label: {
                                Text(emoji)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .overlay(alignment: isFromMe ? .bottomTrailing : .bottomLeading) {
            HStack(spacing: 2) {
                ForEach(message.reactions) { reaction in
                    Text(reaction.emoji)
                        .font(.caption)
                        .padding(4)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
            }
            .offset(y: 12)
        }
    }
}

struct EditMessageView: View {
    @Binding var text: String
    var onCancel: () -> Void
    var onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading) {
                Text("Edit Message")
                    .font(.caption)
                    .fontWeight(.bold)
                TextField("Editing...", text: $text)
            }
            
            Button(action: onSave) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
