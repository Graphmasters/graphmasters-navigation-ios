import CoreLocation
import GraphmastersNavigation
import GraphmastersNavigationCore
import Mapbox
import UIKit

class ViewController: UIViewController {
    /// - note: This can be replaced by `DetailedDistanceConverter`
    private let distanceConverter: DistanceConverter = RoundedDistanceConverter()

    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()

    private lazy var navigationSdk = IosNavigationSdk(
        serviceUrl: Configuration.navigationApiUrl,
        apiKey: Configuration.navigationApiKey
    )

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private lazy var routeDetachStateProvider: RouteDetachStateProvider = OffRouteDetachStateProvider(navigationSdk: navigationSdk)

    private lazy var uiLocationProvider: LocationProvider = PredictedLocationProvider(
        executor: AppleExecutor(),
        navigationSdk: navigationSdk,
        routeDetachStateProvider: routeDetachStateProvider,
        maxMilestoneStopSpeed: PredictedLocationProvider.Companion.shared
            .DEFAULT_NEXT_MILESTONE_STOP_SPEED,
        locationUpdateInterval: PredictedLocationProvider.Companion.shared
            .DEFAULT_LOCATION_UPDATE_INTERVAL
    )

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

        uiLocationProvider.addLocationUpdateListener(locationUpdateListener: self)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            try? self.navigationSdk.navigationEngine.startNavigation(routable_: RoutableFactory.shared.create(latLng: .init(latitude: 52, longitude: 8).graphmastersOfficeVienna))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        uiLocationProvider.startLocationUpdates()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
        uiLocationProvider.stopLocationUpdates()
    }

    private func configureMapView() {
        mapView.styleURL = URL(string: Configuration.mapStyleUrl)!
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithCourse
        mapView.delegate = self
    }

    // MARK: - User Interactions

    @IBAction func stopNavigationButtonPressed(_: Any) {
        navigationSdk.navigationEngine.stopNavigation()
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
                                           20: 19
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
        navigationSdk.updateLocation(location: Location.companion.from(clLocation: newLocation))
    }
}

extension ViewController: LocationProviderLocationUpdateListener {
    func onLocationUpdated(location: Location) {
        mapView.locationManager.delegate?.locationManager(mapView.locationManager, didUpdate: [location.clLocation])
    }
}

// MARK: - Navigation Events

extension ViewController: NavigationEventHandlerOnNavigationStartedListener {
    func onNavigationStarted(routable _: Routable) {
        GMLog.shared.d(msg: "onNavigationStarted")
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

        arrivalLabel.text = timeFormatter.string(from: Date().addingTimeInterval(routeProgress.remainingTravelTime.timeinterval))

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
        routeMapSource.shape = try! routeFeatureCreator.createFeatures(waypoints: route.waypoints).mglFeature
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
