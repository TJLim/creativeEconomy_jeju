//
//  WebViewController1.swift
//  CreativeEconomy.IOS.legacy
//
//  Created by 안치홍 on 2017. 2. 17..
//  Copyright © 2017년 Hong. All rights reserved.
//

import UIKit
import Tamra
import Alamofire
import SystemConfiguration

class CE_WebViewController1: UIViewController, TamraManagerDelegate {
    
    @IBOutlet var webView: UIWebView!
    
    var receiveUrl = "/creativeEconomy/CreativeInfo.do"    // 치홍
    var tamraManager: TamraManager!
    var visited: [Int: Visit] = [:]

    var mappingContentsNo: Int?         // 매핑 컨텐츠 no
    var mappingContentsTitle: String?   // 매핑 컨텐츠 title
    var mappingFilePath: String?        // 매핑 컨텐츠 path
    
    var common: CommonController!
    
    var getDataOfProcessNetwork: Bool = false // Network가 연결 되어있는지 확인하는  Bool 타입 변수
    var getDataThreadTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        common = CommonController()
        initData()
        
        getDataOfProcessNetwork = isConnectedNetwork()
        
        if getDataOfProcessNetwork {
            
            print("네트워크 연결 OK")
        } else {
            print("네트워크 연결 NO")
        }
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    
    //    func willEnterForeground() {
    //        print("will enter foreground")
    //
    //    }
    //
    //    func didEnterBackground() {
    //
    //        print("did enter Background")
    //
    //    }
    
    
    /* 해당 화면으로 접속 시 비콘 검색 시작*/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        getDataProcess()
    }
    
    /*
     * 네트워크 연결 성공시 콘텐츠 url호출 및 비콘 감지 시작.
     * 네트워크 연결 실패시 메시지 띄우고 네트워크가 연결 될때 까지 쓰레드 동작.
     */
    func getDataProcess() {
        
        if getDataOfProcessNetwork {
            
            let req = URLRequest(url: URL(string: "\(common.HOST)\(self.receiveUrl)")!)
            self.webView.loadRequest(req)
            
            print("Main_ViewController : 비콘 검색 시작")
            tamraManager.startMonitoring(forId: 2)
            tamraManager.startMonitoring(forId: 3)
            tamraManager.startMonitoring(forId: 4)
            
        } else {
            
            makeAlertDialog("NetworkOff")
            getDataThreadTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(CE_WebViewController1.getDataThread), userInfo: nil, repeats: true)
        }
    }
    
    
    /* 다른 화면으로 이동시 비콘 검색 종료 */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("CE_Beacon_1 : 비콘 검색 종료")
        
        tamraManager.stopMonitoring()
    }
    
    
    /*
     * tamraSDK 초기화
     */
    func initData() {
        
        /*비콘 검색 초기화*/
        Tamra.requestLocationAuthorization()
        
        tamraManager = TamraManager()
        tamraManager.delegate = self
        tamraManager.ready()
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
    
    
    /* 
     * 네트워크 관련 메시지 띄우는 함수.
     * 확인 버튼 클릭시 아이폰 설정 화면으로 이동
     * 취소 버튼 클릭시 아무런 반응 없음.
     */
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
    
    
    
    /* 네트워크가 꺼져있을 때 설정 화면에서 네트워크를 켠 후 복귀 하면 해당 메소드가 탄다. */
    func getDataThread() {
        
        getDataOfProcessNetwork = isConnectedNetwork()
        
        if getDataOfProcessNetwork {
            
            getDataThreadTimer.invalidate()
            
            getDataProcess()
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
    
    /* Alamofire 를 이용하여 웹페이지 url을 호출하고 그에 맞는 결과값을 얻어 내오는 함수.
     
     감지한 비콘의 매핑 컨텐츠가 존재하는 경우 alert창을 띄움
     감지한 비콘의 매핑 컨텐츠가 존재하지 않는 경우 반응 없음
     */
    func isExistsMappingContentsId(_ spotId: Int, spotDesc: String) {
        
        if spotId == 37 {
            
            makeAlertMessageGoCreative(spotDesc)
            
        } else {
            
            print("CE_Beacon_1 : 매핑 컨텐츠 검색 시작")
            
            Alamofire.request(.GET, common.mappingURL, parameters: ["beaconId": spotId, "userKey": "ietrceea"]).responseJSON{

                response in switch response.result {
                    
                case .Success(let JSON):
                    
                    let response = JSON as! NSDictionary
                    
                    // 응답 Json 의 Key인 "contentsNo" 로 Value를 얻음
                    let contentsNo = response.objectForKey("contentsNo")!
                    let contentsTitle = response.objectForKey("contentsTitle")
                    let filePath = response.objectForKey("filePath")
                    
                    print("Mapping Contents No : \(contentsNo)")
                    
                    // 리턴 받은 Json 의 Value가 FALSE가 아닌 경우 메시지창 띄움
                    if !contentsNo.isEqual("FALSE") {
                        
                        self.mappingContentsNo = Int(contentsNo as! String)
                        self.mappingContentsTitle = contentsTitle as? String
                        self.mappingFilePath = filePath as? String
                        
                        self.makeAlertMessage(contentsNo, name: spotDesc)
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier : \(segue.identifier)")
        
        if segue.identifier == "mappingContents" {
            
            let sendData = segue.destination as! MappingContentsViewController

            sendData.mappingContentsNo = mappingContentsNo
            sendData.mappingContentsTitle = mappingContentsTitle
            sendData.mappingFilePath = mappingFilePath
        }
    }
    
    
    
    /* 매핑된 컨텐츠가 제주공항 37번 비콘일 경우 alert창을 띄워 지도를 보여줄지 말지 선택하는 함수*/
    func makeAlertMessageGoCreative(_ name: String) {
        
        let alert = UIAlertController(title: "비콘신호감지", message: "\(name)에서 제주 창조경제혁신센터로 갈 수 있는 지도정보를 제공합니다.\n해당 내용을 확인 하시겠습니까?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title:  "확인", style: .default, handler: {
            alert -> Void in

            self.open(self.common.creativeGoInfoURL)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func Back(_ sender: AnyObject) {
        
        if self.webView.canGoBack {
            
            self.webView.goBack()
            
        } else {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
