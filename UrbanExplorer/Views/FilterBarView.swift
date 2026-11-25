import SwiftUI

struct FilterBarView: View {
    @Binding var filter: SpotFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                sortMenu

                chip("Todos", symbol: "square.grid.2x2.fill",
                     isSelected: filter.category == nil && !filter.onlyFavorites) {
                    filter.category = nil
                    filter.onlyFavorites = false
                }

                chip("Favoritos", symbol: "heart.fill", isSelected: filter.onlyFavorites) {
                    filter.onlyFavorites.toggle()
                }

                ForEach(SpotCategory.allCases) { category in
                    chip(category.rawValue, symbol: category.symbol,
                         isSelected: filter.category == category) {
                        filter.category = filter.category == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Ordenar por", selection: $filter.sort) {
                ForEach(SpotSort.allCases) { sort in
                    Text(sort.rawValue).tag(sort)
                }
            }
        } label: {
            Label(filter.sort == .featured ? "Ordenar" : filter.sort.rawValue,
                  systemImage: "arrow.up.arrow.down")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .overlay(Capsule().stroke(.tint, lineWidth: 1.5))
        }
    }

    private func chip(_ title: String, symbol: String, isSelected: Bool,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? Color.brandRed : Color.accentColor.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.snappy(duration: 0.2), value: isSelected)
    }
}
