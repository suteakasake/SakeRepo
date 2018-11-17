import UIKit
import FMDB
import PopupDialog

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                              カテゴリー別クイズ一覧画面
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class QuizListViewController: UIViewController {
    
    // QuizListBaseViewControllerの画面情報
    var quizListBaseViewController: QuizListBaseViewController!     // 前画面の情報

    // アウトレット接続
    @IBOutlet weak var TableView: UITableView!                      // テーブルビュー
    
    // 可変変数
    var categoryNum: Int = 0                                        // カテゴリーナンバー
    var fileSettingList : [FileSetting] = []                        // FileSettingクラス格納配列
    
    // 共通クラス
    let common: Common = Common()                                   // 共通クラス
    let commonJson: CommonJson = CommonJson()                       // 共通Jsonクラス
    let commonDB: CommonDB = CommonDB()                             // 共通DBクラス
    
    
    /* /////////////////////////////////////////////////////////////////////////////////
     *
     *                                   ライフサイクル
     *
     ///////////////////////////////////////////////////////////////////////////////// */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSetting()
        initUISetting()
        setLongTapped()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* /////////////////////////////////////////////////////////////////////////////////
     *
     *                                   初期化処理
     *
     ///////////////////////////////////////////////////////////////////////////////// */
    
    
    /// 初期化処理
    func initSetting() {
        // Documentsディレクトリ内の指定したカテゴリーのJsonデータのFileSettingクラスを全て取得する
        self.fileSettingList = commonJson.getFileSettingList(categoryNum: categoryNum)
    }

    /// UI初期化処理
    func initUISetting() {
        // テーブルビューの共通設定
        common.tableViewSetting(TableView: TableView,
                                ViewController: self,
                                DelegateDatasource: true,
                                SeparatorNot: true,
                                SeparatorMax: true,
                                TopMargin: 0,
                                AppBackgroundColor: true,
                                ClearBackgroundColor: false,
                                CellHeightVariable: true)
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                           セルを長押しした際のポップアップ処理
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizListViewController {
    /// セルのロングタップ時の動作を設定する
    func setLongTapped() {
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(QuizListViewController.cellLongPressed(recognizer:)))
        
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        
        // tableViewにrecognizerを設定
        TableView.addGestureRecognizer(longPressRecognizer)
    }
    
    /// 長押しした際に呼ばれるメソッド
    ///
    /// - Parameter recognizer: recognizer
    @objc func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: TableView)
        let indexPath = TableView.indexPathForRow(at: point)
        
        if indexPath == nil {
            
        } else if recognizer.state == UIGestureRecognizerState.began  {
            // 長押しされた場合の処理
            showFileSettingChangePopup(indexPath: indexPath!)
        }
    }
    
    /// ポップアップの内容・動作を設定して表示する
    ///
    /// - Parameter indexPath: 押されたセルのIndexPath
    func showFileSettingChangePopup(indexPath: IndexPath) {
        
        // 基本設定を取得
        let fileSetting = fileSettingList[indexPath.row]
        // ポップアップに表示したいビューコントローラー
        let vc = SettingChangePopUpDialog(nibName: "SettingChangePopUpDialog", bundle: nil)
        
        // ポップアップ画面のFileSetting構造体に基本設定の値を格納する
        vc.fileSettingValue.fileName = fileSetting.fileName
        vc.fileSettingValue.fileNo = fileSetting.fileNo
        vc.fileSettingValue.title = fileSetting.title
        vc.fileSettingValue.description = fileSetting.description
        vc.fileSettingValue.category = fileSetting.category
        vc.beforeCategory = fileSetting.category
        
        // ポジティブボタン押下時に実行する関数
        let okFunc = DefaultButton(title: "変更する") {
            
            // デリゲート起動前にセグメント切り替えフラグをfalseにする
            vc.segmentedChangeFlg = false
            
            // デリゲートを起動するために明示的にキーボードを閉じる処理を書く
            self.view.endEditing(true)
            
            // Jsonファイルに書き込む
            func writeFileSetting(fileName: String) {
                // 入力された内容をもとに、FileSettingクラスを作成
                let fileSetting = self.commonJson.getFileSetting(
                    value: [
                        vc.fileSettingValue.fileNo,
                        vc.fileSettingValue.title,
                        vc.fileSettingValue.description,
                        vc.fileSettingValue.category
                    ]
                )
                // QuestionSettingクラスを格納した配列を取得
                let questionSettingList = self.commonJson.getQuestionSettingJson(jsonFile: fileName)
                // Jsonファイルに書き込む
                self.commonJson.EditJsonTest(jsonFileName: fileName,
                                             fileSetting: fileSetting,
                                             questionSettingLista: questionSettingList)
            }
            
            // Jsonファイルに書き込む
            writeFileSetting(fileName: vc.fileSettingValue.fileName)
            
            // カテゴリーが変更された場合
            if vc.beforeCategory != vc.fileSettingValue.category {
                print("カテゴリーが変更されました")
                // 前のコントローラー    : 配列から削除 → テーブルの更新
                self.fileSettingList.remove(at: indexPath.row)
                self.TableView.reloadData()
                
                // 変更後のコントローラー : 変更されたカテゴリーにカーソルを持っていく、テーブルの更新
                self.quizListBaseViewController.updateTalbeView(categoryNum: vc.fileSettingValue.category)
            } else {
                // 配列に格納し直す
                self.fileSettingList[indexPath.row] = self.commonJson.getFileSettingJson(jsonFile: vc.fileSettingValue.fileName)
                // テーブルを更新する
                self.TableView.reloadData()
            }
        }
        
        // ネガティブボタン押下時のメソッド
        let ngFunc = DefaultButton(title: "キャンセル") {
            // ここでは特に何もしない
        }
        
        // ポップアップダイアログを作成する
        let cPopupDialog: CommonPopupDialog =
            CommonPopupDialog(
                this: self,
                vc: vc,
                buttonAlign: 0,
                okFunc: okFunc,
                ngFunc: ngFunc
        )
        
        // ポップアップを表示する
        cPopupDialog.showPopupDialog()
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                 テーブルビュークラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizListViewController : UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    /// テーブルビューに表示するセルの個数を設定する
    ///
    /// - Parameters:
    ///   - tableView:  テーブルビュー
    ///   - section:    セクション
    /// - Returns: セルの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileSettingList.count
    }
    
    /// テーブルビューのセルの設定
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    /// - Returns: セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "quizListCell") as! QuizListViewCell
        // セルにファイル名を格納する
        cell.fileName = fileSettingList[indexPath.row].fileName
        // セルに表示する値を設定する
        cell.TitleLabel.text = fileSettingList[indexPath.row].title                 // タイトル
        cell.DescriptionLabel.text = fileSettingList[indexPath.row].description     // 説明
        
        return cell
    }
    
    /// セルが押された際の処理
    ///
    /// - Parameters:
    ///   - tableView: テーブルビュー
    ///   - indexPath: インデックスパス
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 遷移先（問題一覧画面）の情報を取得
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuizContentsListView") as! QuizContentsListViewController
        // 押下されたセルを取得
        let cell = tableView.cellForRow(at: indexPath) as! QuizListViewCell
        // ファイル名を遷移先画面に渡す
        secondViewController.fileName = cell.fileName
        // 遷移する
        quizListBaseViewController.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    /// テーブルビューを更新する
    func updateTalbeView() {
        // FileSettingクラス一覧を取得する
        self.fileSettingList = commonJson.getFileSettingList(categoryNum: categoryNum)
        // 再描画
        TableView.reloadData()
    }
}
