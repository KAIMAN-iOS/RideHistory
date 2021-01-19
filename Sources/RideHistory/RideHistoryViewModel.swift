//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import UIViewExtension
import TableViewExtension

class RideHistoryViewModel {
    enum Section: Int, Hashable {
        case main
    }
    enum CellType: Hashable {
        static func == (lhs: CellType, rhs: CellType) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        case ride(_: RideHistoryModelable)
        var ride: RideHistoryModelable {
            switch self {
            case .ride(let ride): return ride
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .ride(let ride): hasher.combine(ride.id)
            }
        }
    }
    
    enum RouteState {
        case requested, completed
    }
    typealias RouteStateResult = (state: RouteState, routes: [Route])
    private var routes: [String: RouteStateResult] = [:]
    private(set) var mapDelegate: RideHistoryMapDelegate!
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, CellType>
    private var dataSource: DataSource!
    
    init(rides: [RideHistoryModelable]) {
        self.rides = rides
    }
    
    func dataSource(for collectionView: UICollectionView) -> DataSource {
        // Handle cells
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collection, indexPath, model) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            guard let cell: RideHistoryCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
            cell.configure(model.ride, mapDelegate: self.mapDelegate)
            if let route = self.routes[model.ride.id], route.state == .completed {
                cell.add(routes: route.routes)
            } else if self.routes[model.ride.id] == nil {
                self.routes[model.ride.id] = (state: .requested, routes: [])
                self.mapDelegate.loadRoutes(for: model.ride, delegate: self)
            }
            return cell
        }
        return dataSource
    }
    
    private var rides: [RideHistoryModelable] = []
    func applySnapshot(in dataSource: DataSource, animatingDifferences: Bool = true, completion: @escaping (() -> Void)) {
        var snap = dataSource.snapshot()
        snap.appendItems(rides.compactMap({ CellType.ride($0) }), toSection: .main)
        dataSource.apply(snap, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    // MARK: - CollectionView Layout Modern API
    func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            return self.generateLayout(for: section, environnement: env)
        }
        return layout
    }
    
    private func generateLayout(for section: Int, environnement: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let fullItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(335)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(335)), subitem: fullItem, count: 1)
        let layoutSection = NSCollectionLayoutSection(group: group)
        return layoutSection
    }
    
    func reload(_ ride: RideHistoryModelable) {
        var snap = dataSource.snapshot()
        snap.reloadItems([CellType.ride(ride)])
        applySnapshot(in: dataSource, animatingDifferences: false) {}
    }
}

extension RideHistoryViewModel: RideHistoryMapRouteDelegate {
    func routes(_ routes: [Route], for ride: RideHistoryModelable) {
        self.routes[ride.id] = (state: .completed, routes: routes)
        reload(ride)
    }
}
