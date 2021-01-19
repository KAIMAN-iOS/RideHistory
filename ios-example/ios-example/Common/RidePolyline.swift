//
//  RidePolyline.swift
//  taxi.Chauffeur
//
//  Created by GG on 18/12/2020.
//

import UIKit
import MapKit
import RideHistory

class RidePolyline: MKPolyline {
    var routeType: Route.RouteType = .approach
    var color: UIColor {
        switch routeType {
        case .approach: return .gray
        case .ride: return .red
        }
    }
    var lineDashPattern: [NSNumber]? {
        switch routeType {
        case .approach: return [4, 6]
        case .ride: return nil
        }
    }
    
    var lineWidth: CGFloat {
        switch routeType {
        case .approach: return 2
        case .ride: return 5
        }
    }
    
    public convenience init(points: UnsafePointer<MKMapPoint>, count: Int, routeType: Route.RouteType) {
        self.init(points: points, count: count)
        self.routeType = routeType
    }

    public convenience init(coordinates coords: UnsafePointer<CLLocationCoordinate2D>, count: Int, routeType: Route.RouteType) {
        self.init(coordinates: coords, count: count)
        self.routeType = routeType
    }
}
