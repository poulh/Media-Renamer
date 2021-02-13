//
//  ViewController.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 2/1/21.
//

import Cocoa

class ViewController: NSViewController {

    var searchFolder : URL? = nil
    @IBOutlet weak var searchDirectoryLabel: NSTextField!
    @IBOutlet weak var chooseSearchDirectoryButton: NSButton!
    
    @IBOutlet weak var subtitleResutsCheckbox: NSButton!
    @IBOutlet weak var videoResultsCheckbox: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    var renameTargetFolder : URL? = nil
    @IBOutlet weak var destinationDirectoryLabel: NSTextField!
    @IBOutlet weak var chooseDestinationDirectoryButton: NSButton!
    @IBOutlet weak var addSeriesFolderCheckbox: NSButton!
    @IBOutlet weak var addSeasonFolderCheckbox: NSButton!
    
    @IBOutlet weak var moveParentFolderToTrashCheckbox: NSButton!
    @IBOutlet weak var includeYearInSeriesCheckbox: NSButton!
    @IBOutlet weak var renameButton: NSButton!
    
    let kSearchPathID = NSUserInterfaceItemIdentifier(rawValue: "SearchPathID")
    let kDestPathID = NSUserInterfaceItemIdentifier(rawValue: "DestPathID")
    
    let kZeroPaddingCount = 2
   
    var needsNewSearch: Bool = true
    
    var episodes : [Episode] = [
        
    ]
    
    let fileSearcher = FileSearcher()
    let episodeParser = EpisodeFilenameParser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        fileSearcher.delegate = self
        
        chooseSearchDirectoryButton.identifier = kSearchPathID
        chooseDestinationDirectoryButton.identifier = kDestPathID
        
        DispatchQueue.main.async {
            self.chooseSearchDirectoryButton.performClick(self.chooseSearchDirectoryButton)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func refreshUI() {
        searchDirectoryLabel.stringValue = searchFolder?.path ?? ""
        destinationDirectoryLabel.stringValue = renameTargetFolder?.path ?? ""
        
        if needsNewSearch {
            if let searchUrl = searchFolder {
                fileSearcher.search(at: searchUrl, withRegexFilters: self.episodeParser.filters)
            }
        } else {
            tableView.reloadData()
        }
        
        renameButton.isEnabled = (renameTargetFolder != nil)
    }

    // todo: ask permission and save : https://benscheirman.com/2019/10/troubleshooting-appkit-file-permissions/
    @IBAction func chooseSourceDirectoryButtonPressed(_ sender: NSButton) {
        let dialog = NSOpenPanel();
     
        dialog.title = "Choose a directory";
        
        switch sender.identifier {
        case kSearchPathID:
            dialog.directoryURL = URL(fileURLWithPath: searchDirectoryLabel.stringValue)
        case kDestPathID:
            dialog.directoryURL = URL(fileURLWithPath: searchDirectoryLabel.stringValue)
            dialog.canCreateDirectories = true
        default:
            return
        }
        
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = true;
        dialog.canChooseFiles = false
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let result = dialog.url  {
                switch sender.identifier {
                case kSearchPathID:
                    searchFolder = result
                    needsNewSearch = true
                case kDestPathID:
                    renameTargetFolder = result
                default:
                    print("unknown path")
                    return
                }
                refreshUI()
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func includeSubtitlesInResultsToggled(_ sender: NSButton) {
        needsNewSearch = true
        refreshUI()
    }
    
    @IBAction func includeVideosInResultsToggled(_ sender: NSButton) {
        needsNewSearch = true
        refreshUI()
    }
    
    
    @IBAction func addSeriesDirectoryCheckboxToggled(_ sender: NSButton) {
        refreshUI()
    }
    
    @IBAction func addSeasonDirectoryCheckboxToggled(_ sender: NSButton) {
        refreshUI()
    }
    
    @IBAction func moveParentFolderToTrashCheckboxToggled(_ sender: NSButton) {
    }
    
    @IBAction func includeYearInSeriesRenameCheckboxToggled(_ sender: NSButton) {
        refreshUI()
    }
    
    @IBAction func renameButtonClicked(_ sender: NSButton) {
       // var parentFolders : Set<URL> = []
        
        for episode in episodes {
            let pathComponents = episode.pathComponents(withSeriesFolder: (addSeriesFolderCheckbox.state == .on),
                                                        andSeasonFolder: (addSeasonFolderCheckbox.state == .on),
                                                        includeYearInSeason: (includeYearInSeriesCheckbox.state == .on),
                                                        zeroPaddingCount: kZeroPaddingCount)
            if var targetUrl = renameTargetFolder {
             //  let bundleID = Bundle.main.bundleIdentifier {

              //  targetUrl.appendPathComponent(bundleID)
                for component in pathComponents {
                    targetUrl.appendPathComponent(component)
                }
                let targetParentUrl = targetUrl.deletingLastPathComponent()

              //  parentFolders.insert(episode.original.deletingLastPathComponent())
              //  print(episode.original)
              //  print(targetUrl)
                do {
                    let fileManager = FileManager.default
                    try fileManager.createDirectory(at: targetParentUrl, withIntermediateDirectories: true, attributes: nil)
                    try fileManager.moveItem(at: episode.original, to: targetUrl)
                   // NEED TO ENSURE THIS IS MOVE TO TRASH try fileManager.removeItem(at: movie.parentDir)
                } catch {
                    print(error)
                }
                
               
            }
            
            
//            for parents in parentFolders {
//                print(parents)
//            }
         
        }
        self.needsNewSearch = true
        refreshUI()
    }
}

extension ViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return episodes.count
    }
}

extension ViewController : EpisodeFilenameViewDelegate {
    func viewInFinder(atIndex: Int) {
        let episode = episodes[atIndex]
        
        //reveal in Finder
        NSWorkspace.shared.activateFileViewerSelecting([episode.original])
    }
    
    func remove(atIndex: Int) {
        episodes.remove(at: atIndex)
        DispatchQueue.main.async {

            self.tableView.removeRows(at: IndexSet(integer: atIndex), withAnimation: .slideUp)
            self.tableView.reloadData()
        }
    }
}

extension ViewController : NSTableViewDelegate {
  
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        return false
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EpisodeFilenameViewID"), owner: nil) as?  EpisodeFilenameView {
            
            let episode = episodes[row]

           // var parsedPaths : [String] = []

            
            let pathComponents = episode.pathComponents(withSeriesFolder: (addSeriesFolderCheckbox.state == .on),
                                                        andSeasonFolder: (addSeasonFolderCheckbox.state == .on),
                                                        includeYearInSeason: (includeYearInSeriesCheckbox.state == .on),
                                                        zeroPaddingCount: kZeroPaddingCount)

            cell.title.stringValue = episode.original.lastPathComponent
            
            cell.subTitle.stringValue = pathComponents.joined(separator: "/")
            
            cell.index = row
            cell.delegate = self

            return cell
        }

        return nil
    }
}

extension ViewController : FileSearcherDelegate {
    func onsearchBegin(rootUrl: URL) {
        print("search begin: \(rootUrl)")
        DispatchQueue.main.async {
            self.episodes = []
            self.tableView.reloadData()
        }
    }
    
    func onsearchEnd(rootUrl: URL) {
        print("search end: \(rootUrl)")
    }
    
    func onFileFound(rootUrl: URL, result: URL, pattern: String) {
        
        
        if let episode = episodeParser.parse(at: result) {
            DispatchQueue.main.async {
                let isSubtitle = self.episodeParser.allowedSubtitleTypes.contains(episode.type)
                let isVideo = self.episodeParser.allowedVideoTypes.contains(episode.type)
                let displaySubtitles = self.subtitleResutsCheckbox.state == .on
                let displayVideos = self.videoResultsCheckbox.state == .on
                
                if( (isSubtitle && displaySubtitles) || (isVideo && displayVideos)) {
                    //  print(result)
                    
                    self.episodes.append(episode)
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
}

