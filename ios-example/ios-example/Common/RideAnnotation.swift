//
//  RideAnnotation.swift
//  taxi.Chauffeur
//
//  Created by GG on 18/12/2020.
//

import UIKit
import MapKit
import RideHistory

class RideAnnotation: NSObject, MKAnnotation {
    var isStart: Bool = true
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    var tintColor: UIColor {
        isStart ? .green : .red
    }
    
    init(address: AddressReprensentable, isStart: Bool = true) {
        self.isStart = isStart
        coordinate = address.addressCoordinates
        title = address.displayAddress
    }
    
    init(coordinates: CLLocationCoordinate2D, isStart: Bool = true) {
        coordinate = coordinates
        title = nil
        self.isStart = isStart
    }
}
