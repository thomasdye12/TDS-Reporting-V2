//
//  PDFView.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 14/04/2025.
//

import SwiftUI

struct ReportPDFView: View {
    let viewModel: NewReportViewModel

    var body: some View {
        NewReportView(viewModel: viewModel, mode: .export)
        .frame(width: 612, height: 1000) // A4 at 72dpi
        .preferredColorScheme(.light)
    }
}
