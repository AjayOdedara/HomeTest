//
//  NewJourneyViewController.swift
//  MyTakeHomeTest
//
//  Created by Ajay Odedra on 23/03/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//



import UIKit
import CoreLocation
import MapKit

class NewJourneyViewController: UIViewController {
    
    @IBOutlet weak var trackingSwitch: UISwitch!
    @IBOutlet weak var launchPromptStackView: UIStackView!
    @IBOutlet weak var dataStackView: UIStackView!
    @IBOutlet weak var userTrackingStack: UIStackView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    let viewModel: NewJourneyViewModel = NewJourneyViewModel()
    private var locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func bindViewModel(){
        self.title = viewModel.title
        trackingSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        dataStackView.isHidden = true
    }
    
    @objc func switchChanged(tracking: UISwitch) {
        
        if tracking.isOn{
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }else{
            locationManager.stopUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.pausesLocationUpdatesAutomatically = true
        }
    }
    
    @IBAction func startTapped() {
        startRun()
    }
    
    @IBAction func stopTapped() {
        
        let alertController = UIAlertController(title: "End run?",
                                                message: "Do you wish to end your run?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.stopRun()
            self.viewModel.saveRun()
            self.performSegue(withIdentifier: .details, sender: nil)
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.stopRun()
            _ = self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alertController, animated: true)
    }
    
    private func startRun() {
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        userTrackingStack.isHidden = false
        launchPromptStackView.isHidden = true
        dataStackView.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = false
        mapContainerView.isHidden = false
        
        mapView.showsUserLocation = true
        mapView.removeOverlays(mapView.overlays)
        
        viewModel.seconds = 0
        viewModel.distance = Measurement(value: 0, unit: UnitLength.meters)
        viewModel.locationList.removeAll()
        updateDisplay()
        viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        
        DispatchQueue.main.async {
            self.startLocationUpdates()
        }
        
    }
    
    private func stopRun() {
        
        userTrackingStack.isHidden = true
        launchPromptStackView.isHidden = false
        dataStackView.isHidden = true
        startButton.isHidden = false
        stopButton.isHidden = true
        mapContainerView.isHidden = true
        
        
        locationManager.stopUpdatingLocation()
    }
    
    func eachSecond() {
        viewModel.seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(viewModel.distance)
        let formattedTime = FormatDisplay.time(viewModel.seconds)
        let formattedPace = FormatDisplay.pace(distance: viewModel.distance,
                                               seconds: viewModel.seconds,
                                               outputUnit: UnitSpeed.minutesPerMile)
        
        distanceLabel.text = "Distance:  \(formattedDistance)"
        timeLabel.text = "Time:  \(formattedTime)"
        paceLabel.text = "Pace:  \(formattedPace)"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
}

// MARK: - Navigation

extension NewJourneyViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        case details = "RunDetailsViewController"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .details:
            let destination = segue.destination as! RunDetailsViewController
            destination.run = viewModel.run
        }
    }
}

// MARK: - Location Manager Delegate

extension NewJourneyViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = viewModel.locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                viewModel.distance = viewModel.distance + Measurement(value: delta, unit: UnitLength.meters)
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
            }
            
            viewModel.locationList.append(newLocation)
        }
    }
}

// MARK: - Map View Delegate

extension NewJourneyViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
}

