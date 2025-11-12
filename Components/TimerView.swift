//
//  TimerView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 01/11/25.
//

import SwiftUI
import Combine

struct TimerView: View {
    @State private var timeRemaining = 30
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // --- MODIFICATION ---
    // Use the brand green
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    // Action to run when "Resend" is tapped
    var onResend: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Progress ring
            ProgressView(value: Double(timeRemaining), total: 30)
                .progressViewStyle(CircularProgressViewStyle(tint: appGreen))
                .frame(width: 20, height: 20)
            
            // Countdown text
            Text("00:\(String(format: "%02d", timeRemaining))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
            
            Button("Resend OTP") {
                timeRemaining = 30 // Reset timer
                onResend() // Call the resend action
            }
            .font(.subheadline)
            .fontWeight(.medium)
            // --- MODIFICATION ---
            // Disable button until timer hits 0
            .disabled(timeRemaining > 0)
            .tint(timeRemaining > 0 ? .secondary : appGreen)
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.upstream.connect().cancel() // Stop the timer
            }
        }
    }
}

