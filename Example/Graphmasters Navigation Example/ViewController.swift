import CoreLocation
import GraphamstersNavigationVoiceInstructions
import GraphmastersNavigation
import GraphmastersNavigationCore
import Mapbox
import UIKit

class ViewController: UIViewController {
    private lazy var navigationSdk: NavigationSdk = IosNavigationSdk(
        apiKey: Configuration.navigationApiKey
    )

    private lazy var cameraComponent = CameraComponent(navigationSdk: navigationSdk, paddingProvider: self)
    private lazy var voiceInstructionComponent = VoiceInstructionComponent(navigationSdk: navigationSdk)

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()

    /// - note: This can be replaced by `DetailedDistanceConverter`
    private let distanceConverter: DistanceConverter = RoundedDistanceConverter()

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    // MARK: - Outlets

    @IBOutlet var mapView: MGLMapView!

    @IBOutlet var turnCommandLabel: UILabel!
    @IBOutlet var turnDirectionLabel: UILabel!
    @IBOutlet var turnDistanceLabel: UILabel!
    @IBOutlet var arrivalLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        voiceInstructionComponent.enabled = true
        locationManager.requestWhenInUseAuthorization()

        configureMapView()

        navigationSdk.navigationEventHandler.addOnNavigationStartedListener(onNavigationStartedListener: self)
        navigationSdk.navigationEventHandler.addOnInitialRouteReceivedListener(onInitialRouteReceivedListener: self)
        navigationSdk.navigationEventHandler.addOnTrackingSpeedReachedListener(onTrackingSpeedReachedListener: self)
        navigationSdk.navigationEventHandler.addOnRouteUpdateListener(onRouteUpdateListener: self)
        navigationSdk.navigationEventHandler.addOnDestinationChangedListener(onDestinationChangedListener: self)
        navigationSdk.navigationEventHandler.addOnDestinationReachedListener(onDestinationReachedListener: self)
        navigationSdk.navigationEventHandler.addOnNavigationStoppedListener(onNavigationStoppedListener: self)

        navigationSdk.navigationStateProvider.addOnNavigationStateInitializedListener(onNavigationStateInitializedListener: self)
        navigationSdk.navigationStateProvider.addOnNavigationStateUpdatedListener(onNavigationStateUpdatedListener: self)

        cameraComponent.navigationCameraHandler.addCameraUpdateListener(cameraUpdateListener: self)
        cameraComponent.navigationCameraHandler.startCameraTracking()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    private func configureMapView() {
        mapView.styleURL = URL(string: Configuration.mapStyleUrl)!
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.addGestureRecognizer(mapLongPressGestureRecognizer)
    }

    // MARK: - User Interactions

    @IBAction func stopNavigationButtonPressed(_: Any) {
        navigationSdk.navigationEngine.stopNavigation()
    }

    @IBAction func followButtonPressed(_: Any) {
        cameraComponent.navigationCameraHandler.startCameraTracking()
    }

    private lazy var mapLongPressGestureRecognizer: UILongPressGestureRecognizer = .init(
        target: self,
        action: #selector(didLongPressMapView(sender:))
    )

    @IBAction
    private func didLongPressMapView(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: nil)
        do {
            try navigationSdk.navigationEngine.startNavigation(
                latLng: LatLng(latitude: coordinate.latitude, longitude: coordinate.longitude)
            )
        } catch {
            GMLog.shared.e(msg: "Can not start navigation")
        }
    }

    // MARK: - Route Layer

    /// - note: This can be replaced by any available `RouteFeatureCreator` or creating yourself.
    private lazy var routeFeatureCreator: RouteFeatureCreator = ColoringRouteFeatureCreator()

    private lazy var routeMapSource = MGLShapeSource(identifier: "ROUTE_SOURCE", shapes: [])

    private lazy var routeMapLayer: MGLStyleLayer = {
        let layer = MGLLineStyleLayer(identifier: "ROUTE_LAYER", source: routeMapSource)
        layer.lineWidth = NSExpression(forMGLInterpolating: .zoomLevelVariable,
                                       curveType: .linear,
                                       parameters: nil,
                                       stops: NSExpression(forConstantValue: [
                                           1: 1,
                                           16: 10,
                                           20: 16,
                                       ]))
        layer.lineColor = NSExpression(forKeyPath: "fill-color")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineJoin = NSExpression(forConstantValue: "round")
        return layer
    }()

    private lazy var routeOutlineMapLayer: MGLStyleLayer = {
        let layer = MGLLineStyleLayer(identifier: "ROUTE_OUTLINE_LAYER", source: routeMapSource)
        layer.lineWidth = NSExpression(forMGLInterpolating: .zoomLevelVariable,
                                       curveType: .linear,
                                       parameters: nil,
                                       stops: NSExpression(forConstantValue: [
                                           1: 2.5,
                                           16: 12.5,
                                           20: 19,
                                       ]))
        layer.lineColor = NSExpression(forKeyPath: "outline-color")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineJoin = NSExpression(forConstantValue: "round")
        return layer
    }()
}

// MARK: - Map Handling

extension ViewController: MGLMapViewDelegate {
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        guard mapView.styleURL == URL(string: Configuration.mapStyleUrl) else {
            return
        }
        style.addSource(routeMapSource)
        style.addLayer(routeOutlineMapLayer)
        style.addLayer(routeMapLayer)
    }

    func mapView(_: MGLMapView, regionIsChangingWith reason: MGLCameraChangeReason) {
        guard reason != MGLCameraChangeReason.programmatic else {
            return
        }
        cameraComponent.navigationCameraHandler.stopCameraTracking()
    }
}

// MARK: - Location Updating

extension ViewController: CLLocationManagerDelegate {
    func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let newLocation = locations.last else {
            return
        }
        navigationSdk.updateLocation(location: .companion.from(clLocation: newLocation))
    }
}

// MARK: - Camera Handling

extension ViewController: NavigationCameraHandlerCameraUpdateListener {
    func onCameraUpdateReady(cameraUpdate: CameraUpdate) {
        let camera = MGLMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(
                latitude: cameraUpdate.latLng.latitude,
                longitude: cameraUpdate.latLng.longitude
            ),
            acrossDistance: convertToDistance(
                zoom: cameraUpdate.zoom?.doubleValue ?? 12,
                pitch: cameraUpdate.tilt?.doubleValue ?? 0,
                latitude: cameraUpdate.latLng.latitude
            ),
            pitch: cameraUpdate.tilt?.doubleValue ?? 0,
            heading: cameraUpdate.bearing?.doubleValue ?? 0
        )

        mapView.setCamera(
            camera,
            withDuration: cameraUpdate.duration?.timeInterval ?? 0,
            animationTimingFunction: CAMediaTimingFunction(name: .linear),
            edgePadding: UIEdgeInsets(
                top: CGFloat(cameraUpdate.padding.top),
                left: CGFloat(cameraUpdate.padding.left),
                bottom: CGFloat(cameraUpdate.padding.bottom),
                right: CGFloat(cameraUpdate.padding.right)
            ),
            completionHandler: nil
        )
    }

    private func convertToDistance(zoom: Double, pitch: CGFloat, latitude: CLLocationDegrees) -> CLLocationDistance {
        return MGLAltitudeForZoomLevel(
            zoom,
            pitch,
            latitude,
            mapView.bounds.size
        )
    }
}

extension ViewController: PaddingProvider {
    func getPadding() -> CameraUpdate.Padding {
        CameraUpdate.Padding(left: 0, top: Int32(0.4 * view.bounds.height), right: 0, bottom: 0)
    }
}

// MARK: - Navigation Events

extension ViewController: NavigationEventHandlerOnNavigationStartedListener {
    func onNavigationStarted(routable _: Routable) {
        GMLog.shared.d(msg: "onNavigationStarted")
        cameraComponent.navigationCameraHandler.startCameraTracking()
    }
}

extension ViewController: NavigationEventHandlerOnInitialRouteReceivedListener {
    func onInitialRouteReceived(route _: Route) {
        GMLog.shared.d(msg: "onInitialRouteReceived")
    }
}

extension ViewController: NavigationStateProviderOnNavigationStateInitializedListener {
    func onNavigationStateInitialized(navigationState _: NavigationStateProviderNavigationState) {
        GMLog.shared.d(msg: "onNavigationStateInitialized")
    }
}

extension ViewController: NavigationStateProviderOnNavigationStateUpdatedListener {
    func onNavigationStateUpdated(navigationState: NavigationStateProviderNavigationState) {
        GMLog.shared.d(msg: "onNavigationStateUpdated")

        guard let routeProgress = navigationState.routeProgress else {
            return clearNavigationInfoView()
        }
        updateNavigationInfoView(from: routeProgress)
    }

    private func updateNavigationInfoView(from routeProgress: RouteProgressTrackerRouteProgress) {
        turnCommandLabel.text = routeProgress.nextMilestone?.turnInfo?.turnCommand.description() ?? "---"
        turnDirectionLabel.text = routeProgress.nextMilestone?.turnInfo.map {
            TurnInfoUtils.shared.getTurnInfoLabel(turnInfo: $0)
        } ?? "---"
        let formattedTurnCommandDistance = distanceConverter.convert(
            length: routeProgress.nextMilestoneDistance,
            measurementSystem: .metric
        )
        turnDistanceLabel.text = "\(formattedTurnCommandDistance.value) \(formattedTurnCommandDistance.unit)"

        arrivalLabel.text = timeFormatter.string(from: Date().addingTimeInterval(routeProgress.remainingTravelTime.timeInterval))

        durationLabel.text = "\(routeProgress.remainingTravelTime.minutes()) min"

        let formattedDistance = distanceConverter.convert(
            length: routeProgress.remainingDistance,
            measurementSystem: .metric
        )
        distanceLabel.text = "\(formattedDistance.value) \(formattedDistance.unit)"
    }

    private func clearNavigationInfoView() {
        turnCommandLabel.text = "---"
        turnDirectionLabel.text = "---"
        turnDistanceLabel.text = "---"

        arrivalLabel.text = "---"
        durationLabel.text = "---"
        distanceLabel.text = "---"
    }
}

extension ViewController: NavigationEventHandlerOnTrackingSpeedReachedListener {
    func onTrackingSpeedReached(speed _: Speed) {
        GMLog.shared.d(msg: "onTrackingSpeedReached")
    }
}

extension ViewController: NavigationEventHandlerOnRouteUpdateListener {
    func onRouteUpdated(route: Route) {
        GMLog.shared.d(msg: "onRouteUpdated")
        updateRouteOnMap(route: route)
    }

    private func updateRouteOnMap(route: Route) {
        do {
            routeMapSource.shape = try routeFeatureCreator.createFeatures(waypoints: route.waypoints).mglFeature
        } catch {
            GMLog.shared.e(msg: "Can not create route features")
        }
    }
}

extension ViewController: NavigationEventHandlerOnDestinationChangedListener {
    func onDestinationChanged(routable _: Routable?) {
        GMLog.shared.d(msg: "onDestinationChanged")
    }
}

extension ViewController: NavigationEventHandlerOnDestinationReachedListener {
    func onDestinationReached(routable _: Routable) {
        GMLog.shared.d(msg: "onDestinationReached")
    }
}

extension ViewController: NavigationEventHandlerOnNavigationStoppedListener {
    func onNavigationStopped() {
        GMLog.shared.d(msg: "onNavigationStopped")
        clearNavigationInfoView()
        routeMapSource.shape = nil
    }
}
