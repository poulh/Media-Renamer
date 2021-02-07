//
//  EpisodeFileTableCellView.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 2/1/21.
//

import Cocoa

class EpisodeFileTableCellView: NSTableCellView {

    
    @IBOutlet weak var filenameLabel: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var yearLabel: NSTextField!
    @IBOutlet weak var seasonLabel: NSTextField!
    @IBOutlet weak var episodeLabel: NSTextField!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
