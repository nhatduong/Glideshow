//
//  GlideLabel.swift
//  Glideshow
//
//  Created by Visal Rajapakse on 2021-02-28.
//

import UIKit

class GlideLabel: UILabel {
    
    /// Gliding factor deciding speed of the transition of `GlideLabel`
    var glideFactor: CGFloat!
    
    /// Gets estimated height of a GlideLabel based on content
    /// - Parameter withMaxWidth: Maximum allocatable width
    /// - Returns: Maximum occupying height of the GlideLabel text
    // func getHeight(withMaxWidth :CGFloat) -> CGFloat {
    //     self.frame = CGRect(
    //         x: 0,
    //         y: 0,
    //         width: withMaxWidth,
    //         height: CGFloat.greatestFiniteMagnitude)
    //     self.numberOfLines = 0
    //     self.lineBreakMode = NSLineBreakMode.byWordWrapping
    //     self.sizeToFit()
    //     return self.frame.height
    // }
    func getHeight(withMaxWidth: CGFloat) -> CGFloat {
        let label = UILabel()
        label.font = self.font
        label.text = self.text
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = self.textAlignment

        label.frame = CGRect(x: 0, y: 0, width: withMaxWidth, height: .greatestFiniteMagnitude)
        label.sizeToFit()

        return label.frame.height
    }
}
