import SwiftUI
import Combine

struct TimerView: View {
    @State private var timeRemaining = 30
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    var onResend: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ProgressView(value: Double(timeRemaining), total: 30)
                .progressViewStyle(CircularProgressViewStyle(tint: appGreen))
                .frame(width: 20, height: 20)
            
            Text("00:\(String(format: "%02d", timeRemaining))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
            
            Button("Resend OTP") {
                timeRemaining = 30
                onResend()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .disabled(timeRemaining > 0)
            .tint(timeRemaining > 0 ? .secondary : appGreen)
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.upstream.connect().cancel()
            }
        }
    }
}

