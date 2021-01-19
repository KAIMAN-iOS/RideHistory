//
//  File.swift
//  
//
//  Created by GG on 18/01/2021.
//

import UIKit
import Ampersand
import LabelExtension
import ATAConfiguration
import MapKit
import UIViewExtension
import KStorage

class RideHistoryCell: UICollectionViewCell {
    private static var dayFormatter: DateFormatter = {
        let form = DateFormatter()
        form.locale = .current
        form.dateStyle = .medium
        form.timeStyle = .none
        form.doesRelativeDateFormatting = true
        return form
    }()
    private static var timeFormatter: DateFormatter = {
        let form = DateFormatter()
        form.locale = .current
        form.doesRelativeDateFormatting = true
        form.dateStyle = .none
        form.timeStyle = .short
        return form
    }()
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var map: MKMapView!  {
        didSet {
            map.isScrollEnabled = false
            map.isUserInteractionEnabled = false
            map.delegate = self
        }
    }

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var fromIconView: UIView!  {
        didSet {
            fromIconView.roundedCorners = true
        }
    }
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var carLabel: UILabel!
    
    private(set) var ride: RideHistoryModelable!
    private(set) var mapDelegate: RideHistoryMapDelegate!
    func configure(_ ride: RideHistoryModelable, mapDelegate: RideHistoryMapDelegate) {
        self.ride = ride
        self.mapDelegate = mapDelegate
        
        dateLabel.set(text: String(format: "%@, %@", RideHistoryCell.dayFormatter.string(from: ride.startDate), RideHistoryCell.timeFormatter.string(from: ride.startDate)),
                      for: .subheadline,
                      textColor: RideHistoryTabController.conf.palette.mainTexts)
        priceLabel.isHidden = ride.priceDisplay == nil
        priceLabel.set(text: ride.priceDisplay, for: .callout, textColor: RideHistoryTabController.conf.palette.primary)
        fromLabel.set(text: ride.startLocation.displayAddress, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        carLabel.set(text: ride.options.vehicleTypeDisplay, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        // map data
        if let image = ImageManager.fetchImage(with: ride.id) {
            mapImage.image = image
            map.isHidden = true
            mapImage.isHidden = false
        } else {
            map.isHidden = false
            mapImage.isHidden = true
            map.addAnnotations(mapDelegate.annotations(for: ride))
        }
    }
    
    override func prepareForReuse() {
        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)
    }
    
    func add(routes: [Route]) {
        map.addOverlays(mapDelegate.overlays(for: routes))
        if let first = routes.first?.route {
            let rect = routes.compactMap({ $0.route?.polyline.boundingMapRect }).reduce(first.polyline.boundingMapRect, { $1.union($0) })
            map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: false)
        }
    }
}

extension RideHistoryCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer { mapDelegate.renderer(for: overlay) }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { mapDelegate.view(for: annotation) }
}
