//
//  XCTestCase+MemoryLeak.swift
//
//
//  Created by Chung Han Hsin on 2024/1/23.
//

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString=#file, line: UInt=#line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Protential memory leak.", file: file, line: line)
        }
    }
}
