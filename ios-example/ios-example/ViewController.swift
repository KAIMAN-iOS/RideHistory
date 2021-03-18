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
    var action: UIColor { #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1) }
    var confirmation: UIColor { #colorLiteral(red: 0.3411764801, green: 0.721568644, blue: 0.650980413, alpha: 1) }
    var alert: UIColor { #colorLiteral(red: 0.8313725591, green: 0.2156862766, blue: 0.180392161, alpha: 1) }
    var primary: UIColor { #colorLiteral(red: 0.8313725591, green: 0.2156862766, blue: 0.180392161, alpha: 1) }
    var secondary: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    var mainTexts: UIColor { #colorLiteral(red: 0.09803921729, green: 0.09803921729, blue: 0.09803921729, alpha: 1)}
    var secondaryTexts: UIColor { #colorLiteral(red: 0.1879811585, green: 0.1879865527, blue: 0.1879836619, alpha: 1) }
    var textOnPrimary: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    var inactive: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    var placeholder: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    var lightGray: UIColor { #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) }
}

class ViewController: UIViewController {

    var coord: RideHistoryCoordinator<Int>!
    override func viewDidLoad() {
        super.viewDidLoad()
        let configurationURL = Bundle.main.url(forResource: "Poppins", withExtension: "json")!
        UIFont.registerApplicationFont(withConfigurationAt: configurationURL)
        // Do any additional setup after loading the view.
    }

    var rides = [Ride.with(id: "765426"), Ride.with(id: "878927"), Ride.with(id: "9870987"), Ride.with(id: "9087967")]
    @IBAction func show(_ sender: Any) {
        let router = Router(navigationController: navigationController!)
        print(rides.reduce("", { $0 + "\n\($1)" }))
        coord = RideHistoryCoordinator(router: router,
                                       mode: .driver,
                                       rides: rides,
                                       delegate: self,
                                       mapDelegate: self,
                                       conf: Configuration())
        navigationController?.pushViewController(coord.toPresentable(), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coord = nil
    }
}

extension ViewController: RideHistoryActionnable {
    func printTicket(for ride: RideHistoryModel) {
        print("printTicket")
    }
    
    func openDispute(for ride: RideHistoryModel) {
        print("openDispute")
    }
    
    func foundObject(for ride: RideHistoryModel) {
        print("foundObject")
    }
    
    func cancel(_ rideId: String, completion: @escaping (() -> Void)) {
        print("cancel")
    }
    
    func loadRides(completion: @escaping (([RideHistoryModel]) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.rides.append(contentsOf: [Ride.with(id: "87987"), Ride.with(id: "28E97"), Ride.with(id: "389749")])
            completion(self.rides)
        }
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
    
    func annotations(for ride: RideHistoryModel) -> [MKAnnotation] {
        var anno: [MKAnnotation] = []
        anno.append(RideAnnotation(address: ride.startLocation, isStart: true))
        if let end = ride.endLocation {
            anno.append(RideAnnotation(address: end, isStart: false))
        }
        if let pickUp = ride.pickUpLocation {
            anno.append(DriverAnnotation(coordinate: pickUp.addressCoordinates))
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
    
    func loadRoutes(for ride: RideHistoryModel, completion: @escaping RouteCompletion) {
        guard let ride = ride as? Ride else { return }
        RideDirectionManager.shared.loadDirections(for: ride, completion: completion)
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

struct Ride: RideHistoryModel, Hashable, CustomStringConvertible {
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
    var isImmediate: Bool
    var originDisplay: String
    var rideType: RideHistoryType
    var rideOptions: OptionsReprensentable
    var rideStats: [PendingPaymentRideData] = []
    var plate: String?
    var username: String
    var userIconURL: String?
    
    static func with(id: String) -> Ride {
        let randomType = Int.random(in: 0...2)
        return Ride(id: id,
             startLocation: Address.random,
             endLocation: Address.optionnalRandom,
             pickUpLocation: Address.optionnalRandom,
             priceDisplay: Int.random(in: 0...1) == 0 ? "23,50 €" : nil,
             vat: Int.random(in: 0...1) == 0 ? 20 : nil,
             startDate: Int.random(in: 0...1) == 0 ? Date() : Date().addingTimeInterval(23*87*7),
             isImmediate: Int.random(in: 0...1) == 0 ? true : false,
             originDisplay: "1001 BUSINESS",
             rideType: randomType == 0 ? .booked : (randomType == 1 ? .cancelled : .completed),
             rideOptions: Option.random,
             rideStats: [RideStats.distanceStat, RideStats.timeStat, RideStats.priceStat].compactMap({$0}),
             plate: Int.random(in: 0...1) == 0 ? nil : "BU-682-VT",
             username: "Jean-Pierre Bacri",
             userIconURL: "https://images.laprovence.com/media/afp/2021-01/2021-01-18/6b1814044de4a65ba1376d500122ec3972e17570.jpg?twic=v1/dpr=2/focus=900x576.5/cover=1000x562")
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

struct RideStats: PendingPaymentRideData {
    var value: Double
    var additionnalValue: Double?
    var unit: String
    var statType: RideStat
    
    static var distanceStat: RideStats? {
        [RideStats(value: 25, additionnalValue: nil, unit: "km", statType: .distance),
         RideStats(value: 216, additionnalValue: nil, unit: "km", statType: .distance),
         RideStats(value: 8, additionnalValue: nil, unit: "km", statType: .distance),
        nil][Int.random(in: 0...3)]
    }
    static var priceStat: RideStats? {
        [RideStats(value: 25.9, additionnalValue: nil, unit: "€", statType: .amount),
         RideStats(value: 216.3, additionnalValue: nil, unit: "$", statType: .amount),
         RideStats(value: 8, additionnalValue: nil, unit: "£", statType: .amount),
         nil][Int.random(in: 0...3)]
    }
    static var timeStat: RideStats? {
        [RideStats(value: 40, additionnalValue: nil, unit: "min", statType: .time),
         RideStats(value: 216, additionnalValue: nil, unit: "min", statType: .time),
         RideStats(value: 8, additionnalValue: nil, unit: "sec", statType: .time),
         nil][Int.random(in: 0...3)]
    }
}

struct Address: AddressReprensentable, CustomStringConvertible {
    var addressCoordinates: CLLocationCoordinate2D
    var displayAddress: String
    
    static var add1: Address {
        Address(addressCoordinates: CLLocationCoordinate2D(latitude: 43.47865284174063, longitude: 5.53859787072443), displayAddress: "la barque 13710 FUVEAU")
    }
    static var add2: Address {
        Address(addressCoordinates: CLLocationCoordinate2D(latitude: 43.52645372148015, longitude: 5.452597832139817), displayAddress: "Place Saint-Jean de Malte, 13100 Aix-en-Provence")
    }
    static var add3: Address {
        Address(addressCoordinates: CLLocationCoordinate2D(latitude: 43.454551591901144, longitude: 5.468953808988056), displayAddress: "départ adresse 13510 Fuveau")
    }
    static var add4: Address {
        Address(addressCoordinates: CLLocationCoordinate2D(latitude: 43.471590283851015, longitude: 5.4925626895974045), displayAddress: "rue Courbet 13736 Gardanne")
    }
    static var add5: Address {
        Address(addressCoordinates: CLLocationCoordinate2D(latitude: 43.30295892353656, longitude: 5.380216342283413), displayAddress: "Gare Saint Charles 13000 Marseille")
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
