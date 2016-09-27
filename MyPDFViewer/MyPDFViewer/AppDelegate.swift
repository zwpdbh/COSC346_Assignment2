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
    
    
    // MARK: - pdf variable
    
    var pdfSet: PDFSet?
    var pdfDoc: PDFDoc?

    // MARK: - outlet and action
    
    // open file action
    @IBAction func openFile(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true;
        
        panel.beginWithCompletionHandler { (result) in
            if(result == NSFileHandlingPanelOKButton) {
                self.pdfSet = PDFSet(urlSet: panel.URLs)
                self.pdfView.setDocument(self.pdfSet?.getCurrentPDFDoc().getPDFDocument())
            }
        }
    }
    
    // go to previous page
    @IBAction func previousPage(sender: NSButton) {
        self.pdfDoc?.moveToPreviouPage()
        pdfView.goToPreviousPage(sender)
        
        updateView()
    }
    
    
    // go to the next page
    @IBAction func nextPage(sender: NSButton) {
        self.pdfDoc?.moveToNextPage()
        pdfView.goToNextPage(sender)
        updateView()
    }
    
    // go to the Given page
    @IBAction func goToGivenPage(sender: NSTextField) {
        if let pageNumber = Int(sender.stringValue) {
            self.pdfDoc?.moveToPageAt(pageNumber)
            updateView()
        }
    }
    
    
    // if there is not one pdf, then click this can go to previous one
    @IBAction func goToPreviousPDF(sender: NSButton) {

    }
    
    // if there is not one pdf, then click this can to to next one
    @IBAction func goToNextPDF(sender: NSButton) {

    }
    
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var window: NSWindow!

    func updateView() {
        self.currentPageDisplay.stringValue = "\(self.pdfDoc?.getCurrentPage())/\(self.pdfDoc?.getTotalPages()))"
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

