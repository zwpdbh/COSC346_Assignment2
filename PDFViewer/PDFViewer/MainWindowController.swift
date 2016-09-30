//
//  MainWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/28/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz


class MainWindowController: NSWindowController, PDFViewerDelegate, NSTableViewDataSource {

    // MARK: - Outlet
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var tableView: NSTableView!
    
    
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
                
                
                if let set = self.pdfSet {
                    for title in set.getTitlesOfPDFSet() {
                        self.selectPDFButton.addItemWithTitle(title)
                    }
                    set.delegate = self
                    self.pdfView.setDocument(set.moveToGivenPDF(0))
                    
                    // dataSource for outline
                    
                }
            }
        }
    }
    
    // go to previous page
    @IBAction func previousPage(sender: NSButton) {
        if let set = self.pdfSet {
            if let page = set.moveToPreviousPage() {
                self.pdfView.goToPage(page)
            }
        }
    }
    
    
    // go to the next page
    @IBAction func nextPage(sender: NSButton) {
        if let set = self.pdfSet {
            if let page = set.moveToNextPage() {
                self.pdfView.goToPage(page)
            }
        }
    }
    
    // go to the Given page
    @IBAction func goToGivenPage(sender: NSTextField) {
        if let set = self.pdfSet {
            if let index = Int(sender.stringValue) {
                if let page = set.moveToGivenPage(index) {
                    self.pdfView.goToPage(page)
                }
            }
        }
    }
    
    // if there is not one pdf, then click this can go to previous one
    @IBAction func goToPreviousPDF(sender: NSButton) {
        if let set = self.pdfSet {
            if let pdf = set.moveToPreviousPDF() {
                self.pdfView.setDocument(pdf)
            }
        }

    }
    
    // if there is not one pdf, then click this can to to next one
    @IBAction func goToNextPDF(sender: NSButton) {
        if let set = self.pdfSet {
            if let pdf = set.moveToNextPDF() {
                self.pdfView.setDocument(pdf)
            }
        }
    }
    
    // move to selected pdf
    @IBAction func selectPDF(sender: NSPopUpButtonCell) {
        if let set = self.pdfSet {
            let selectedIndex = self.selectPDFButton.indexOfSelectedItem
            if let pdf = set.moveToGivenPDF(selectedIndex) {
                self.pdfView.setDocument(pdf)
            }
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
    
    // MARK: - Model Variables
    // a array of pdfs
    var pdfSet: PDFSet?
    
    var notes: Array<Note> = []
    
    

    
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
        NSNotificationCenter.defaultCenter().postNotificationName(PDFViewPageChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pageChangedAfterScroll), name: PDFViewPageChangedNotification, object: nil)
        
        for i in 1...10 {
            self.notes.append(Note(name: "\(i * i)"))
        }
        self.tableView.setDataSource(self)
        self.tableView.reloadData()
        
    }
    // update view, set current pdf to certain page, and update current page info
    func pageChangedAfterScroll() {
        if let page = self.pdfView.currentPage() {
            self.pdfSet!.setPage(page)
        }
    }
    
    // MARK: - PDFSetDelegate
    func pdfInfoNeedChangeTo(nthPDF: Int, totalPDFs: Int, title: String, page: Int) {
        self.window?.title = "\(nthPDF)/\(totalPDFs)_" + title
        self.currentPageDisplay.stringValue = "\(page)"
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.notes.count
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return self.notes[row].name
    }
}
