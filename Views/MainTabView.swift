import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var scanResultManager: ScanResultManager
    @State private var selectedTab = 0

    var body: some View {

        TabView(selection: $selectedTab) {

            ScanOptionsView()

                .tabItem {

                    Label("Scan", systemImage: "plus.viewfinder")

                }

                .tag(0)



            ScanResultsView()

                .tabItem {

                    Label("Results", systemImage: "list.bullet.rectangle.portrait.fill")

                }

                .tag(1)
            
            
            AboutTechView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
            
                .tag(2)

        }

        .onChange(of: scanResultManager.currentScanResult) { newResult in

            if newResult != nil {

                selectedTab = 1

            }

        }

    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
