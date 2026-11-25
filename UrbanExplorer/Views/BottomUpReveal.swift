import SwiftUI

/// Rectángulo que crece desde abajo. `progress` va de 0 (oculto) a 1 (visible).
private struct BottomUpMask: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        // Margen extra para que el desenfoque solo se note en el borde superior.
        let margin: CGFloat = 80
        let travel = (rect.height + margin * 2) * progress
        let bottom = rect.maxY + margin
        return Path(CGRect(x: rect.minX - margin, y: bottom - travel,
                           width: rect.width + margin * 2, height: travel))
    }
}

extension View {
    func revealsFromBottom(_ revealed: Bool) -> some View {
        mask {
            BottomUpMask(progress: revealed ? 1 : 0)
                .fill(.black)
                .blur(radius: 22)
                .ignoresSafeArea()
        }
        .offset(y: revealed ? 0 : 40)
    }
}
