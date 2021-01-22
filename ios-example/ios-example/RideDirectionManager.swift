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

typealias RouteCompletion = ((_ routes: [Route]) -> Void)
class RideDirectionManager {
    
    static let shared: RideDirectionManager = RideDirectionManager()
    private var routes: [Ride: [Route]] = [:]
    private init() {}
    
    private var loadQueue: DispatchQueue = DispatchQueue(label: "LoadRoutes", qos: .default)
    
    func loadDirections(for ride: Ride, completion: @escaping RouteCompletion) {        
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
            DispatchQueue.main.async {  [weak self, completion] in
                completion(self?.routes[ride] ?? [])
                // delete routes
                self?.routes[ride] = nil
                // delete routes
                self?.routes[ride] = nil
            }
        }
    }
    
    func loadApproachDirections(for ride: Ride, group: DispatchGroup) {
        guard let userLocation = ride.pickUpLocation?.addressCoordinates else {
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: ride.startLocation.addressCoordinates, addressDictionary: nil))
        request.transportType = .automobile
        loadRoute(.approach,
                  request: request,
                  for: ride,
                  group: group)
    }
    
    func loadRideDirections(for ride: Ride, toAdress: Address, group: DispatchGroup) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: ride.startLocation.addressCoordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: toAdress.addressCoordinates, addressDictionary: nil))
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
