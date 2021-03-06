//
//  WebViewController4.swift
//  CreativeEconomy.IOS.legacy
//
//  Created by 안치홍 on 2017. 2. 17..
//  Copyright © 2017년 Hong. All rights reserved.
//

import UIKit
import KakaoNavi

class CE_WebViewController4: UIViewController {

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        tabBarController?.selectedIndex = 0
        self.tabBarController?.selectedViewController?.viewDidAppear(true)
        
        loadNavi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loadNavi() {

        // NAVI INIT START
        let option: KNVOptions = KNVOptions.init()
        let naviLauncher:KNVNaviLauncher = KNVNaviLauncher.init()
        let coordType: KNVCoordType = KNVCoordType.init(rawValue: 2)!
        let navi: KNVLocation = KNVLocation(name: "제주창조경제혁신센터", x:126.5300349, y: 33.5003147)
        option.coordType = coordType
//        let params: KNVParams = KNVParams.param(withDestination: navi, options: option)
        let params: KNVParams = KNVParams.param(withDestination: navi, options: option)
//        let params: KNVParams = KNVParams.param(withDestination: navi, options: option)
        
        // NAVI START
        
        naviLauncher.shareDestination(with: params, error: nil)
//        naviLauncher.shareDestination(with: params, error: nil)

        // NAVI RELATED ACTION FINISH
    }
}
