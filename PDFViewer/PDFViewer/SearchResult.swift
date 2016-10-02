//
//  SearchResult.swift
//  PDFViewer
//
//  Created by zwpdbh on 10/2/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz

class SearchResult: NSObject {
    let title: String
    let page = "" // dummy data for outlineView's second column
    
    var resultItems = Array<PDFSelection>()
    
    init(title: String) {
        self.title = title
    }
    
    func addSearchResultItem(selection: PDFSelection) {
        self.resultItems.append(selection)
    }
}

class ResultItem: NSObject {
    var page: Int
    var key: String
    var occurence: Int = 0
    weak var parent: SearchResult?
    
    init(page: Int, key: String, parent: SearchResult) {
        self.key = key
        self.page = page
        self.parent = parent
    }
}
