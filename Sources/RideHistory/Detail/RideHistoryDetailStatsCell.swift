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

extension RideHistoryModelable {
    var amountStat: RideStatsModelable? { stat(for: .amount) }
    var distanceStat: RideStatsModelable? { stat(for: .distance) }
    var timeStat: RideStatsModelable? { stat(for: .time) }
    private func stat(for type: RideStat) -> RideStatsModelable? { rideStats.filter({ $0.statType == type }).first }
}

class RideHistoryDetailStatsCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
    @IBOutlet weak var plate: UILabel!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var distanceUnit: UILabel! {
        didSet {
            distanceUnit.set(text: RideStat.distance.title.uppercased(), for: 10, weight: .regular, textColor: RideHistoryTabController.conf.palette.mainTexts)
        }
    }
    @IBOutlet weak var distanceContainer: UIView!
    @IBOutlet weak var timeValue: UILabel!
    @IBOutlet weak var timeUnit: UILabel!  {
        didSet {
            timeUnit.set(text: RideStat.time.title.uppercased(), for: 10, weight: .regular, textColor: RideHistoryTabController.conf.palette.mainTexts)
        }
    }
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var priceUnit: UILabel! {
        didSet {
            priceUnit.set(text: RideStat.amount.title.uppercased(), for: 10, weight: .regular, textColor: RideHistoryTabController.conf.palette.primary)
        }
    }
    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var rideType: UILabel!
    @IBOutlet weak var rideTypeContainer: UIView!
    
    override func prepareForReuse() {
        [priceValue, distanceValue, timeValue].forEach({ $0?.text = "-" })
    }
    
    func configure(_ ride: RideHistoryModelable) {
        dayLabel.set(text: String(format: "%@, %@", RideHistoryCell.dayFormatter.string(from: ride.startDate).capitalizingFirstLetter(), RideHistoryCell.timeFormatter.string(from: ride.startDate)),
                     for: .subheadline,
                     textColor: RideHistoryTabController.conf.palette.mainTexts)
        vehicleType.set(text: ride.rideOptions.vehicleTypeDisplay.isEmpty ? "-" : ride.rideOptions.vehicleTypeDisplay, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        plate.set(text: ride.plate, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        plate.isHidden = ride.plate?.isEmpty ?? true
        [priceValue, distanceValue, timeValue].forEach({ $0?.text = "-" })
        ride.rideStats.forEach { stat in
            switch stat.statType {
            case .amount: update(priceContainer, value: priceValue, stat: stat)
            case .distance: update(distanceContainer, value: distanceValue, stat: stat)
            case .time: update(timeContainer, value: timeValue, stat: stat)
            }
        }
        rideType.set(text: "\(ride.isImmediate ? "immediate ride".bundleLocale() : "booked ride".bundleLocale())  : \(ride.originDisplay)".uppercased(),
                     for: .subheadline,
                     fontScale: 0.85,
                     textColor: RideHistoryTabController.conf.palette.textOnPrimary)
        rideTypeContainer.backgroundColor = RideHistoryTabController.conf.palette.secondary
    }
    
    private func update(_ container: UIView, value: UILabel, stat: RideStatsModelable) {
        let textColor = stat.statType == .amount ?  RideHistoryTabController.conf.palette.primary : RideHistoryTabController.conf.palette.mainTexts
        value.attributedText = stat.attributedString(textColor: textColor)
    }
}
