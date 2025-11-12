import SwiftUI

struct OTPInputView: View {
    @Binding var otp: String
    
    let digitCount: Int = 6
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            ZStack {
                TextField("", text: $otp)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .onChange(of: otp) { newValue in
                        if newValue.count > digitCount {
                            otp = String(newValue.prefix(digitCount))
                        }
                    }
                
                HStack(spacing: 12) {
                    ForEach(0..<digitCount, id: \.self) { index in
                        OTPBox(
                            digit: digit(at: index),
                            isFocused: isFocused && otp.count == index
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
        }
    }
    
    private func digit(at index: Int) -> String {
        guard index < otp.count else {
            return ""
        }
        let startIndex = otp.index(otp.startIndex, offsetBy: index)
        let endIndex = otp.index(startIndex, offsetBy: 1)
        return String(otp[startIndex..<endIndex])
    }
}

private struct OTPBox: View {
    let digit: String
    let isFocused: Bool
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)

    var body: some View {
        Text(digit.isEmpty ? "-" : digit)
            .font(.title2)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? appGreen : Color.clear, lineWidth: 2)
            )
    }
}
