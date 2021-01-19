//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit

class RideHistoryController: UIViewController {
    
    static func create(rides: [RideHistoryModelable],
                       delegate: RideHistoryActionnable,
                       coordinatorDelegate: RideHistoryCoordinatorDelegate,
                       mapDelegate: RideHistoryMapDelegate) -> RideHistoryController {
        let ctrl: RideHistoryController = UIStoryboard(name: "RideHistory", bundle: Bundle.module).instantiateViewController(identifier: "RideHistoryController")
        ctrl.rides = rides
        ctrl.rideDelegate = delegate
        ctrl.mapDelegate = mapDelegate
        ctrl.coordinatorDelegate = coordinatorDelegate
        ctrl.model = RideHistoryViewModel(rides: rides)
        return ctrl
    }
    var rides: [RideHistoryModelable] =  []
    weak var rideDelegate: RideHistoryActionnable!
    weak var coordinatorDelegate: RideHistoryCoordinatorDelegate!
    weak var mapDelegate: RideHistoryMapDelegate!
    
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.register(UINib(nibName: "RideHistoryCell", bundle: .module), forCellWithReuseIdentifier: "RideHistoryCell")
        }
    }

    var model: RideHistoryViewModel!
}
