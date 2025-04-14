//
//  ReportsListViewModel.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//


import SwiftUI
@MainActor
class ReportsListViewModel: ObservableObject {
    @Published var reports: [Report] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchReports() async {
        guard let url = URL(string: "\(RootURL)/v1/report/View") else {
            errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Auth header if needed
        request.setValue("Bearer \(auth.GetToken())", forHTTPHeaderField: "Authorization")

        do {
            isLoading = true

            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(ResponseWrapper.self, from: data)

            reports = decoded.reports
        } catch {
            print(error)
            errorMessage = "Failed to load reports: \(error.localizedDescription)"
        }

        isLoading = false
    }

    
    func fetchReport(_ id:String) async  -> Report?{
        guard let url = URL(string: "\(RootURL)/v1/report/View/\(id)") else {
            errorMessage = "Invalid URL"
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Auth header if needed
        request.setValue("Bearer \(auth.GetToken())", forHTTPHeaderField: "Authorization")

        do {
            isLoading = true

            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(ResponseWrapper.self, from: data)

            return decoded.reports.first
        } catch {
            print(error)
            errorMessage = "Failed to load reports: \(error.localizedDescription)"
        }

        isLoading = false
        return nil
    }
    private struct ResponseWrapper: Codable {
        let status: String
        let reports: [Report]
    }
}


