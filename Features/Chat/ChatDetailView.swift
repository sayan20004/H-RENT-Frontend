import SwiftUI
import PhotosUI

struct ChatDetailView: View {
    let conversation: Conversation
    @State private var messages: [Message] = []
    @State private var newMessageText: String = ""
    @State private var errorMessage: String?
    
    @State private var messageToEdit: Message?
    @State private var textForEditing: String = ""
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isUploadingImage: Bool = false
    
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
                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(appGreen)
                }
                .onChange(of: selectedPhotoItem) {
                    Task {
                        if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                            self.selectedPhotoItem = nil
                            await sendPhoto(imageData: data)
                        }
                    }
                }
                
                TextField("Type a message...", text: $newMessageText)
                    .textFieldStyle(.roundedBorder)
                
                if isUploadingImage {
                    ProgressView()
                } else {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(appGreen)
                    }
                    .disabled(newMessageText.isEmpty)
                }
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
            self.textForEditing = message.wrappedValue.text ?? ""
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
                    text: textToSend,
                    imageUrl: nil
                )
                self.messages.append(response.message)
            } catch {
                self.errorMessage = error.localizedDescription
                self.newMessageText = textToSend
            }
        }
    }
    
    func sendPhoto(imageData: Data) async {
        isUploadingImage = true
        errorMessage = nil
        do {
            let uploadResponse = try await APIService.shared.uploadImage(imageData: imageData)
            
            let messageResponse = try await APIService.shared.sendMessage(
                conversationId: conversation.id,
                text: nil,
                imageUrl: uploadResponse.imageUrl
            )
            self.messages.append(messageResponse.message)
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isUploadingImage = false
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
                messageContent
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
                messageContent
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
    
    @ViewBuilder
    private var messageContent: some View {
        VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
            if let imageUrl = message.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 250, maxHeight: 300)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    ProgressView()
                        .frame(width: 250, height: 300)
                }
            }
            
            if let text = message.text, !text.isEmpty {
                Text(text)
            }
            
            if message.isEdited == true {
                Text("(edited)")
                    .font(.caption2)
                    .foregroundColor(isFromMe ? .white.opacity(0.8) : .secondary)
            }
        }
        .padding(12)
        .background(isFromMe ? appGreen : Color(.secondarySystemBackground))
        .foregroundColor(isFromMe ? .white : .primary)
        .cornerRadius(16, corners: isFromMe ? [.topLeft, .bottomLeft, .bottomRight] : [.topRight, .bottomLeft, .bottomRight])
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
