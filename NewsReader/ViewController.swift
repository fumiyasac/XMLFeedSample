//
//  ViewController.swift
//  NewsReader
//
//  Created by 酒井文也 on 2014/12/04.
//  Copyright (c) 2014年 just1factory. All rights reserved.
//

/* ----------------------------
■ Interface Builderにて忘れずにする作業：
1. TableViewからViewControllerにdelegateとdataSourceの連結
2. TableViewからDetailViewControllerへセグエを張る（segue identifierは"toDetail"）

■ 使用API：
このサンプルでは「お菓子の虜」APIを利用しています。
http://www.sysbird.jp/toriko/webapi/

■ 画面仕様：
ViewController → 

1. 上記APIを使用してランダムでデータを30件取得
2. セルをタップすると詳細画面へ遷移

※セルをタップするとSafariが開くも可能です。

＜更新情報＞
2015/01/13: AutoResizing対応と画像がnilになった際の対応
2015/07/11: NSXMLParserの仕様変更による改修

(Old)
parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!)

(New)
parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
---------------------------- */

import UIKit

//デリゲートを追加しておく（今回はUIViewControllerを使っているので、テーブルビューとXMLパーサのデリゲートを設定）
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate {

    //フィード表示用のテーブルビュー
    @IBOutlet var feedTableView: UITableView!

    //テーブルビューの要素数(今回は決めうちだからこれで)
    let sectionCount: Int = 1

    //テーブルビューセルの高さ(Xibのサイズに合わせるのが理想)
    let tableViewCellHeight: CGFloat = 80.0

    //XMLのフィードURL
    let feedUrl : NSURL = NSURL(string:"http://www.sysbird.jp/webapi/?apikey=guest&max=30&order=r")!

    //XMLをパースする処理
    var currentElementName : String!

    //取得する要素名の決定(とりはじめの要素)
    let itemElementName : String  = "item"

    //取得する要素名の決定(item要素の下にあるもの)
    let nameElementName : String  = "name"
    let makerElementName : String = "maker"
    let priceElementName : String = "price"
    let typeElementName : String  = "type"
    let urlElementName : String   = "url"
    let imageElementName : String = "image"

    //各エレメント用の変数
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var name = NSMutableString()
    var maker = NSMutableString()
    var price = NSMutableString()
    var type = NSMutableString()
    var url = NSMutableString()
    var image = NSMutableString()

    override func viewDidLoad() {
        super.viewDidLoad()

        //入れ物を作る
        posts = []

        //tableViewデリゲート
        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self

        //Xibのクラスを読み込む宣言を行う
        var nib:UINib = UINib(nibName: "ApiDataTableViewCell", bundle: nil)
        self.feedTableView.registerNib(nib, forCellReuseIdentifier: "apiDataCell")

        //NSXMLParserクラスのインスタンスを準備
        var parser : NSXMLParser = NSXMLParser(contentsOfURL: feedUrl)!

        //XMLパーサのデリゲート
        parser.delegate = self

        //XMLパースの実行
        parser.parse()
    }
    
    //テーブルの行数を設定する ※必須
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //取得データの総数 ※要素数からとるようにすること！
        return posts.count
    }

    //テーブルの要素数を設定する ※必須
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        //今回は1セクションだけ
        return sectionCount
    }
    
    //表示するセルの中身を設定する ※必須
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        //Xibファイルを元にデータを作成する
        var cell = tableView.dequeueReusableCellWithIdentifier("apiDataCell") as? ApiDataTableViewCell;

        //Xibのプロパティの中にそれぞれの要素名を入れる

        //お菓子名
        cell!.okashiName.text = posts.objectAtIndex(indexPath.row).valueForKey("name") as? String

        //メーカー名
        cell!.okashiMaker?.text = posts.objectAtIndex(indexPath.row).valueForKey("maker") as? String

        //カテゴリー ※取得した文字列に応じて表記の変更
        var categoryParameter: String! = (posts.objectAtIndex(indexPath.row).valueForKey("type")!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))

        if(categoryParameter == "snack"){
            cell!.okashiCategory?.text = "スナック"
        }else if(categoryParameter == "chocolate"){
            cell!.okashiCategory?.text = "チョコレート"
        }else if(categoryParameter == "cookie"){
            cell!.okashiCategory?.text = "クッキー・洋菓子"
        }else if(categoryParameter == "candy"){
            cell!.okashiCategory?.text = "飴・ガム"
        }else if(categoryParameter == "senbei"){
            cell!.okashiCategory?.text = "せんべい・和風"
        }else{
            cell!.okashiCategory?.text = "-"
        }

        //価格 ※nilの可能性があるものはあらかじめチェック
        var priceParameter: String = (posts.objectAtIndex(indexPath.row).valueForKey("price") as? String)!

        if(priceParameter != ""){
            cell!.okashiPrice?.text = priceParameter
        }else{
            cell!.okashiPrice?.text = "-"
        }

        //画像 ※image要素のデータを取得した後にnilの可能性をチェック
        var q_global: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        var q_main: dispatch_queue_t   = dispatch_get_main_queue();

        var imageParameter: String! = (posts.objectAtIndex(indexPath.row).valueForKey("image")!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))

        //URLがあれば画像取得処理を実行
        if(imageParameter != ""){

            //サムネイルのURLをもとに画像データ(NSData型)を作成
            var imageURL = NSURL(string: imageParameter)

            //非同期でURLデータを取得
            dispatch_async(q_global,{

                //サムネイルのURLをもとに画像データ(NSData型)を作成
                var error: NSError?
                var imageData = NSData(contentsOfURL: imageURL!, options: nil, error: &error)

                if error != nil {
                    //nilの時はデフォルトイメージを表示してあげる
                    var image: UIImage = UIImage(named: "no_image.gif")!
                    cell!.okashiImage?.image = image
                }
                
                //更新はメインスレッドで行う
                dispatch_async(q_main,{

                    //イメージデータがnilでなければサムネイル画像を表示
                    if((imageData) != nil){
                        
                        //xibのサムネイルエリアに表示する
                        var image: UIImage = UIImage(data: imageData!)!
                        cell!.okashiImage?.image = image
                        cell!.layoutSubviews()
                    }
                })
            })
            
        }else{
            
            //nilの時はデフォルトイメージを表示してあげる
            var image: UIImage = UIImage(named: "no_image.gif")!
            cell!.okashiImage?.image = image
            
        }
        
        //セルの右に矢印をつけてあげる
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;

        return cell!
    }
    
    //セルをタップした時に呼び出される
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let post: AnyObject = posts[indexPath.row]
        let urlString: String = (posts.objectAtIndex(indexPath.row).valueForKey("url") as? String)!

        //セグエの実行時に値を渡す
        performSegueWithIdentifier("toDetail", sender: urlString)
        
        //（別）Safariを開かせる際はこれを使う
        //UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
    }
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //セグエ名で判定を行う
        if segue.identifier == "toDetail"{
            
            //遷移先のコントローラーの変数を用意する
            var detailViewController = segue.destinationViewController as! DetailViewController
            
            //遷移先のコントローラーに渡したい変数を格納（型を合わせてね）
            var urlParam : String
            detailViewController.urlString = sender as! String
        }
    }
    
    //セルの高さを返す ※任意
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    
    //データのリロード　※任意
    func reloadData(){
        self.feedTableView.reloadData()
    }
    
    //下にスクロールでコンテンツの追加読み込み ※任意
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var contentOffsetWidthWindow: CGFloat = self.feedTableView.contentOffset.y + self.feedTableView.bounds.size.height
        if(contentOffsetWidthWindow >= self.feedTableView.contentSize.height){
            
            //Explain. スクロールして一番下に行った際に次のページを読み込む処理をする際に活用
        }
    }
    
    //XMLパース処理実行開始時に行う処理
    func parserDidStartDocument(parser: NSXMLParser) {
    }
    
    //XMLパース処理実行中に行う処理（タグの最初を検出）
    //item要素を見つける ※上から順番に調べていくイメージです
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        element = elementName
        if (elementName as NSString).isEqualToString(itemElementName){
            elements = NSMutableDictionary.alloc()
            elements = [:]
            name = NSMutableString.alloc()
            name = ""
            maker = NSMutableString.alloc()
            maker = ""
            price = NSMutableString.alloc()
            price = ""
            type = NSMutableString.alloc()
            type = ""
            url = NSMutableString.alloc()
            url = ""
            image = NSMutableString.alloc()
            image = ""
        }
    }
    
    //XMLパース処理実行中に行う処理（実際のパース処理）
    //item要素内からさらにname・url・price・maker・url・image要素を見つけてitem要素を見つけた際に用意した入れ物に入れてあげる
    func parser(parser: NSXMLParser, foundCharacters string: String?){

        if element.isEqualToString(nameElementName) {
            name.appendString( strip(string!) )
        } else if element.isEqualToString(makerElementName) {
            maker.appendString( strip(string!) )
        } else if element.isEqualToString(priceElementName) {
            price.appendString( strip(string!) )
        } else if element.isEqualToString(typeElementName) {
            type.appendString( strip(string!) )
        } else if element.isEqualToString(urlElementName) {
            url.appendString( strip(string!) )
        } else if element.isEqualToString(imageElementName) {
            image.appendString( strip(string!) )
        }
    }

    //XMLパース処理実行中に行う処理（タグの最後を検出）
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if (elementName as NSString).isEqualToString(itemElementName) {
            
            if !name.isEqual(nil) {
                elements.setObject(name, forKey: nameElementName)
            }
            if !maker.isEqual(nil) {
                elements.setObject(maker, forKey: makerElementName)
            }
            if !price.isEqual(nil) {
                elements.setObject(price, forKey: priceElementName)
            }
            if !type.isEqual(nil) {
                elements.setObject(type, forKey: typeElementName)
            }
            if !url.isEqual(nil) {
                elements.setObject(url, forKey: urlElementName)
            }
            if !image.isEqual(nil) {
                elements.setObject(image, forKey: imageElementName)
            }
            posts.addObject(elements)
        }

    }

    //XMLパース処理実行終了時に行う処理
    func parserDidEndDocument(parser: NSXMLParser) {
        self.feedTableView.reloadData()
        
        //Debug.要素が取れているかの確認用
        //println(posts)
    }
    
    //改行と半角スペースの除去
    func strip(str: String) -> String {
        var strBr: String
        var strSp: String
        //改行除去
        strBr = str.stringByReplacingOccurrencesOfString("\n", withString: "", options: nil, range: nil)
        //半角スペース除去
        strSp = strBr.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
        return strSp
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

