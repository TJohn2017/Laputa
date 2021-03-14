//
//  LaputaTests.swift
//  LaputaTests
//
//  Created by Tyler Johnson on 2/2/21.
//

import XCTest
@testable import Laputa

class LaputaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // BEGIN -- SSH Connection Tests. TODO TJ refactor into separate testing file?
    
    // TODO TJ Actually write this like a unit test. Assert things
    func testSimpleConnection() throws {
//        let connection = SSHConnection(host: "myth.stanford.edu", andUsername: "tjohn21")
//        do {
//            try connection.connect(withAuth: true, password: "") // Write in your password to test
//            let result = connection.executeCommand(command: "ls")
//            print(result)
//            connection.disconnect()
//        } catch SSHSessionError.authorizationFailed {
//            print("Authorization failed")
//        }
    }
    
    // END -- SSH Connection Tests.

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
