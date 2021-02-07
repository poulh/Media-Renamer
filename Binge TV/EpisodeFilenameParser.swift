//
//  EpisodeFilenameParser.swift
//  Binge TV
//
//  Created by Poul Hornsleth on 2/2/21.
//

import Foundation

extension String {
    
    func matchingRange(fromRegex regex: String ) -> NSRange? {
       // let pattern = ".*(19\\d{2}|20\\d{2}).*"
       // let regex = "(19\\d{2}|20\\d{2})"
       // let pattern = ".*(19\\d{2}|20(?:0\\d|1[0-9])).*"
        guard let regularExpression = try? NSRegularExpression(pattern: regex) else {
            print("bad regex: \(regex)")
            return nil
        }
        let results = regularExpression.matches(in:self, range:NSMakeRange(0, self.count))

        // let kFullStringIdx = 0
        let kMatchIdx = 1
        for result in results {
            
            let match = result.range(at:kMatchIdx)
            return match
        }
        return nil
    }
    
    func substring(fromRange range:NSRange) -> String {
        let startIdx = self.index(self.startIndex, offsetBy: range.location)
        let endIdx = self.index(startIdx,offsetBy: range.length)
        let substr = self[startIdx..<endIdx]
        return String(substr)
    }
    
    func replaceAnyOccurance(of targets: [String], with replacement: String) -> String {
        var rval = self
        for target in targets {
            rval = rval.replacingOccurrences(of: target, with: replacement)
        }
        return rval
    }
  
}
struct  Episode {
    var series : String
    var season : Int
    var episode : Int
    var type : String
    var subtitleLanguage : String?
    var year : Int?
    var original : URL
    
    func parsedSeasonName(withZeroPaddingCount paddingCount: Int) -> String {
        return String(format: "Season %0\(paddingCount)d", season)
    }
    
    func parsedSeriesName(withYear: Bool) -> String {
        var fmtYear :String? = nil
        if withYear {
            if let year = self.year {
                fmtYear = " (\(year))"
            }
        }
        return "\(series)\(fmtYear ?? "")"
    }
    
    func parsedFilename(withYear includeYear: Bool, andZeroPaddingCount paddingCount: Int) -> String {
        let fmtSeasonEpisode = String(format: "S%0\(paddingCount)dE%0\(paddingCount)d", season, episode)
        
        let seriesName = parsedSeriesName(withYear: includeYear)
       
        
        let basename =  "\(seriesName) \(fmtSeasonEpisode)"
        var rval : [String] = [basename]
        if let subtitleLanguage = subtitleLanguage {
            rval.append(subtitleLanguage)
        }
        rval.append(type)
        
        return rval.joined(separator: ".")
    }
    
    func pathComponents(withSeriesFolder includeSeriesFolder: Bool, andSeasonFolder includeSeasonFolder: Bool, includeYearInSeason includeYear: Bool, zeroPaddingCount: Int) -> [String] {
        var rval : [ String ] = []
        if includeSeriesFolder {
            rval.append(self.parsedSeriesName(withYear: includeYear))
        }
        
        if includeSeasonFolder {
            rval.append(self.parsedSeasonName(withZeroPaddingCount: zeroPaddingCount))
        }
        
        rval.append(self.parsedFilename(withYear: includeYear, andZeroPaddingCount: zeroPaddingCount))
//        rval.append(self.parsedSeriesName(withYear: includeYear))

        //parsedPaths.append(episode.parsedSeasonName(withZeroPaddingCount: kZeroPaddingCount))

          //  episode.parsedFilename(withYear: includeYear, andZeroPaddingCount: kZeroPaddingCount)
            //episode.original.lastPathComponent
           // parsedPaths.joined(separator: "/")
        
        return rval
      
    }
//    var parsedNameWithYear : String {
//        let fmtSeasonEpisode = String(format: "S%02dE%02d", season, episode)
//        
//        let fmtYear = year == nil ? "" : "(\(year!)) "
//        return "\(series) \(fmtYear)\(fmtSeasonEpisode).\(type)"
//    }
}

class EpisodeFilenameParser {
    
    let filters = [
        "[sS][0-9]+[eE][0-9]+"
    ]
    
    let allowedSubtitleTypes = ["sub","srt"]
    let allowedVideoTypes : Set = ["mkv","avi","mpeg","mpg","mp4"]
    let yearRegex = "(19\\d{2}|20\\d{2})"
    let seasonEpisodeRegex = "([sS][0-9]+[eE][0-9]+)"
    let seasonRegex = "[sS]([0-9]+)"
    let episodeRegex = "[eE]([0-9]+)"

    let tokensToStrip = [
        ".",
        " - ",
        "(",
        ")"
    ]
    
    func parse(at url: URL ) -> Episode? {
        var original = url

        let type = url.pathExtension
        var languageSubtitle : String? = nil
        if !(allowedVideoTypes + allowedSubtitleTypes).contains(type) {
            return nil
        }
        
        if allowedSubtitleTypes.contains(type) {
            // special subtitle parsing to retain 2nd extension which tells the subtitle's language
            original.deletePathExtension()
            languageSubtitle = original.pathExtension
            original.appendPathExtension(type)
            if (languageSubtitle?.count == 2) || (languageSubtitle?.count == 3) {
                // do nothing, we've detected a language subtitle sub-extension  (.eng.srt)

            } else {
                languageSubtitle = nil
            }
        }
        
        let originalFilename = original.lastPathComponent
        
        let strippedFilename = originalFilename.replaceAnyOccurance(of: tokensToStrip, with: " ")
        
        guard let seasonEpisodeRange = strippedFilename.matchingRange(fromRegex: seasonEpisodeRegex) else {
            print("bad season/episode")
            return nil
        }
        let seasonEpisodeString = strippedFilename.substring(fromRange: seasonEpisodeRange)

        guard let seasonRange = seasonEpisodeString.matchingRange(fromRegex: seasonRegex) else {
            print("bad season from range")
            print(originalFilename)
            print(strippedFilename)
            print(seasonEpisodeString)
            return nil
        }
        guard let episodeRange = seasonEpisodeString.matchingRange(fromRegex: episodeRegex) else {
            print("bad episode from range")
            print(originalFilename)
            print(strippedFilename)
            print(seasonEpisodeString)
            print(url)

            return nil
        }
        
        let seriesRange = NSRange(location: 0, length: seasonEpisodeRange.location)
        var seriesString = strippedFilename.substring(fromRange: seriesRange)
        
        var yearInt : Int? = nil
        if let yearRange = seriesString.matchingRange(fromRegex: yearRegex) {
            let yearString = seriesString.substring(fromRange: yearRange)
            yearInt = Int(yearString)
            seriesString = seriesString.substring(fromRange: NSRange(location: 0, length: yearRange.location))
        }
        
        seriesString = seriesString.trimmingCharacters(in: .whitespaces)
//        if let languageSubtitle = languageSubtitle {
//            original.appendPathExtension(languageSubtitle)
//            original.appendPathExtension(type)
//            seriesString = [seriesString,languageSubtitle,type].joined(separator: ".")
//        } else {
//            original.appendPathExtension(type)
//            seriesString = [seriesString,type].joined(separator: ".")
//        }
        let seasonString = seasonEpisodeString.substring(fromRange: seasonRange)
        let episodeString = seasonEpisodeString.substring(fromRange: episodeRange)
        
        guard let seasonInt = Int(seasonString) else {
            print("bad season: \(seasonString)")
            return nil
        }
        
        guard let episodeInt = Int(episodeString) else {
            print("bad episode: \(episodeString)")
            return nil
        }
        
        return Episode(series: seriesString, season: seasonInt, episode: episodeInt, type: type, subtitleLanguage: languageSubtitle, year: yearInt, original: original)
    }
    
    
}
