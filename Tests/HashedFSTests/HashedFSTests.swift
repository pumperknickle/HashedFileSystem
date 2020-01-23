import XCTest
import Regenerate
@testable import HashedFS

final class HashedFSTests: XCTestCase {
    func testExample() {
        let emptyHFS = HashedFS256.empty()
        let rootDirectory = "jbao"
        let childDirectory = "Documents"
        let fileName = "File.txt"
        let fileContents = "Hello World"
        let mkdir = emptyHFS.makeDirectory([rootDirectory, childDirectory])!
        XCTAssert(mkdir.listDirectories([rootDirectory]) != nil)
        XCTAssert(mkdir.listDirectories([rootDirectory])!.contains(childDirectory))
        let fileCreated = mkdir.createFile([rootDirectory, childDirectory, fileName], contents: fileContents)
        XCTAssert(fileCreated != nil)
        XCTAssert(fileCreated!.listFiles([rootDirectory, childDirectory]) != nil)
        XCTAssert(fileCreated!.listFiles([rootDirectory, childDirectory])!.contains(fileName))
        XCTAssert(fileCreated!.getFile([rootDirectory, childDirectory, fileName]) == fileContents)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
