import SwiftUI

struct PeripheralNameView: View {
    var name: String
    var tapAction: () -> Void

    var body: some View {
        Text(name)
            .font(.largeTitle)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .top)
            .onTapGesture {
                tapAction()
            }
    }
}
