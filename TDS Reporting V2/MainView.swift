//
//  MainView.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//

import SwiftUI

struct MainView: View {
    @State private var deepLinkedReport: Report?
    
    var body: some View {
        NavigationStack {
            TabView {
                NewReportView(viewModel: NewReportViewModel(), mode: .interactive)
                    .tabItem {
                        Label("New Report", systemImage: "plus.circle")
                    }

                ReportsListView()
                    .tabItem {
                        Label("Reports", systemImage: "list.bullet")
                    }
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { deepLinkedReport != nil },
                set: { if !$0 { deepLinkedReport = nil } }
            )) {
                if let id = deepLinkedReport {
                    NewReportView(viewModel: .init(report: id), mode: .interactive)
                }
            }
            .task {
                auth.IncomingDeepLink = { link in
                    Task {
                        // Parse ID from deep link (e.g. "TDSRP://67fc4018051a718dad0c1d82")
                        if link?.scheme?.lowercased() == "tdsrp", let id = link?.host {
                            deepLinkedReport = await ReportsListViewModel().fetchReport(id)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    MainView()
}
