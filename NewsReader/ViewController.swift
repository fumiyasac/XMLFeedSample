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
    
    //Itemクラスのインスタンス
    var items : [Item] = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return items.count
        
    }
    
    //テーブルの要素数を設定する ※必須
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //今回は1セクションだけ
        return sectionCount
        
    }
    
    //表示するセルの中身を設定する ※必須
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Xibファイルを元にデータを作成する
        var cell = tableView.dequeueReusableCellWithIdentifier("apiDataCell") as ApiDataTableViewCell;
        var item = items[indexPath.row]
        
        //Xibのプロパティの中にそれぞれの要素名を入れる
        //cell.okashiCategory?.text = item.maker as Stringと書くのもOK
        
        //お菓子名
        cell.okashiName?.text = "\(item.name)"
        
        //メーカー名
        cell.okashiMaker?.text = "\(item.maker)"
        
        //カテゴリー ※nilの可能性があるものはあらかじめチェック
        if(item.type != nil){
            
            //取得した文字列に応じて表記の変更
            if(String(item.type) == "snack"){
                cell.okashiCategory?.text = "スナック"
            }else if(String(item.type) == "chocolate"){
                cell.okashiCategory?.text = "チョコレート"
            }else if(String(item.type) == "cookie"){
                cell.okashiCategory?.text = "クッキー・洋菓子"
            }else if(String(item.type) == "candy"){
                cell.okashiCategory?.text = "飴・ガム"
            }else if(String(item.type) == "senbei"){
                cell.okashiCategory?.text = "せんべい・和風"
            }
            
        }else{
            cell.okashiCategory?.text = "-"
        }
        
        //価格 ※nilの可能性があるものはあらかじめチェック
        if(item.price != nil){
            cell.okashiPrice?.text = "\(item.price)"
        }else{
            cell.okashiPrice?.text = "-"
        }
        
        //セルの右に矢印をつけてあげる
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
        
        return cell
    }
    
    //セルをタップした時に呼び出される
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = items[indexPath.row]
        let urlString:String = String(item.url)
        
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
            var detailViewController = segue.destinationViewController as DetailViewController
            
            //遷移先のコントローラーに渡したい変数を格納（型を合わせてね）
            detailViewController.urlString = sender as String
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
    
    //XMLをパースする処理
    var currentElementName : String!
    
    //取得する要素名の決定(とりはじめの要素)
    let itemElementName:String  = "item"
    
    //取得する要素名の決定(item要素の下にあるもの)
    let nameElementName:String  = "name"
    let makerElementName:String = "maker"
    let priceElementName:String = "price"
    let typeElementName:String  = "type"
    let urlElementName:String   = "url"
    
    //※XMLの中身がどのような構造をしているのかは下記のURLを直接たたいて確認をしてみてください
    //http://www.sysbird.jp/webapi/?apikey=guest&max=30&order=r
    
    //XMLパース処理実行開始時に行う処理
    func parserDidStartDocument(parser: NSXMLParser!) {
    }
    
    //fun parse()についてはオーバーロード（名前は一緒なんだけど引数の型が違う）してます
    
    //XMLパース処理実行中に行う処理
    //item要素を見つける ※上から順番に調べていくイメージです
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!) {
        
        currentElementName = nil
        
        if elementName == itemElementName {
            
            //読み込んだXMLでitem要素を見つけたらitemクラスのインスタンスを入れる
            //※空っぽの入れ物だけを準備してあげるイメージです
            items.append(Item())
            
        } else {
            
            //item要素じゃなければ単純に現在位置をcurrentElementNameに入れておく
            currentElementName = elementName
            
        }
    }
    
    //XMLパース処理実行中に行う処理
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
        currentElementName = nil;
        
    }
    
    //XMLパース処理実行中に行う処理
    //item要素内からさらにname・url・price・make要素を見つけてitem要素を見つけた際に用意した入れ物に入れてあげる
    func parser(parser: NSXMLParser!, foundCharacters string: String!){
        
        //itemsの中に空っぽの入れ物が準備できている場合の処理
        if items.count > 0 {
            
            //空っぽの入れ物のなかにそれぞれの要素の文字列を入れる
            var lastItem = items[items.count-1]
            if currentElementName? == nameElementName {
                
                //name要素を入れる
                //一番最初に取ってくるものについてはこの書き方（もしname要素内にすでに値があったら追記する）
                var tmpString : String? = lastItem.name
                lastItem.name = (tmpString != nil) ? tmpString! + string : string
                
            } else if currentElementName? == urlElementName {
                
                //url要素を入れる
                lastItem.url = string
                
            } else if currentElementName? == makerElementName {
                
                //maker要素を入れる
                lastItem.maker = string
                
            } else if currentElementName? == typeElementName {
                
                //type要素を入れる
                lastItem.type = string
                
            } else if currentElementName? == priceElementName {
                
                //price要素を入れる
                lastItem.price = string
                
            }
        }
    }
    
    //XMLパース処理実行終了時に行う処理
    func parserDidEndDocument(parser: NSXMLParser!)
    {
        self.feedTableView.reloadData()
        
        //Debug.要素が取れているかの確認用
        //println(items)
    }
    
    //XMLから取得した値を保持するだけのクラス
    class Item {
        var name:  String! //item要素の下のname要素を入れる
        var maker: String! //item要素の下のmaker要素を入れる
        var price: String! //item要素の下のprice要素を入れる
        var type:  String! //item要素の下のtype要素を入れる
        var url:   String! //item要素の下のurl要素を入れる
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

