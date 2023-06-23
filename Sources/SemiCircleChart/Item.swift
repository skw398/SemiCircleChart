import UIKit

public extension SemiCircleChart {
    
    struct Item {
        let value: Double
        let color: UIColor
        
        public init(value: Double, color: UIColor) {
            self.value = value
            self.color = color
        }
    }
}
