import SwiftUI

/// La fila y el corazón son botones separados para que marcar favorito no abra el detalle.
struct SpotRowView: View {
    let spot: Spot
    let onSelect: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Button(action: onSelect) {
                HStack(alignment: .center, spacing: 14) {
                    Color.clear
                        .frame(width: 86, height: 86)
                        .overlay { SpotImageView(url: spot.mainImageURL) }
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(spot.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)

                        if !spot.tags.isEmpty {
                            Text(spot.tags.joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(.secondaryText)
                                .lineLimit(1)
                        }

                        HStack(spacing: 8) {
                            Label(spot.category.rawValue, systemImage: spot.category.symbol)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tint)

                            SpotRatingView(rating: spot.rating)
                                .font(.caption.weight(.semibold))
                        }
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Abre el detalle")

            FavoriteButton(spot: spot)
        }
        .padding(.vertical, 6)
    }
}

struct SpotRatingView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundStyle(.gold)
                .accessibilityHidden(true)
            Text(rating, format: .number.precision(.fractionLength(1)))
                .monospacedDigit()
        }
        .accessibilityLabel("Valoración")
        .accessibilityValue(Text(rating, format: .number.precision(.fractionLength(1))))
    }
}
