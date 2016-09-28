//
//  MainWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/28/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz

class MainWindowController: NSWindowController {

    // MARK: - Outlet
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var pdfView: PDFView!
    
    
    @IBOutlet weak var selectPDFButton: NSPopUpButton!
    
    // MARK: - Action
    // open pdf files and put them into array
    @IBAction func openFile(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true;
        
        panel.beginWithCompletionHandler { (result) in
            if(result == NSFileHandlingPanelOKButton) {
                self.selectPDFButton.removeAllItems()
                self.pdfSet = PDFSet(pdfURLS: panel.URLs)
                self.currentPDFDocument = self.pdfSet?.currentPDF
                self.pdfView.setDocument(self.currentPDFDocument)
                
                for title in self.pdfSet!.titles {
                    self.selectPDFButton.addItemWithTitle(title)
                }
                
                self.updateWindow()
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
                currentPageNumber = pageNumber
            }
        }
    }
    
    // if there is not one pdf, then click this can go to previous one
    @IBAction func goToPreviousPDF(sender: NSButton) {
        if let set = self.pdfSet {
            if (set.index - 1) >= 0 {
                set.index -= 1
                self.currentPDFDocument = set.currentPDF
                self.selectPDFButton.selectItemAtIndex(set.index)
                updateWindow()
            }
        }
    }
    
    // if there is not one pdf, then click this can to to next one
    @IBAction func goToNextPDF(sender: NSButton) {
        if let set = self.pdfSet {
            if (set.index + 1) < totalNumberOfPDFs {
                set.index += 1
                self.currentPDFDocument = set.currentPDF
                self.selectPDFButton.selectItemAtIndex(set.index)
                updateWindow()
            }
        }
    }
    // move to selected pdf
    @IBAction func selectPDF(sender: NSPopUpButtonCell) {
        if let set = self.pdfSet {
            let selectedIndex = self.selectPDFButton.indexOfSelectedItem
            set.index = selectedIndex
            self.currentPDFDocument = set.currentPDF
            self.window?.title = "Total:\(set.index + 1)/\(self.totalNumberOfPDFs) "
                + set.titles[set.index]
        }
    }
    @IBAction func zoomIn(sender: NSButton) {
        self.pdfView.zoomIn(sender)
    }
    
    @IBAction func zoomOut(sender: NSButton) {
        self.pdfView.zoomOut(sender)
    }
    
    @IBAction func resetZoom(sender: NSButton) {
        self.pdfView.setAutoScales(true)
    }
    
    // MARK: - PDF Model Variables
    // a array of pdfs
    var pdfSet: PDFSet? {
        didSet {
            self.currentPDFDocument = self.pdfSet?.currentPDF
            self.totalNumberOfPDFs = self.pdfSet!.totalNumberOfPDFs
        }
    }
    // the total number of pdfs in the array
    var totalNumberOfPDFs = 0
    // current Viewing pdf
    var currentPDFDocument: PDFDocument? {
        didSet {
            self.pdfView.setDocument(self.currentPDFDocument)
            currentPageNumber = 1
            totoalNumberOfPages = currentPDFDocument!.pageCount()
            updateView()
        }
    }
    // current pdf pages
    var totoalNumberOfPages = 0
    // current viewing page
    var currentPageNumber: Int = 1 {
        didSet {
            updateView()
        }
    }
    
    // update windown info to indicate selected pdf
    func updateWindow() {
        if let set = self.pdfSet {
            self.window?.title = "Total:\(set.index + 1)/\(self.totalNumberOfPDFs) "
                + set.titles[set.index]
        }
    }
    
    // update view, set current pdf to certain page, and update current page info
    func updateView() {
        pdfView.goToPage(currentPDFDocument?.pageAtIndex(currentPageNumber))
        currentPageDisplay.stringValue = "\(currentPageNumber)/\(totoalNumberOfPages)"
    }
    
    // MARK: - Action Related to Window
    func windowDidResize(notification: NSNotification) {
        self.pdfView.setAutoScales(true)
    }

    override var windowNibName: String? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
