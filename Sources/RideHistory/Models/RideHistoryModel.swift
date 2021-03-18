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
        let hasDigits = value - Double(Int(value)) > 0
        return NSAttributedString {
            AText(String(format: hasDigits ? "%0.2f" : "%d", (hasDigits ? value : Int(value))))
                .foregroundColor(textColor)
                .font(.applicationFont(ofSize: 18, weight: .semibold))
            
            AText(unit)
                .foregroundColor(textColor)
                .font(.applicationFont(ofSize: 12, weight: .semibold))
                .baselineOffset(6)
            
        }
    }
}
