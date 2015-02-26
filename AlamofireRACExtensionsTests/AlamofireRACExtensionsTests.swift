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

private struct Dummy {
    static let JSONRequest = NSURLRequest(URL: NSURL(string: "http://test.com/test.json")!)
    static let JSONPath = NSBundle(forClass: AlamofireRACExtensionsTests.self).pathForResource("test", ofType: "json")!
    static let PropertyListRequest = NSURLRequest(URL: NSURL(string: "http://test.com/test.plist")!)
    static let PropertyListPath = NSBundle(forClass: AlamofireRACExtensionsTests.self).pathForResource("test", ofType: "plist")!
}

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
        OHHTTPStubs.stubRequestsPassingTest({ $0 == Dummy.JSONRequest }) { _ in
            OHHTTPStubsResponse(data: nil, statusCode: 403, headers: nil)
        }
        let expectation = expectationWithDescription("Request should error")
        stubbedManager().rac_request(Dummy.JSONRequest, serializer: Alamofire.Request.responseDataSerializer())
            .start(error: { error in
                XCTAssertNotNil(error)
                expectation.fulfill()
            })
        waitForExpectationsWithTimeout(1, handler: { _ in })
    }
    
    func testSerializesValidResponse() {
        OHHTTPStubs.stubRequestsPassingTest({ $0 == Dummy.JSONRequest }) { _ in
            OHHTTPStubsResponse(fileAtPath: Dummy.JSONPath, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        let expectation = expectationWithDescription("Response should be serialized using a custom serializer")
        stubbedManager().rac_request(Dummy.JSONRequest) { (_, _, data) in
            XCTAssertNotNil(data)
            return (NSString(data: data!, encoding: NSUTF8StringEncoding), nil)
        }
        .start(next: { (string, response) in
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(string as String, String(contentsOfFile: Dummy.JSONPath, encoding: NSUTF8StringEncoding, error: nil)!)
        }, error: { error in
            XCTFail("Request failed with error \(error)")
        }, completed: {
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(1, handler: { _ in })
    }
    
    func testRequestData() {
        OHHTTPStubs.stubRequestsPassingTest({ $0 == Dummy.JSONRequest }) { _ in
            OHHTTPStubsResponse(fileAtPath: Dummy.JSONPath, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        let expectation = expectationWithDescription("Response object should be data")
        stubbedManager().rac_dataWithRequest(Dummy.JSONRequest)
            .start(next: { (data, response) in
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(data, NSData(contentsOfFile: Dummy.JSONPath)!)
            }, error: { error in
                XCTFail("Request failed with error \(error)")
            }, completed: {
                expectation.fulfill()
            })
        waitForExpectationsWithTimeout(1, handler: { _ in })
    }
    
    func testRequestJSON() {
        OHHTTPStubs.stubRequestsPassingTest({ $0 == Dummy.JSONRequest }) { _ in
            OHHTTPStubsResponse(fileAtPath: Dummy.JSONPath, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
        let expectation = expectationWithDescription("Response object should be a JSON dictionary")
        stubbedManager().rac_JSONWithRequest(Dummy.JSONRequest)
            .start(next: { (object, response) in
                XCTAssertEqual(response.statusCode, 200)
                if let dictionary = object as? [String: AnyObject] {
                    XCTAssertEqual(dictionary["key"] as String, "value")
                } else {
                    XCTFail("JSON object is not a dictionary")
                }
            }, error: { error in
                XCTFail("Request failed with error \(error)")
            }, completed: {
                expectation.fulfill()
            })
        waitForExpectationsWithTimeout(1, handler: { _ in })
    }
    
    func testRequestPropertyList() {
        OHHTTPStubs.stubRequestsPassingTest({ $0 == Dummy.PropertyListRequest }) { _ in
            OHHTTPStubsResponse(fileAtPath: Dummy.PropertyListPath, statusCode: 200, headers: ["Content-Type": "application/xml"])
        }
        let expectation = expectationWithDescription("Response object should be a property list dictionary")
        stubbedManager().rac_propertyListWithRequest(Dummy.PropertyListRequest)
            .start(next: { (object, response) in
                XCTAssertEqual(response.statusCode, 200)
                if let dictionary = object as? [String: AnyObject] {
                    XCTAssertEqual(dictionary["key"] as String, "value")
                } else {
                    XCTFail("Property list object is not a dictionary")
                }
            }, error: { error in
                XCTFail("Request failed with error \(error)")
            }, completed: {
                expectation.fulfill()
            })
        waitForExpectationsWithTimeout(1, handler: { _ in })
    }
}
