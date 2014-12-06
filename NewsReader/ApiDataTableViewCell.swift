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
---------------------------- */

import UIKit

class ApiDataTableViewCell: UITableViewCell {

    //お菓子データ表示のプロパティ
    @IBOutlet var okashiName: UILabel!
    @IBOutlet var okashiMaker: UILabel!
    @IBOutlet var okashiCategory: UILabel!
    @IBOutlet var okashiPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
