import SwiftUI

extension String {
    /// Converts an HTML string into an `AttributedString`, preserving inline styles and links.
    /// Falls back to plain text when parsing fails.
    fileprivate var htmlToAttributedString: AttributedString {
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
            nsAttributedString = try? NSAttributedString(
                data: data, options: options, documentAttributes: nil)
        }
        else {
            DispatchQueue.main.sync {
                nsAttributedString = try? NSAttributedString(
                    data: data, options: options, documentAttributes: nil)
            }
        }

        if let nsAttr = nsAttributedString,
            let attributedString = try? AttributedString(nsAttr, including: \.uiKit)
        {
            return attributedString
        }

        return AttributedString(self)
    }

    /// Strips HTML tags and common entities, returning a plain-text string.
    ///
    /// Deliberately avoids `NSAttributedString`'s HTML parsing — that path is
    /// main-thread-only, spins the run loop and is reentrant, so calling it
    /// while SwiftUI evaluates a view corrupts the layout (the screen renders
    /// blank). A plain character scan is safe anywhere.
    fileprivate var strippingHTML: String {
        var output = ""
        output.reserveCapacity(count)
        var insideTag = false

        for character in self {
            switch character {
            case "<":
                insideTag = true
            case ">":
                insideTag = false
            default:
                if !insideTag { output.append(character) }
            }
        }

        return
            output
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String {
    /// HTML description prepared for the detail screen: white body text with
    /// links underlined so they read as tappable buttons.
    var htmlDetailDescription: AttributedString {
        htmlToAttributedString.detailStyled
    }

    /// Plain-text description prepared the same way. The search API returns
    /// plain descriptions, but they are still tag-stripped in case one carries
    /// stray markup.
    var plainDetailDescription: AttributedString {
        AttributedString(strippingHTML).detailStyled
    }
}

extension AttributedString {
    fileprivate var detailStyled: AttributedString {
        var attributed = self
        let linkRanges = attributed.runs.compactMap { run in
            run.link != nil ? run.range : nil
        }

        attributed.foregroundColor = .white
        for range in linkRanges {
            attributed[range].underlineStyle = .single
        }
        return attributed
    }
}

extension AstroPictureModel {
    var htmlToAttributedString: AttributedString {
        description.htmlToAttributedString
    }

    /// The HTML description prepared for the detail screen: the body text is
    /// forced to white and any links are underlined so they read as tappable
    /// buttons rather than default blue links.
    var detailDescription: AttributedString {
        description.htmlDetailDescription
    }

    var plainCredit: String? {
        credit?.strippingHTML
    }

    var plainCopyright: String? {
        copyRight?.strippingHTML
    }
}
