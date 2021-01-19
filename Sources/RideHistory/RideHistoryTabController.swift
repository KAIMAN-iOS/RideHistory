//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import ATAConfiguration
import Tabman
import Pageboy

extension Array where Element == RideHistoryModelable {
    var tabs: [RideHistoryType : [RideHistoryModelable]] {
        Dictionary(grouping: self) { $0.rideType }
    }
}

class RideHistoryTabController: TabmanViewController {
    static var conf: ATAConfiguration!
    
    static func create(rides: [RideHistoryModelable],
                       delegate: RideHistoryActionnable,
                       coordinatorDelegate: RideHistoryCoordinatorDelegate,
                       mapDelegate: RideHistoryMapDelegate,
                       conf: ATAConfiguration!) -> RideHistoryTabController {
        let ctrl: RideHistoryTabController = UIStoryboard(name: "RideHistory", bundle: Bundle.module).instantiateViewController(identifier: "RideHistoryController")
        RideHistoryTabController.conf = conf
        ctrl.rides = rides
        ctrl.rideDelegate = delegate
        ctrl.mapDelegate = mapDelegate
        ctrl.coordinatorDelegate = coordinatorDelegate
        return ctrl
    }
    
    private(set) var rides: [RideHistoryModelable] = []  {
        didSet {
            tabs = rides.tabs
        }
    }
    var tabs: [RideHistoryType : [RideHistoryModelable]]!
    weak var rideDelegate: RideHistoryActionnable!
    weak var coordinatorDelegate: RideHistoryCoordinatorDelegate!
    weak var mapDelegate: RideHistoryMapDelegate!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        let bar = TMBar.ButtonBar()
        addBar(bar.systemBar(), dataSource: self, at: .top)
        loader.startAnimating()
        rideDelegate.loadRides { [weak self] rides in
            self?.rides = rides
            self?.reloadData()
        }
    }
    
    private func key(at index: Int) -> RideHistoryType? {
        return index < tabs.keys.count ? tabs.keys.sorted(by: { $0.rawValue < $1.rawValue })[index] : nil
    }
}

extension RideHistoryTabController: TMBarDataSource {

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return tabs.keys.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return nil
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        guard let key = key(at: index) else { fatalError() }
        let title = key.title
        return TMBarItem(title: title)
    }
}
