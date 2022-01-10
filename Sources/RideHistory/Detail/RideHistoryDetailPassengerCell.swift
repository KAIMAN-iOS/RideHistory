//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import Ampersand
import LabelExtension
import ATAConfiguration
import UIImageViewExtension
import Nuke
import ATACommonObjects

extension RideState {
    var color: UIColor {
        switch self {
        case .booked: return RideHistoryTabController.conf.palette.action
        case .ended: return RideHistoryTabController.conf.palette.confirmation
        case .cancelled: return RideHistoryTabController.conf.palette.primary
        default: return RideHistoryTabController.conf.palette.primary
        }
    }
    
    var stateDisplay: String {
        switch self {
        case .booked: return "booked display".bundleLocale()
        case .ended: return "completed display".bundleLocale()
        case .cancelled: return "cancelled display".bundleLocale()
        default: return "cancelled display".bundleLocale()
        }
    }
}

class RideHistoryDetailPassengerCell: UICollectionViewCell {
    @IBOutlet weak var passenger: UILabel!
    @IBOutlet weak var options: UILabel!
    @IBOutlet weak var state: UILabel!  {
        didSet {
            state.numberOfLines = 2
            state.textAlignment = .center
        }
    }
    @IBOutlet weak var reason: UILabel!
    @IBOutlet weak var stateContainer: UIView!
    @IBOutlet weak var passengerImage: UIImageView!  {
        didSet {
            passengerImage.roundedCorners = true
            passengerImage.backgroundColor = RideHistoryTabController.conf.palette.mainTexts
            passengerImage.tintColor = RideHistoryTabController.conf.palette.lightGray
        }
    }
    var imageTast: ImageTask?
    
    override func prepareForReuse() {
        imageTast?.cancel()
        imageTast = nil
    }
    
    func configure(_ ride: RideHistoryModel, mode: Mode) {
        backgroundColor = RideHistoryTabController.conf.palette.lightGray
        var imageUrl: String?
        switch mode {
        case .passenger:
            imageUrl = ride.driver?.imageUrl
            passenger.set(text: ride.driver?.fullname, for: .body, fontScale: 0.9, traits: [.traitBold], textColor: RideHistoryTabController.conf.palette.secondaryTexts)
            
        case .driver: imageUrl =
            ride.passenger?.imageUrl
            passenger.set(text: ride.passenger?.fullname, for: .body, fontScale: 0.9, traits: [.traitBold], textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        default: ()
        }
        if let url = imageUrl,
           let imageUrl = URL(string: url) {
            imageTast = passengerImage.downloadImage(from: imageUrl, placeholder: UIImage(named: "documentUser", in: .module, compatibleWith: nil), activityColor: RideHistoryTabController.conf.palette.primary)
            passengerImage.contentMode = .scaleAspectFill
        } else {
            passengerImage.image = UIImage(named: "documentUser", in: .module, compatibleWith: nil)
            passengerImage.contentMode = .scaleAspectFit
        }
        options.set(text: String(format: "%d pers. %d bag.".bundleLocale(), ride.ride.numberOfPassengers, ride.ride.numberOfLuggages),
                    for: .footnote,
                    textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        stateContainer.backgroundColor = ride.ride.state.color
        state.set(text: ride.ride.state.displayCellText?.uppercased(),
                  for: .callout,
//                  fontScale: 0.8,
                  textColor:RideHistoryTabController.conf.palette.textOnPrimary)
        reason.superview?.isHidden = ride.cancellationReason == nil
        reason.set(text: ride.cancellationReason?.reason, for: .caption1, textColor: RideHistoryTabController.conf.palette.primary)
    }
}

extension RideCancelReason {
    var reason: String? {
        switch self {
        case .none: return nil
        case .cancelPendingRideByPassenger: return "cancelPendingRideByPassenger reason".bundleLocale()
        case .noDriverFound: return "noDriverFound reason".bundleLocale()
        case .engineBreakdown: return "engineBreakdown reason".bundleLocale()
        case .passengerNotFound: return "passengerNotFound reason".bundleLocale()
        case .otherReasonbyDriver: return "otherReasonbyDriver reason".bundleLocale()
        case .cancelledyPassenger: return "cancelledyPassenger reason".bundleLocale()
        }
    }
}
