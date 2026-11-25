import SwiftUI

struct AboutDetailView: View {
    private let studentNames = [
        "Guillermo Garcia Andugar",
        "Juan Miguel Hernandez Romero",
        "Alejandro Marti Cadavid",
        "Abel Hernandez Carrasco"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    ExplorerLogo()
                        .frame(width: 78, height: 78)

                    Text("ABocados")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)

                    Text("Tapas y gastronomía de Murcia")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.banner, in: RoundedRectangle(cornerRadius: 22))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Aplicación de la asignatura de iOS de la UCAM. Reúne bares de tapas, restaurantes, mercados y museos de la gastronomía murciana y muestra sus datos desde un catálogo incluido en la app.")

                    Divider()

                    LabeledContent("Alumnos") {
                        VStack(alignment: .trailing, spacing: 4) {
                            ForEach(studentNames, id: \.self) { name in
                                Text(name)
                            }
                        }
                        .foregroundStyle(.secondaryText)
                    }
                    LabeledContent("Entrega") {
                        Text("Parcial 1")
                            .foregroundStyle(.secondaryText)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.surface, in: RoundedRectangle(cornerRadius: 18))
            }
            .padding(16)
        }
        .background(.appBackground)
        .navigationTitle("Acerca de")
        .navigationBarTitleDisplayMode(.inline)
    }
}
