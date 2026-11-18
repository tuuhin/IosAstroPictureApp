import SwiftUI

private extension String {
    /// Converts an HTML string into an `AttributedString`, preserving inline styles and links.
    /// Falls back to plain text when parsing fails.
    var htmlToAttributedString: AttributedString {
        guard let data = data(using: .utf8) else {
            return AttributedString(self)
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]

        // NSAttributedString HTML parsing MUST happen on the main thread
        var nsAttributedString: NSAttributedString? = nil
        if Thread.isMainThread {
            nsAttributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        } else {
            DispatchQueue.main.sync {
                nsAttributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
            }
        }

        if let nsAttr = nsAttributedString,
           let attributedString = try? AttributedString(nsAttr, including: \.uiKit)
        {
            return attributedString
        }

        return AttributedString(self)
    }

    /// Strips HTML tags and entities, returning a plain-text string.
    var strippingHTML: String {
        String(htmlToAttributedString.characters)
    }
}

extension AstroPictureModel {
    var htmlToAttributedString: AttributedString {
        description.htmlToAttributedString
    }

    var plainCredit: String? {
        credit?.strippingHTML
    }

    var plainCopyright: String? {
        copyRight?.strippingHTML
    }
}
