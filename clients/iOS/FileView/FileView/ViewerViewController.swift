//
//  ViewerViewController.swift
//  FileView
//
//  Created by Kevin Scardina on 3/27/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class ViewerViewController: ViewController {
    var contents = Data()
    var contentsType = ""
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var exitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.allowsInlineMediaPlayback = true
        self.webView.allowsPictureInPictureMediaPlayback = true
        self.webView.mediaPlaybackAllowsAirPlay = true
        
        self.webView.load(contents, mimeType: contentsType, textEncodingName: "UTF-8", baseURL: NSURL() as URL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
