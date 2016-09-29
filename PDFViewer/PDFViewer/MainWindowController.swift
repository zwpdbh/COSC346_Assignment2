//
//  MainWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/28/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz


class MainWindowController: NSWindowController, PDFViewerDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate {

    // MARK: - Outlet
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
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
                    self.outlineView.setDataSource(self)
                    self.notes = Note(title: "My Note")
                    for i in 1...10 {
                        self.notes?.subNote.append(Note(title: "note\(i)"))
                    }
                    self.outlineView.reloadItem(self.notes)
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
    
    var notes: Note? = Note(title: "Default Note")
    
    

    
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
    
    // MARK: - NSOutlineViewDataSource
    
    /**
     If you are using conventional data sources for content you must implement the basic methods that provide the outline view with data: outlineView:child:ofItem:, outlineView:isItemExpandable:, outlineView:numberOfChildrenOfItem:, and outlineView:objectValueForTableColumn:byItem:.
     */
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        print("1")
        if let notes = self.notes {
            return notes.subNote.count
        } else {
            print("datasource for outline is not found!")
            return 0
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        print(2)
        if let notes = self.notes {
            return notes.isItemExpandable()
        } else {
            return false
        }
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        print(3)
        if let childNote = self.notes?.childNoteAtIndex(index) {
            return childNote
        } else {
            return self.notes!
        }
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        print(4)
        if let notes = self.notes {
            return notes.title
        } else {
            return nil
        }
    }
}
