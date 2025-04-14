//
//  TopicSelectionView.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 14/04/2025.
//

import SwiftUI
struct TopicSelectionView: View {
    @Binding var selectedTopic: String
    let topics: [String]
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    var filteredTopics: [String] {
        if searchText.isEmpty {
            return topics
        } else {
            return topics.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        List {
            ForEach(filteredTopics, id: \.self) { topic in
                Button {
                    selectedTopic = topic
                    dismiss()
                } label: {
                    HStack {
                        Text(topic)
                        if topic == selectedTopic {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Select Topic")
    }
}
