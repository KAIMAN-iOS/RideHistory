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

extension RideHistoryType {
    var color: UIColor {
        switch self {
        case .booked: return RideHistoryTabController.conf.palette.action
        case .completed: return RideHistoryTabController.conf.palette.confirmation
        case .cancelled: return RideHistoryTabController.conf.palette.primary
        }
    }
    
    var stateDisplay: String {
        switch self {
        case .booked: return "booked display".bundleLocale()
        case .completed: return "completed display".bundleLocale()
        case .cancelled: return "cancelled display".bundleLocale()
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
    
    func configure(_ ride: RideHistoryModelable) {
        backgroundColor = RideHistoryTabController.conf.palette.lightGray
        passenger.set(text: ride.username, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        if let url = ride.userIconURL,
           let imageUrl = URL(string: url) {
            imageTast = passengerImage.downloadImage(from: imageUrl, placeholder: UIImage(named: "documentUser", in: .module, compatibleWith: nil))
        } else {
            passengerImage.image = UIImage(named: "documentUser", in: .module, compatibleWith: nil)
        }
        options.set(text: String(format: "%d pers. %d bag.".bundleLocale(), ride.rideOptions.numberOfPassengers, ride.rideOptions.numberOfLuggages),
                    for: .caption1,
                    textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        stateContainer.backgroundColor = ride.rideType.color
        state.set(text: ride.rideType.stateDisplay.uppercased(),
                  for: .callout,
                  fontScale: 0.8,
                  textColor:RideHistoryTabController.conf.palette.textOnPrimary)
    }
}
