//
//  ViewController.swift
//  ios-example
//
//  Created by GG on 19/01/2021.
//

import UIKit
import RideHistory
import KCoordinatorKit
import MapKit
import ATAConfiguration

class Configuration: ATAConfiguration {
    var logo: UIImage? { nil }
    var palette: Palettable { Palette() }
}

class Palette: Palettable {
    var primary: UIColor { #colorLiteral(red: 0.8313725591, green: 0.2156862766, blue: 0.180392161, alpha: 1) }
    var secondary: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    
    var mainTexts: UIColor { #colorLiteral(red: 0.09803921729, green: 0.09803921729, blue: 0.09803921729, alpha: 1)}
    
    var secondaryTexts: UIColor { #colorLiteral(red: 0.1879811585, green: 0.1879865527, blue: 0.1879836619, alpha: 1) }
    
    var textOnPrimary: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    
    var inactive: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    
    var placeholder: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    var lightGray: UIColor { #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) }
    
    
}

class ViewController: UIViewController {

    var coord: RideHistoryCoordinator<Int>!
    override func viewDidLoad() {
        super.viewDidLoad()
        let configurationURL = Bundle.main.url(forResource: "Poppins", withExtension: "json")!
        UIFont.registerApplicationFont(withConfigurationAt: configurationURL)
        // Do any additional setup after loading the view.
    }

    @IBAction func show(_ sender: Any) {
        let router = Router(navigationController: navigationController!)
        let rides = [Ride.with(id: "765426"), Ride.with(id: "878927"), Ride.with(id: "9870987"), Ride.with(id: "9087967")]
        print(rides.reduce("", { $0 + "\n\($1)" }))
        coord = RideHistoryCoordinator(router: router,
                                       rides: rides,
                                       delegate: self,
                                       mapDelegate: self,
                                       conf: Configuration())
        navigationController?.pushViewController(coord.toPresentable(), animated: true)
    }
}

extension ViewController: RideHistoryActionnable {
    func cancel(_ rideId: String, completion: @escaping (() -> Void)) {
        
    }
    
    func loadRides(completion: @escaping (([RideHistoryModelable]) -> Void)) {
        
    }
}

extension ViewController: RideHistoryMapDelegate {
    func view(for annotation: MKAnnotation) -> MKAnnotationView? {
        if let driver = annotation as? DriverAnnotation {
            return DriverAnnotationView(annotation: driver)
        }
        if let rideAnnotation = annotation as? RideAnnotation {
            return RideAnnotationView(annotation: rideAnnotation)
        }
        return nil
    }
    
    func renderer(for overlay: MKOverlay) -> MKPolylineRenderer {
        guard let line = overlay as? RidePolyline else { return MKPolylineRenderer() }
        let renderer = MKPolylineRenderer(polyline: line)
        renderer.strokeColor = line.color
        renderer.lineWidth = line.lineWidth
        renderer.lineDashPattern = line.lineDashPattern
        renderer.lineJoin = .round
        renderer.lineCap = .square
        return renderer
    }
    
    func annotations(for ride: RideHistoryModelable) -> [MKAnnotation] {
        var anno: [MKAnnotation] = []
        anno.append(RideAnnotation(address: ride.startLocation, isStart: true))
        if let end = ride.endLocation {
            anno.append(RideAnnotation(address: end, isStart: false))
        }
        if let pickUp = ride.pickUpLocation {
            anno.append(DriverAnnotation(coordinate: pickUp.coordinates))
        }
        print("Annos \(anno.count) for \(ride.id)")
        return anno
    }
    
    func overlays(for routes: [Route]) -> [MKOverlay] {
        var overlays: [MKOverlay] = []
        routes.forEach { route in
            if let poly = route.route?.polyline {
                overlays.append(RidePolyline(coordinates: poly.coordinates, count: poly.coordinates.count, routeType: route.routeType))
            }
        }
        return overlays
    }
    
    func loadRoutes(for ride: RideHistoryModelable, delegate: RideHistoryMapRouteDelegate) {
        guard let ride = ride as? Ride else { return }
        RideDirectionManager.shared.loadDirections(for: ride, delegate: delegate)
    }
}

public extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}

struct Ride: RideHistoryModelable, Hashable, CustomStringConvertible {
    static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    var id: String
    var startLocation: AddressReprensentable
    var endLocation: AddressReprensentable?
    var pickUpLocation: AddressReprensentable?
    var priceDisplay: String?
    var vat: Double?
    var startDate: Date
    var endDate: Date?
    var isImmediate: Bool
    var originDisplay: String
    var rideType: RideHistoryType
    var options: OptionsReprensentable
    
    static func with(id: String) -> Ride {
        let randomType = Int.random(in: 0...2)
        return Ride(id: id,
             startLocation: Address.random,
             endLocation: Address.optionnalRandom,
             pickUpLocation: Address.optionnalRandom,
             priceDisplay: Int.random(in: 0...1) == 0 ? "23,50 €" : nil,
             vat: Int.random(in: 0...1) == 0 ? 20 : nil,
             startDate: Int.random(in: 0...1) == 0 ? Date() : Date().addingTimeInterval(23*87*7),
             endDate: Int.random(in: 0...1) == 0 ? Date().addingTimeInterval(3680) : nil,
             isImmediate: Int.random(in: 0...1) == 0 ? true : false,
             originDisplay: "1001 BUSINESS",
             rideType: randomType == 0 ? .booked : (randomType == 1 ? .cancelled : .completed),
             options: Option.random)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var description: String {
        var str = "\(rideType) - from : \(startLocation)"
        if let pickUp = pickUpLocation {
            str.append(" - ⬇ \(pickUp)")
        }
        if let end = endLocation {
            str.append(" - ➡ \(end)")
        }
        return str
    }
}

struct Address: AddressReprensentable, CustomStringConvertible {
    var coordinates: CLLocationCoordinate2D
    var displayAddress: String
    
    static var add1: Address {
        Address(coordinates: CLLocationCoordinate2D(latitude: 43.47865284174063, longitude: 5.53859787072443), displayAddress: "la barque 13710 FUVEAU")
    }
    static var add2: Address {
        Address(coordinates: CLLocationCoordinate2D(latitude: 43.52645372148015, longitude: 5.452597832139817), displayAddress: "Place Saint-Jean de Malte, 13100 Aix-en-Provence")
    }
    static var add3: Address {
        Address(coordinates: CLLocationCoordinate2D(latitude: 43.454551591901144, longitude: 5.468953808988056), displayAddress: "départ adresse 13510 Fuveau")
    }
    static var add4: Address {
        Address(coordinates: CLLocationCoordinate2D(latitude: 43.471590283851015, longitude: 5.4925626895974045), displayAddress: "rue Courbet 13736 Gardanne")
    }
    static var add5: Address {
        Address(coordinates: CLLocationCoordinate2D(latitude: 43.30295892353656, longitude: 5.380216342283413), displayAddress: "Gare Saint Charles 13000 Marseille")
    }
    
    static var random: Address {
        return [Address.add1, Address.add2, Address.add3, Address.add4, Address.add5][Int.random(in: 0...4)]
    }
    static var optionnalRandom: Address? {
        return [Address.add1, Address.add2, Address.add3, Address.add4, Address.add5, nil][Int.random(in: 0...5)]
    }
    
    var description: String {
        displayAddress
    }
}

struct Option: OptionsReprensentable, CustomStringConvertible {
    var numberOfPassengers: Int
    var numberOfLuggages: Int
    var vehicleTypeDisplay: String
    
    static var opt1: Option {
        Option(numberOfPassengers: 1, numberOfLuggages: 1, vehicleTypeDisplay: "Peugeot 5008")
    }
    static var opt2: Option {
        Option(numberOfPassengers: 3, numberOfLuggages: 1, vehicleTypeDisplay: "Mercédès classe S")
    }
    static var opt3: Option {
        Option(numberOfPassengers: 2, numberOfLuggages: 0, vehicleTypeDisplay: "BMX série 1")
    }
    static var opt4: Option {
        Option(numberOfPassengers: 5, numberOfLuggages: 3, vehicleTypeDisplay: "Visa Classic Turbo GTI")
    }
    static var random: Option {
        [Option.opt1, Option.opt2, Option.opt3, Option.opt4][Int.random(in: 0...3)]
    }
    
    var description: String {
        "😬 \(numberOfPassengers) - 💼 \(numberOfLuggages) - 🚕 \(vehicleTypeDisplay)"
    }
}

/*
 let ride = Ride(id: "8976987986",
                 date: CustomDate<ISODateFormatterDecodable>.init(date: Date().addingTimeInterval(2400)),
                 validUntil: CustomDate<ISODateFormatterDecodable>.init(date: Date().addingTimeInterval(15)),
                 isImmediate: false,
                 fromAddress: Address(address: "la barque 13710 FUVEAU", coordinates: Coordinates(location: CLLocationCoordinate2D(latitude: 43.47865284174063,
                                                                                                                                          longitude: 5.53859787072443))),
                 toAddress: Address(address: "Place Saint-Jean de Malte, 13100 Aix-en-Provence", coordinates: Coordinates(location: CLLocationCoordinate2D(latitude: 43.52645372148015,
                                                                                                                                         longitude: 5.452597832139817))),
                 options: Rideoptions(numberOfPassengers: 2, numberOfLuggages: 1, vehicleType: nil),
                 origin: .default)
 
 DispatchQueue.main.async {
     self.load(ride: ride)
 }
 
 let ride2 = Ride(id: "7698675",
                  date: CustomDate<ISODateFormatterDecodable>.init(date: Date().addingTimeInterval(3600)),
                  validUntil: CustomDate<ISODateFormatterDecodable>.init(date: Date().addingTimeInterval(30)),
                  isImmediate: true,
                  fromAddress: Address(address: "départ adresse 13510 Fuveau", coordinates: Coordinates(location: CLLocationCoordinate2D(latitude: 43.454551591901144,
                                                                                                                                          longitude: 5.468953808988056))),
                  toAddress: nil,
                  options: Rideoptions(numberOfPassengers: 2, numberOfLuggages: 1, vehicleType: nil),
                  origin: .default)
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
     self.load(ride: ride2)
 }
 
 let ride3 = Ride(id: "908076756",
                  date: CustomDate<ISODateFormatterDecodable>.init(date: Date().addingTimeInterval(1000)),
                  validUntil: CustomDate<ISODateFormatterDecodable>.init(date: Date().addingTimeInterval(20)),
                  isImmediate: true,
                  fromAddress: Address(address: "rue Courbet 13736 Gardanne", coordinates: Coordinates(location: CLLocationCoordinate2D(latitude: 43.471590283851015,
                                                                                                                                                longitude: 5.4925626895974045))),
                  toAddress: Address(address: "Gare Saint Charles 13000 Marseille", coordinates: Coordinates(location: CLLocationCoordinate2D(latitude: 43.30295892353656,
                                                                                                                                          longitude: 5.380216342283413))),
                  options: Rideoptions(numberOfPassengers: 6, numberOfLuggages: 10, vehicleType: nil),
                  origin: .leTaxi)
 */
