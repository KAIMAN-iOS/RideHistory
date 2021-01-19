//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import Foundation
import CoreLocation

public protocol AddressReprensentable {
    var coordinates: CLLocationCoordinate2D { get }
    var displayAddress: String { get }
}

public protocol OptionsReprensentable {
    var numberOfPassengers: Int { get }
    var numberOfLuggages: Int { get }
    var vehicleTypeDisplay: String { get }
}

public protocol RideHistoryModelable {
    var id: String { get }
    var startLocation: AddressReprensentable { get }
    var endLocation: AddressReprensentable? { get }
    var pickUpLocation: AddressReprensentable? { get }
    var priceDisplay: String? { get }
    var vat: Double? { get }
    var startDate: Date { get }
    var endDate: Date? { get }
    var isImmediate: Bool { get }
    var originDisplay: String { get }
    var rideType: RideHistoryType { get }
    var options: OptionsReprensentable { get }
}
