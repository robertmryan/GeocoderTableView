//
//  ViewController.swift
//  GeocoderTableView
//
//  Created by Robert Ryan on 1/21/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var jobs: [Job] = []

    lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 100 // if we're displaying distance to nearest tenth of kilometer, then update table when location changes by that amount
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        jobs = [
            Job(company: "Apple", position: "Senior iOS Developer", location: "One Apple Park Way, Cupertino, CA 95014"),
            Job(company: "Google", position: "Senior Android Developer", location: "1600 Amphitheatre Parkway, Mountain View, CA 94043"),
            Job(company: "Microsoft", position: "Senior .NET Developer", location: "4001 156th Ave NE, Redmond, WA  98052")
        ]

        startLocationManager()
        addRandomJobs(count: 100)
    }
}

// MARK: - Private utility methods

private extension ViewController {
    func addRandomJobs(count: Int) {
        guard count > 0 else { return }

        let geocoder = CLGeocoder()

        let location = CLLocation(latitude: .random(in: 30 ... 50), longitude: .random(in: -120 ... -80))
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // delay a second to avoid getting rate limited
                self.addRandomJobs(count: count - 1)
            }

            if let error = error {
                print(error)
            }

            guard let placemark = placemarks?.first else { return }
            
            let address = [placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode]
                .compactMap { $0 }
                .joined(separator: ", ")
            let job = Job(company: "Company \(count)", position: "Position \(count)", location: address)
            let row = self.jobs.count
            self.jobs.append(job)
            self.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
    }

    func startLocationManager() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        manager.startUpdatingLocation()
    }
}

// MNARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell

        let job = jobs[indexPath.row]
        let location = job.coordinate.flatMap { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        cell.update(header: job.company, jobLocation: location, userLocation: manager.location)

        jobs[indexPath.row].geocodeIfNecessary { [weak self] didUpdateCoordinates in
            // reload cell if coordinates were updated
            // nb: search for the job in the array again (in case you edited the list while this asynchronous process was running)

            if didUpdateCoordinates, let index = self?.jobs.firstIndex(for: job.id) {
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }

        return cell
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        tableView.reloadData()
    }
}
