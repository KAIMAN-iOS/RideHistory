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

public protocol AddressReprensentable {
    var addressCoordinates: CLLocationCoordinate2D { get }
    var displayAddress: String { get }
}

public protocol OptionsReprensentable {
    var numberOfPassengers: Int { get }
    var numberOfLuggages: Int { get }
    var vehicleTypeDisplay: String { get }
}

public protocol RideHistoryModelable {
    var id: Int { get }
    var startLocation: AddressReprensentable { get }
    var endLocation: AddressReprensentable? { get }
    var pickUpLocation: AddressReprensentable? { get }
    var priceDisplay: String? { get }
    var vat: Double? { get }
    var startDate: Date { get }
    var isImmediate: Bool { get }
    var originDisplay: String { get }
    var rideType: RideHistoryType { get }
    var cancellationReason: String? { get }
    var rideOptions: OptionsReprensentable { get }
    var rideStats: [RideStatsModelable] { get }
    var plate: String? { get }
    var username: String { get }
    var userIconURL: String? { get }
}

public enum RideStat: Int, Codable {
    case amount = 0, distance, time
    
    var title: String {
        switch self {
        case .amount: return "amount stat".bundleLocale()
        case .distance: return "distance stat".bundleLocale()
        case .time: return "time stat".bundleLocale()
        }
    }
}

public protocol RideStatsModelable {
    var value: Double { get }
    var additionnalValue: Double? { get } // used for VAT
    var unit: String { get }
    var statType: RideStat { get }
    
}

extension RideStatsModelable {    
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
