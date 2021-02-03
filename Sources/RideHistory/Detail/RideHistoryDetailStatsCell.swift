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

class RideHistoryDetailStatsCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
    @IBOutlet weak var plate: UILabel!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var distanceUnit: UILabel!
    @IBOutlet weak var distanceContainer: UIView!
    @IBOutlet weak var timeValue: UILabel!
    @IBOutlet weak var timeUnit: UILabel!
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var priceUnit: UILabel!
    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var rideType: UILabel!
    @IBOutlet weak var rideTypeContainer: UIView!
    
    func configure(_ ride: RideHistoryModelable) {
        dayLabel.set(text: String(format: "%@, %@", RideHistoryCell.dayFormatter.string(from: ride.startDate).capitalizingFirstLetter(), RideHistoryCell.timeFormatter.string(from: ride.startDate)),
                     for: .subheadline,
                     textColor: RideHistoryTabController.conf.palette.mainTexts)
        vehicleType.set(text: ride.rideOptions.vehicleTypeDisplay.isEmpty ? "-" : ride.rideOptions.vehicleTypeDisplay, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        plate.set(text: ride.plate, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        plate.isHidden = ride.plate?.isEmpty ?? true
        [priceContainer, distanceContainer, timeContainer].forEach({ $0?.isHidden = true })
        ride.rideStats.forEach { stat in
            switch stat.statType {
            case .amount: update(priceContainer, value: priceValue, unit: priceUnit, stat: stat)
            case .distance: update(distanceContainer, value: distanceValue, unit: distanceUnit, stat: stat)
            case .time: update(timeContainer, value: timeValue, unit: timeUnit, stat: stat)
            }
        }
        rideType.set(text: "\(ride.isImmediate ? "immediate ride".bundleLocale() : "booked ride".bundleLocale())  : \(ride.originDisplay)".uppercased(),
                     for: .callout,
                     fontScale: 0.7,
                     textColor: RideHistoryTabController.conf.palette.textOnPrimary)
        rideTypeContainer.backgroundColor = RideHistoryTabController.conf.palette.secondary
    }
    
    private func update(_ container: UIView, value: UILabel, unit: UILabel, stat: RideStatsModelable) {
        container.isHidden = false
        let textColor = stat.statType == .amount ?  RideHistoryTabController.conf.palette.primary : RideHistoryTabController.conf.palette.mainTexts
        unit.set(text: stat.statType.title.uppercased(), for: 10, weight: .regular, textColor: textColor)
        value.attributedText = stat.attributedString(textColor: textColor)
    }
}
