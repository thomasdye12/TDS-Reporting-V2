//
//  SmartForm.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 14/04/2025.
//

import SwiftUI

enum FormRenderingMode {
    case interactive      // Regular form for on-screen use
    case export           // ScrollView/VStack for snapshot/PDF
}

struct SmartForm<Content: View>: View {
    let mode: FormRenderingMode
    @ViewBuilder let content: () -> Content

    var body: some View {
        switch mode {
        case .interactive:
            Form { content() }
                .formStyle(.grouped)
        case .export:
            Form { content() }
                .formStyle(.columns)
                .ignoresSafeArea(.all)
        }
    }
}
