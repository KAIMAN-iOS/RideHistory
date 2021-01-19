//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import KCoordinatorKit
import ATAConfiguration
import MapKit

public enum RideHistoryType: Int, CaseIterable {
    case booked, completed, cancelled
    var canCancel: Bool {
        return self == .booked
    }
    
    var title: String {
        switch self {
        case .booked: return "booked".bundleLocale()
        case .completed: return "completed".bundleLocale()
        case .cancelled: return "cancelled".bundleLocale()
        }
    }
}

public protocol RideHistoryActionnable: class {
    func cancel(_ rideId: String, completion: @escaping (() -> Void))
    func loadRides(completion: @escaping (([RideHistoryModelable]) -> Void))
}

protocol RideHistoryCoordinatorDelegate: class {
    func didSelect(_ rideId: String)
}

public protocol RideHistoryMapDelegate: class {
    func view(for annotation: MKAnnotation) -> MKAnnotationView?
    func renderer(for overlay: MKOverlay) -> MKOverlayRenderer
    func annotations(for ride: RideHistoryModelable) -> [MKAnnotation]
    func overlays(for ride: RideHistoryModelable) -> [MKOverlay]
    func loadRoutes(for ride: RideHistoryModelable, delegate: RideHistoryMapRouteDelegate)
}

public struct Route {
    enum RouteType {
        case approach, ride
    }
    var routeType: RouteType!
    var route: MKRoute?
}

public protocol RideHistoryMapRouteDelegate: class {
    func routes(_ routes: [Route], for ride: RideHistoryModelable)
}

public class RideHistoryCoordinator<DeepLink>: Coordinator<DeepLink> {
    var controller: RideHistoryTabController!    
    public init(router: RouterType,
         rides: [RideHistoryModelable],
         delegate: RideHistoryActionnable,
         mapDelegate: RideHistoryMapDelegate,
         conf: ATAConfiguration) {
        super.init(router: router)
        controller = RideHistoryTabController.create(rides: rides,
                                                  delegate: delegate,
                                                  coordinatorDelegate: self,
                                                  mapDelegate: mapDelegate,
                                                  conf: conf)
    }
    
    public override func toPresentable() -> UIViewController { controller }
}

extension RideHistoryCoordinator: RideHistoryCoordinatorDelegate {
    func didSelect(_ rideId: String) {
        
    }
}

extension String {
    func bundleLocale() -> String {
        NSLocalizedString(self, bundle: .module, comment: self)
    }
}
