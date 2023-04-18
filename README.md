# SemiCircleChart

`Swift5.7+` `iOS13+`

## Demo

https://user-images.githubusercontent.com/114917347/232467287-2a38cccc-2a5e-4412-a913-aafc7890250b.mov


```swift
import UIKit
import SemiCircleChart

class ViewController: UIViewController {
    
    let data: [(name: String, value: Double)] = [
        ("Dog", 30), ("Cat", 25), ("Fish", 20), ("Bird", 15), ("Rabbit", 10)
    ]
    let colors: [UIColor] = [.red, .orange, .yellow, .green, .cyan]
    
    let chart: SemiCircleChart = {
        let chart = SemiCircleChart()
        
        chart.configuration =  SemiCircleChart.Configuration(
            holeSizeMultiplier: 0.5,
            spacing: 4,
            highlightExpansionSize: 8,
            horizontalInset: 16,
            impactFeedbackEnabled: false
        )
        
        chart.backgroundColor = .black
        chart.holeColor = .purple
        
        return chart
    }()
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(chart)
        view.addSubview(label)
        
        chart.frame.size.width = view.bounds.width * 0.75
        chart.frame.size.height = chart.bounds.width
        chart.center = view.center
        
        label.text = "Unhighlighted"
        label.sizeToFit()
        label.frame.origin = .init(
            x: chart.frame.minX, y: chart.frame.minY - label.bounds.height - 4
        )
        
        chart.setHighlightedIndexDidChangeHandler { [weak self] index in
            guard let self else { return }
            
            self.label.text = {
                if let index {
                    return "\(index) - \(self.data[index].name)"
                } else {
                    return "Unhighlighted"
                }
            }()
        }
        
        let items: [SemiCircleChart.Item] = zip(data, colors)
            .map { data, color in
                SemiCircleChart.Item(
                    value: data.value,
                    color: color
                )
            }
        
        chart.draw(items)
    }
}
```
