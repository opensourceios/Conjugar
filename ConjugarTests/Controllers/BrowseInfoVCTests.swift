//
//  BrowseInfoVCTests.swift
//  ConjugarTests
//
//  Created by Joshua Adams on 9/2/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import XCTest
@testable import Conjugar

class BrowseInfoVCTests: XCTestCase {
  func testBrowseInfoVC() {
    let bivc = BrowseInfoVC()
    let nc = MockNavigationC(rootViewController: bivc)
    UIApplication.shared.keyWindow?.rootViewController = nc
    XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController)
    XCTAssertNotNil(bivc)
    XCTAssertEqual(bivc.tableView(UITableView(), numberOfRowsInSection: 0), 27)
    bivc.browseInfoView.difficultyControl.selectedSegmentIndex = 0
    XCTAssertEqual(bivc.tableView(UITableView(), numberOfRowsInSection: 0), 8)
    bivc.browseInfoView.difficultyControl.selectedSegmentIndex = 1
    XCTAssertEqual(bivc.tableView(UITableView(), numberOfRowsInSection: 0), 16)
    bivc.tableView(UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0))
    XCTAssertTrue(nc.pushedViewController is InfoVC)
  }
}

