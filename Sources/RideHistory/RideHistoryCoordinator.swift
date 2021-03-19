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
import ATACommonObjects

public protocol RideHistoryActionnable: class {
    func cancel(_ rideId: Int, completion: @escaping (() -> Void))
    func printTicket(for ride: RideHistoryModel)
    func openDispute(for ride: RideHistoryModel)
    func foundObject(for ride: RideHistoryModel)
    func loadRides(completion: @escaping (([RideHistoryModel]) -> Void))
}

protocol RideHistoryCoordinatorDelegate: class {
    func didSelect(_ ride: RideHistoryModel)
}

public protocol RideHistoryMapDelegate: class {
    func view(for annotation: MKAnnotation) -> MKAnnotationView?
    func renderer(for overlay: MKOverlay) -> MKPolylineRenderer
    func annotations(for ride: RideHistoryModel) -> [MKAnnotation]
    func overlays(for routes: [Route]) -> [MKOverlay]
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
                rides: [RideHistoryModel],
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
    func didSelect(_ ride: RideHistoryModel) {
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
