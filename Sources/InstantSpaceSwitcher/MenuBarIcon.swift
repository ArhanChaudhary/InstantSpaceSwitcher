import SwiftUI
import ISS

struct MenuBarIcon: View {
    let info: ISSSpaceInfo?

    private let iconSize: CGFloat = 18 // Standard template size
    private let cornerRadius: CGFloat = 6

    private var displayText: String {
        guard let info else { return "?" }
        return String(Int(info.currentIndex) + 1)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.primary)
                .frame(width: iconSize, height: iconSize)

            Text(displayText)
                .font(.system(size: iconSize * 0.7, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
                .blendMode(.destinationOut)
                .padding(.horizontal, iconSize * 0.10)
        }
        .compositingGroup()
        .frame(width: iconSize, height: iconSize)
    }
}
