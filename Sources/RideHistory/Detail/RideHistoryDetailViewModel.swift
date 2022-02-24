//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import ATACommonObjects

class RideHistoryDetailViewModel {
    private(set) var ride: RideHistoryModel
    private(set) var mapDelegate: RideHistoryMapDelegate!
    private let directionManager = RideDirectionManager.shared
    private var mode: Mode!
    init(ride: RideHistoryModel, mapDelegate: RideHistoryMapDelegate, mode: Mode) {
        self.ride = ride
        self.mapDelegate = mapDelegate
        self.mode = mode
    }
    
    enum Section: Hashable {
        case map, stats, user, addresses, mainAction, secondaryAction
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .map: hasher.combine(0)
            case .stats: hasher.combine(1)
            case .user: hasher.combine(2)
            case .addresses: hasher.combine(3)
            case .mainAction: hasher.combine(4)
            case .secondaryAction: hasher.combine(5)
            }
        }
        
        var layoutSize: NSCollectionLayoutSize {
            var height: CGFloat = 300
            switch self {
            case .map: height = 195
            case .stats: height = 95
            case .user: height = 57
            case .addresses: height = 141
            case .mainAction: height = 77
            case .secondaryAction: height = 97
            }
            return NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(height))
        }
    }
    
    enum CellType: Hashable {
        case map, stats, user, addresses, mainAction(_: RideMainActionType), secondaryAction(_: SecondaryActionType)
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .map: hasher.combine(0)
            case .stats: hasher.combine(1)
            case .user: hasher.combine(2)
            case .addresses: hasher.combine(3)
            case .mainAction(let action):
                hasher.combine(4)
                switch action {
                case .cancel: hasher.combine("cancel")
                case .printTicket: hasher.combine("printTicket")
                }
                
            case .secondaryAction(let action):
                hasher.combine(5)
                switch action {
                case .dispute: hasher.combine("dispute")
                case .lostAndFound: hasher.combine("lostAndFound")
                }
            }
        }
    }
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellType>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, CellType>
    private var dataSource: DataSource!
    var routeState: RouteStateResult?
    
    func dataSource(for collectionView: UICollectionView) -> DataSource {
        // Handle cells
        dataSource = DataSource(collectionView: collectionView) { [weak self] (collection, indexPath, model) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            switch model {
            case .map:
                guard let cell: RideHistoryDetailMapCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(self.ride, mapDelegate: self.mapDelegate)
                if let state = self.routeState, state.state == .completed {
                    cell.add(routes: state.routes)
                } else if self.routeState == nil && ImageManager.fetchImage(with: "\(self.ride.ride.id)") == nil {
                    self.routeState = (state: .requested, routes: [])
                    self.directionManager.loadDirections(for: self.ride.ride) { [weak self] ride, routes in
                        self?.routeState = (state: .completed, routes: routes)
                        self?.reloadMap()
                    }
                }
                return cell
                
            case .stats:
                guard let cell: RideHistoryDetailStatsCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(self.ride)
                return cell
                
            case .user:
                guard let cell: RideHistoryDetailPassengerCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(self.ride, mode: self.mode)
                return cell
                
            case .addresses:
                guard let cell: RideHistoryDetailAdressesCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(self.ride)
                return cell
                
            case .mainAction(let action):
                    guard let cell: RideHistoryDetailActionCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                    cell.configure(action)
                    return cell
            
            case .secondaryAction(let action):
                guard let cell: RideHistoryDetailSecondaryActionCell = collectionView.automaticallyDequeueReusableCell(forIndexPath: indexPath) else { return nil }
                cell.configure(action, isEnabled: self.ride.ride.state != .booked, isLastcell: action == .lostAndFound)
                return cell
            }
        }
        return dataSource
    }
    
    func reloadMap() {
        var snap = dataSource.snapshot()
        snap.reloadItems([.map])
        applySnapshot(in: dataSource) { }
    }
    
    func applySnapshot(in dataSource: DataSource, animatingDifferences: Bool = true, completion: @escaping (() -> Void)) {
        var snap = dataSource.snapshot()
        snap.deleteAllItems()
        snap.appendSections([.map, .stats, .user, .addresses])
        snap.appendItems([.map], toSection: .map)
        snap.appendItems([.stats], toSection: .stats)
        snap.appendItems([.user], toSection: .user)
        snap.appendItems([.addresses], toSection: .addresses)
        if let action = ride.mainActionType {
            snap.appendSections([.mainAction])
            snap.appendItems([.mainAction(action)], toSection: .mainAction)
        }
        switch mode {
        case .driver:
            snap.appendSections([.secondaryAction])
            snap.appendItems([.secondaryAction(.dispute), .secondaryAction(.lostAndFound)], toSection: .secondaryAction)
            
        default: ()
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
        guard section < dataSource.snapshot().sectionIdentifiers.count else { return nil }
        let section = dataSource.snapshot().sectionIdentifiers[section]
        let fullItem = NSCollectionLayoutItem(layoutSize: section.layoutSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: section.layoutSize, subitem: fullItem, count: 1)
        let layoutSection = NSCollectionLayoutSection(group: group)
        return layoutSection
    }
    
    func cellType(at indexPath: IndexPath) -> CellType? {
        dataSource.itemIdentifier(for: indexPath)
//        return self.ride.ride.state != .booked ? dataSource.itemIdentifier(for: indexPath) : nil
    }
}

