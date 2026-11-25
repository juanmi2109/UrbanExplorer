import SwiftUI

struct FavoriteButton: View {
    let spot: Spot

    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        let isFavorite = favorites.contains(spot)

        Button {
            favorites.toggle(spot)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.accentColor : .secondaryText)
                .symbolEffect(.bounce, value: isFavorite)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isFavorite)
        .accessibilityLabel(isFavorite ? "Quitar de favoritos" : "Añadir a favoritos")
        .accessibilityAddTraits(isFavorite ? .isSelected : [])
    }
}
