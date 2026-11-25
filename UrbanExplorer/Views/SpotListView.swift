import SwiftUI

struct SpotListView: View {
    let spots: [Spot]

    @Environment(FavoritesStore.self) private var favorites
    @State private var filter = SpotFilter()
    @State private var path: [Spot] = []
    @State private var showsAbout = false

    private var visibleSpots: [Spot] {
        filter.apply(to: spots, favorites: favorites.ids)
    }

    // Solo se agrupa por categoría con el orden por defecto y sin categoría elegida.
    private var groupsByCategory: Bool {
        filter.category == nil && filter.sort == .featured
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                masthead
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 14, trailing: 20))
                    .clearListRow()

                FilterBarView(filter: $filter)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .clearListRow()

                content
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(.appBackground)
            .searchable(text: $filter.searchText, prompt: "Buscar un sitio o un plato")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Spot.self) { spot in
                SpotDetailView(spot: spot)
            }
            .navigationDestination(isPresented: $showsAbout) {
                AboutDetailView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Acerca de", systemImage: "info.circle") {
                        showsAbout = true
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let results = visibleSpots

        if spots.isEmpty {
            emptyState("No hay lugares disponibles", symbol: "fork.knife",
                       detail: "No se pudieron cargar los datos de la guía.")
        } else if results.isEmpty {
            emptyState("Nada por aquí", symbol: "magnifyingglass",
                       detail: filter.onlyFavorites && favorites.ids.isEmpty
                       ? "Toca el corazón de un sitio para guardarlo en tus favoritos."
                       : "Prueba con otro filtro o con un plato, como «torpedo» o «pastel de carne».")
        } else if groupsByCategory {
            ForEach(SpotCategory.allCases) { category in
                let group = results.filter { $0.category == category }
                if !group.isEmpty {
                    Section {
                        rows(group)
                    } header: {
                        SectionTitle(title: category.rawValue, symbol: category.symbol, count: group.count)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
        } else {
            Section {
                rows(results)
            } header: {
                SectionTitle(title: filter.category?.rawValue ?? filter.sort.rawValue,
                             symbol: filter.category?.symbol ?? "arrow.up.arrow.down",
                             count: results.count)
            }
            .listSectionSeparator(.hidden)
        }
    }

    private func rows(_ group: [Spot]) -> some View {
        ForEach(group) { spot in
            SpotRowView(spot: spot) { path.append(spot) }
                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 12))
                .clearListRow()
        }
    }

    private func emptyState(_ title: LocalizedStringKey, symbol: String, detail: LocalizedStringKey) -> some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(detail))
            .clearListRow()
    }

    private var masthead: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("ABOCADOS · GUÍA GASTRONÓMICA")
                    .font(.caption2.weight(.heavy))
                    .tracking(2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(.tint)
                Spacer()
                Button {
                    showsAbout = true
                } label: {
                    ExplorerLogo()
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Acerca de ABocados")
            }

            Text("Murcia,")
                .font(.system(.largeTitle, design: .serif, weight: .black))
            Text("a bocados.")
                .font(.system(.largeTitle, design: .serif, weight: .regular).italic())
                .foregroundStyle(.tint)

            DottedLine()
                .stroke(Color.secondaryText.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 6]))
                .frame(height: 2)
                .padding(.vertical, 4)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondaryText)
        }
    }

    private var subtitle: LocalizedStringKey {
        spots.isEmpty
            ? "Tapas, mercados y mesas con historia."
            : "\(spots.count) sitios para picar, comprar y aprender."
    }
}

private struct SectionTitle: View {
    let title: String
    let symbol: String
    let count: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
            Text(title.uppercased())
                .tracking(3)
            Text("\(count)")
                .foregroundStyle(.secondaryText)
            DottedLine()
                .stroke(Color.secondaryText.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 6]))
                .frame(height: 2)
        }
        .font(.footnote.weight(.heavy))
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground)
        .listRowInsets(EdgeInsets())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

private extension View {
    func clearListRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}
