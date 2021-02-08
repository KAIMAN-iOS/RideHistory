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

public enum RideHistoryType: Int, CaseIterable, Comparable {
    public static func < (lhs: RideHistoryType, rhs: RideHistoryType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case booked = 0, completed, cancelled
    var canCancel: Bool {
        return self == .booked
    }
    
    var title: String {
        switch self {
        case .booked: return "booked".bundleLocale().uppercased()
        case .completed: return "completed".bundleLocale().uppercased()
        case .cancelled: return "cancelled".bundleLocale().uppercased()
        }
    }
    
    var subtitle: String {
        switch self {
        case .booked: return "booked subtitle".bundleLocale().uppercased()
        case .completed: return "completed subtitle".bundleLocale().uppercased()
        case .cancelled: return "cancelled subtitle".bundleLocale().uppercased()
        }
    }
}

public protocol RideHistoryActionnable: class {
    func cancel(_ rideId: String, completion: @escaping (() -> Void))
    func printTicket(for ride: RideHistoryModelable)
    func openDispute(for ride: RideHistoryModelable)
    func foundObject(for ride: RideHistoryModelable)
    func loadRides(completion: @escaping (([RideHistoryModelable]) -> Void))
}

protocol RideHistoryCoordinatorDelegate: class {
    func didSelect(_ ride: RideHistoryModelable)
}

public protocol RideHistoryMapDelegate: class {
    func view(for annotation: MKAnnotation) -> MKAnnotationView?
    func renderer(for overlay: MKOverlay) -> MKPolylineRenderer
    func annotations(for ride: RideHistoryModelable) -> [MKAnnotation]
    func overlays(for routes: [Route]) -> [MKOverlay]
    func loadRoutes(for ride: RideHistoryModelable, completion: @escaping ((RideHistoryModelable, [Route]) -> Void))
}

public struct Route {
    public enum RouteType {
        case approach, ride
    }
    public var routeType: RouteType!
    public var route: MKRoute?
    public init(routeType: RouteType!, route: MKRoute?) {
        self.routeType = routeType
        self.route = route
    }
}

public enum Mode {
    case driver, passenger, business
}

public class RideHistoryCoordinator<DeepLink>: Coordinator<DeepLink> {
    var controller: RideHistoryTabController!
    private var mode: Mode!
    public init(router: RouterType,
                mode: Mode,
                defaultSelectedTab: RideHistoryType = .booked,
                rides: [RideHistoryModelable],
                delegate: RideHistoryActionnable,
                mapDelegate: RideHistoryMapDelegate,
                conf: ATAConfiguration) {
        super.init(router: router)
        controller = RideHistoryTabController.create(rides: rides,
                                                     delegate: delegate,
                                                     defaultSelectedTab: defaultSelectedTab,
                                                     coordinatorDelegate: self,
                                                     mapDelegate: mapDelegate,
                                                     conf: conf)
        self.mode = mode
    }
    
    public override func toPresentable() -> UIViewController { controller }
    
    deinit {
        print("💀 DEINIT \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
}

extension RideHistoryCoordinator: RideHistoryCoordinatorDelegate {
    func didSelect(_ ride: RideHistoryModelable) {
        let ctrl: RideHistoryDetailController = RideHistoryDetailController.create(ride: ride,
                                                                                   mode: mode,
                                                                                   delegate: controller.rideDelegate,
                                                                                   coordinatorDelegate: self,
                                                                                   mapDelegate: controller.mapDelegate)
        router.push(ctrl, animated: true, completion: nil)
    }
}

extension String {
    func bundleLocale() -> String {
        NSLocalizedString(self, bundle: .module, comment: self)
    }
}
