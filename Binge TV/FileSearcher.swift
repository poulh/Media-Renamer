//
//  FileSearcher.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 2/2/21.
//

import Foundation

extension String {
    func firstRegexMatch(inRegexArray regexes:[String]) -> String? {
        for regex in regexes {
            if( self.range(of: regex, options:.regularExpression) != nil ) {
                return regex
            }
        }
        return nil
    }
}

protocol FileSearcherDelegate {
    func onsearchBegin( rootUrl: URL)
    func onsearchEnd( rootUrl: URL )
    func onFileFound( rootUrl: URL, result: URL, pattern: String)
}

class FileSearcher {
   
    var delegate: FileSearcherDelegate?
    
    func search(at rootUrl:URL, withRegexFilters filters:[String]) {
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: rootUrl, includingPropertiesForKeys: [URLResourceKey.isRegularFileKey])
        

        
        DispatchQueue.global(qos: .userInteractive).async {
            self.delegate?.onsearchBegin(rootUrl: rootUrl)
            while let path = enumerator?.nextObject() as? URL {
                if let matchedRegex = path.lastPathComponent.firstRegexMatch(inRegexArray: filters) {
                    self.delegate?.onFileFound(rootUrl: rootUrl, result: path, pattern: matchedRegex)
                }
            }
            self.delegate?.onsearchEnd(rootUrl: rootUrl)
        }
    }
    
    
}
