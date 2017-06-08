//
//  MappingContentsViewController.swift
//  creative_beaconApp_IOS_legacy
//
//  Created by 안치홍 on 2017. 4. 4..
//  Copyright © 2017년 안치홍. All rights reserved.
//

import UIKit

class MappingContentsViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    var mappingContentsNo: Int?
    var mappingContentsTitle: String?
    var mappingFilePath: String?
    
    @IBOutlet var NaviTItle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("filePath : \(mappingFilePath)")
        
        let req = URLRequest(url: URL(string: mappingFilePath!)!)
        print("req :  \(req)")
        
        NaviTItle.title = mappingContentsTitle
        self.webView.loadRequest(req)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Back(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
