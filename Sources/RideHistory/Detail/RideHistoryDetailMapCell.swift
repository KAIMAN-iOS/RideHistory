//
//  File.swift
//  
//
//  Created by GG on 20/01/2021.
//

import UIKit
import MapKit
import ATACommonObjects

class RideHistoryDetailMapCell: UICollectionViewCell {
    @IBOutlet weak var map: MKMapView!  {
        didSet {
            map.delegate = self
            map.isScrollEnabled = false
            map.isUserInteractionEnabled = false
        }
    }

    @IBOutlet weak var image: UIImageView!
    private(set) var mapDelegate: RideHistoryMapDelegate!
    private var snapshotter: SnapManager = SnapManager()
    private(set) var ride: RideHistoryModel!
    
    func configure(_ ride: RideHistoryModel, mapDelegate: RideHistoryMapDelegate) {
        self.ride = ride
        self.mapDelegate = mapDelegate
        if let image = ImageManager.fetchImage(with: "ride/\(ride.ride.id)") {
            self.image.image = image
            map.isHidden = true
            self.image.isHidden = false
        } else {
            map.isHidden = false
            image.isHidden = true
            map.addAnnotations(mapDelegate.annotations(for: ride))
        }
    }
    
    func add(routes: [Route]) {
        guard map.isHidden == false, image.isHidden == true else { return }
        let overlays = mapDelegate
            .overlays(for: routes)
            .compactMap({ $0 as? MKPolyline })
        map.addOverlays(overlays)
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
            self.image.image = image
            self.map.isHidden = true
            self.image.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        image.image = nil
        snapshotter = SnapManager()
        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)
    }
}

extension RideHistoryDetailMapCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer { mapDelegate.renderer(for: overlay) }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { mapDelegate.view(for: annotation) }
}
