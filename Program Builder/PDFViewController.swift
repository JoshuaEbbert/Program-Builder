//
//  PDFViewController.swift
//  Program Builder
//
//  Created by Adam Grow on 8/15/22.
//

import UIKit
import PDFKit
import WebKit

class PDFViewController: UIViewController {
    var webView: WKWebView!
    var programItems: ProgramItems!
    var url: URL?
    
    // PDF sizing. Default is for 8.5 x 11 inch page
    var pdfWidth = 72 * 8.5
    var pdfHeight = 72 * 11
    var sideMargins = 100
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    
        programItems = ProgramItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Change Sizing", style: .plain, target: self, action: #selector(choosePDFSize))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        programItems.allItems = defaults.object(forKey: "AllItems") as? [[String]]
        generatePDF()
        
        if let pdfURL = url {
            webView.load(URLRequest(url: pdfURL))
        } else {
            print("Unable to load pdf file")
        }
    }

    @objc func generatePDF() {
        let format = UIGraphicsPDFRendererFormat()
        let metaData = [
            kCGPDFContextAuthor: "Program Builder App"
        ]
        format.documentInfo = metaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: Int(pdfWidth), height: Int(pdfHeight)) // dimensions of an 8.5 x 11 sheet of paper
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        url = Bundle.main.url(forResource: "ChurchProgram", withExtension: "pdf")
        
        guard let pdfURL = url else {
            print("Unable to load url for pdf")
            return
        }
        try? renderer.writePDF(to: pdfURL) { context in
            // Spacing based on item count
            var count = 0
            for item in programItems.allItems {
                count += item.count
            }
            
            let lineSpacing = (pdfHeight - sideMargins * 2 - 65 ) / count > 40 ? (pdfHeight - sideMargins * 2 - 65 ) / count : 40 // See if there is enough room for all the lines to fit on the page well. If not, set spacing to a hardcoded 40.
            
            context.beginPage()
            
            // Title
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            var attributes = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)
            ]
            var textRect = CGRect(x: sideMargins, y: sideMargins, width: Int(pdfWidth) - sideMargins * 2, height: 40)
            let title = programItems.allItems[0][0]
            title.draw(in: textRect, withAttributes: attributes)
            
            // Header, Body, and Misc
            paragraphStyle.alignment = .left
            attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                          NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
            for i in 1...3 {
                textRect = textRect.offsetBy(dx: 0, dy: 25) // Offset by an extra line between sections
                for item in programItems.allItems[i] {
                    if textRect.maxY >= CGFloat(pdfHeight - sideMargins) {
                        context.beginPage()
                        textRect = CGRect(x: sideMargins, y: sideMargins, width: Int(pdfWidth) - sideMargins * 2, height: lineSpacing)
                    }
                    
                    textRect = textRect.offsetBy(dx: 0, dy: 30)
                    item.draw(in: textRect, withAttributes: attributes)
                }
            }
        }
    }
    
    @objc func choosePDFSize() {
        let ac = UIAlertController(title: "Document Size", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Letter (8.5 x 11 inches)", style: .default, handler: sizeSelectionHandler))
        ac.addAction(UIAlertAction(title: "Half-Sheet (4.25 x 5.5 inches)", style: .default, handler: sizeSelectionHandler))
        ac.addAction(UIAlertAction(title: "Junior Legal (8 x 5 inches)", style: .default, handler: sizeSelectionHandler))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
                     
    func sizeSelectionHandler(_ action: UIAlertAction) {
        switch action.title {
        case "Half-Sheet (4.25 x 5.5 inches)":
            pdfWidth = 4.25 * 72
            pdfHeight = Int(5.5 * 72)
            sideMargins = 50
            
        case "Junior Legal (8 x 5 inches)":
            pdfWidth = 8 * 72
            pdfHeight = 5 * 72
            sideMargins = 50
            
        default:
            pdfWidth = 8.5 * 72
            pdfHeight = 11 * 72
            sideMargins = 100
        }
        
        generatePDF()
        webView.reload()
    }
    
    @objc func shareTapped() {
        guard let pdfURL = url, let programPDF = try? Data(contentsOf: pdfURL) else { print("Unable to share PDF"); return }
        
        let vc = UIActivityViewController(activityItems: [programPDF], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(vc, animated: true)
    }
}
