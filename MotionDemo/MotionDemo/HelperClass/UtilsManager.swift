import Foundation
import UIKit

class UtilsManager {
    static let shared = UtilsManager()
    private init() { }
    
    func changeOrientation(orientation: UIInterfaceOrientationMask) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)
        windowScene.requestGeometryUpdate(geometryPreferences) { error in
            print("Error requesting geometry update: \(error.localizedDescription)")
        }
    }
}
