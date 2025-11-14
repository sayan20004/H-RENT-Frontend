import SwiftUI

public struct ErrorStateView: View {
    private let message: String
    private let retryAction: () -> Void
    
    private let appGreen = Color(red: 104/255, green: 222/255, blue: 122/255)

    public init(message: String, retryAction: @escaping () -> Void) {
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Something Went Wrong")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Could not load content. Please check your connection and try again.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(appGreen)
                    .foregroundColor(.black)
                    .cornerRadius(100)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0))
    }
}

struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorStateView(message: "Unable to load data. Please try again.") {}
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
