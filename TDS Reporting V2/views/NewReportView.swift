//
//  NewReportView.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//

import SwiftUI


import SwiftUI

struct NewReportView: View {
    @StateObject var viewModel: NewReportViewModel
    let mode: FormRenderingMode
    @State private var showShareSheet = false
       @State private var pdfData: Data?
    var body: some View {
        NavigationStack {
            SmartForm(mode: mode)  {
                if viewModel.IsSavedReport() &&  !viewModel.CreatedByself() {
                    ReportViewEditable(viewModel: viewModel)
                    
                }
                NewReportViewFillInfo(viewModel: viewModel)
                //                .disabled(viewModel.IsSavedReport())
                
                
                Section("User Info") {
                    Label("Username: \(viewModel.report.user.username)", systemImage: "person.fill")
                    Label("User ID: \(viewModel.report.user.GUUID)", systemImage: "person.crop.circle")
                    Label("APNS Token: \(viewModel.report.user.apnsToken)…", systemImage: "antenna.radiowaves.left.and.right")
                    Label("Report ID: \(viewModel.report.id)…", systemImage: "doc.plaintext")
                    Label("Status: \(viewModel.report.status)", systemImage: "pencil.and.list.clipboard")
                }
                
                if viewModel.canSubmit && viewModel.IsSavedReport() == false {
                    Button(action: viewModel.submitReport) {
                        Label("Submit Report", systemImage: "pencil.and.list.clipboard")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .toolbar {
            if viewModel.IsSavedReport() {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        self.showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
             }
             .sheet(isPresented: $showShareSheet) {
                 ShareURL(FormID: viewModel.report.id)
             }
        .task {
            await viewModel.loadFormOptions()
        }
        .refreshable {
            if (!viewModel.IsSavedReport()) {
                viewModel.resetReport()
            } else  {
                if let newupdate = await ReportsListViewModel().fetchReport(viewModel.report.id) {
                    viewModel.report = newupdate
                }
            }
        }
        
        .alert("Report Submitted", isPresented: $viewModel.showSubmitted) {
            Button("OK", role: .cancel) {}
        }
        .navigationTitle(viewModel.IsSavedReport() ? "View Report" : "New Report")
    }
}


struct NewReportViewFillInfo: View {
    
    @StateObject var viewModel: NewReportViewModel
    @FocusState private var isTextEditorFocused: Bool
    var body: some View {
        
        Section {
            TextField("Issue Title", text: $viewModel.report.title)
                .disabled(viewModel.IsSavedReport())
        }
        
        Section("Topic") {
            NavigationLink(destination: TopicSelectionView(
                selectedTopic: $viewModel.report.topic,
                topics: viewModel.topics
            )) {
                HStack {
                    Text("Topic")
                    Spacer()
                    Text(viewModel.report.topic.isEmpty ? "Select…" : viewModel.report.topic)
                        .foregroundColor(viewModel.report.topic.isEmpty ? .gray : .primary)
                }
            }
        }

        if let types = viewModel.typeOptions[viewModel.report.topic] {
            Section("Type of Issue") {
                Picker("Type", selection: $viewModel.report.type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }
            }.pickerStyle(.automatic)
//                .disabled(viewModel.IsSavedReport())
        }
        // Dynamically add custom questions if available
        
        if viewModel.IsSavedReport() && viewModel.report.customAnswers?.count ?? 0 > 0   {
            if let sections = viewModel.report.customAnswers {
                        Section("Custom") {
                            ForEach(sections.keys.sorted(), id: \.self) { question in
                                VStack(alignment: .leading) {
                                    Text(question)
                                        .font(.caption2)
                                    Text(viewModel.report.customAnswers?[question] ?? "")
                                }
                            }
                        }
            }
            
            
        } else if viewModel.report.customAnswers != nil  {
            if let sections = viewModel.customQuestions[viewModel.report.topic] {
                ForEach(sections.keys.sorted(), id: \.self) { sectionTitle in
                    if let questions = sections[sectionTitle] {
                        Section(sectionTitle) {
                            ForEach(questions, id: \.self) { question in
                                TextField(question, text: Binding(
                                    get: {
                                        viewModel.report.customAnswers![question] ?? ""
                                    },
                                    set: {
                                        viewModel.report.customAnswers![question] = $0
                                    }
                                ))
                            }
                        }
                    }
                }
            }
        }

        Section("Severity") {
            Picker("Severity", selection: $viewModel.report.severity) {
                ForEach(severities, id: \.self) { level in
                    Label(level, systemImage: severityIcons[level] ?? "circle").tag(level)
                }
            }.pickerStyle(.automatic)
//                .disabled(viewModel.IsSavedReport())
        }

        Section("First Seen") {
            DatePicker("Date & Time", selection: $viewModel.report.firstSeen, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.automatic)
                .disabled(viewModel.IsSavedReport())
        }

        Section("Description") {
                       TextEditor(text: $viewModel.report.description)
                           .frame(height: 150)
                           .disabled(viewModel.IsSavedReport())
                           .focused($isTextEditorFocused)
                           .toolbar {
                               ToolbarItemGroup(placement: .keyboard) {
                                   Spacer()
                                   Button("Done") {
                                       isTextEditorFocused = false
                                   }
                               }
                           }
                   }
        
        
    }
    
}
    



#Preview {
    let dummyUser = UserInfo(username: "previewuser", GUUID: "user-0000", apnsToken: .init(APNStoken: ""))
    let dummyReport = Report(
        id: UUID().uuidString,
        title: "Preview Bug in UI",
        topic: "Software",
        type: "Incorrect behavior",
        severity: "High",
        firstSeen: Date(),
        description: "This is a dummy issue used for preview purposes.",
        status: .inProgress,
        user: dummyUser
    )

    let vm = NewReportViewModel()
    vm.report = dummyReport
    vm.topics = ["Software", "Hardware"]
    vm.typeOptions = ["Software": ["Incorrect behavior", "Crash", "Suggestion"]]


    return NavigationView {
        NewReportView(viewModel: vm, mode: .interactive)
      }
}
