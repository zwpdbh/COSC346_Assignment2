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
    
    var filePath: String?
    
    var pdfDoc: PDFDocument?
    
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

    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

