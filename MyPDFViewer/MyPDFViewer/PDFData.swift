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
    private var pdfDocSet: Array<PDFDoc>
    
    private var fileIndex: Int
    
    init(urlSet: Array<NSURL>) {
        var dataSet = Array<PDFDoc>()
        
        for i in 0..<urlSet.count {
            dataSet.append(PDFDoc(pdfURL: urlSet[i]))
        }
        self.pdfDocSet = dataSet
        
        self.fileIndex = 0
    }
    
    internal func getPDFAtIndex(index: Int) -> PDFDoc? {
        if index >= 0 && index < self.pdfDocSet.count {
            self.fileIndex = index
            return self.pdfDocSet[index]
        } else {
            return nil
        }
    }
    
    // MARK: - PDFDoc operation
    internal func getPreviousPDFDoc() -> PDFDoc{
        fileIndex = fileIndex - 1 < 0 ? (pdfDocSet.count - 1) : (fileIndex - 1)
        return self.pdfDocSet[fileIndex]
    }
    
    internal func getNextPDFDoc() -> PDFDoc {
        self.fileIndex = (fileIndex + 1) % self.pdfDocSet.count
        return self.pdfDocSet[fileIndex]
    }
    
    internal func getCurrentPDFDoc() -> PDFDoc {
        return self.pdfDocSet[fileIndex]
    }
}



class PDFDoc {
    private var pdfURL: NSURL
    private var pdfDoc: PDFDocument
    private var title: String?
    private var totalPages: Int
    private var currentPDFPage: PDFPage
    private var currentPage: Int {
        didSet {
            self.currentPDFPage = self.pdfDoc.pageAtIndex(currentPage - 1)
        }
    }
    
    init(pdfURL: NSURL) {
        self.pdfURL = pdfURL
        self.pdfDoc = PDFDocument(URL: pdfURL)
        self.totalPages = self.pdfDoc.pageCount()
        self.currentPage = 1
        self.currentPDFPage = self.pdfDoc.pageAtIndex(currentPage - 1)
    }
    
    internal func getCurrentPage() -> Int {
        return self.currentPage
    }
    
    internal func moveToNextPage() -> PDFPage {
        self.currentPage = (self.currentPage + 1) >= self.totalPages ? (self.totalPages - 1) : (self.currentPage + 1)
        return self.currentPDFPage
    }
    
    internal func moveToPreviouPage() -> PDFPage {
        self.currentPage = (self.currentPage - 1) <= 0 ? 0 : (self.currentPage - 1)
        return self.currentPDFPage
    }
    
    internal func moveToPageAt(page: Int) -> PDFPage? {
        if page >= 1 && page <= self.totalPages {
            self.currentPage = page
            return self.currentPDFPage
        } else {
            return nil
        }
    }
    
    internal func getTotalPages() -> Int {
        return self.totalPages
    }
    
    internal func getPDFDocument() ->PDFDocument {
        return self.pdfDoc
    }
}
