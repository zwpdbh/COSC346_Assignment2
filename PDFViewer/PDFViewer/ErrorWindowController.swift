//
//  ErrorWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 05/10/2016.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa

class ErrorWindowController: NSWindowController {

    @IBOutlet weak var errorMessageLabel: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override var windowNibName: String? {
        return "ErrorWindowController"
    }
    
    func updateError(error: String) {
        self.errorMessageLabel.stringValue = error
    }
    
}
