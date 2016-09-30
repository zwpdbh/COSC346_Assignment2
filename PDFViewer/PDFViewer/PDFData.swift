//
//  PDFData.swift
//  MyPDFViewer
//
//  Created by zwpdbh on 9/27/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz

public protocol PDFViewerDelegate {
    func pdfInfoNeedChangeTo(nthPDF: Int, totalPDFs: Int, title: String, page: Int)
}

class PDFSet: NSObject{
    private var pdfDocuments: Array<PDFDocument> = [] {
        didSet {
            totalNumberOfPDFs = self.pdfDocuments.count
            indexOfPDF = 0
            currentPageNumber = 0
        }
    }
    
    internal var delegate: PDFViewerDelegate?
    
    private var titles: Array<String> = []
    
    private var currentPageNumber = 0
    private var indexOfPDF = 0
    
    private var currentPDF: PDFDocument {
        didSet {
            currentPageNumber = 1
        }
    }
    
    private var totalNumberOfPDFs: Int
    
    
    init(pdfURLS: Array<NSURL>) {
        for i in 0..<pdfURLS.count {
            let url = pdfURLS[i]
            let pdfDoc = PDFDocument(URL: url)
            self.pdfDocuments.append(pdfDoc)
            self.titles.append(url.lastPathComponent!)
        }
        currentPDF = self.pdfDocuments[0]
        totalNumberOfPDFs = pdfURLS.count
        currentPageNumber = 0
    }
    
    func getTitlesOfPDFSet() -> [String] {
        return self.titles
    }
    
    func moveToNextPage() -> PDFPage? {
        if (currentPageNumber + 1) <= currentPDF.pageCount() {
            currentPageNumber += 1
            updatePDFInfo()
            return currentPDF.pageAtIndex(currentPageNumber)
        }
        return nil
    }
    
    func moveToPreviousPage() -> PDFPage? {
        
        if (currentPageNumber - 1) >= 0 {
            currentPageNumber -= 1
            updatePDFInfo()
            return currentPDF.pageAtIndex(currentPageNumber)
        }
        return nil
    }
    
    func moveToGivenPage(page: Int) -> PDFPage? {
        
        if page>=0 && page<=currentPDF.pageCount()  {
            currentPageNumber = page
            updatePDFInfo()
            return currentPDF.pageAtIndex(currentPageNumber)
        }
        return nil
    }
    
    func moveToNextPDF() -> PDFDocument? {
        if (indexOfPDF + 1) < totalNumberOfPDFs {
            indexOfPDF += 1
            currentPDF = self.pdfDocuments[indexOfPDF]
            updatePDFInfo()
            return currentPDF
        }
        return nil
    }
    
    func moveToPreviousPDF() -> PDFDocument? {
        if (indexOfPDF - 1) >= 0 {
            indexOfPDF -= 1
            currentPDF = self.pdfDocuments[indexOfPDF]
            updatePDFInfo()
            return currentPDF
        }
        return nil
    }
    
    func moveToGivenPDF(pdfIndex: Int) -> PDFDocument? {
        if (pdfIndex >= 0 && pdfIndex < totalNumberOfPDFs) {
            indexOfPDF = pdfIndex
            currentPDF = self.pdfDocuments[indexOfPDF]
            updatePDFInfo()
            return currentPDF
        }
        return nil
    }
    
    func setPage(page: PDFPage) {
        currentPageNumber = currentPDF.indexForPage(page)
        updatePDFInfo()
    }
 
    func updatePDFInfo() {
        delegate?.pdfInfoNeedChangeTo(indexOfPDF + 1, totalPDFs: totalNumberOfPDFs, title: titles[indexOfPDF], page: currentPageNumber)
    }
    
    func numberOfPDFs() -> Int {
        return self.totalNumberOfPDFs
    }
    
    func getCurrentPage() -> Int {
        return self.currentPageNumber
    }
    
    func getCurrentPDFTitle() -> String {
        return self.titles[self.indexOfPDF]
    }
    
//    func moveToBookMark(mark: Note) {
//        if let pdf = getIndexByTitle(mark.name) {
//            moveToGivenPDF(pdf)
//            moveToGivenPage(Int(mark.value)!)
//            updatePDFInfo()
//        }
//    }
    
    func getIndexByTitle(wanted: String) -> Int? {
        for i in 0..<titles.count {
            if wanted == titles[i] {
                return i
            }
        }
        return nil
    }
}


