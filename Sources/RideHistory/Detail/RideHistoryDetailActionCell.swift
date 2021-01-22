//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import ActionButton

public enum RideMainActionType {
    case printTicket, cancel
    
    var title: String {
        switch self {
        case .printTicket: return "print ticket".bundleLocale()
        case .cancel: return "cancel ride".bundleLocale()
        }
    }
    
    var color: UIColor {
        switch self {
        case .printTicket: return RideHistoryTabController.conf.palette.confirmation
        case .cancel: return RideHistoryTabController.conf.palette.action
        }
    }
}

extension RideHistoryModelable {
    var mainActionType: RideMainActionType? {
        switch rideType {
        case .booked: return .cancel
        case .completed: return .printTicket
        case .cancelled: return nil
        }
    }
}

class RideHistoryDetailActionCell: UICollectionViewCell {
    @IBOutlet weak var actionButton: ActionButton!
    
    func configure(_ mainActionType: RideMainActionType) {
        actionButton.setTitle(mainActionType.title, for: .normal)
        actionButton.backgroundColor = mainActionType.color
        actionButton.isUserInteractionEnabled = false
    }
}
