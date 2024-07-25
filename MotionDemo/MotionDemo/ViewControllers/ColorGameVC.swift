import UIKit
import CoreMotion

enum MotionTypes {
    case front
    case back
    case ideal
}

class ColorGameVC: UIViewController {

    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var startCountLbl: UILabel!
    @IBOutlet weak var startCountBackground: UIView!
    @IBOutlet weak var stopBtn: UIButton!
    
    private let motionManager = CMMotionManager()
    private var lastMotion: MotionTypes = .ideal
    private var startCounter = 3 {
        didSet {
            if startCounter < 0 {
                self.startCountBackground.removeFromSuperview()
            }
            self.startCountLbl.text = "\(startCounter)"
        }
    }
    private var numberCount: Int = 50 {
        didSet {
            self.numberLbl.text = "\(numberCount)"
        }
    }
    
    private let deviceOrientation: UIInterfaceOrientationMask = .landscape
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doInitSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UtilsManager.shared.changeOrientation(orientation: deviceOrientation)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.startCountBackground.alpha = 1
            UIView.animate(withDuration: 0.5, animations: {
                self.startCountBackground.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.startCountBackground.alpha = 0.4
            }, completion: { _ in
                self.startCountBackground.alpha = 0
                self.startCountBackground.transform = .identity
                self.startCounter -= 1
                if self.startCounter < 0 {
                    timer.invalidate()
                    self.startGame()
                }
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startCountBackground.layer.cornerRadius = self.startCountBackground.frame.size.width / 2
        self.startCountBackground.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
    }

    private func doInitSetup(){
        self.numberLbl.isHidden = true
        self.stopBtn.isHidden = true
        self.startCountBackground.alpha = 0
        self.startCountLbl.text = "\(startCounter)"
    }

}

// MARK: Private methods
extension ColorGameVC {
    private func startGame() {
        self.numberLbl.isHidden = false
        self.stopBtn.isHidden = false
        self.numberLbl.text = "\(numberCount)"
        self.view.backgroundColor = .white
        
        // Request permission for motion usage
        CMMotionActivityManager().queryActivityStarting(from: Date(), to: Date(), to: OperationQueue.main) { activities, error in
            if let error = error {
                debugPrint("Motion data access was denied or restricted: \(error.localizedDescription)")
            } else {
                debugPrint("Motion data access was granted.")
                self.startMotionDetection()
            }
        }
    }
    
    private func startMotionDetection() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1 // Update interval in seconds
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (motion, error) in
                guard let motion = motion, error == nil else {
                    return
                }
                self?.handleDeviceMotion(motion: motion)
            }
        } else {
            print("Device motion is not available")
        }
    }
    
    private func handleDeviceMotion(motion: CMDeviceMotion) {
        let xDegree = motion.gravity.x * 180 / .pi
        let yDegree = motion.gravity.y * 180 / .pi
        let zDegree = motion.gravity.z * 180 / .pi
        debugPrint("X Degree: \(xDegree)")
        debugPrint("Y Degree: \(yDegree)")
        debugPrint("Z Degree: \(zDegree)")

        var currentMotion: MotionTypes = .ideal
        if zDegree >= 20 && zDegree <= 30 && abs(yDegree) <= 20 {
            self.changeColor(to: .blue)
            currentMotion = .front
        } else if zDegree <= -30 && zDegree >= -40 && xDegree <= -20{
            self.changeColor(to: .red)
            currentMotion = .back
        } else if zDegree > 30 || zDegree < -40 {
            currentMotion = lastMotion
        } else {
            currentMotion = .ideal
        }
        
        if currentMotion != lastMotion {
            switch currentMotion {
            case .front:
                numberCount -= 1
            case .back:
                numberCount += 1
            case .ideal:
                break
            }
            lastMotion = currentMotion
        }
    }
    
    private func changeColor(to color: UIColor) {
        self.view.backgroundColor = color
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
            self.view.backgroundColor = .white
        })
    }
}

// MARK: Action Methods
extension ColorGameVC {
    @IBAction func stopBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
