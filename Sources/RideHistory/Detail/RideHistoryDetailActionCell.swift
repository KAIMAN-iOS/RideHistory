//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import ActionButton
import ATACommonObjects

public enum RideMainActionType {
    case printTicket, cancel, startRide
    
    var title: String {
        switch self {
            case .printTicket: return "print ticket".bundleLocale()
            case .cancel: return "cancel ride".bundleLocale()
            case .startRide: return "start ride".bundleLocale()
        }
    }
    
    var isEnabled: Bool { self != .printTicket }
    
    var color: UIColor {
        switch self {
            case .printTicket: return RideHistoryTabController.conf.palette.inactive
            case .cancel: return RideHistoryTabController.conf.palette.action
            case .startRide: return RideHistoryTabController.conf.palette.confirmation
        }
    }
}

extension RideHistoryModel {
    var mainActionTypes: [RideMainActionType]? {
        switch ride.state {
            case .booked: return [.startRide, .cancel]
            case .ended: return [.printTicket]
            default: return nil
        }
    }
}

class RideHistoryDetailActionCell: UICollectionViewCell {
    @IBOutlet weak var actionButton: ActionButton!
    
    func configure(_ mainActionType: RideMainActionType) {
        actionButton.setTitle(mainActionType.title, for: .normal)
        actionButton.backgroundColor = mainActionType.color
        actionButton.isUserInteractionEnabled = false //mainActionType.isEnabled
    }
}
