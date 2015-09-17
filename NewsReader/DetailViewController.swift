//
//  DetailViewController.swift
//  NewsReader
//
//  Created by 酒井文也 on 2014/12/06.
//  Copyright (c) 2014年 just1factory. All rights reserved.
//

/* ----------------------------
■ Interface Builderにて忘れずにする作業：
1. @IBActionを作った後にgoBackButtonを選択して、Touch UP Insideから線をDetail View Controllerへつなげる
2. goback:と出たらそいつをクリックする

■ 画面仕様：
DetailViewController → 

1. ViewControllerから渡ってきたAPIに記載されているURLを表示
2. 戻るボタンを押すと一覧に戻ります。

＜更新情報＞
2015/01/13: AutoResizing対応
---------------------------- */

import UIKit

class DetailViewController: UIViewController {
    
    //URL表示用のWebView
    @IBOutlet var feedDetailWebView: UIWebView!
    
    //受け取るURL文字列
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ViewControllerから渡ってきたURLを表示します
        let url = NSURL(string: self.urlString)
        let request = NSURLRequest(URL: url!)
        
        //WebViewでURLを表示
        feedDetailWebView.loadRequest(request)
    }
    
    //前の画面に戻る
    @IBAction func goBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
