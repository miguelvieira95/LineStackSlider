import UIKit
import Combine

final public class LineStackSliderView: UIView {
    @IBInspectable private var minValue: Double = 0
    @IBInspectable private var maxValue: Double = 1
    @IBInspectable private var numberOfLines: Int = 10
    @IBInspectable private var initialValue: Double = 0.5
    @IBInspectable private var lineColor: UIColor = .black
    private var currentValueSubject: CurrentValueSubject<Double, Never> = .init(0)
    private var lines = [UIView]()
    private var subscriptions = Set<AnyCancellable>()
    public private(set) lazy var currentValuePublisher: AnyPublisher<Double, Never> = currentValueSubject.eraseToAnyPublisher()
    
    public var currentValue: Double {
        currentValueSubject.value
    }
    public var onValueChanged: ((Double) -> Void)?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()

    public init(onValueChanged: ((Double) -> Void)?,
                minValue: Double,
                maxValue: Double,
                initialValue: Double = 0,
                numberOfLines: Int = 100,
                lineColor: UIColor = .black) {
        self.onValueChanged = onValueChanged
        self.maxValue = maxValue
        self.minValue = minValue
        self.numberOfLines = numberOfLines
        self.initialValue = initialValue
        self.currentValueSubject.send(initialValue)
        self.lineColor = lineColor
        
        super.init(frame: .zero)

        setupUI()
        setupSubscriptions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.currentValueSubject.send(initialValue)
        setupUI()
        setupSubscriptions()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        stackView.spacing = 1.0 / CGFloat(numberOfLines) / 2 * stackView.bounds.width
    }
    
    private func setupSubscriptions() {
        currentValueSubject
            .sink { [weak self] value in self?.onValueChanged?(value) }
            .store(in: &subscriptions)

        currentValueSubject.sink { [weak self] currentValue in
            guard let self = self else {
                return
            }
            UIView.animate(withDuration: 0.2) {
                self.lines.forEach { $0.transform = .identity }

                self.lines[safe: Int(currentValue) * self.numberOfLines / Int(self.maxValue) - 1]?.transform = CGAffineTransform.init(scaleX: 1.6, y: 1.6)
                
                self.lines[safe: Int(currentValue) * self.numberOfLines / Int(self.maxValue) - 2]?.transform = CGAffineTransform.init(scaleX: 1.35, y: 1.35)
                self.lines[safe: Int(currentValue) * self.numberOfLines / Int(self.maxValue)]?.transform = CGAffineTransform.init(scaleX: 1.35, y: 1.35)
                
                self.lines[safe: Int(currentValue) * self.numberOfLines / Int(self.maxValue) - 3]?.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                self.lines[safe: Int(currentValue) * self.numberOfLines / Int(self.maxValue) + 1]?.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            }
        }
        .store(in: &subscriptions)
    }
    
    private func setupUI() {
        var constraints = [NSLayoutConstraint]()
        
        addSubview(stackView)
        
        constraints.append(contentsOf: [
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
                
        (0..<numberOfLines).forEach { _ in
            let line = UIView()
            line.backgroundColor = lineColor
            line.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                line.heightAnchor.constraint(equalTo: stackView.heightAnchor),
                line.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0 / CGFloat(numberOfLines) / 2)
            ])
            
            lines.append(line)
            stackView.addArrangedSubview(line)
        }
        
        NSLayoutConstraint.activate(constraints)
        
        setNeedsLayout()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            super.touchesBegan(touches, with: event)
            return
        }
        
        handle(touch)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            super.touchesBegan(touches, with: event)
            return
        }
        
        handle(touch)
    }
    
    private func handle(_ touch: UITouch) {
        let touchLocation = touch.location(in: self)
        
        let clampedValue = CGFloat.minimum(maxValue, CGFloat.maximum(minValue, touchLocation.x * maxValue / bounds.width))
        currentValueSubject.send(clampedValue)
    }
}
