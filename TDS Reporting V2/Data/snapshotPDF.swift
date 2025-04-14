//
//  snapshotPDF.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 14/04/2025.
//

import SwiftUI

extension View {
    func snapshotPDF(pageSize: CGSize) -> Data {
        let hostingController = UIHostingController(rootView: self)
        hostingController.view.bounds = CGRect(origin: .zero, size: CGSize(width: pageSize.width, height: 10_000)) // Large height to capture all content
        hostingController.view.backgroundColor = .systemBackground

        let window = UIWindow(frame: hostingController.view.bounds)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        let fullSize = hostingController.view.systemLayoutSizeFitting(
            CGSize(width: pageSize.width, height: UIView.layoutFittingCompressedSize.height)
        )

        hostingController.view.bounds = CGRect(origin: .zero, size: fullSize)

        let totalHeight = fullSize.height
        let numberOfPages = Int(ceil(totalHeight / pageSize.height))
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

        return renderer.pdfData { context in
            for pageIndex in 0..<numberOfPages {
                context.beginPage()

                let yOffset = CGFloat(pageIndex) * pageSize.height
                context.cgContext.saveGState()
                context.cgContext.translateBy(x: 0, y: -yOffset)

                hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)

                context.cgContext.restoreGState()
            }
        }
    }
}
