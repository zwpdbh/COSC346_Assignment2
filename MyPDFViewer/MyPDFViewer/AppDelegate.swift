//
//  AppDelegate.swift
//  MyPDFViewer
//
//  Created by zwpdbh on 9/27/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var window: NSWindow!
    
    

    // MARK: - Action
    
    // open file action
    @IBAction func openFile(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true;
        
        panel.beginWithCompletionHandler { (result) in
            if(result == NSFileHandlingPanelOKButton) {
                self.pdfSet = PDFSet(pdfURLS: panel.URLs)
                self.currentPDFDocument = self.pdfSet?.currentPDF
                self.pdfView.setDocument(self.currentPDFDocument)
            }
        }
    }
    
    // go to previous page
    @IBAction func previousPage(sender: NSButton) {
        if self.currentPDFDocument != nil {
            if currentPageNumber > 1 {
                currentPageNumber -= 1
            } else {
                currentPageNumber = 1
            }
        }
    }
    
    
    // go to the next page
    @IBAction func nextPage(sender: NSButton) {
        if let doc = self.currentPDFDocument {
            currentPageNumber = (currentPageNumber + 1) % doc.pageCount()
        }
    }
    
    // go to the Given page
    @IBAction func goToGivenPage(sender: NSTextField) {
        if let pageNumber = Int(currentPageDisplay.stringValue) {
            if pageNumber >= 1 && pageNumber <= totoalNumberOfPages {
                print("move to page: \(pageNumber)")
                currentPageNumber = pageNumber
            }
        }
    }
    
    // if there is not one pdf, then click this can go to previous one
    @IBAction func goToPreviousPDF(sender: NSButton) {
        if self.pdfSet?.index > 1 {
            self.pdfSet?.index -= 1
            self.currentPDFDocument = self.pdfSet?.currentPDF
        }
    }
    
    // if there is not one pdf, then click this can to to next one
    @IBAction func goToNextPDF(sender: NSButton) {
        if self.pdfSet?.index < totalNumberOfPDFs {
            self.pdfSet?.index += 1
            self.currentPDFDocument = self.pdfSet?.currentPDF
        }
        
    }
    
    
    // MARK: - PDF Model variables
    // a array of pdfs
    var pdfSet: PDFSet? {
        didSet {
            self.currentPDFDocument = self.pdfSet?.currentPDF
            self.totalNumberOfPDFs = self.pdfSet!.totalNumberOfPDFs
            print("total number of pdfs is \(totalNumberOfPDFs)")
        }
    }
    // the total number of pdfs in the array
    var totalNumberOfPDFs = 0
    // current Viewing pdf
    var currentPDFDocument: PDFDocument? {
        didSet {
            currentPageNumber = 1
            totoalNumberOfPages = currentPDFDocument!.pageCount()
        }
    }
    // current pdf pages
    var totoalNumberOfPages = 0
    // current viewing page
    var currentPageNumber: Int = 1 {
        didSet {
            print("go to page: \(currentPageNumber)")
            pdfView.goToPage(currentPDFDocument?.pageAtIndex(currentPageNumber))
            currentPageDisplay.stringValue = "\(currentPageNumber)/\(totoalNumberOfPages)"
        }
    }
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

