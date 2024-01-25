import SwiftUI

struct ModeCard: View {
    let modeName: String
    var isSelected: Bool
    var selectedColor: Color
    var action: () -> Void
    
    var body: some View {
        Text(modeName)
            .font(.headline)
            .fontWeight(isSelected ? .bold : .regular)
            .foregroundColor(isSelected ? .white : .gray)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(isSelected ? selectedColor                        : Color.black.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? selectedColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? selectedColor.opacity(0.5) : Color.clear, radius: 5, x: 0, y: 0)
            .onTapGesture {
                action()
            }
    }
}
