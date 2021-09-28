//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import UIViewControllerExtension
import ATACommonObjects

class RideHistoryDetailController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!    
    static func create(ride: RideHistoryModel,
                       mode: Mode,
                       delegate: RideHistoryActionnable,
                       coordinatorDelegate: RideHistoryCoordinatorDelegate,
                       mapDelegate: RideHistoryMapDelegate) -> RideHistoryDetailController {
        let ctrl: RideHistoryDetailController = UIStoryboard(name: "RideHistory", bundle: Bundle.module).instantiateViewController(identifier: "RideHistoryDetailController")
        ctrl.ride = ride
        ctrl.rideDelegate = delegate
        ctrl.mapDelegate = mapDelegate
        ctrl.coordinatorDelegate = coordinatorDelegate
        ctrl.model = RideHistoryDetailViewModel(ride: ride, mapDelegate: mapDelegate, mode: mode)
        return ctrl
    }
    var ride: RideHistoryModel!
    weak var rideDelegate: RideHistoryActionnable!
    weak var coordinatorDelegate: RideHistoryCoordinatorDelegate!
    weak var mapDelegate: RideHistoryMapDelegate!
    var model: RideHistoryDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideBackButtonText = true
        title = "ride detail".bundleLocale()
        datasource = model.dataSource(for: collectionView)
        collectionView.dataSource = datasource
        collectionView.delegate = self
        collectionView.collectionViewLayout = model.layout()
        model.applySnapshot(in: datasource) {
            
        }
    }
    
    var datasource: RideHistoryDetailViewModel.DataSource!

}

extension RideHistoryDetailController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellType = model.cellType(at: indexPath) else { return }
        switch cellType {
        case .mainAction(let action):
            switch action {
            case .printTicket: () //rideDelegate.printTicket(for: ride)
            case .cancel: rideDelegate.cancel(ride.ride.id) {}
            }
            
        case .secondaryAction(let action):
            switch action {
            case .dispute: rideDelegate.openDispute(for: ride)
            case.lostAndFound: rideDelegate.foundObject(for: ride)
            }
            
        default: ()
        }
    }
}
