//
//  ApiDataTableViewCell.swift
//  NewsReader
//
//  Created by 酒井文也 on 2014/12/05.
//  Copyright (c) 2014年 just1factory. All rights reserved.
//

/* ----------------------------
■ Interface Builderにて忘れずにする作業：
1. ApiDataTableViewCell.xibより各ラベルのプロパティ（アシスタントエディタを利用してドラッグ）を設定
2. xibを選択して、Custom Classを"ApiDataTableViewCell" identifierは"apiDataCell"にする

■ 画面仕様：
ApiDataTableViewCell →

1. ViewControllerのTableViewへ読み込むセルになります

※ラベルの配色やフォントの変更も可能です

＜更新情報＞
2015/01/13: テーブルセルの暫定デバイス対応
2015/01/15: 暫定デバイス対応でおかしな所があったので修正
---------------------------- */

import UIKit

class ApiDataTableViewCell: UITableViewCell {

    //お菓子データ表示のプロパティ
    @IBOutlet var okashiName: UILabel!
    @IBOutlet var okashiMaker: UILabel!
    @IBOutlet var okashiCategory: UILabel!
    @IBOutlet var okashiPrice: UILabel!
    @IBOutlet var okashiImage: UIImageView!
    
    //カレンダーの位置決め用メンバ変数
    var okashiNameLabelWidth: Int!
    var okashiMakerLabelWidth: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //現在起動中のデバイスを取得（スクリーンの幅・高さ）
        let screenWidth  = DeviseSize.screenWidth()
        let screenHeight = DeviseSize.screenHeight()
        
        //iPhone4s
        if(screenWidth == 320 && screenHeight == 480){
            
            okashiNameLabelWidth  = 204;
            okashiMakerLabelWidth = 204;
            
        //iPhone5またはiPhone5s
        }else if (screenWidth == 320 && screenHeight == 568){
            
            okashiNameLabelWidth  = 204;
            okashiMakerLabelWidth = 204;
            
        //iPhone6
        }else if (screenWidth == 375 && screenHeight == 667){
            
            okashiNameLabelWidth  = 259;
            okashiMakerLabelWidth = 259;
            
        //iPhone6 plus
        }else if (screenWidth == 414 && screenHeight == 736){
            
            okashiNameLabelWidth  = 298;
            okashiMakerLabelWidth = 298;
        }
        
        //表示用ラベルのフィックスをする
        self.okashiName.frame = CGRectMake(85, 8, CGFloat(okashiNameLabelWidth), 23);
        self.okashiMaker.frame = CGRectMake(85, 30, CGFloat(okashiMakerLabelWidth), 21);
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
