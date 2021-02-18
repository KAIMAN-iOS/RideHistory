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

enum SecondaryActionType {
    case dispute, lostAndFound
    
    var title: String {
        switch self {
        case .dispute: return "dispute title".bundleLocale()
        case .lostAndFound: return "lostAndFound title".bundleLocale()
        }
    }
    var subtitle: String {
        switch self {
        case .dispute: return "dispute subtitle".bundleLocale()
        case .lostAndFound: return "lostAndFound subtitle".bundleLocale()
        }
    }
}

class RideHistoryDetailSecondaryActionCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!  {
        didSet {
            icon.tintColor = RideHistoryTabController.conf.palette.secondary
        }
    }
    @IBOutlet weak var separator: UIView!  {
        didSet {
            separator.backgroundColor = RideHistoryTabController.conf.palette.lightGray
        }
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    func configure(_ actionType: SecondaryActionType, isEnabled: Bool = true, isLastcell: Bool = false) {
        title.set(text: actionType.title, for: .callout, textColor: isEnabled ? RideHistoryTabController.conf.palette.mainTexts : RideHistoryTabController.conf.palette.inactive)
        subtitle.set(text: actionType.subtitle, for: .body, fontScale: 0.8, textColor: isEnabled ? RideHistoryTabController.conf.palette.mainTexts : RideHistoryTabController.conf.palette.inactive)
        separator.isHidden = isLastcell
    }
}
