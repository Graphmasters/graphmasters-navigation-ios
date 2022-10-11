import Mapbox
import UIKit

class ViewController: UIViewController {
    @IBOutlet var mapView: MGLMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.styleURL = URL(string: Configuration.mapStyleUrl)!
    }
}
