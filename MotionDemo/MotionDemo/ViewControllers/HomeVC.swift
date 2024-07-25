import UIKit

class HomeVC: UIViewController {

    private let deviceOrientation: UIInterfaceOrientationMask = .portrait
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UtilsManager.shared.changeOrientation(orientation: deviceOrientation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: Action method
extension HomeVC {
    @IBAction func startBtnTapped(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ColorGameVC") as! ColorGameVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
