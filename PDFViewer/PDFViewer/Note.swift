//
//  PDFNote.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/29/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Foundation

class Note: NSObject {
    var title: String
    var content: String
    var parent: Note?
    var subnotes: Array<Note> = []
    var indexAmongSiblings: Int
    var depth: Int {
        if let parent = self.parent {
            return parent.depth
        } else {
            return 0
        }
    }
    
    init(title: String, content: String, index: Int) {
        self.title = title
        self.content = content
        self.indexAmongSiblings = index
    }
    
    override var hashValue: Int {
        get {
            return (title + content).hashValue
        }
    }
    
    override var description: String {
        return title + ": " + content
    }
}