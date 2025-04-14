//
//  ReportDetailView.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//

import SwiftUI

struct ReportViewEditable: View {
    @StateObject var viewModel: NewReportViewModel
    @State private var newComment: String = ""
    @State var userData:Auth_UserInfo?
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
            Section(header: Text("Report Details")) {
                Text(viewModel.report.title)
                Text("Topic: \(viewModel.report.topic)")
                Text("Type: \(viewModel.report.type)")
                Text("Severity: \(viewModel.report.severity)")
            }
        
            
       

            Section("Status") {
                Picker("Status", selection: $viewModel.report.status) {
                    ForEach(ReportStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("Comments")) {
                if (viewModel.report.comments ?? [] ).count  > 0 {
                    ForEach(viewModel.report.comments ?? []) { comment in
                        VStack {
                            Text(comment.Comments)
                                .font(.body)
                            HStack {
                                Text(comment.username)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(comment.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                } else {
                    Text("No comments yet.")
                        .foregroundColor(.secondary)
                }

                TextEditor(text: $newComment)
                    .frame(height: 150)
                    .focused($isTextEditorFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isTextEditorFocused = false
                            }
                        }
                    }
                Button("Submit Comment") {
                     submitComment()
                }
                .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.task {
                Task {
                    userData = try await auth.GetUserDataAsync()
                }
            }
        if viewModel.EditinghasChanges {
                   Section {
                       Button("Save Changes") {
                           Task {
                               await viewModel.submitReportUpdate()
                           }
                       }
                       .foregroundColor(.blue)
                       .font(.headline)
                       .frame(maxWidth: .infinity)
                   }
               }
    }

    func submitComment()  {
        
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let userData = userData else { return }
      
        let comment = Comments(id: UUID().uuidString, username: userData.username, GUUID: userData.GeneratedUID, Comments: trimmed,timestamp: Date())

        if viewModel.report.comments == nil {
            viewModel.report.comments = []
        }

        viewModel.report.comments?.append(comment)
        newComment = ""
    }
    
    func sortedComments() -> [Comments]{
        return  (viewModel.report.comments ?? []).sorted(by: { $0.timestamp > $1.timestamp })
    }

}

struct ShareURL: UIViewControllerRepresentable {
    let FormID: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
     

        let controller = UIActivityViewController(activityItems: [URLFromString(FormID)], applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    func URLFromString(_ input: String) -> URL {
        return URL(string: "TDSRP://\(input)")!
    }
}

//#Preview {
//    ReportViewEditable(viewModel: .init())
//}
