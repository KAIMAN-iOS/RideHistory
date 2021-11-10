//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import ATAConfiguration
import Ampersand
import SnapKit
import UIViewControllerExtension
import ATACommonObjects

extension Array where Element == RideHistoryModel {
    var tabs: [RideState : [RideHistoryModel]] {
        Dictionary(grouping: self) { $0.ride.state }
    }
}

extension UIView {
    var safeArea : ConstraintLayoutGuideDSL {
        return safeAreaLayoutGuide.snp
    }
}

class RideHistoryTabController: ButtonBarPagerTabStripViewController {
    static var conf: ATAConfiguration!
    
    static func create(rides: [RideHistoryModel],
                       mode: Mode,
                       allowedRideStates: [RideState],
                       defaultSelectedTab: RideState,
                       delegate: RideHistoryActionnable,
                       coordinatorDelegate: RideHistoryCoordinatorDelegate,
                       mapDelegate: RideHistoryMapDelegate,
                       conf: ATAConfiguration!) -> RideHistoryTabController {
        let ctrl: RideHistoryTabController = UIStoryboard(name: "RideHistory", bundle: Bundle.module).instantiateViewController(identifier: "RideHistoryTabController")
        RideHistoryTabController.conf = conf
        ctrl.rideDelegate = delegate
        ctrl.mapDelegate = mapDelegate
        ctrl.coordinatorDelegate = coordinatorDelegate
        ctrl.allowedRideStates = allowedRideStates
        ctrl.mode = mode // before setting ctrl.rides, otherwise fails
        ctrl.rides = rides
        ctrl.defaultSelectedTab = defaultSelectedTab
        return ctrl
    }
    
    var defaultSelectedTab: RideState!
    private(set) var rides: [RideHistoryModel] = []  {
        didSet {
            // async control
            guard let coordinatorDelegate = coordinatorDelegate else { return }
            let tabs = rides.tabs.filter { allowedRideStates.contains($0.key) }
            controllers.removeAll()
            
            allowedRideStates.forEach { tab in
                var rides: [RideHistoryModel] = []
                if let index = tabs.index(forKey: tab) {
                    rides = tabs[index].value
                }
                
                let ctrl: RideHistoryController = RideHistoryController.create(rides: rides.sorted(by: { $0.ride.startDate.value > $1.ride.startDate.value }),
                                                                               mode: mode,
                                                                               rideState: tab,
                                                                               delegate: self,
                                                                               coordinatorDelegate: coordinatorDelegate,
                                                                               mapDelegate: mapDelegate)
                controllers[tab] = ctrl
            }
        }
    }

    private var mode: Mode!
    var allowedRideStates: [RideState] = []
//    var tabs: [RideHistoryType : [RideHistoryModel]] = [:]
    var controllers: [RideState : RideHistoryController] = [:]
    weak var rideDelegate: RideHistoryActionnable!
    weak var coordinatorDelegate: RideHistoryCoordinatorDelegate!
    weak var mapDelegate: RideHistoryMapDelegate!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    lazy var scrollView = UIScrollView()
      lazy var barView: ButtonBarView = {
        let layout = UICollectionViewFlowLayout()
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 64)
        let collectionView = ButtonBarView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = navigationController?.navigationBar.barTintColor ?? .white
        return collectionView
      }()
    
    private func addViews() {
        
        view.addSubview(barView)
        buttonBarView = barView
        barView.snp.makeConstraints {
            $0.top.equalTo(view.safeArea.top)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        view.addSubview(scrollView)
        containerView = scrollView
        scrollView.snp.makeConstraints {
            $0.top.equalTo(barView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    func addLoadingBar() {
        let activity = UIActivityIndicatorView(style: .medium)
        switch mode {
        case .driver:    activity.color = RideHistoryTabController.conf.palette.confirmation
        case .passenger: activity.color = RideHistoryTabController.conf.palette.navigationItem
        default: ()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        activity.startAnimating()
    }
    
    deinit {
        print("💀 DEINIT \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
    
    override func viewDidLoad() {
        updateSettings()
        addViews()
        super.viewDidLoad()
        
        hideBackButtonText = true
        title = "Mes Courses".bundleLocale().capitalized
        navigationController?.navigationBar.prefersLargeTitles = true
        buttonBarView.reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.moveToViewController(at: self.allowedRideStates.firstIndex(of: self.defaultSelectedTab) ?? 0, animated: false)
        }
    }
    
    private func updateSettings() {
        settings.style.buttonBarBackgroundColor = navigationController?.navigationBar.barTintColor ?? .white
        settings.style.buttonBarItemBackgroundColor = navigationController?.navigationBar.barTintColor ?? .white
        switch mode {
        case .driver:    settings.style.selectedBarBackgroundColor = RideHistoryTabController.conf.palette.confirmation
        case .passenger: settings.style.selectedBarBackgroundColor = RideHistoryTabController.conf.palette.primary
        default: ()
        }
        settings.style.buttonBarItemFont = .applicationFont(forTextStyle: .subheadline)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = RideHistoryTabController.conf.palette.secondaryTexts
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = RideHistoryTabController.conf.palette.mainTexts
            oldCell?.label.font = oldCell?.label.font.noBold()
            newCell?.label.font = newCell?.label.font.bold()
            switch self.mode {
            case .driver:    newCell?.label.textColor = RideHistoryTabController.conf.palette.mainTexts
            case .passenger: newCell?.label.textColor = RideHistoryTabController.conf.palette.primary
            default: ()
            }
        }
    }
    
    private func key(at index: Int) -> RideState? {
        return index < controllers.keys.count ? controllers.keys.sorted(by: { $0.rawValue < $1.rawValue })[index] : nil
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let ctrls = controllers.keys.sorted().compactMap({ controllers[$0] })
        print("ctrls \(ctrls)")
        return ctrls
    }
    
    private func isAllowedRideState(rideState: RideState) -> Bool {
        allowedRideStates.first { allowedRideState in
            rideState == allowedRideState
        } != nil
    }
}

extension RideHistoryTabController: RideHistoryActionnable {
    func cancel(_ rideId: Int, completion: @escaping (() -> Void)) {
        rideDelegate.cancel(rideId, completion: completion)
    }
    
    func printTicket(for ride: RideHistoryModel) {
        rideDelegate.printTicket(for: ride)
    }
    
    func openDispute(for ride: RideHistoryModel) {
        rideDelegate.openDispute(for: ride)
    }
    
    func foundObject(for ride: RideHistoryModel) {
        rideDelegate.foundObject(for: ride)
    }
    
    func loadRides(for state: RideState, completion: @escaping (([RideHistoryModel]) -> Void)) {
        addLoadingBar()
        rideDelegate.loadRides(for: state) { [weak self] rides in
            guard let self = self else { return }
            self.navigationItem.rightBarButtonItem = nil
            completion(rides)
        }
    }
}
