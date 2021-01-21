//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import UIViewControllerExtension

class RideHistoryDetailController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!    
    static func create(ride: RideHistoryModelable,
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
    var ride: RideHistoryModelable!
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
        collectionView.collectionViewLayout = model.layout()
        model.applySnapshot(in: datasource) {
            
        }
    }
    
    var datasource: RideHistoryDetailViewModel.DataSource!

}
