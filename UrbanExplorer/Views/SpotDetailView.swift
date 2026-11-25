import SwiftUI

struct SpotDetailView: View {
    let spot: Spot

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                photo

                VStack(alignment: .leading, spacing: 10) {
                    Label(spot.category.rawValue, systemImage: spot.category.symbol)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.tint)

                    Text(spot.title)
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)

                    HStack(spacing: 14) {
                        SpotRatingView(rating: spot.rating)
                        Label("\(spot.visitCount.formatted()) visitas", systemImage: "person.2")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondaryText)

                    Text(spot.description)

                    if !spot.tags.isEmpty {
                        Text(spot.tags.joined(separator: " · "))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.tint)
                    }
                }

                if let dishes = spot.dishes, !dishes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Qué probar")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(dishes, id: \.self) { dish in
                            Label(dish, systemImage: "fork.knife")
                                .font(.subheadline)
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.surface, in: RoundedRectangle(cornerRadius: 18))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Datos del lugar")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    LabeledContent("Añadido") {
                        Text(spot.createdAt, format: .dateTime.day().month(.wide).year())
                            .foregroundStyle(.secondaryText)
                    }

                    LabeledContent("Coordenadas") {
                        Text(coordinates)
                            .foregroundStyle(.secondaryText)
                            .monospacedDigit()
                            .multilineTextAlignment(.trailing)
                    }
                }
                .font(.subheadline)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.surface, in: RoundedRectangle(cornerRadius: 18))

                if !spot.reviews.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Opiniones de ejemplo")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(spot.reviews) { review in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(review.author)
                                        .fontWeight(.semibold)
                                    Spacer(minLength: 8)
                                    Text("\(review.points) de 5")
                                        .foregroundStyle(.secondaryText)
                                }
                                Text(review.comment)
                                Text(review.date, format: .dateTime.day().month(.wide).year())
                                    .font(.caption)
                                    .foregroundStyle(.secondaryText)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.surface, in: RoundedRectangle(cornerRadius: 18))
                }

                if let directionsURL = spot.directionsURL {
                    Link(destination: directionsURL) {
                        Label("Cómo llegar", systemImage: "location.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.brandRed)
                    .controlSize(.large)
                }

                if let webURL = spot.webURL {
                    Link(destination: webURL) {
                        Label("Visitar la web oficial", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                NavigationLink {
                    AboutDetailView()
                } label: {
                    Label("Acerca de ABocados", systemImage: "info.circle")
                }
                .font(.subheadline)
            }
            .padding(16)
        }
        .background(.appBackground)
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(spot: spot)
            }
        }
    }

    private var photo: some View {
        Color.clear
            .aspectRatio(1.7, contentMode: .fit)
            .overlay { SpotImageView(url: spot.imageURL.first) }
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var coordinates: String {
        let format = FloatingPointFormatStyle<Double>().precision(.fractionLength(5))
        return "\(spot.latitude.formatted(format))° / \(spot.longitude.formatted(format))°"
    }
}
