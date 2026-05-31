//
//  ViewController.swift
//  Ex1
//
//  Created by sagi dreshman on 31/05/2026.
//

import UIKit
import CoreLocation

enum PlayerSide {
    case west
    case east
}

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sideLabel: UILabel!

    private let nameKey = "playerName"
    private let middleLongitude = 34.817549168324334

    private let locationManager = CLLocationManager()
    private var playerSide: PlayerSide?

    private var playerName: String? {
        get { UserDefaults.standard.string(forKey: nameKey) }
        set { UserDefaults.standard.set(newValue, forKey: nameKey) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        print("Saved name on launch: \(playerName ?? "<none>")")
        updateNameButton()
        updateStartButton()
        requestLocation()
    }

    // MARK: - Name button

    @IBAction func nameButtonTapped(_ sender: UIButton) {
        if playerName == nil {
            promptForName()
        }
    }

    private func updateNameButton() {
        if let name = playerName, !name.isEmpty {
            nameButton.setTitle("Hi \(name)", for: .normal)
        } else {
            nameButton.setTitle("Insert name", for: .normal)
        }
    }

    private func promptForName() {
        let alert = UIAlertController(title: "Enter your name", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Your name"
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces)
            guard let name = name, !name.isEmpty else { return }
            self.playerName = name
            self.updateNameButton()
            self.updateStartButton()
        })
        present(alert, animated: true)
    }

    // MARK: - Start button

    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard let name = playerName, !name.isEmpty, let side = playerSide else { return }
        print("Starting game as \(name) on side \(side)")
        performSegue(withIdentifier: "showGame", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGame",
           let dest = segue.destination as? GameViewController,
           let name = playerName, let side = playerSide {
            dest.playerName = name
            dest.playerSide = side
            dest.modalPresentationStyle = .fullScreen
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Returning from game/summary - keep UI consistent.
        updateNameButton()
        updateStartButton()
    }

    private func updateStartButton() {
        let hasName = !(playerName?.isEmpty ?? true)
        let hasSide = playerSide != nil
        startButton.isEnabled = hasName && hasSide
        updateSideLabel()
    }

    private func updateSideLabel() {
        switch playerSide {
        case .west:
            sideLabel.text = "You are on the West Side"
        case .east:
            sideLabel.text = "You are on the East Side"
        case .none:
            sideLabel.text = "Waiting for location..."
        }
    }

    // MARK: - Location

    private func requestLocation() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            showLocationDeniedAlert()
        @unknown default:
            break
        }
    }

    private func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "Location required",
            message: "The game needs your location to decide your side. Enable it in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let longitude = loc.coordinate.longitude
        playerSide = (longitude >= middleLongitude) ? .east : .west
        manager.stopUpdatingLocation()
        print("Got location: longitude=\(longitude), side=\(playerSide!)")
        updateStartButton()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
