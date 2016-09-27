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
    var pdfDocuments: Array<PDFDocument> = []
    var index = 0
    var currentPDF: PDFDocument {
        return pdfDocuments[index]
    }
    
    init(pdfURLS: Array<NSURL>) {
        for i in 0..<pdfURLS.count {
            let url = pdfURLS[i]
            self.pdfDocuments.append(PDFDocument(URL: url))
        }
        
    }
}


