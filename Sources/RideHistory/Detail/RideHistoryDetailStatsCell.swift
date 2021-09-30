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
import ATACommonObjects
import DateExtension

extension RideHistoryModel {
    var amountStat: PendingPaymentRideData? { stat(for: .amount) }
    var distanceStat: PendingPaymentRideData? { stat(for: .distance) }
    var timeStat: PendingPaymentRideData? { stat(for: .time) }
    private func stat(for type: RideEndStat) -> PendingPaymentRideData? { payment.stats.filter({ $0.type == type }).first }
    var startDate: CustomDate<GMTISODateFormatterDecodable> { ride.startDate }
}

class RideHistoryDetailStatsCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var vehicleType: UILabel!
    @IBOutlet weak var plate: UILabel!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var distanceUnit: UILabel! {
        didSet {
            distanceUnit.set(text: RideEndStat.distance.title.uppercased(), for: 10, weight: .regular, textColor: RideHistoryTabController.conf.palette.mainTexts)
        }
    }
    @IBOutlet weak var distanceContainer: UIView!
    @IBOutlet weak var timeValue: UILabel!
    @IBOutlet weak var timeUnit: UILabel!  {
        didSet {
            timeUnit.set(text: RideEndStat.time.title.uppercased(), for: 10, weight: .regular, textColor: RideHistoryTabController.conf.palette.mainTexts)
        }
    }
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var priceUnit: UILabel! {
        didSet {
            priceUnit.set(text: RideEndStat.amount.title.uppercased(), for: 10, weight: .regular, textColor: RideHistoryTabController.conf.palette.primary)
        }
    }
    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var rideType: UILabel!
    @IBOutlet weak var rideTypeContainer: UIView!
    
    override func prepareForReuse() {
        [priceValue, distanceValue, timeValue].forEach({ $0?.text = "-" })
    }
    
    func configure(_ ride: RideHistoryModel) {
        dayLabel.set(text: String(format: "%@, %@", RideHistoryCell.dayFormatter.string(from: ride.ride.startDate.value).capitalizingFirstLetter(), RideHistoryCell.timeFormatter.string(from: ride.startDate.value)),
                     for: .subheadline,
                     textColor: RideHistoryTabController.conf.palette.mainTexts)
        vehicleType.set(text: ride.vehicle.mediumDescription, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        plate.set(text: ride.vehicle.plate, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        [priceValue, distanceValue, timeValue].forEach({ $0?.text = "-" })
        ride.payment.stats.forEach { stat in
            switch stat.type {
            case .amount: update(priceContainer, value: priceValue, stat: stat)
            case .distance: update(distanceContainer, value: distanceValue, stat: stat)
            case .time: update(timeContainer, value: timeValue, stat: stat)
            }
        }
        rideType.set(text: "\(ride.ride.isImmediate ? "immediate ride".bundleLocale() : "booked ride".bundleLocale())  : \(ride.ride.origin.displayText)".uppercased(),
                     for: .subheadline,
                     fontScale: 0.85,
                     textColor: RideHistoryTabController.conf.palette.textOnPrimary)
        rideTypeContainer.backgroundColor = RideHistoryTabController.conf.palette.secondary
    }
    
    private func update(_ container: UIView, value: UILabel, stat: PendingPaymentRideData) {
        let textColor = stat.type == .amount ?  RideHistoryTabController.conf.palette.primary : RideHistoryTabController.conf.palette.mainTexts
        value.attributedText = stat.attributedString(textColor: textColor)
    }
}
