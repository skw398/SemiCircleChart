import UIKit

public final class SemiCircleChart: UIView {
    public struct Item {
        let value: Double
        let color: UIColor
        
        public init(value: Double, color: UIColor) {
            self.value = value
            self.color = color
        }
    }
    
    public struct Configuration {
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
    
    public var configuration: Configuration = .default {
        didSet {
            if !items.isEmpty { draw(items) }
        }
    }
    
    public var holeColor: UIColor? {
        didSet {
            if !items.isEmpty { draw(items) }
        }
    }
    
    override public var backgroundColor: UIColor? {
        didSet {
            if !items.isEmpty { draw(items) }
        }
    }
    
    private var items: [Item] = [] {
        didSet {
            total = items.reduce(0, { $0 + $1.value })
        }
    }
    
    private var total: Double!

    private var sliceLayers: [CAShapeLayer] = []
    private var holeLayer: CAShapeLayer = .init()
    
    private var circleCenter: CGPoint { .init(
        x: bounds.width / 2,
        y: bounds.height / 2 + bounds.width / 2 / 2 - configuration.horizontalInset / 2
    )}
    private var radius: CGFloat {
        bounds.width / 2 - configuration.horizontalInset + configuration.spacing / 2
    }
        
    public func setHighlightedIndexDidChangeHandler(_ handler: @escaping (_ index: Int?) -> Void) {
        highlightedIndexDidChange = handler
    }
    
    private var highlightedIndexDidChange: ((_ index: Int?) -> Void)?

    private var highlightedIndex: Int? = nil {
        didSet {
            highlightedIndexDidChange?(highlightedIndex)
            if configuration.impactFeedbackEnabled {
                if highlightedIndex != nil {
                    self.impactFeedbackGenerator.impactOccurred(intensity: 0.7)
                }
            }
        }
    }
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    public func draw(_ items: [Item]) {
        sliceLayers = []
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        self.items = items

        var from: CGFloat = .pi

        // Slices
        items.forEach { item in
            let delta = (item.value / total) * .pi

            let path: UIBezierPath = .init()
            path.move(to: circleCenter)
            path.addArc(
                withCenter: circleCenter,
                radius: radius,
                startAngle: from,
                endAngle: from + delta,
                clockwise: true
            )
            from += delta
            path.close()

            let sliceLayer: CAShapeLayer = .init()
            sliceLayer.path = path.cgPath
            sliceLayer.fillColor = item.color.cgColor
            sliceLayer.strokeColor = backgroundColor?.cgColor ?? UIColor.systemBackground.cgColor
            sliceLayer.lineWidth = configuration.spacing

            layer.addSublayer(sliceLayer)

            sliceLayers += [sliceLayer]
        }

        var holeCenter = circleCenter
        holeCenter.y -= configuration.spacing / 2

        // Hole
        let semiCircle: UIBezierPath = .init(
            arcCenter: holeCenter,
            radius: radius * configuration.holeSizeMultiplier,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        let holeLayer: CAShapeLayer = .init()
        holeLayer.path = semiCircle.cgPath

        holeLayer.fillColor = holeColor?.cgColor ?? backgroundColor?.cgColor ?? UIColor.systemBackground.cgColor
        holeLayer.strokeColor = backgroundColor?.cgColor ?? UIColor.systemBackground.cgColor
        holeLayer.lineWidth = configuration.spacing
        layer.addSublayer(holeLayer)
        self.holeLayer = holeLayer
    }

    private func setHighlighting(_ highlighting: Bool, for index: Int) {
        var from: CGFloat = .pi
        items.prefix(index).forEach { from += ($0.value / total) * .pi }

        let delta = (items[index].value / total) * .pi

        let path: UIBezierPath = .init()
        path.move(to: circleCenter)
        path.addArc(
            withCenter: circleCenter,
            radius: highlighting ? radius + configuration.highlightExpansionSize : radius,
            startAngle: from,
            endAngle: from + delta,
            clockwise: true
        )
        path.close()

        let sliceLayer = sliceLayers[index]

        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.07
        animation.fromValue = sliceLayer.path
        animation.toValue = path.cgPath
        sliceLayer.add(animation, forKey: "pathAnimation")
        sliceLayer.path = path.cgPath

        sliceLayers[index] = sliceLayer
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let point = touches.first?.location(in: self) else { return }
        guard let index = sliceLayers.firstIndex(where: { $0.path?.contains(point) ?? false }) else { return }

        if holeLayer.path?.contains(point) == false {
            setHighlighting(true, for: index)
            highlightedIndex = index
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let point = touches.first?.location(in: self) else { return }

        let newIndex = sliceLayers.firstIndex(where: { $0.path?.contains(point) ?? false })

        if holeLayer.path?.contains(point) == true || newIndex == nil {
            if let highlightedIndex {
                setHighlighting(false, for: highlightedIndex)
                self.highlightedIndex = nil
            }
            return
        }

        if let newIndex, highlightedIndex != newIndex {
            if let highlightedIndex { setHighlighting(false, for: highlightedIndex) }
            setHighlighting(true, for: newIndex)
            highlightedIndex = newIndex
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let highlightedIndex else { return }
        setHighlighting(false, for: highlightedIndex)
        self.highlightedIndex = nil
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let highlightedIndex else { return }
        setHighlighting(false, for: highlightedIndex)
        self.highlightedIndex = nil
    }
    
    public init(frame: CGRect = .zero, configuration: Configuration) {
        super.init(frame: frame)
        self.configuration = configuration
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
