import Foundation
import UIKit

class Common {
    let config: Config = Config()
    let commonString: ConfigString = ConfigString()
    let commonColor: CommonColor = CommonColor(colorFlg: 0)     // アプリ全体の色
    
    init () {}
    
    /// カテゴリーナンバーからカテゴリー名を取得する
    ///
    /// - Parameter categoryNumber: カテゴリーナンバー
    /// - Returns: カテゴリー名
    func convertCategoryString(categoryNumber: Int) -> String {
        let categoryList: [[Any]] = config.CategoryList
        for category in categoryList {
            if category[0] as! Int == categoryNumber {
                return category[1] as! String
            }
        }
        return ""
    }
    
    /// ファイル名の先頭に付けるカテゴリー判別ナンバーを取得する（01,02・・・）
    ///
    /// - Parameter categoryNumber: カテゴリーナンバー
    /// - Returns: カテゴリー判別ナンバー
    func convertCategoryFileHeadNumber(categoryNumber: Int) -> String {
        return config.CategoryNumber[categoryNumber]
    }
    
    
    /// クイズタイプナンバーからクイズタイプ文字を取得する
    ///
    /// - Parameter quizType: クイズタイプナンバー
    /// - Returns: クイズタイプ文字
    func getQuizTypeString(quizType: Int) -> String {
        return config.quizTypeConfig[quizType][1] as! String
    }
    
    
    /// クイズタイプナンバーから設定値のクイズタイプナンバーを返す（念のため設定値から取得する）
    ///
    /// - Parameter quizType: クイズタイプナンバー
    /// - Returns: 設定値のクイズタイプナンバー
    func getQuizTypeNumber(quizType: Int) -> Int {
        return config.quizTypeConfig[quizType][0] as! Int
    }
    
    
    /// テーブルビューの設定
    ///
    /// - Parameters:
    ///   - TableView:              テーブルビュー
    ///   - ViewController:         ビューコントローラー
    ///   - DelegateDatasource:     デリゲートとデータソース
    ///   - SeparatorNot:           空のセパレーターを消す
    ///   - SeparatorMax:           セパレーターを右まで付ける
    ///   - TopMargin:              テーブルビュー上部に余白を作る
    ///   - AppBackgroundColor:     アプリ規定の背景色を設定する
    ///   - ClearBackgroundColor:   テーブルビューの背景を透過する
    ///   - CellHeightVariable:     セルの高さを可変にする
    func tableViewSetting(TableView: UITableView,
                          ViewController: UIViewController,
                          DelegateDatasource: Bool,
                          SeparatorNot: Bool,
                          SeparatorMax: Bool,
                          TopMargin: CGFloat,
                          AppBackgroundColor: Bool,
                          ClearBackgroundColor: Bool,
                          CellHeightVariable: Bool) {
        // デリゲートとデータソースの設定
        if DelegateDatasource {
            TableView.delegate = ViewController as? UITableViewDelegate
            TableView.dataSource = ViewController as? UITableViewDataSource
        }
        // 空のセルのセパレーターを消す
        if SeparatorNot { TableView.separatorInset = .zero }
        // セパレーターを画面の右端まで付ける
        if SeparatorMax { TableView.tableFooterView = UIView(frame: .zero) }
        // テーブルビュー上部に余白を作る
        if TopMargin != 0 { TableView.contentInset = UIEdgeInsetsMake(TopMargin, 0, 0, 0) }
        // アプリ規定の背景色を設定
        if AppBackgroundColor { TableView.backgroundColor = UIColor.ApplicationBackgrounColor() }
        // テーブルビューの背景を透過
        if ClearBackgroundColor { TableView.backgroundColor = UIColor.clear }
        // セルの高さを可変にする
        if CellHeightVariable {
            TableView.rowHeight = UITableViewAutomaticDimension
            TableView.estimatedRowHeight = 5
        }
    }
    
    /// テーブルビューの設定
    ///
    /// - Parameters:
    ///   - TableView:              テーブルビュー
    ///   - ViewController:         ビューコントローラー
    ///   - DelegateDatasource:     デリゲートとデータソース
    ///   - SeparatorNot:           空のセパレーターを消す
    ///   - SeparatorMax:           セパレーターを右まで付ける
    ///   - TopMargin:              テーブルビュー上部に余白を作る
    ///   - AppBackgroundColor:     アプリ規定の背景色を設定する
    ///   - ClearBackgroundColor:   テーブルビューの背景を透過する
    ///   - CellHeightVariable:     セルの高さを可変にする
    ///   - RegistarXib             [Xib名 : Cellのidentifier]
    func tableViewSetting(TableView: UITableView,
                          ViewController: UIViewController,
                          DelegateDatasource: Bool,
                          SeparatorNot: Bool,
                          SeparatorMax: Bool,
                          TopMargin: CGFloat,
                          AppBackgroundColor: Bool,
                          ClearBackgroundColor: Bool,
                          CellHeightVariable: Bool,
                          RegistarXib: [String : String]) {
        // デリゲートとデータソースの設定
        if DelegateDatasource {
            TableView.delegate = ViewController as? UITableViewDelegate
            TableView.dataSource = ViewController as? UITableViewDataSource
        }
        // 空のセルのセパレーターを消す
        if SeparatorNot { TableView.separatorInset = .zero }
        // セパレーターを画面の右端まで付ける
        if SeparatorMax { TableView.tableFooterView = UIView(frame: .zero) }
        // テーブルビュー上部に余白を作る
        if TopMargin != 0 { TableView.contentInset = UIEdgeInsetsMake(TopMargin, 0, 0, 0) }
        // アプリ規定の背景色を設定
        if AppBackgroundColor { TableView.backgroundColor = UIColor.ApplicationBackgrounColor() }
        // テーブルビューの背景を透過
        if ClearBackgroundColor { TableView.backgroundColor = UIColor.clear }
        // セルの高さを可変にする
        if CellHeightVariable {
            TableView.rowHeight = UITableViewAutomaticDimension
            TableView.estimatedRowHeight = 5
        }
        // XibのCellを使用可能にする
        for xib in RegistarXib {
            let xibObject = UINib(nibName: xib.key, bundle: nil)
            let xibCell = xib.value
            // XibのセルをTableViewに登録する
            TableView.register(xibObject, forCellReuseIdentifier: xibCell)
        }
    }
    
    
    /// ナビゲーションバーの設定
    ///
    /// - Parameter navigationController: ナビゲーションコントローラー
    func navigationBarSetting(navigationController: UINavigationController) {
        // 背景色を変更する
        navigationController.navigationBar.barTintColor = commonColor.getNavigationBarBackgroundColor()
        // アイテムカラー
        navigationController.navigationBar.tintColor = commonColor.getNavigationBarItemColor()
    }
    
    
    
    /// ナビゲーションバーに配置するボタンの設定
    ///
    /// - Parameters:
    ///   - this:       画面情報
    ///   - place       ボタン配置位置（left: 0, right: 1）
    ///   - icon:       アイコン
    ///   - selector:   セレクター
    func navigationIconSetting(this: UIViewController,
                         place: Int,
                         icon: UIBarButtonSystemItem,
                         selector: Selector) {
        // ナビゲーションバーに追加する、アイコンを作成
        let barButtonItem:UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: icon,
            target: this,
            action: selector
        )
        // ナビゲーションバーにアイコンをセットする
        if place == 0 {
            this.navigationItem.setLeftBarButtonItems([barButtonItem], animated: true)
        } else {
            this.navigationItem.setRightBarButtonItems([barButtonItem], animated: true)
        }
    }
    
    
    func navigationButtonSetting(this: UIViewController,
                                 place: Int,
                                 title: String,
                                 style: UIBarButtonItemStyle,
                                 selector: Selector) {
        // 「作成」ボタンの定義
        let barButtonItem = UIBarButtonItem(
            title: title,
            style: style,
            target: this,
            action: selector
        )
        // ナビゲーションバーにアイコンをセットする
        if place == 0 {
            this.navigationItem.setLeftBarButtonItems([barButtonItem], animated: true)
        } else {
            this.navigationItem.setRightBarButtonItems([barButtonItem], animated: true)
        }
    }
    
    
    

    
    
    
    
}
