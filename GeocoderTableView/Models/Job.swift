//
//  Job.swift
//  GeocoderTableView
//
//  Created by Robert Ryan on 1/21/21.
//

import Foundation
import CoreLocation

enum GeocodeError: Error {
    case notFound
    case alreadyGeocoded
}

class Job: Identifiable {
    let id = UUID()
    let company: String
    let position: String
    let location: String                           // I personally would call this `address`, to avoid confusion with logical assumption that a property called `location` might be a `CLLocation` object
    var coordinate: CLLocationCoordinate2D? = nil

    init(company: String, position: String, location: String) {
        self.company = company
        self.position = position
        self.location = location
    }
}

extension Job {
    func geocodeIfNecessary(completion: @escaping (Bool) -> Void) {
        guard coordinate == nil else {
            completion(false)
            return
        }

        CLGeocoder().geocodeAddressString(location) { [weak self] placemarks, error in
            guard let location = placemarks?.first(where: { $0.location != nil })?.location else {
                completion(false)
                return
            }

            self?.coordinate = location.coordinate

            completion(true)
        }
    }
}

extension Collection where Element == Job {
    func firstIndex(for identifier: Job.ID) -> Self.Index? {
        return firstIndex(where: { $0.id == identifier })
    }
}
