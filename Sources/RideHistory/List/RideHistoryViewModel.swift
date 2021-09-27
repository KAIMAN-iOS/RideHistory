//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import UIViewExtension
import TableViewExtension
import ATACommonObjects

typealias RouteStateResult = (state: RouteState, routes: [Route])
enum RouteState {
    case requested, completed
}

class RideHistoryViewModel {
    enum Section: Int, Hashable {
        case main
    }
    enum CellType: Hashable {
        static func == (lhs: CellType, rhs: CellType) -> Bool {
            return lhs.ride.ride.id == rhs.ride.ride.id
        }
        case ride(_: RideHistoryModel)
        var ride: RideHistoryModel {
            switch self {
            case .ride(let ride): return ride
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .ride(let ride):
                hasher.combine(ride.ride.id)
                hasher.combine(ride.ride.state)
            }
        }
    }
    
    private var routes: [Int: RouteStateResult] = [:]
    private(set) weak var mapDelegate: RideHistoryMapDelegate!
    private let directionManager = RideDirectionManager.shared
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, CellType>
    private var dataSource: DataSource!
    
    deinit {
        print("💀 DEINIT \(rides.first?.ride.state ?? .ended) - \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
    
    init(rides: [RideHistoryModel], mapDelegate: RideHistoryMapDelegate) {
        self.rides = rides
        self.mapDelegate = mapDelegate
    }
    
    func dataSource(for collectionView: UICollectionView) -> DataSource {
        // Handle cells
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collection, indexPath, model) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            guard let cell: RideHistoryCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
            cell.configure(model.ride, mapDelegate: self.mapDelegate)
            if let route = self.routes[model.ride.ride.id], route.state == .completed {
                cell.add(routes: route.routes)
            } else if self.routes[model.ride.ride.id] == nil {
                self.routes[model.ride.ride.id] = (state: .requested, routes: [])
                self.directionManager.loadDirections(for: model.ride.ride) { [weak self] ride, routes in
                    self?.routes[ride.id] = (state: .completed, routes: routes)
                    self?.reload(model.ride)
                }
            }
            return cell
        }
        return dataSource
    }
    
    private var rides: [RideHistoryModel] = []
    func applySnapshot(in dataSource: DataSource, animatingDifferences: Bool = true, completion: @escaping (() -> Void)) {
        var snap = dataSource.snapshot()
        if snap.itemIdentifiers.isEmpty {
            snap.appendSections([.main])
            snap.appendItems(rides.compactMap({ CellType.ride($0) }), toSection: .main)
        }
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
        let fullItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(290)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(290)), subitem: fullItem, count: 1)
        let layoutSection = NSCollectionLayoutSection(group: group)
        return layoutSection
    }
    
    func reload(_ ride: RideHistoryModel) {
        var snap = dataSource.snapshot()
        snap.reloadItems([CellType.ride(ride)])
        applySnapshot(in: dataSource, animatingDifferences: false) {}
    }
}
