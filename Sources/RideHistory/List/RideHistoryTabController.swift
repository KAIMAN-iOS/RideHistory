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

extension Array where Element == RideHistoryModelable {
    var tabs: [RideHistoryType : [RideHistoryModelable]] {
        Dictionary(grouping: self) { $0.rideType }
    }
}

extension UIView {
    var safeArea : ConstraintLayoutGuideDSL {
        return safeAreaLayoutGuide.snp
    }
}

class RideHistoryTabController: ButtonBarPagerTabStripViewController {
    static var conf: ATAConfiguration!
    
    static func create(rides: [RideHistoryModelable],
                       delegate: RideHistoryActionnable,
                       coordinatorDelegate: RideHistoryCoordinatorDelegate,
                       mapDelegate: RideHistoryMapDelegate,
                       conf: ATAConfiguration!) -> RideHistoryTabController {
        let ctrl: RideHistoryTabController = UIStoryboard(name: "RideHistory", bundle: Bundle.module).instantiateViewController(identifier: "RideHistoryTabController")
        RideHistoryTabController.conf = conf
        ctrl.rideDelegate = delegate
        ctrl.mapDelegate = mapDelegate
        ctrl.coordinatorDelegate = coordinatorDelegate
        ctrl.rides = rides
        return ctrl
    }
    
    private(set) var rides: [RideHistoryModelable] = []  {
        didSet {
            tabs = rides.tabs
            controllers.removeAll()
            tabs.forEach { (tab, rides) in
                let ctrl: RideHistoryController = RideHistoryController.create(rides: rides,
                                                                               rideType: tab,
                                                                               delegate: rideDelegate,
                                                                               coordinatorDelegate: coordinatorDelegate,
                                                                               mapDelegate: mapDelegate)
                controllers[tab] = ctrl
            }
        }
    }
    var tabs: [RideHistoryType : [RideHistoryModelable]] = [:]
    var controllers: [RideHistoryType : RideHistoryController] = [:]
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
        activity.color = RideHistoryTabController.conf.palette.primary
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
//        reloadPages()
        // load rides from WS too...
        addLoadingBar()
        rideDelegate.loadRides { [weak self] rides in
            self?.navigationItem.rightBarButtonItem = nil
            self?.rides = rides
            self?.reloadPagerTabStripView()
        }
    }
    
    private func updateSettings() {
        settings.style.buttonBarBackgroundColor = navigationController?.navigationBar.barTintColor ?? .white
        settings.style.buttonBarItemBackgroundColor = navigationController?.navigationBar.barTintColor ?? .white
        settings.style.selectedBarBackgroundColor = RideHistoryTabController.conf.palette.primary
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
            newCell?.label.textColor = RideHistoryTabController.conf.palette.primary
        }
    }
    
    private func key(at index: Int) -> RideHistoryType? {
        return index < tabs.keys.count ? tabs.keys.sorted(by: { $0.rawValue < $1.rawValue })[index] : nil
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let ctrls = tabs.keys.sorted().compactMap({ controllers[$0] })
        print("ctrls \(ctrls)")
        return ctrls
    }
}
