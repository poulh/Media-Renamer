//
//  Binge_TVTests.swift
//  Binge TVTests
//
//  Created by Poul Hornsleth on 2/1/21.
//

import XCTest
@testable import Binge_TV


class Binge_TVTests: XCTestCase {

    let parser = EpisodeFilenameParser()
    let urlStrings :[String] = [
        "file:///Users/myusername/Downloads/Succession%20Season%201%20Complete%20720p%20WEB%20x264%20%5Bi_c%5D/Succession%20S01E03%20Lifeboats.mkv",
        "file:///Users/myusername/Downloads/The%20Mandalorian%20-%20Season%201%20(2019)%20%5B1080p%5D/The%20Mandalorian%20-%20S01E07%20-%20Chapter%207%20-%20The%20Reckoning.mkv",
        "file:///Users/myusername/Downloads/For%20All%20Mankind%20Season%201%20Complete%20720p%20x264%20%5Bi_c%5D/For%20All%20Mankind%20S01e04%20Prime%20Crew.mkv",
        "file:///Users/myusername/Downloads/Yellowstone.2018.S03E06.720p.WEB.x265-MiNX.mkv",
        "file:///Users/myusername/Downloads/The%20Mandalorian%20-%20Season%201%20(2019)%20%5B1080p%5D/The%20Mandalorian%20-%20S01E08%20-%20Chapter%208%20-%20Redemption.mkv"
    ]
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUrls() throws {
        for urlStr in urlStrings {
            let url = URL(string: urlStr)

            XCTAssertNotNil(url, "Bad URL: \(urlStr)")
        }
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        for urlStr in urlStrings {
            if let url = URL(string: urlStr) {
                let episode = parser.parse(at: url)
                XCTAssertNotNil(episode, "Bad URL: \(url)")
            }
        }
       // XCTAssertNil(5)
      //  parser.parse(at: URL() )
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
