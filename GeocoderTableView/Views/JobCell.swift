//
//  JobCell.swift
//  GeocoderTableView
//
//  Created by Robert Ryan on 1/21/21.
//

import UIKit
import CoreLocation

class JobCell: UITableViewCell {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    func update(header: String, jobLocation: CLLocation?, userLocation: CLLocation?) {
        headerLabel.text = header
        
        guard
            let jobLocation = jobLocation, jobLocation.horizontalAccuracy >= 0
        else {
            distanceLabel.text = "Retrieving job coordinates"
            return
        }

        guard
            let userLocation = userLocation,
            userLocation.horizontalAccuracy >= 0
        else {
            distanceLabel.text = "Still determining your location"
            return
        }

        let distance = jobLocation.distance(from: userLocation) / 1000
        distanceLabel.text = Self.formatter.string(for: distance)
    }
}

