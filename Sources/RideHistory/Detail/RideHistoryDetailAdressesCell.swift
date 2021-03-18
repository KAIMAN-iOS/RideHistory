//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import UIViewExtension
import Ampersand
import LabelExtension
import ATAConfiguration
import ATACommonObjects

class RideHistoryDetailAdressesCell: UICollectionViewCell {
    @IBOutlet weak var dashedView: DottedView!  {
        didSet {
            dashedView.orientation = .vertical
            dashedView.dotColor = RideHistoryTabController.conf.palette.secondary
            dashedView.backgroundColor = .clear
            dashedView.dashes = [4, 4]
        }
    }
    @IBOutlet weak var pickUpIcon: UIView!  {
        didSet {
            pickUpIcon.roundedCorners = true
            pickUpIcon.backgroundColor = RideHistoryTabController.conf.palette.mainTexts
        }
    }
    @IBOutlet weak var pickUpAddress: UILabel!
    @IBOutlet weak var pickUpContainer: UIView!
    @IBOutlet weak var fromIcon: UIView!  {
        didSet {
            fromIcon.roundedCorners = true
            fromIcon.backgroundColor = RideHistoryTabController.conf.palette.confirmation
        }
    }
    @IBOutlet weak var fromAddress: UILabel!
    @IBOutlet weak var fromContainer: UIView!
    @IBOutlet weak var toIcon: UIView!  {
        didSet {
            toIcon.roundedCorners = true
            toIcon.backgroundColor = RideHistoryTabController.conf.palette.primary
        }
    }
    @IBOutlet weak var toAddress: UILabel!
    @IBOutlet weak var toContainer: UIView!
    
    func configure(_ ride: RideHistoryModel) {
        fromAddress.set(text: ride.fromAddress.address, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        if let pickUp = ride.pickUpAddress {
            pickUpAddress.set(text: pickUp.address, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        }
        pickUpContainer.isHidden = ride.pickUpAddress == nil
        if let toAddress = ride.toAddress {
            self.toAddress.set(text: toAddress.address, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        }
        toContainer.isHidden = ride.toAddress == nil
    }
}
