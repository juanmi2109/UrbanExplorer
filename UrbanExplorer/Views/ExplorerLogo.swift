import SwiftUI

struct ExplorerLogo: View {
    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.3)
                    .fill(.logoBackground)
                Image(systemName: "fork.knife")
                    .font(.system(size: side * 0.5, weight: .bold))
                    .foregroundStyle(.brandRed)
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview {
    ExplorerLogo()
        .frame(width: 120, height: 120)
}
