//
//  PDFData.swift
//  MyPDFViewer
//
//  Created by zwpdbh on 9/27/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz

// use this delegate protocol to sync the PDF info with Window title info
public protocol PDFViewerDelegate {
    func pdfInfoNeedChangeTo(_ nthPDF: Int, totalPDFs: Int, title: String, page: Int, totalPages: Int)
}

/**
 * My PDF model, when open a panel and select multiple PDFs, use the selected
 * NSURLs to initialize this model
 */
class PDFSet: NSObject{
    internal var pdfDocuments: Array<PDFDocument> = [] {
        didSet {
            totalNumberOfPDFs = self.pdfDocuments.count
            indexOfPDF = 0
            indexOfPage = 0
        }
    }
    
    internal var delegate: PDFViewerDelegate?
    // the titles of those PDFs
    fileprivate var titles: Array<String> = []
    // the NSURL of those PDFs
    var addresses: Array<URL> = []
    
    // the default page in one PDF
    fileprivate var indexOfPage = 0
    // the default PDF among PDF set
    fileprivate var indexOfPDF = 0
    
    // the current viewing PDF
    internal var currentPDF: PDFDocument {
        didSet {
            indexOfPage = 0
        }
    }
    
    // the number of PDFs after multiple selection
    fileprivate var totalNumberOfPDFs: Int
    
    
    init(pdfURLS: Array<URL>) {
        for i in 0..<pdfURLS.count {
            let url = pdfURLS[i]
            let pdfDoc = PDFDocument(url: url)
            self.pdfDocuments.append(pdfDoc!)
            self.titles.append(url.lastPathComponent)
            self.addresses.append(url)
        }
        currentPDF = self.pdfDocuments[0]
        totalNumberOfPDFs = pdfURLS.count
        indexOfPage = 0
    }
    
    // return the titles
    func getTitlesOfPDFSet() -> [String] {
        return self.titles
    }
    
    // move current viewing page to the next one
    func moveToNextPage() -> PDFPage? {
        if (indexOfPage + 1) < currentPDF.pageCount {
            indexOfPage += 1
            updatePDFInfo()
            return currentPDF.page(at: indexOfPage)
        }
        return nil
    }
    
    // move current viewing page to the previous one
    func moveToPreviousPage() -> PDFPage? {
        
        if (indexOfPage - 1) >= 0 {
            indexOfPage -= 1
            updatePDFInfo()
            return currentPDF.page(at: indexOfPage)
        }
        return nil
    }
    
    // move to a given page
    func moveToGivenPage(_ page: Int) -> PDFPage? {
        
        if page>=1 && page<=currentPDF.pageCount  {
            indexOfPage = page - 1
            updatePDFInfo()
            return currentPDF.page(at: indexOfPage)
        }
        return nil
    }
    
    // move to the next PDF
    func moveToNextPDF() -> PDFDocument? {
        if (indexOfPDF + 1) < totalNumberOfPDFs {
            indexOfPDF += 1
            currentPDF = self.pdfDocuments[indexOfPDF]
            updatePDFInfo()
            return currentPDF
        }
        return nil
    }
    
    // move to the previous PDF
    func moveToPreviousPDF() -> PDFDocument? {
        if (indexOfPDF - 1) >= 0 {
            indexOfPDF -= 1
            currentPDF = self.pdfDocuments[indexOfPDF]
            updatePDFInfo()
            return currentPDF
        }
        return nil
    }
    
    // move to the selected PDF, selected by pop up menu button
    func moveToGivenPDF(_ pdfIndex: Int) -> PDFDocument? {
        if (pdfIndex >= 0 && pdfIndex < totalNumberOfPDFs) {
            indexOfPDF = pdfIndex
            currentPDF = self.pdfDocuments[indexOfPDF]
            updatePDFInfo()
            return currentPDF
        }
        return nil
    }
    
    // through PDFPage, get the page index.
    func setPage(_ page: PDFPage) {
        indexOfPage = currentPDF.index(for: page)
        updatePDFInfo()
    }
 
    // update PDF info using model's delegate
    func updatePDFInfo() {
        delegate?.pdfInfoNeedChangeTo(indexOfPDF + 1, totalPDFs: totalNumberOfPDFs, title: titles[indexOfPDF], page: indexOfPage + 1, totalPages: currentPDF.pageCount)
    }
    
    // return the number of PDFs in the set
    func numberOfPDFs() -> Int {
        return self.totalNumberOfPDFs
    }
    
    // return the current viewing page number
    func getCurrentPage() -> Int {
        return self.indexOfPage + 1
    }
    
    // return the current viewing PDF's title
    func getCurrentPDFTitle() -> String {
        return self.titles[self.indexOfPDF]
    }
    
    // From a given title, return the index of current viewing PDF file in the set.
    func getIndexByTitle(_ wanted: String) -> Int? {
        for i in 0..<titles.count {
            if wanted == titles[i] {
                return i
            }
        }
        return nil
    }
    
    // set MainWindowController as each PDF (PDFDocument)'s delegate
    func setPDFDocumentsDelegate(_ controller: MainWindowController) {
        for each in self.pdfDocuments {
            each.delegate = controller
        }
    }
}


