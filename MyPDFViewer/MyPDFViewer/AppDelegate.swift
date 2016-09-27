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
    var currentPDFPage: PDFPage?
    var currentPageIndex: Int = 1 {
        didSet {
            currentPageDisplay.stringValue = "\(currentPageIndex)/\(self.totalPageCount)"
        }
    };
    
    var totalPageCount = 0;
    var pdfDoc: PDFDocument? {
        didSet {
            updateWithDocInfo()
        }
    }
    
    
    // MARK: - outlet and action
    @IBAction func openFile(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.beginWithCompletionHandler { (result) in
            if(result == NSFileHandlingPanelOKButton) {
                var docURL: NSURL?
                docURL = panel.URLs[0]
                self.pdfDoc = PDFDocument(URL: docURL)
                self.pdfView.setDocument(self.pdfDoc)
            }
        }
    }
    
    // go to previous page
    @IBAction func previousPage(sender: NSButton) {
       pdfView.goToPreviousPage(sender)
        if currentPageIndex > 1 {
            currentPageIndex -= 1
            print("currentPage go to: \(currentPageIndex)")
        }
    }
    
    
    // go to the next page
    @IBAction func nextPage(sender: NSButton) {
        pdfView.goToNextPage(sender)
        if currentPageIndex < self.totalPageCount {
            currentPageIndex += 1
            print("currentPage go to: \(currentPageIndex)")
        }
    }
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var window: NSWindow!

    func updateWithDocInfo() {
        if let doc = self.pdfDoc {
            currentPDFPage = pdfView.currentPage()
            totalPageCount = doc.pageCount()
            currentPageIndex = 1
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

