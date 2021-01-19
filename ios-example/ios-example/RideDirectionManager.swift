//
//  RideDirectionManager.swift
//  taxi.Chauffeur
//
//  Created by GG on 22/12/2020.
//

import UIKit
import MapKit
import RideHistory

protocol RideDirectionsDelegate: class {
    func routesReady(_ routes: [Route], for ride: Ride)
}

class RideDirectionManager {
    static let shared: RideDirectionManager = RideDirectionManager()
    weak var delegate: RideHistoryMapRouteDelegate?
    private var routes: [Ride: [Route]] = [:]
    private init() {}
    
    private var loadQueue: DispatchQueue = DispatchQueue(label: "LoadRoutes", qos: .default)
    
    func loadDirections(for ride: Ride, delegate: RideHistoryMapRouteDelegate) {
        self.delegate = delegate
        
        let group = DispatchGroup()
        // init in order to simplify process
        routes[ride] = []
        // load directions
        loadApproachDirections(for: ride, group: group)
        if let toAddress = ride.endLocation as? Address {
            loadRideDirections(for: ride, toAdress: toAddress, group: group)
        }
        group.notify(queue: loadQueue) {
            // refreh the view if it is curretnly displayed
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.routes(self?.routes[ride] ?? [], for: ride)
                // delete routes
                self?.routes[ride] = nil
            }
        }
    }
    
    func loadApproachDirections(for ride: Ride, group: DispatchGroup) {
        guard let userLocation = ride.pickUpLocation?.coordinates else {
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: ride.startLocation.coordinates, addressDictionary: nil))
        request.transportType = .automobile
        loadRoute(.approach,
                  request: request,
                  for: ride,
                  group: group)
    }
    
    func loadRideDirections(for ride: Ride, toAdress: Address, group: DispatchGroup) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: ride.startLocation.coordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: toAdress.coordinates, addressDictionary: nil))
        request.transportType = .automobile
        loadRoute(.ride,
                  request: request,
                  for: ride,
                  group: group)
    }
    
    func loadRoute(_ routeType: Route.RouteType, request: MKDirections.Request, for ride: Ride, group: DispatchGroup) {
        group.enter()
        MKDirections(request: request)
            .calculate { [weak self] response, error in
                defer {
                    group.leave()
                }
                guard let self = self,
                      let route = response?.routes.first else { return }
                self.routes[ride]?.append(Route(routeType: routeType, route: route))
                
            }
    }
}
