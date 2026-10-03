import SwiftUI
import MapKit
struct MapView: View {
    var body: some View {
        Map(initialPosition: .region(region))
    }
}
private var region:MKCoordinateRegion{
    MKCoordinateRegion(center:
            CLLocationCoordinate2D(latitude: 22.2887, longitude:73.3634),
                       span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                       )
}
#Preview {
    MapView()
}
