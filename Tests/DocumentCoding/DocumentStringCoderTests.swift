import XCTest
import SoraCrypto

class DocumentStringCoderTests: XCTestCase {
    func testDateAndTimeEncodingDecoding() throws {
        // given

        let expectedDateString = "2020-07-24T03:37:37Z"

        let coder = DocumentStringCoder()

        // when

        let date = try coder.decodeDate(expectedDateString)
        let dateString = try coder.encode(date)

        // then

        XCTAssertEqual(dateString, expectedDateString)
    }
}
