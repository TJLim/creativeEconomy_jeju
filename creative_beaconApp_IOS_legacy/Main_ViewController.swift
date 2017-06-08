//
//  ViewController.swift
//  CreativeEconomy.IOS.legacy
//
//  Created by 안치홍 on 2017. 2. 17..
//  Copyright © 2017년 Hong. All rights reserved.
//

import UIKit
import Tamra
//import CoreBluetooth
import Alamofire
import SystemConfiguration

class Main_ViewController: UIViewController,  TamraManagerDelegate {
    
    var tamraManager: TamraManager!
    var visited: [Int: Visit] = [:]
//    var bluetoothPeripheralManager: CBPeripheralManager?
    var appDelegate = AppDelegate()
    var mappingContentsNo: Int?
    var mappingContentsTitle: String?
    var mappingFilePath: String?
    
    let screenWidth = UIScreen.main.bounds.size.width   // 뷰 전체 폭 길이
    let screenHeight = UIScreen.main.bounds.size.height // 뷰 전체 높이 길이
    
    let creativeGoBtn = UIButton()
    let jungmunGoBtn = UIButton()
//    let middleLabel = UILabel()
    
    let CE_middleLabel = UILabel()
    let JM_middleLabel = UILabel()
    
    var getDataOfProcessNetwork: Bool = false // Network가 연결 되어있는지 확인하는  Bool 타입 변수
    var getDataThreadTimer: Timer!
    var common: CommonController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initData()
        makeUI()
        
        common = CommonController()
        
        getDataOfProcessNetwork = isConnectedNetwork()
        
        if getDataOfProcessNetwork {
            
            print("네트워크 연결 OK")
        } else {
            print("네트워크 연결 NO")
        }
        
    }
    
    /* 해당 화면으로 접속 시 비콘 검색 시작*/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getDataProcess()
    }
    
    
    
    /* 다른 화면으로 이동시 비콘 검색 종료 */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Main_ViewController : 비콘 검색 종료")
        
        tamraManager.stopMonitoring()
    }
    
    func tamraManager(didRangeSpots spots: TamraNearbySpots) {
        let filtered = spots.filter {
            spot in
            return spot.proximity == .Immediate || spot.proximity == .Near
        }
        
        for spot in filtered {
            if let visit = visited[spot.id] {
                visited[spot.id] = visit.update()
            } else {
                visited[spot.id] = Visit(desc: spot.desc, entry: NSDate())
                let message = "\(spot.desc) 에 접근했습니다."
                
                print(message)
                
                isExistsMappingContentsId(spot.id, spotDesc: spot.desc)
            }
        }
    }
    
    
    
    func initData() {
        
//        let options = [CBCentralManagerOptionShowPowerAlertKey:0] //<-this is the magic bit!
//        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: options)
        /*비콘 검색 초기화*/
        Tamra.requestLocationAuthorization()
        
        tamraManager = TamraManager()
        tamraManager.delegate = self
        tamraManager.ready()
    }
    
    
    /*
     *
     */
    func getDataProcess() {
        
        if getDataOfProcessNetwork {
            
            print("Main_ViewController : 비콘 검색 시작")
            tamraManager.startMonitoring(forId: 2)
            tamraManager.startMonitoring(forId: 3)
            tamraManager.startMonitoring(forId: 4)
            
//            tamraManager.startMonitoring(forId: 72)
//            tamraManager.startMonitoring(forId: 73)
//            tamraManager.startMonitoring(forId: 74)
//            tamraManager.startMonitoring(forId: 75)
//            tamraManager.startMonitoring(forId: 76)
//            tamraManager.startMonitoring(forId: 77)
//            tamraManager.startMonitoring(forId: 78)
            
            
            
        } else {
            
            makeAlertDialog("NetworkOff")
            getDataThreadTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(Main_ViewController.getDataThread), userInfo: nil, repeats: true)
        }
    }
    
    
    
    func makeUI() {
        let view1 = UIView()
        let view2 = UIView()
        
        creativeGoBtn.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight / 2)
        jungmunGoBtn.frame = CGRect(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight / 2)

        view1.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight / 2)
        view2.frame = CGRect(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight / 2)
        view1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        view2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        creativeGoBtn.setImage(UIImage(named: "img_1"), for: UIControlState())
//        creativeGoBtn.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        jungmunGoBtn.setImage(UIImage(named: "img_2"), for: UIControlState())

        creativeGoBtn.addTarget(self, action: #selector(Main_ViewController.goCreative), for: .touchUpInside)
        jungmunGoBtn.addTarget(self, action: #selector(Main_ViewController.goJungmun), for: .touchUpInside)
        
        let creativeGesture = UITapGestureRecognizer(target: self, action: #selector(Main_ViewController.goCT(_:)))
        let jungmunGesture = UITapGestureRecognizer(target: self, action: #selector(Main_ViewController.goJM(_:)))
        view1.addGestureRecognizer(creativeGesture)
        view2.addGestureRecognizer(jungmunGesture)
        
        CE_middleLabel.text = "새로운 연결을 통한 창조의 섬\n제주창조경제혁신센터"
        CE_middleLabel.numberOfLines = 0
        CE_middleLabel.font = UIFont(name: (CE_middleLabel.font?.fontName)!, size: 17)
        CE_middleLabel.textAlignment = .center
        
        let middleLabelHeight1 = calculateContentHeight(CE_middleLabel)

        CE_middleLabel.frame = CGRect(x: 15, y: (screenHeight / 2 - middleLabelHeight1) / 2, width: screenWidth - 30, height: middleLabelHeight1)
        CE_middleLabel.textColor = UIColor(red: 248/255, green: 242/255, blue: 224/255, alpha: 1)
        
        JM_middleLabel.text = "천혜의 자연경관, 국가대표 관광지\n중문관광단지"
        JM_middleLabel.numberOfLines = 0
        JM_middleLabel.font = UIFont(name: (CE_middleLabel.font?.fontName)!, size: 17)
        JM_middleLabel.textAlignment = .center
        
        let middleLabelHeight2 = calculateContentHeight(JM_middleLabel)

        JM_middleLabel.frame = CGRect(x: 15, y: screenHeight / 2 + (screenHeight / 2 - middleLabelHeight1) / 2, width: screenWidth - 30, height: middleLabelHeight2)
        JM_middleLabel.textColor = UIColor(red: 248/255, green: 242/255, blue: 224/255, alpha: 1)
        
        
        self.view.addSubview(creativeGoBtn)
        self.view.insertSubview(view1, aboveSubview: creativeGoBtn)
        self.view.addSubview(jungmunGoBtn)
        self.view.insertSubview(view2, aboveSubview: jungmunGoBtn)
        self.view.addSubview(CE_middleLabel)
        self.view.addSubview(JM_middleLabel)
    }
    
    
    func goCT(_ sender:UIGestureRecognizer) {
        
        self.performSegue(withIdentifier: "goCreativeSegue", sender: self)
    }
    
    func goJM(_ sender:UIGestureRecognizer) {
        
        self.performSegue(withIdentifier: "goJungmunSegue", sender: self)
    }
    
    
    /* 네트워크가 꺼져있을 때 설정 화면에서 네트워크를 켠 후 복귀 하면 해당 메소드가 탄다. */
    func getDataThread() {
        
        getDataOfProcessNetwork = isConnectedNetwork()
        
        if getDataOfProcessNetwork {
            
            getDataThreadTimer.invalidate()

            getDataProcess()
        }
    }
    
    /* 현재위치 불러오는 메소드 */
    @IBAction func goCreative(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "goCreativeSegue", sender: self)
    }
    
    
    /* 현재위치 불러오는 메소드 */
    @IBAction func goJungmun(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "goJungmunSegue", sender: self)
    }
    
    
    func calculateContentHeight(_ setLable: UILabel) -> CGFloat {
        
        let widthSizeminus: CGFloat = 30
        let maxlabelSize: CGSize = CGSize(width: self.view.frame.size.width - widthSizeminus, height: CGFloat(9999))
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]

        let contentNSString = setLable.text! as NSString
        let expectedLabelSize = contentNSString.boundingRect(with: maxlabelSize, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)], context: nil)
        
        return expectedLabelSize.size.height
    }
    
    
   
    
    /* Alamofire 를 이용하여 웹페이지 url을 호출하고 그에 맞는 결과값을 얻어 내오는 함수.
     
     감지한 비콘의 매핑 컨텐츠가 존재하는 경우 alert창을 띄움
     감지한 비콘의 매핑 컨텐츠가 존재하지 않는 경우 반응 없음
     */
    func isExistsMappingContentsId(_ spotId: Int, spotDesc: String) {
        
        if spotId == 37 {
            
            makeAlertMessageGoCreative(spotDesc)
            
        } else {
            
            print("MAIN_VIEWER : 매핑 컨텐츠 검색 시작")
            
            Alamofire.request(.GET, common.mappingURL, parameters: ["beaconId": spotId, "userKey": "ietrceea"]).responseJSON{
//            Alamofire.request(.GET, common.mappingURL, parameters: ["beaconId": spotId, "userKey": "nndoonw"]).responseJSON{
                
                response in switch response.result {
                    
                case .Success(let JSON):
                    
                    let response = JSON as! NSDictionary
                    
                    // 응답 Json 의 Key인 "contentsNo" 로 Value를 얻음
                    let contentsNo = response.objectForKey("contentsNo")!
                    let contentsTitle = response.objectForKey("contentsTitle")
                    let filePath = response.objectForKey("filePath")
                    
                    print("Mapping Contents No : \(contentsNo)")
                    print("Spot ID : \(spotId)")
                    // 리턴 받은 Json 의 Value가 FALSE가 아닌 경우 메시지창 띄움
                    if !contentsNo.isEqual("FALSE") {
                        
                        self.mappingContentsNo = Int(contentsNo as! String)
                        self.mappingContentsTitle = contentsTitle as? String
                        self.makeAlertMessage(contentsNo, name: spotDesc)
                        self.mappingFilePath = filePath as? String
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
//    
//    override func prepareS(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        print("segue.identifier : \(segue.identifier)")
//        
//        
//        if segue.identifier == "mappingContents" {
//            
//            let sendData = segue.destination as! MappingContentsViewController
//            sendData.mappingContentsNo = mappingContentsNo
//            sendData.mappingContentsTitle = mappingContentsTitle
//            sendData.mappingFilePath = mappingFilePath
//        }
//    }
//    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier : \(segue.identifier)")
        
        
        if segue.identifier == "mappingContents" {
            
            let sendData = segue.destination as! MappingContentsViewController
            
            sendData.mappingContentsNo = mappingContentsNo
            sendData.mappingContentsTitle = mappingContentsTitle
            sendData.mappingFilePath = mappingFilePath
        }
    }
    
    
    
    /* url scheme 이용하여 다음지도 열기 */
    func open(_ scheme: String) {
        let url = URL(string: scheme)!
        
        if #available(iOS 10, *) {

            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    
    
    
    /* 매핑된 컨텐츠가 제주공항 37번 비콘일 경우 alert창을 띄워 지도를 보여줄지 말지 선택하는 함수*/
    func makeAlertMessageGoCreative(_ name: String) {
        
        let alert = UIAlertController(title: "비콘신호감지", message: "\(name)에서 제주 창조경제혁신센터로 갈 수 있는 지도정보를 제공합니다.\n해당 내용을 확인 하시겠습니까?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title:  "확인", style: .default, handler: {
            alert -> Void in
            
            self.open("daummaps://route?sp=33.5098976,126.4896447&ep=33.5003147,126.5300349&by=PUBLICTRANSIT")
        })

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /* 매핑된 컨텐츠가 있을 경우 alert창을 띄워 매핑 컨텐츠를 보여줄지 말지 선택하는 함수*/
    func makeAlertMessage(_ contentsNo: AnyObject, name: String) {
        
        let alert = UIAlertController(title: "비콘신호감지", message: "\(name)에서 비콘 신호를 감지하였습니다.\n해당 내용을 확인 하시겠 습니까?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title:  "확인", style: .default, handler: {
            alert -> Void in
            
            self.performSegue(withIdentifier: "mappingContents", sender: self)

        })

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
//    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
//        print("블루투스 상태 확인")
//        
//        var statusMessage = ""
//        
//        switch peripheral.state {
//            
//        case .PoweredOn:
//            statusMessage = "Bluetooth Status: Turned On"
//            
//        case .PoweredOff:
//            statusMessage = "Bluetooth Status: Turned Off"
//            
//        case .Resetting:
//            statusMessage = "Bluetooth Status: Resetting"
//            
//        case .Unauthorized:
//            statusMessage = "Bluetooth Status: Not Authorized"
//            
//        case .Unsupported:
//            statusMessage = "Bluetooth Status: Not Supported"
//            
//        default:
//            statusMessage = "Bluetooth Status: Unknown"
//        }
//        
//        print(statusMessage)
//        
//        if peripheral.state == .PoweredOff {
//            bluetoothPowerOffSetMessage()
//            appDelegate.bluetoothState = false
//            
//            print("Main_ViewController : BlueTooth.PowerOff => 비콘 검색 종료")
//            tamraManager.stopMonitoring()
//            
//        } else if peripheral.state == .PoweredOn {
//            appDelegate.bluetoothState = true
//        }
//    }
    
    
    func makeAlertDialog(_ type: String) {
        
        if type == "NetworkOff" {
            
            let alert = UIAlertController(title: "네트워크 오류", message: common.networkOffMessage, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "확인", style: .default) {
                (parameter) -> Void in
                
                UIApplication.shared.open(URL(string: "App-Prefs:root=Settings")!, options: [:], completionHandler: { (success) in
                    print("Open url : \(success)")
                })
                
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /*
     * 네트워크 연결 상태 체크 메서드
     * return true : 네트워크 연결 성공
     * return false : 네트워크 연결 실패
     */
    func isConnectedNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    /* 블루투스 상태 체크 확인 */
    func bluetoothPowerOffSetMessage() {
        
        let alert = UIAlertController(title: "블루투스 설정", message: "블루투스가 꺼져 있습니다.\n비콘에서 제공되는 컨텐츠를 앱에서 보기를 원하신다면 블루투스를 키셔야 합니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

struct Visit {
    let desc: String
    let entry: Date
    let stay: Date = Date()
    
    init(desc: String, entry: Date) {
        self.desc = desc
        self.entry = entry
    }
    
    func update() -> Visit {
        return Visit(desc: self.desc, entry: self.entry)
    }
}
