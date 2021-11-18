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
import ATACommonObjects

class RideHistoryCell: UICollectionViewCell {
    static var dayFormatter: DateFormatter = {
        let form = DateFormatter()
        form.locale = .current
        form.dateFormat = "EEEE d MMMM"
        return form
    }()
    static var timeFormatter: DateFormatter = {
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
    @IBOutlet weak var toIconView: UIView!  {
        didSet {
            toIconView.roundedCorners = true
        }
    }
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var carLabel: UILabel!
    private var snapshotter: SnapManager = SnapManager()
    
    private(set) var ride: RideHistoryModel!
    private(set) var mapDelegate: RideHistoryMapDelegate!
    func configure(_ ride: RideHistoryModel, mapDelegate: RideHistoryMapDelegate) {
        self.ride = ride
        self.mapDelegate = mapDelegate
        
        dateLabel.set(text: String(format: "%@, %@", RideHistoryCell.dayFormatter.string(from: ride.ride.startDate.value).capitalizingFirstLetter(), RideHistoryCell.timeFormatter.string(from: ride.startDate.value)),
                      for: .subheadline,
                      textColor: RideHistoryTabController.conf.palette.mainTexts)
        priceLabel.isHidden = ride.priceDisplay == nil
        priceLabel.set(text: ride.priceDisplay, for: .subheadline, traits: [.traitBold], textColor: RideHistoryTabController.conf.palette.primary)
        fromLabel.set(text: ride.ride.fromAddress.address, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        if let toAdress = ride.ride.toAddress?.address, toAdress.isEmpty == false {
            toLabel.set(text: toAdress, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        } else {
            toLabel.isHidden = true
            toIconView.isHidden = true
        }
        carLabel.set(text: ride.vehicle.longDescription, for: .body, fontScale: 0.8, textColor: RideHistoryTabController.conf.palette.secondaryTexts)
        // map data
        if let image = ImageManager.fetchImage(with: "ride/\(ride.ride.id)") {
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
        snapshotter = SnapManager()
        mapImage.image = nil
    }
    
    func add(routes: [Route]) {
        guard map.isHidden == false, mapImage.isHidden == true else { return }
        let overlays = mapDelegate
            .overlays(for: routes)
            .compactMap({ $0 as? MKPolyline })
        map.addOverlays(overlays)
        // TODO: ECH > faire un union sur les MapRect au lieu de prendre le premier. Tips > Utiliser reduce
        if let first = routes.first?.route {
            let rect = routes.compactMap({ $0.route?.polyline.boundingMapRect }).reduce(first.polyline.boundingMapRect, { $1.union($0) })
            map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: false)
        }
        snapshotter.snap(from: map,
                         annotationViews: mapDelegate.annotations(for: ride).compactMap({ mapDelegate.view(for: $0) }),
                         lines: overlays.compactMap({ PolylineData(polyline: $0, renderer: mapDelegate.renderer(for: $0)) })) { [weak self] image in
            guard let self = self else { return }
            guard let image = image else { return }
            let _ = try? ImageManager.save(image, imagePath: "ride/\(self.ride.ride.id)")
            self.mapImage.image = image
            self.map.isHidden = true
            self.mapImage.isHidden = false
        }
    }
}

extension RideHistoryCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer { mapDelegate.renderer(for: overlay) }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { mapDelegate.view(for: annotation) }
}
