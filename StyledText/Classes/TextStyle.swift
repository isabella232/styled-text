import Foundation

public protocol TextStyleDefaultsGenerator {
    static func defaultKern(for font: UIFont) -> CGFloat?
}

public struct TextStyle {
    public static var defaultsGenerator: TextStyleDefaultsGenerator.Type?

    private static func autosetDefaultsGeneratorIfPossible() {
        guard defaultsGenerator == nil else { return }
        // If the client app has extended this type to provide defaults, we can automatically use them [RH]
        guard let generator = self as? TextStyleDefaultsGenerator.Type else { return }  // This causes an expected warning that tragically can't be supressed yet [RH]
        defaultsGenerator = generator
    }

    // A default style to only be used in the absence of a specified style
    public static var unspecified = TextStyle(font: .systemFont(ofSize: 11), color: .black)

    public let font: UIFont
    public let color: UIColor
    public let lineSpacing: CGFloat?
    public let lineHeightMultiple: CGFloat?
    public let kern: CGFloat?
    public let alignment: NSTextAlignment?
    public let lineBreakMode: NSLineBreakMode?

    public init(font: UIFont,
                color: UIColor,
                lineSpacing: CGFloat? = nil,
                lineHeightMultiple: CGFloat? = nil,
                kern: CGFloat? = nil,
                alignment: NSTextAlignment? = nil,
                lineBreakMode: NSLineBreakMode? = nil) {
        TextStyle.autosetDefaultsGeneratorIfPossible()

        self.font = font
        self.color = color
        self.lineSpacing = lineSpacing
        self.lineHeightMultiple = lineHeightMultiple

        if kern == nil,
            let defaultKern = TextStyle.defaultsGenerator?.defaultKern(for: font) {
            self.kern = defaultKern
        } else {
            self.kern = kern
        }

        self.alignment = alignment
        self.lineBreakMode = lineBreakMode
    }

    public var attributes: [String: Any] {
        var attributes: [String: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.setParagraphStyle(.default)

        attributes[NSFontAttributeName] = font
        attributes[NSForegroundColorAttributeName] = color

        if let lineSpacing = lineSpacing { paragraphStyle.lineSpacing = lineSpacing }
        if let lineHeightMultiple = lineHeightMultiple {
            let adjustedLineHeightMultiple = lineHeightMultiple * (font.pointSize / font.lineHeight)
            paragraphStyle.lineHeightMultiple = adjustedLineHeightMultiple
        }
        if let kern = kern { attributes[NSKernAttributeName] = kern }
        if let alignment = alignment { paragraphStyle.alignment = alignment }
        if let lineBreakMode = lineBreakMode { paragraphStyle.lineBreakMode = lineBreakMode }

        attributes[NSParagraphStyleAttributeName] = paragraphStyle

        return attributes
    }

    public func with(size: CGFloat? = nil,
                     color: UIColor? = nil,
                     alignment: NSTextAlignment? = nil,
                     lineBreakMode: NSLineBreakMode? = nil) -> TextStyle {
        let newFont: UIFont
        if let size = size {
            newFont = font.withSize(size)
        } else {
            newFont = font
        }

        return TextStyle(font: newFont,
                         color: color ?? self.color,
                         lineSpacing: lineSpacing,
                         lineHeightMultiple: lineHeightMultiple,
                         kern: kern,
                         alignment: alignment ?? self.alignment,
                         lineBreakMode: lineBreakMode ?? self.lineBreakMode)
    }

    public func with(font newFont: UIFont) -> TextStyle {
        return TextStyle(font: newFont,
                         color: color,
                         lineSpacing: lineSpacing,
                         lineHeightMultiple: lineHeightMultiple,
                         kern: kern,
                         alignment: alignment,
                         lineBreakMode: lineBreakMode)
    }
}