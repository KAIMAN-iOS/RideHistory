//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import ATACommonObjects

class RideHistoryController: UIViewController {
    
    static func create(rides: [RideHistoryModel],
                       rideType: RideHistoryType,
                       delegate: RideHistoryActionnable,
                       coordinatorDelegate: RideHistoryCoordinatorDelegate,
                       mapDelegate: RideHistoryMapDelegate) -> RideHistoryController {
        let ctrl: RideHistoryController = UIStoryboard(name: "RideHistory", bundle: Bundle.module).instantiateViewController(identifier: "RideHistoryController")
        ctrl.rides = rides
        ctrl.rideType = rideType
        ctrl.rideDelegate = delegate
        ctrl.mapDelegate = mapDelegate
        ctrl.coordinatorDelegate = coordinatorDelegate
        ctrl.model = RideHistoryViewModel(rides: rides, mapDelegate: mapDelegate)
        return ctrl
    }
    var rideType: RideHistoryType!
    var rides: [RideHistoryModel] =  []
    weak var rideDelegate: RideHistoryActionnable!
    weak var coordinatorDelegate: RideHistoryCoordinatorDelegate!
    weak var mapDelegate: RideHistoryMapDelegate!
    
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.register(UINib(nibName: "RideHistoryCell", bundle: .module), forCellWithReuseIdentifier: "RideHistoryCell")
            collectionView.delegate = self
        }
    }
    @IBOutlet weak var noRidesIcon: UIImageView!  {
        didSet {
            noRidesIcon.tintColor = RideHistoryTabController.conf.palette.inactive
        }
    }

    @IBOutlet weak var noRidesLabel: UILabel!  {
        didSet {
            noRidesLabel.numberOfLines = 0
        }
    }

    @IBOutlet weak var noRidesContainer: UIStackView!

    var model: RideHistoryViewModel!
    
    deinit {
        print("💀 DEINIT \(rideType ?? .completed) - \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
    
    var datasource: RideHistoryViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource = model.dataSource(for: collectionView)
        collectionView.dataSource = datasource
        collectionView.collectionViewLayout = model.layout()
        noRidesContainer.isHidden = rides.count > 0
        noRidesLabel.set(text: rideType.subtitle, for: .subheadline, textColor: RideHistoryTabController.conf.palette.inactive)
        model.applySnapshot(in: datasource) {
            
        }
    }
}

extension RideHistoryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinatorDelegate?.didSelect(rides[indexPath.row])
    }
}

extension RideHistoryController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: rideType.title)
    }
}
