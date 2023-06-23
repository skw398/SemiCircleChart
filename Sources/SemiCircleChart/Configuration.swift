import UIKit

public extension SemiCircleChart {
    
    struct Configuration {
        var holeSizeMultiplier: CGFloat
        var spacing: CGFloat
        var highlightExpansionSize: CGFloat
        var horizontalInset: CGFloat
        var impactFeedbackEnabled: Bool
        
        public init(
            holeSizeMultiplier: CGFloat,
            spacing: CGFloat,
            highlightExpansionSize: CGFloat,
            horizontalInset: CGFloat,
            impactFeedbackEnabled: Bool
        ) {
            self.holeSizeMultiplier = holeSizeMultiplier
            self.spacing = spacing
            self.highlightExpansionSize = highlightExpansionSize
            self.horizontalInset = horizontalInset
            self.impactFeedbackEnabled = impactFeedbackEnabled
        }
        
        public static let `default`: Self = .init(
            holeSizeMultiplier: 0.5,
            spacing: 4,
            highlightExpansionSize: 16,
            horizontalInset: 32,
            impactFeedbackEnabled: true
        )
    }
}
