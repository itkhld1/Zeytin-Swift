import SwiftUI

struct HarvestRoadmapView: View {
    @EnvironmentObject var scanResultManager: ScanResultManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var ripeness: CGFloat = 0.0
    @State private var showingPestReportSheet = false

    private var latestResult: ScanResult? {
        scanResultManager.results.last
    }

    private var pestAlerts: [ScanResult] {
        scanResultManager.results.filter { $0.status == "Pest" || $0.status == "Disease" }
    }

    private func ripenessValue(for status: String?) -> CGFloat {
        switch status {
        case "Green": return 0.25
        case "Veraison": return 0.60
        case "Black": return 0.95
        default: return 0.0
        }
    }

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {

                    // MARK: Ripeness Card
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 18)
                                .opacity(0.15)
                                .foregroundColor(Color("Background"))

                            Circle()
                                .trim(from: 0, to: ripeness)
                                .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                                .foregroundColor(Color("Background"))
                                .rotationEffect(.degrees(-90))

                            VStack(spacing: 6) {
                                Text("\(Int(ripeness * 100))%")
                                    .font(.system(size: horizontalSizeClass == .regular ? 50 : 34, weight: .bold))
                                    .foregroundColor(Color("Background"))

                                Text(latestResult?.status ?? "No Scans Yet")
                                    .font(horizontalSizeClass == .regular ? .title2 : .subheadline)
                                    .foregroundColor(Color("Background"))
                            }
                        }
                        .frame(width: horizontalSizeClass == .regular ? 250 : 170, height: horizontalSizeClass == .regular ? 250 : 170)

                        Text("Harvest Readiness")
                            .font(horizontalSizeClass == .regular ? .title : .headline)
                            .foregroundColor(Color("Background"))
                    }
                    .cardStyle()

                    // MARK: Quality Cards
                    VStack(spacing: 15) {

                        GradientInfoCard(
                            title: "Peak Quality",
                            description: "Optimal 'Veraison' stage for liquid gold. High polyphenol count ensures premium, peppery Aegean oil.",
                            icon: "drop.circle.fill"
                        )
                        .opacity(latestResult?.status == "Veraison" || latestResult?.status == "Black" ? 1 : 0.45)

                        GradientInfoCard(
                            title: "For Brining",
                            description: "Perfect for crunchy breakfast olives, homemade pizza toppings, and traditional Aegean curing.",
                            icon: "fork.knife.circle.fill"
                        )
                        .opacity(latestResult?.status == "Green" ? 1 : 0.45)
                    }

                    // MARK: Varieties
                    SectionHeader(title: "Olive Varieties & Uses", color: Color("ButtonColor"))

                    VStack(spacing: 15) {
                        GradientInfoCardforVarieties(title: "Gemlik", location: "📍 Marmara Region (Bursa)", description: "Turkey’s most famous table olive. Small pit, high flesh ratio, rich aroma, excellent for breakfast olives and brining.", icon: "leaf.fill")
                        GradientInfoCardforVarieties(title: "Ayvalık (Edremit)", location: "📍 Aegean Region (Balıkesir, İzmir)", description: "Produces golden-yellow, mild, fruity olive oil. One of Turkey’s top oil varieties.", icon: "leaf.fill")
                        GradientInfoCardforVarieties(title: "Memecik", location: "📍 Aegean Region (Aydın, Muğla, İzmir)", description: "Very high oil content, strong aroma, slightly bitter & peppery. Ideal for premium extra virgin olive oil.", icon: "drop.fill")
                        GradientInfoCardforVarieties(title: "Domat", location: "📍 Aegean Region (Akhisar, Manisa)", description: "Large-sized olives, crisp texture. Famous for green cracked olives & stuffed olives.", icon: "leaf.fill")
                    }
                    .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)

                    // MARK: Harvest Stages
                    SectionHeader(title: "Harvest Stages", color: Color("ButtonColor"))

                    VStack(spacing: 15) {
                        GradientInfoCard(title: "Green Stage", description: "High polyphenols, bitter oil.", icon: "leaf.fill")
                        GradientInfoCard(title: "Veraison",  description: "Balanced & complex flavors.", icon: "paintpalette.fill")
                        GradientInfoCard(title: "Black Stage", description: "Mild, buttery oil.", icon: "circle.fill")
                        GradientInfoCard(title: "Overripe", description: "Low quality – avoid.", icon: "exclamationmark.triangle.fill")
                    }
                    .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)

                    // MARK: Pest Report Button
                    if !pestAlerts.isEmpty {
                        Button(action: { showingPestReportSheet = true }) {
                            Label("View Pest Report (\(pestAlerts.count))", systemImage: "ladybug.fill")
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .foregroundColor(Color("Background"))
                                .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.red, .red.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(18)
                                .shadow(radius: 6)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                    }

                }
                .padding(.vertical, 30)
            }
        }
        .navigationTitle("Harvest Roadmap")        
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                ripeness = ripenessValue(for: latestResult?.status)
            }
        }
        .sheet(isPresented: $showingPestReportSheet) {
            PestReportView(pestAlerts: pestAlerts)
        }
    }
}

extension View {
    func cardStyle() -> some View {
        ResponsiveCardModifier(content: self)
    }
}

struct ResponsiveCardModifier<Content: View>: View {
    let content: Content
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        content
            .frame(width: horizontalSizeClass == .regular ? 500 : 300)
            .padding(horizontalSizeClass == .regular ? 40 : 30)
            .background(
                LinearGradient(
                    colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
    }
}

struct GradientInfoCard: View {
    let title: String
    let description: String
    let icon: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(horizontalSizeClass == .regular ? .title : .title2)
                .foregroundColor(Color("Background"))
                .frame(width: horizontalSizeClass == .regular ? 44 : 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(horizontalSizeClass == .regular ? .title2 : .headline)
                    .foregroundColor(Color("Background"))

                Text(description)
                    .font(horizontalSizeClass == .regular ? .body : .subheadline)
                    .foregroundColor(Color("Background").opacity(0.85))
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 20)
    }
}

struct GradientInfoCardforVarieties: View {
    let title: String
    let location: String
    let description: String
    let icon: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(horizontalSizeClass == .regular ? .title : .title2)
                .foregroundColor(Color("Background"))
                .frame(width: horizontalSizeClass == .regular ? 44 : 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(horizontalSizeClass == .regular ? .title2 : .headline)
                    .foregroundColor(Color("Background"))
                
                Text(location)
                    .font(horizontalSizeClass == .regular ? .body : .caption2)
                    .foregroundColor(Color("Background"))

                Text(description)
                    .font(horizontalSizeClass == .regular ? .body : .subheadline)
                    .foregroundColor(Color("Background").opacity(0.85))
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 20)
    }
}

struct SectionHeader: View {
    let title: String
    let color: Color
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init(title: String, color: Color = Color("Background")) {
        self.title = title
               self.color = color
    }

    var body: some View {
        Text(title)
            .font(.system(size: horizontalSizeClass == .regular ? 32 : 22, weight: .bold))
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, horizontalSizeClass == .regular ? 40 : 22)
            .padding(.top, 10)
    }
}

struct HarvestRoadmapView_Previews: PreviewProvider {
    static var previews: some View {
        HarvestRoadmapView()
    }
}
