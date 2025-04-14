//
//  NewReportViewModel.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//

import SwiftUI
var severityIcons: [String: String] = [
    "Low": "tortoise",
    "Medium": "exclamationmark.triangle",
    "High": "flame",
    "Critical": "bolt.fill"
]
var severities: [String] = ["Low", "Medium", "High", "Critical"]
class NewReportViewModel: ObservableObject {
    
    @Published private(set) var originalReport: Report
    
    @Published var report = Report(
        id: UUID().uuidString,
        title: "",
        topic: "",
        type: "",
        severity: "Medium",
        firstSeen: Date(),
        description: "",
        status: .created,
        user: UserInfo(username: "", GUUID: "", apnsToken: auth.APNSObject.CreateAPNSarray()),
        customAnswers: [:]
    )

    init() {
        self.originalReport = Report(
            id: UUID().uuidString,
            title: "",
            topic: "",
            type: "",
            severity: "Medium",
            firstSeen: Date(),
            description: "",
            status: .created,
            user: UserInfo(username: "", GUUID: "", apnsToken: auth.APNSObject.CreateAPNSarray())
        )
        
        Task {
            try await ReportUserData()
        }
   
    }
    
    
    
    init(report:Report) {
        self.report = report
        self.originalReport = report
    }
    @Published var topics: [String] = ["Software", "Hardware", "Plumbing", "Garden", "Electrical", "Internet"]
    @Published var typeOptions: [String: [String]] = [
        "Software": ["Incorrect behavior", "Crash", "Suggestion"],
        "Hardware": ["Broken", "Doesn't work", "Improvement"],
        "Plumbing": ["Leak", "Blockage", "Other"],
        "Garden": ["Damage", "Broken item", "Idea"],
        "Electrical": ["Power issue", "Faulty socket", "Danger"],
        "Internet": ["No connection", "Slow speed", "Router problem"]
    ]
    @Published var customQuestions: [String: [String: [String]]] = [:]
    @Published var showSubmitted = false

   



    var canSubmit: Bool {
        !report.title.isEmpty &&
        !report.topic.isEmpty &&
        !report.type.isEmpty &&
        !report.description.isEmpty
    }

    func submitReport() {
        Task {
            guard let url = URL(string: "\(RootURL)/v1/report/Submit") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Set your Authorization header here — customize token if needed
            request.setValue("Bearer \(auth.GetToken())", forHTTPHeaderField: "Authorization")
            
            do {
                let jsonData = try JSONEncoder().encode(report)
                request.httpBody = jsonData
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status Code: \(httpResponse.statusCode)")
                }
                
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response: \(responseBody)")
                }
                
                // Show confirmation in UI
                await MainActor.run {
                    showSubmitted = true
                    resetReport()
                }
                
            } catch {
                print("Submission failed: \(error)")
            }
        }
    }

    func resetReport() {
        report = Report(
            id: UUID().uuidString,
            title: "",
            topic: "",
            type: "",
            severity: "Medium",
            firstSeen: Date(),
            description: "",
            status: .created,
            user: report.user,
            customAnswers: [:]
        )
    }
    
    func ReportUserData() async throws{
        let userData = try await  auth.GetUserDataAsync()
        var userInfo: UserInfo!
        userInfo = UserInfo(username: userData.username, GUUID: userData.GeneratedUID, apnsToken: auth.APNSObject.CreateAPNSarray())
        await MainActor.run {
               report.user = userInfo
           }
    }
    
    func IsSavedReport() -> Bool{
        return report.editableV2 == nil ? false : true
    }
    func CreatedByself() -> Bool {
        return report.editableV2 == "selfCreated" ? true : false
    }
    @MainActor
    func loadFormOptions() async {
        guard let url = URL(string: "\(RootURL)/v1/report/FormOptions") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(auth.GetToken())", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(FormOptionsResponse.self, from: data)

            await MainActor.run {
                self.topics = decoded.topics
                self.typeOptions = decoded.typeOptions
                self.customQuestions = decoded.customQuestions ?? [:]
            }
        } catch {
            print("Failed to load form options: \(error.localizedDescription)")
        }
    }

    
    var EditinghasChanges: Bool {
        return report != originalReport
    }
    @MainActor
    func submitReportUpdate() async {
        guard let url = URL(string: "\(RootURL)/v1/report/Update") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(auth.GetToken())", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(report)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Server responded with: \(httpResponse.statusCode)")
            }
            let saveReport = report
            report = saveReport
            // success — update original snapshot
            originalReport = saveReport

        } catch {
            print("Failed to update report: \(error)")
        }
    }
}

enum ReportStatus: String, Codable, CaseIterable, Identifiable {
    case created = "Created"
    case inProgress = "In Progress"
    case transferred = "Transferred"
    case completed = "Completed"

    var id: String { self.rawValue }
}


//
//Section("Report Status") {
//    Picker("Status", selection: $viewModel.report.status) {
//        ForEach(ReportStatus.allCases) { status in
//            Text(status.rawValue).tag(status)
//        }
//    }
//    .pickerStyle(.segmented)
//}
