import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        print("[LocationManager] Initialized. Auth status: \(manager.authorizationStatus.debugName)")
    }

    func requestLocation() async throws -> CLLocation {
        print("[LocationManager] requestLocation() called. Auth status: \(manager.authorizationStatus.debugName)")
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            switch manager.authorizationStatus {
            case .notDetermined:
                print("[LocationManager] Status not determined — requesting WhenInUse authorization")
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                print("[LocationManager] Already authorized — calling requestLocation on CLLocationManager")
                manager.requestLocation()
            case .denied, .restricted:
                print("[LocationManager] Permission denied/restricted — failing immediately")
                continuation.resume(throwing: LocationError.permissionDenied)
                self.continuation = nil
            @unknown default:
                print("[LocationManager] Unknown auth status — requesting WhenInUse authorization")
                manager.requestWhenInUseAuthorization()
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("[LocationManager] Authorization changed → \(status.debugName)")
        guard continuation != nil else {
            print("[LocationManager] No pending continuation — ignoring auth change")
            return
        }
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("[LocationManager] Authorized — calling requestLocation on CLLocationManager")
            manager.requestLocation()
        case .denied, .restricted:
            print("[LocationManager] Denied/restricted — resuming continuation with error")
            continuation?.resume(throwing: LocationError.permissionDenied)
            continuation = nil
        case .notDetermined:
            print("[LocationManager] Still not determined — waiting for user choice")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("[LocationManager] didUpdateLocations called but list is empty")
            return
        }
        print("[LocationManager] Got location: lat=\(location.coordinate.latitude), lon=\(location.coordinate.longitude), accuracy=\(location.horizontalAccuracy)m")
        continuation?.resume(returning: location)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // CLError.locationUnknown is a transient "still searching" signal from requestLocation().
        // Resuming the continuation here would kill the request prematurely; ignore and wait.
        if let clError = error as? CLError, clError.code == .locationUnknown {
            print("[LocationManager] Transient locationUnknown error — still waiting for fix")
            return
        }
        print("[LocationManager] Failed with error: \(error.localizedDescription)")
        continuation?.resume(throwing: error)
        continuation = nil
    }

    enum LocationError: LocalizedError {
        case permissionDenied

        var errorDescription: String? {
            "Location access denied. Please enable it in Settings → Privacy → Location Services."
        }
    }
}

private extension CLAuthorizationStatus {
    var debugName: String {
        switch self {
        case .notDetermined:      return "notDetermined"
        case .restricted:         return "restricted"
        case .denied:             return "denied"
        case .authorizedAlways:   return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default:         return "unknown(\(rawValue))"
        }
    }
}
