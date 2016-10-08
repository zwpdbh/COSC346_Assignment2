//
//  AboutWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 10/4/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    @IBOutlet weak var aboutImageView: NSImageView!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        aboutImageView.image = NSImage(named: "pages-icon")
    }
    
    override var windowNibName: String? {
        return "AboutWindowController"
    }
}
