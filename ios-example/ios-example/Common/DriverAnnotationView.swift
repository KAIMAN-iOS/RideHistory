//
//  DriverAnnotationView.swift
//  taxi.Chauffeur
//
//  Created by GG on 18/12/2020.
//

import UIKit
import MapKit

class DriverAnnotationView: MKAnnotationView {
    init(annotation: DriverAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: "DriverAnnotation")
        image = UIImage(named: "taxiMapIcon")
        canShowCallout = false
//        centerOffset = CGPoint(x: 0, y: -(image?.size.height ?? 0) / 2.0)
        if #available(iOS 14.0, *) {
            zPriority = .max
        } else {
            displayPriority = .required
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
