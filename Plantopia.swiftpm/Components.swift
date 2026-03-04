import SwiftUI

struct PremiumHeader: View {
    var title: String
    var rightIcon: String? = nil
    var rightAction: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            //back btn
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.medium))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            // Right Side: Optional Custom Button
            if let icon = rightIcon, let action = rightAction {
                Button {
                    action()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        Image(systemName: icon)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.primary)
                    }
                }
            } else {
                
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

