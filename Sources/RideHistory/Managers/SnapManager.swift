//
//  File.swift
//  
//
//  Created by GG on 19/01/2021.
//

import UIKit
import MapKit

struct PolylineData {
    var polyline: MKPolyline
    var renderer: MKPolylineRenderer
}

struct SnapManager {
    func snap(from map: MKMapView,
              annotationViews: [MKAnnotationView],
              lines: [PolylineData],
              imageCompletion: @escaping ((UIImage?) -> Void)) {
        let options: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
        options.region = map.region
        options.size = map.frame.size
        options.scale = UIScreen.main.scale
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start {(snapshot: MKMapSnapshotter.Snapshot?, error: Error?) -> Void in
            guard error == nil, let snapshot = snapshot else { return }
            
            UIGraphicsBeginImageContextWithOptions(snapshot.image.size, true, snapshot.image.scale)
            snapshot.image.draw(at: .zero)
            
            lines.forEach { polyline in
                let count = polyline.polyline.pointCount
                let points = polyline.polyline.points()
                guard count > 1 else { return }
                
                let path = UIBezierPath()
                path.move(to: snapshot.point(for: points[0].coordinate))
                for i in 1 ..< count {
                    path.addLine(to: snapshot.point(for: points[i].coordinate))
                }
                
                path.lineWidth = polyline.renderer.lineWidth
                path.lineCapStyle = polyline.renderer.lineCap
                path.lineJoinStyle = polyline.renderer.lineJoin
                if var pattern = polyline.renderer.lineDashPattern?.compactMap({ CGFloat($0.floatValue) }) {
                    path.setLineDash(&pattern, count: pattern.count, phase: 0)
                }
                polyline.renderer.strokeColor?.setStroke()
                
                path.stroke()
            }
            
            annotationViews.forEach { view in
                guard let anno = view.annotation?.coordinate else { return }
                let point: CGPoint = snapshot.point(for: anno)
                self.drawPin(point: point, annotationView: view)
            }
            let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            imageCompletion(compositeImage)
        }
    }
    
    private func drawPin(point: CGPoint, annotationView: MKAnnotationView) {
        annotationView.contentMode = .scaleAspectFit
        annotationView.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        annotationView.drawHierarchy(in: CGRect(
                                        x: point.x - annotationView.bounds.size.width / 2.0,
                                        y: point.y - annotationView.bounds.size.height / 2.0,
                                        width: annotationView.bounds.width,
                                        height: annotationView.bounds.height),
                                     afterScreenUpdates: true)
    }
}
