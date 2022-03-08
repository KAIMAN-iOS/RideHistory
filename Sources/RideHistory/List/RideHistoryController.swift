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
                       mode: Mode,
                       rideState: RideState,
                       delegate: RideHistoryActionnable,
                       coordinatorDelegate: RideHistoryCoordinatorDelegate,
                       mapDelegate: RideHistoryMapDelegate) -> RideHistoryController {
        let ctrl: RideHistoryController = UIStoryboard(name: "RideHistory", bundle: Bundle.module).instantiateViewController(identifier: "RideHistoryController")
        ctrl.rides = rides
        ctrl.mode = mode
        ctrl.rideState = rideState
        ctrl.rideDelegate = delegate
        ctrl.mapDelegate = mapDelegate
        ctrl.coordinatorDelegate = coordinatorDelegate
        ctrl.model = RideHistoryViewModel(rides: rides, mapDelegate: mapDelegate)
        return ctrl
    }
    var rideState: RideState!
    var rides: [RideHistoryModel] =  []
    var mode: Mode!
    weak var rideDelegate: RideHistoryActionnable!
    weak var coordinatorDelegate: RideHistoryCoordinatorDelegate!
    weak var mapDelegate: RideHistoryMapDelegate!
    
    @IBOutlet weak var collectionView: UICollectionView!  {
        didSet {
            collectionView.register(UINib(nibName: "RideHistoryCell", bundle: .module), forCellWithReuseIdentifier: "RideHistoryCell")
            collectionView.delegate = self
            collectionView.refreshControl = refreshControl
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = { mode in
        let refreshControl = UIRefreshControl()
        switch mode {
        case .driver:    refreshControl.tintColor = RideHistoryTabController.conf.palette.mainTexts
        case .passenger: refreshControl.tintColor = RideHistoryTabController.conf.palette.primary
        default: ()
        }
        refreshControl.addTarget(self, action: #selector(refreshRides), for: .valueChanged)
        return refreshControl
    } (mode)
    
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
        print("💀 DEINIT \(rideState ?? .ended) - \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
    
    var datasource: RideHistoryViewModel.DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        datasource = model.dataSource(for: collectionView)
        collectionView.dataSource = datasource
        collectionView.collectionViewLayout = model.layout()
        noRidesContainer.isHidden = rides.count > 0
        noRidesLabel.set(text: "noRides".bundleLocale(), for: .subheadline, textColor: RideHistoryTabController.conf.palette.inactive)
        model.applySnapshot(in: datasource) {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if self.rides.isEmpty {
            rideDelegate.loadRides(for: rideState) { [weak self] rides in
                self?.reloadRides(rides)
            }
//        }
    }
    
    func reloadRides(_ rides: [RideHistoryModel]) {
        self.rides = rides.sorted(by: { lhs, rhs in
            switch (lhs.ride.state) {
            case .booked:
                return lhs.ride.startDate.value < rhs.ride.startDate.value
            default:
                return lhs.ride.startDate.value >= rhs.ride.startDate.value
            }
        })
        model.updateRides(self.rides)
        noRidesContainer.isHidden = rides.count > 0
    }
    
    @objc func refreshRides() {
        refreshControl.beginRefreshing()
        rideDelegate.loadRides(for: rideState) { [weak self] rides in
            self?.reloadRides(rides)
            self?.refreshControl.endRefreshing()
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
        IndicatorInfo(title: rideState.displayText?.uppercased())
    }
}
