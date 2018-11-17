import UIKit

/// 値を保存する構造体
struct FileSettingValue {
    var fileName: String = ""           // ファイル名
    var fileNo: Int = 0                 // 問題No
    var title: String = ""              // 問題文
    var description: String = ""        // 選択肢の数
    var category: Int = 0               // 答えの数
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                ポップアップダイアログクラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class SettingChangePopUpDialog: UIViewController {
    
    // 構造体
    var fileSettingValue: FileSettingValue = FileSettingValue()     // FileSettingValue構造体を確保
    
    // 可変変数
    var settingType = 0                                         // 0: タイトル, 1: 説明文, 2: カテゴリー
    var segmentedChangeFlg: Bool = false                        // セグメント切り替え判定を検知する変数
    var beforeSettingType: Int = 0                              // セグメント切り替えを行う前の基本設定のタイプを覚えておく変数
    var beforeCategory: Int = 0                                 // セグメント切り替えを行う前のカテゴリーを覚えておく変数
    
    // 固定変数
    var categoryList: [[Any]] = [[]]                            // カテゴリーリストを格納する配列

    // アウトレット接続
    @IBOutlet weak var SettingEditView: UIView!                 // TextView, Picker を表示する領域
    @IBOutlet weak var SettingSegmented: UISegmentedControl!    // 基本設定の選択用Picker
    @IBOutlet weak var HeadingLabel: UILabel!                   // TextView, Pickerの上部に表示するラベル
    
    // UI
    var editView: SettingChangeTextView!                        // タイトル、説明文を入力するTextView
    var editPicker: SettingChangeCategory!                      // カテゴリーを変更するPicker
    
    // 共通クラス
    let config: Config = Config()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // カテゴリー一覧を取得する
        categoryList = config.CategoryList
        
        // セグメントの切り替え時の動作を加える
        SettingSegmented.addTarget(self, action: #selector(SettingChangePopUpDialog.segmentAction(sender:)), for: .valueChanged)
    }
    
    // ポップアップ表示時後に起動する
    override func viewWillAppear(_ animated: Bool) {
        // 編集する基本設定のセグメントに設定する
        changeEditView(settingType: self.settingType)
        // テキストビュー、ピッカーに初期値を入力する
        setEditView(settingType: self.settingType)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /* /////////////////////////////////////////////////////////////////////////////////
     *
     *                                ビューの切り替え
     *
     ///////////////////////////////////////////////////////////////////////////////// */
    /// 編集ビューの中身を切り替える
    ///
    /// - Parameter settingType: 基本設定タイプ
    func changeEditView(settingType: Int) {
        switch settingType {
        case 0:
            // 子要素を全て削除する
            removeAllSubviews(parentView: SettingEditView)
            // Xibをロードする
            editView = Bundle.main.loadNibNamed("SettingChangeView", owner: self, options: nil)!.first! as? SettingChangeTextView
            // デリゲートを設定する
            editView.EditTextView.delegate = self
            // ビューに追加する
            self.SettingEditView.addSubview(editView)
            // editViewに入力値を表示する
            setEditView(settingType: 0)
            break
        case 1:
            // 子要素を全て削除する
            removeAllSubviews(parentView: SettingEditView)
            // Xibをロードする
            editView = Bundle.main.loadNibNamed("SettingChangeView", owner: self, options: nil)!.first! as? SettingChangeTextView
            // デリゲートを設定する
            editView.EditTextView.delegate = self
            // ビューに追加する
            self.SettingEditView.addSubview(editView)
            // editViewに入力値を表示する
            setEditView(settingType: 1)
            break
        case 2:
            // 子要素を全て削除する
            removeAllSubviews(parentView: SettingEditView)
            // Xibをロードする
            editPicker = Bundle.main.loadNibNamed("SettigChangeCategoryView", owner: self, options: nil)!.first! as? SettingChangeCategory
            // Pickerのデリゲートを設定する
            editPicker.CategoryPicker.delegate = self
            editPicker.CategoryPicker.dataSource = self
            // ビューに追加する
            self.SettingEditView.addSubview(editPicker)
            // editViewに入力値を表示する
            setEditView(settingType: 2)
            break
        default:
            break
        }
    }
    
    /// editViewに表示する内容を更新する
    ///
    /// - Parameter settingType: 基本設定タイプ
    func setEditView(settingType: Int) {
        switch settingType {
        case 0:
            HeadingLabel.text = "タイトル"
            // タイトルを表示する
            editView.EditTextView.text = fileSettingValue.title
            break
        case 1:
            HeadingLabel.text = "説明文"
            // 説明文を表示する
            editView.EditTextView.text = fileSettingValue.description
            break
        case 2:
            HeadingLabel.text = "カテゴリー"
            // はじめに表示する項目を指定
            editPicker.CategoryPicker.selectRow(fileSettingValue.category, inComponent: 0, animated: false)
            break
        default:
            break
        }
    }
    
    /// SettingEditViewの子要素を全て削除する
    ///
    /// - Parameter parentView: 親要素
    func removeAllSubviews(parentView: UIView){
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    /* /////////////////////////////////////////////////////////////////////////////////
     *
     *                                セグメントの設定
     *
     ///////////////////////////////////////////////////////////////////////////////// */
    // セグメントコントローラーのアクション
    @objc func segmentAction(sender: Any) {
        // 問題形式番号を取得
        if let selectedIndex = (sender as AnyObject).selectedSegmentIndex {
            //
            segmentedChange(beforeSettingType: self.settingType)
            self.settingType = selectedIndex
            // 編集ビューの更新
            changeEditView(settingType: self.settingType)
        }
    }
    
    // 基本設定タイプを変更した際に、デリゲート処理が後続するので、以前の基本設定タイプを保存する
    func segmentedChange(beforeSettingType: Int) {
        segmentedChangeFlg = true                       // セグメントの切り替えフラグを立てる
        self.beforeSettingType = beforeSettingType      // 切り替え前の基本設定タイプを保存する
    }
}


/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                TextViewのデリゲート
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension SettingChangePopUpDialog: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        segmentedChangeFlg = false
    }
    
    
    /// テキストビューの編集終了時に呼ばれる
    ///
    /// - Parameter textView: textView
    func textViewDidEndEditing(_ textView: UITextView) {
        // キーボードが表示されている状態でセグメントの切り替えが行われた場合、
        // デリゲート処理が後続するので、前の基本設定タイプを参照して、構造体に格納する処理にする
        var tmpSettingType: Int = settingType
        if segmentedChangeFlg {
            tmpSettingType = beforeSettingType
            segmentedChangeFlg = false
        }
        // 基本設定タイプによって、構造体に格納する値を変える
        if tmpSettingType == 0 {
            fileSettingValue.title = textView.text
        } else if tmpSettingType == 1 {
            fileSettingValue.description = textView.text
        }
    }
}


/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                Pickerのデリゲート
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension SettingChangePopUpDialog: UIPickerViewDelegate, UIPickerViewDataSource {
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return categoryList[row][1] as? String
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        // カテゴリーを構造体に格納する
        fileSettingValue.category = categoryList[row][0] as! Int
    }
    
    
}
