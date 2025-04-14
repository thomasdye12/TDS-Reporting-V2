//
//  ReportsListView.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//

import SwiftUI

struct ReportsListView: View {
    @StateObject var viewModel = ReportsListViewModel()
    @State private var showingCompleted = false

    var body: some View {
        NavigationStack{
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Reports…")
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                } else {
                    ReportsListView2(viewModel: viewModel, showingCompleted: $showingCompleted)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Menu {
                                    Button("Show Active Reports") {
                                        showingCompleted = false
                                    }
                                    Button("Show Completed Reports") {
                                        showingCompleted = true
                                    }
                                } label: {
                                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                                }
                            }
                        }
                }
            }

        }
            .navigationTitle("Reports")
       
            .onAppear(perform: {
                Task {
                    await viewModel.fetchReports()
                }
            })
            .refreshable {
                Task {
                    await viewModel.fetchReports()
                }
            }
    }
}



struct ReportsListView2: View {
    @StateObject var viewModel:ReportsListViewModel
    @Binding var showingCompleted:Bool
    var body: some View {
        List {
            if showingCompleted {
                let completedReports = viewModel.reports.filter { $0.status == .completed }
                
                if !completedReports.isEmpty {
                    Section(header: Text("Completed Reports (\(completedReports.count))")) {
                        ForEach(completedReports) { report in
                            NavigationLink(destination: NewReportView(viewModel: NewReportViewModel(report: report), mode: .interactive)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(report.title).font(.headline)
                                    Text(report.topic + " • " + report.type)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } else {
                    Text("No completed reports.")
                        .foregroundColor(.gray)
                }
                
            } else {
                ForEach(severities.reversed(), id: \.self) { severity in
                    let sectionReports = viewModel.reports.filter {
                        $0.severity == severity && $0.status != .completed
                    }
                    
                    if !sectionReports.isEmpty {
                        Section(
                            header: HStack {
                                Label(severity, systemImage: severityIcons[severity] ?? "circle")
                                Spacer()
                                Text("\(sectionReports.count)")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        ) {
                            ForEach(sectionReports) { report in
                                NavigationLink(destination: NewReportView(viewModel: NewReportViewModel(report: report), mode: .interactive)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(report.title).font(.headline)
                                        Text(report.topic + " • " + report.type)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Status: \(report.status)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .disabled(!(report.editable ?? false))
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
