//
//  PDFData.swift
//  MyPDFViewer
//
//  Created by zwpdbh on 9/27/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz

class PDFSet {
    private var pdfDocuments: Array<PDFDocument> = [] {
        didSet {
            totalNumberOfPDFs = self.pdfDocuments.count
            index = 0;
        }
    }
    
    var titles: Array<String> = []
    
    var index = 0
    
    var totalNumberOfPDFs: Int
    
    var currentPDF: PDFDocument {
        assert(index >= 0 && index < self.pdfDocuments.count, "invalid index is: \(index)")
        print("move to \(index)th PDF")
        return pdfDocuments[index]
    }
    
    init(pdfURLS: Array<NSURL>) {
        for i in 0..<pdfURLS.count {
            let url = pdfURLS[i]
            let pdfDoc = PDFDocument(URL: url)
            self.pdfDocuments.append(pdfDoc)
            
            if let title = pdfDoc.documentAttributes()["Title"] {
                self.titles.append(title as! String)
            } else {
                self.titles.append(url.lastPathComponent!)
            }
        }
        totalNumberOfPDFs = pdfURLS.count
    }
    
}


