//
//  EpisodeFilenameView.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 2/5/21.
//

import Cocoa
import LoadedNibView

protocol EpisodeFilenameViewDelegate {
    func viewInFinder(atIndex: Int)
    func remove(atIndex: Int)
}
//NSTableCellView
class EpisodeFilenameView: NSView, LoadedNibView {
    var view: NSView?
    var index: Int?
    var delegate: EpisodeFilenameViewDelegate?
    
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var subTitle: NSTextField!
    @IBOutlet weak var statusButton: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    // MARK: - Init
    required override init(frame: NSRect) {
        super.init(frame: frame)
        _ = load()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _ = load()
    }
    
    @IBAction func viewInFinderButtonPressed(_ sender: NSButton) {
        if let index = self.index {
            delegate?.viewInFinder(atIndex: index)
        }
    }
    
    @IBAction func removeButtonPressed(_ sender: NSButton) {
        if let index = self.index {
            delegate?.remove(atIndex: index)
        }
    }
    
    
}
