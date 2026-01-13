
import XCTest
@testable import DiiaAuthorization

final class RSwiftSimulationTests: XCTestCase {

    func test_R_image() {
        // Arrange
        let imageCases = R.Image.allCases
        
        // Act
        for imageCase in imageCases {
            let generatedImage = imageCase.image
            // Assert
            XCTAssertNotNil(generatedImage, "The image assets for R.image case \(imageCase.name) is missed")
        }
    }
    
    func test_R_Strings() {
        // Arrange
        let stringsCases = R.Strings.allCases
        
        // Act
        for stringsCase in stringsCases {
            let localizedString = stringsCase.localized()
            
            // Assert
            XCTAssertNotEqual(stringsCase.rawValue, localizedString, "The localized string for R.Strings case \(stringsCase.rawValue) is missed")
        }
    }

}
