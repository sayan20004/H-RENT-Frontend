//
//  OTPInputView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 01/11/25.
//

import SwiftUI

struct OTPInputView: View {
    @Binding var otp: String
    
    // --- MODIFICATION ---
    // We use 6 digits to match your backend logic
    let digitCount: Int = 6
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            ZStack {
                // Hidden TextField that handles the actual input
                TextField("", text: $otp)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isFocused)
                    .frame(width: 0, height: 0) // Completely hide it
                    .opacity(0)
                    .onChange(of: otp) { newValue in
                        // Limit the input to 6 digits
                        if newValue.count > digitCount {
                            otp = String(newValue.prefix(digitCount))
                        }
                    }
                
                // The visible boxes that display the OTP
                HStack(spacing: 12) {
                    ForEach(0..<digitCount, id: \.self) { index in
                        OTPBox(
                            digit: digit(at: index),
                            isFocused: isFocused && otp.count == index
                        )
                    }
                }
            }
            .contentShape(Rectangle()) // Makes the whole ZStack tappable
            .onTapGesture {
                isFocused = true // Focus the hidden TextField
            }
        }
    }
    
    /// Helper function to get the digit at a specific index
    private func digit(at index: Int) -> String {
        guard index < otp.count else {
            return "" // Empty if no digit yet
        }
        let startIndex = otp.index(otp.startIndex, offsetBy: index)
        let endIndex = otp.index(startIndex, offsetBy: 1)
        return String(otp[startIndex..<endIndex])
    }
}

/// A View for a single OTP digit box
private struct OTPBox: View {
    let digit: String
    let isFocused: Bool
    
    // --- MODIFICATION ---
    // Use the brand green from the "Confirm" button
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)

    var body: some View {
        Text(digit.isEmpty ? "-" : digit) // Show "-" as a placeholder
            .font(.title2)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity) // Make boxes fill the space
            .frame(height: 52)
            // --- MODIFICATION ---
            // Use system background colors for dark/light mode
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    // --- MODIFICATION ---
                    // Show a green border only on the active box
                    .stroke(isFocused ? appGreen : Color.clear, lineWidth: 2)
            )
    }
}
