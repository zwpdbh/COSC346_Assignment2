//
//  PDFNote.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/29/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Foundation

class Note: NSObject {
    var name: String
    var value: String
    
    var subnotes: Array<Note> = []
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    override var hashValue: Int {
        get {
            return (name + value).hashValue
        }
    }
    
    override var description: String {
        return name + ": " + value
    }
}