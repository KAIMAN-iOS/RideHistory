//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import CoreLocation
import NSAttributedStringBuilder
import ATAConfiguration
import Ampersand
import ATACommonObjects

extension PendingPaymentRideData {    
    func attributedString(textColor: UIColor = RideHistoryTabController.conf.palette.mainTexts) -> NSAttributedString {
        guard let value = value else {
            return NSAttributedString {
                AText("-")
                    .foregroundColor(textColor)
                    .font(.applicationFont(ofSize: 18, weight: .semibold))
            }
        }
        let hasDigits = value - Double(Int(value)) > 0
        var format = "%d"
        switch (type, hasDigits) {
        case (.time, _): format = "%d"
        case (.amount, let hasDigits): format = hasDigits ? "%0.2f" : "%d"
        case (.distance, let hasDigits): format = hasDigits ? "%0.1f" : "%d"
        }
        
        return NSAttributedString {
            AText(String(format: format, (hasDigits ? value : Int(value))))
                .foregroundColor(textColor)
                .font(.applicationFont(ofSize: 18, weight: .semibold))
            
            AText(unit ?? type.defaultUnit)
                .foregroundColor(textColor)
                .font(.applicationFont(ofSize: 12, weight: .semibold))
                .baselineOffset(6)
            
        }
    }
}
