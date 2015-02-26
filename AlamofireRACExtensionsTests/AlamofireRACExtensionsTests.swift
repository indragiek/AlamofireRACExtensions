//
//  AlamofireRACExtensionsTests.swift
//  AlamofireRACExtensionsTests
//
//  Created by Indragie on 2/25/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

import Foundation
import XCTest
import OHHTTPStubs
import Alamofire
import ReactiveCocoa
import AlamofireRACExtensions

private let JSONString = "{\"key\": \"value\"}"
private let JSONData = JSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

private func stubbedManager() -> Manager {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    OHHTTPStubs.setEnabled(true, forSessionConfiguration: configuration)
    return Manager(configuration: configuration)
}

class AlamofireRACExtensionsTests: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testSendsErrorOnValidationFailure() {
        let request = NSURLRequest(URL: NSURL(string: "http://test.com")!)
        OHHTTPStubs.stubRequestsPassingTest({ $0 == request }) { _ in
            OHHTTPStubsResponse(data: nil, statusCode: 403, headers: nil)
        }
        let expectation = expectationWithDescription("Request should error")
        stubbedManager().rac_request(request, serializer: Alamofire.Request.responseDataSerializer()).start(error: { error in
            XCTAssertNotNil(error, "There should be an error")
            expectation.fulfill()
        })
    }
}
