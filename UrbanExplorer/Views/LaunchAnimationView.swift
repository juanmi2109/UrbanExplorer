import SwiftUI

/// Intro: se monta un pincho y cae un palillo con una aceituna. Mientras tanto se
/// descargan las fotos. Tocando la pantalla se salta.
struct LaunchAnimationView: View {
    let preload: @MainActor () async -> Void
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var progress = PinchoProgress()
    @State private var didFinish = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.appBackground

                let glowSize = min(proxy.size.width, proxy.size.height) * 0.98
                Circle()
                    .fill(
                        RadialGradient(
                            stops: [
                                .init(color: PinchoColors.glow.opacity(isDark ? 0.62 : 0.22), location: 0),
                                .init(color: PinchoColors.glow.opacity(isDark ? 0.32 : 0.1), location: 0.5),
                                .init(color: PinchoColors.glow.opacity(isDark ? 0.1 : 0.03), location: 0.8),
                                .init(color: .clear, location: 1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: glowSize / 2
                        )
                    )
                    .frame(width: glowSize, height: glowSize)
                    .opacity(progress.glow ? 1 : 0)
                    .scaleEffect(progress.glow ? 1 : 0.6)

                PinchoArt(progress: progress, dropDistance: proxy.size.height * 0.6, isDark: isDark)
            }
            .ignoresSafeArea()
        }
        .contentShape(Rectangle())
        .onTapGesture { finish() }
        .sensoryFeedback(.impact(weight: .medium), trigger: progress.squashed) { _, isSquashed in isSquashed }
        .accessibilityHidden(true)
        .task { await play() }
    }

    private var isDark: Bool { colorScheme == .dark }

    /// Espera a las descargas como mucho 8 segundos.
    private func waitForImages(_ loading: Task<Void, Never>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await loading.value }
            group.addTask { try? await Task.sleep(for: .seconds(8)) }
            await group.next()
            group.cancelAll()
        }
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }

    private func play() async {
        let loading = Task { await preload() }

        // Con «Reducir movimiento» se muestra el pincho ya montado.
        if reduceMotion {
            progress = PinchoProgress(glow: true, plate: true, bread: true, cheese: true,
                                      tomato: true, pickStuck: true, tilt: 16.4)
            try? await Task.sleep(for: .seconds(1.5))
            await waitForImages(loading)
            finish()
            return
        }

        // Plato
        withAnimation(.easeOut(duration: 0.7)) { progress.glow = true }
        try? await Task.sleep(for: .seconds(0.15))
        withAnimation(.spring(duration: 0.55, bounce: 0.35)) { progress.plate = true }

        // Ingredientes
        try? await Task.sleep(for: .seconds(0.4))
        withAnimation(.spring(duration: 0.45, bounce: 0.45)) { progress.bread = true }
        try? await Task.sleep(for: .seconds(0.25))
        withAnimation(.spring(duration: 0.4, bounce: 0.5)) { progress.cheese = true }
        try? await Task.sleep(for: .seconds(0.2))
        withAnimation(.spring(duration: 0.4, bounce: 0.55)) { progress.tomato = true }

        // Cae el palillo
        try? await Task.sleep(for: .seconds(0.5))
        withAnimation(.timingCurve(0.6, 0, 0.85, 0.45, duration: 0.6)) {
            progress.pickStuck = true
            progress.tilt = 16.4
        }
        try? await Task.sleep(for: .seconds(0.6))

        // Impacto
        progress.wobble = 7
        progress.burstStarted = true
        withAnimation(.easeOut(duration: 0.08)) { progress.squashed = true }
        withAnimation(.easeOut(duration: 0.7)) { progress.burst = true }
        try? await Task.sleep(for: .seconds(0.08))
        withAnimation(.spring(duration: 0.5, bounce: 0.6)) { progress.squashed = false }
        withAnimation(.spring(duration: 0.9, bounce: 0.75)) { progress.wobble = 0 }

        try? await Task.sleep(for: .seconds(1.0))
        await waitForImages(loading)
        finish()
    }
}

private struct PinchoProgress: Equatable {
    var glow = false
    var plate = false
    var bread = false
    var cheese = false
    var tomato = false
    var pickStuck = false
    /// Grados de inclinación del palillo.
    var tilt: Double = 32
    var wobble: Double = 0
    var squashed = false
    var burstStarted = false
    var burst = false
}

/// Dibujo del pincho. Las medidas son las del icono de la app.
private struct PinchoArt: View {
    let progress: PinchoProgress
    let dropDistance: CGFloat
    let isDark: Bool

    private static let canvas: CGFloat = 300
    private static let squashAnchor = UnitPoint(x: 0.5, y: 0.66)
    private static let tipAnchor = UnitPoint(x: 0.452, y: 0.66)
    private static let sparkCount = 10

    private var pickOffset: CGFloat { progress.pickStuck ? 0 : -dropDistance }

    var body: some View {
        ZStack {
            plate
            layer { bread }.scaleEffect(squashScale, anchor: Self.squashAnchor)
            layer { cheese }.scaleEffect(squashScale, anchor: Self.squashAnchor)
            layer { stick }
                .rotationEffect(.degrees(progress.wobble), anchor: Self.tipAnchor)
                .offset(y: pickOffset)
            layer { tomato }.scaleEffect(squashScale, anchor: Self.squashAnchor)
            layer { olive }
                .rotationEffect(.degrees(progress.wobble), anchor: Self.tipAnchor)
                .offset(y: pickOffset)
            sparks
        }
        .frame(width: Self.canvas, height: Self.canvas)
    }

    private var squashScale: CGSize {
        progress.squashed ? CGSize(width: 1.05, height: 0.9) : CGSize(width: 1, height: 1)
    }

    // Todas las capas comparten el mismo lienzo para que tengan el mismo centro.
    private func layer<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ZStack { content() }.frame(width: Self.canvas, height: Self.canvas)
    }

    private var plate: some View {
        ZStack {
            Circle().fill(isDark ? PinchoColors.plateDark : PinchoColors.plate)
            Circle().stroke(PinchoColors.plateRim, lineWidth: 3).padding(28)
        }
        .frame(width: 260, height: 260)
        .shadow(color: .black.opacity(isDark ? 0.5 : 0.28), radius: 20, y: 12)
        .scaleEffect(progress.plate ? 1 : 0.3)
        .rotationEffect(.degrees(progress.plate ? 0 : -40))
        .opacity(progress.plate ? 1 : 0)
    }

    private var bread: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(PinchoColors.crust)
                .frame(width: 157, height: 51)
            RoundedRectangle(cornerRadius: 18)
                .fill(PinchoColors.bread)
                .frame(width: 143, height: 39)
                .offset(y: -3)
        }
        .offset(y: 23 + (progress.bread ? 0 : -90))
        .scaleEffect(progress.bread ? 1 : 0.5)
        .opacity(progress.bread ? 1 : 0)
    }

    private var cheese: some View {
        RoundedRectangle(cornerRadius: 9)
            .fill(PinchoColors.cheese)
            .frame(width: 65, height: 38)
            .offset(x: -26, y: -1 + (progress.cheese ? 0 : -80))
            .scaleEffect(progress.cheese ? 1 : 0.4)
            .opacity(progress.cheese ? 1 : 0)
    }

    private var tomato: some View {
        Circle()
            .fill(PinchoColors.tomato)
            .frame(width: 66, height: 66)
            .overlay(alignment: .topLeading) {
                Circle().fill(.white.opacity(0.35)).frame(width: 16, height: 16).offset(x: 14, y: 12)
            }
            .offset(x: 27, y: -10 + (progress.tomato ? 0 : -80))
            .scaleEffect(progress.tomato ? 1 : 0.3)
            .opacity(progress.tomato ? 1 : 0)
    }

    // Se dibuja detrás del tomate para que parezca que lo atraviesa.
    private var stick: some View {
        Capsule()
            .fill(PinchoColors.stick)
            .frame(width: 6, height: 230)
            .rotationEffect(.degrees(progress.tilt))
            .offset(x: 18, y: -62)
    }

    private var olive: some View {
        Circle()
            .fill(PinchoColors.olive)
            .frame(width: 56, height: 56)
            .overlay {
                Circle().fill(PinchoColors.pepper).frame(width: 20, height: 20)
                    .offset(x: 3, y: 2)
            }
            .overlay(alignment: .topLeading) {
                Circle().fill(.white.opacity(0.28)).frame(width: 12, height: 12).offset(x: 9, y: 8)
            }
            .offset(x: 38, y: -112)
    }

    private var sparks: some View {
        ForEach(0..<Self.sparkCount, id: \.self) { index in
            let angle = Double(index) / Double(Self.sparkCount) * 2 * .pi
            let distance: CGFloat = progress.burst ? 95 : 6
            Circle()
                .fill(index.isMultiple(of: 2) ? PinchoColors.sparkGold : (isDark ? .white : PinchoColors.sparkRed))
                .frame(width: index.isMultiple(of: 2) ? 8 : 5, height: index.isMultiple(of: 2) ? 8 : 5)
                .offset(x: -14 + cos(angle) * distance, y: 48 + sin(angle) * distance * 0.7)
                .opacity(progress.burstStarted && !progress.burst ? 1 : 0)
        }
    }
}

/// Colores del dibujo. Son fijos porque forman parte de la ilustración, no del tema.
private enum PinchoColors {
    static let glow = Color(red: 0.85, green: 0.25, blue: 0.18)
    static let plate = Color(red: 1.0, green: 0.995, blue: 0.97)
    static let plateDark = Color(red: 0.98, green: 0.94, blue: 0.86)
    static let plateRim = Color(red: 0.89, green: 0.80, blue: 0.66)
    static let crust = Color(red: 0.87, green: 0.64, blue: 0.32)
    static let bread = Color(red: 0.94, green: 0.77, blue: 0.44)
    static let cheese = Color(red: 1.0, green: 0.85, blue: 0.38)
    static let tomato = Color(red: 0.87, green: 0.20, blue: 0.16)
    static let stick = Color(red: 0.69, green: 0.47, blue: 0.12)
    static let olive = Color(red: 0.34, green: 0.44, blue: 0.15)
    static let pepper = Color(red: 0.84, green: 0.23, blue: 0.17)
    static let sparkGold = Color(red: 1.0, green: 0.82, blue: 0.35)
    static let sparkRed = Color(red: 0.78, green: 0.2, blue: 0.16)
}

#Preview("Montadito terminado") {
    ZStack {
        Color.appBackground
        PinchoArt(
            progress: PinchoProgress(glow: true, plate: true, bread: true, cheese: true,
                                     tomato: true, pickStuck: true, tilt: 16.4),
            dropDistance: 500,
            isDark: true
        )
    }
    .ignoresSafeArea()
}

#Preview("Palillo cayendo") {
    ZStack {
        Color.appBackground
        PinchoArt(
            progress: PinchoProgress(glow: true, plate: true, bread: true, cheese: true,
                                     tomato: true, pickStuck: false, tilt: 26),
            dropDistance: 160,
            isDark: true
        )
    }
    .ignoresSafeArea()
}
