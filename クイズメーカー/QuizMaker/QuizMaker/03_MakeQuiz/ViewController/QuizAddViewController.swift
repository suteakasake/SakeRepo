import UIKit

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                              新規の問題を作成する画面
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class QuizAddViewController: UIViewController {
    
    // 前画面の情報
    var quizListBaseViewController : QuizListBaseViewController!        // 前画面情報
    
    // 可変変数
    var categoryNum: Int = 0                                            // カテゴリーナンバー

    // アウトレット接続
    @IBOutlet weak var TableView: UITableView!                          // テーブルビュー

    // 共通クラス
    let common: Common = Common()                                       // 共通クラス
    let commonJson: CommonJson = CommonJson()                           // 共通Jsonクラス
    let commonDB: CommonDB = CommonDB()                                 // 共通DBクラス
    let configString: ConfigString = ConfigString()                     // 共通文字設定クラス
    var variableParts: VariousParts? = nil                              // 共通部品クラス
    
    // 固定
    var sectionLabel: [String] = []                                     // セクションラベル
    
    // UI
    var titleTextView:UITextView? = nil                                 // UITextView（問題文）
    var descriptionTextView:UITextView? = nil                           // UITextView（説明）
    
    
    /* /////////////////////////////////////////////////////////////////////////////////
     *
     *                                  ライフサイクル
     *
     ///////////////////////////////////////////////////////////////////////////////// */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 変数を初期化する
        initVariableSetting()
        
        // 共通部品クラスをインスタンス化
        variableParts = VariousParts(this: self)
        
        // テーブルビューの共通設定
        common.tableViewSetting(TableView: TableView,
                                ViewController: self,
                                DelegateDatasource: true,
                                SeparatorNot: true,
                                SeparatorMax: true,
                                TopMargin: 30,
                                AppBackgroundColor: true,
                                ClearBackgroundColor: false,
                                CellHeightVariable: false)
        
        // 「作成」ボタンの定義
        common.navigationButtonSetting(this: self,
                                       place: 1,
                                       title: "作成",
                                       style: .plain,
                                       selector: #selector(QuizAddViewController.makeQuiz))
    }
    
    func initVariableSetting() {
        // セクションのラベル文字を取得する
        self.sectionLabel = configString.QuizAddViewControllerString.SectionLabel
    }
    
    /// 「作成」ボタン押下時の処理
    @objc func makeQuiz() {
        // 新規クイズを作成する
        commonJson.makeQuizFile(
            fileSettingValue: [
                commonDB.getMakeFileNo(),               // シーケンスから取得
                self.titleTextView?.text ?? "",
                self.descriptionTextView?.text ?? "",
                self.categoryNum
            ]
        )
        // 一覧画面のTableViewを更新する
        self.quizListBaseViewController.updateTalbeView(categoryNum: categoryNum)
        // ContactViewControllerに戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// 指定したカテゴリーナンバーを変更する
    ///
    /// - Parameter categoryNumber: カテゴリーナンバーを変更する
    func changeCategoryNumber(categoryNumber: Int) {
        // カテゴリーを変更する
        self.categoryNum = categoryNumber
    }
    
    // テーブルビューの更新
    func updateTableView() {
        // 再描画
        self.TableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                               テーブルビュークラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizAddViewController : UITableViewDelegate, UITableViewDataSource {
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionLabel.count
    }
    
    // １つのセクションに表示するセル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // セクションのラベル
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(origin: CGPoint(x: 50, y: 10), size: CGSize(width: 200, height: 40))
        let paddingLabel = PaddingLabel(frame: frame)
        paddingLabel.textColor = .black
        paddingLabel.text = sectionLabel[section]
        paddingLabel.font = UIFont.systemFont(ofSize: 15)
        
        return paddingLabel
    }
    
    // ヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // ヘッダーViewの高さを返す
        return 25
    }
    
    /*
     セルの高さを設定
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 1 {
            return 120
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                // セルの定義
                let cell = TableView.dequeueReusableCell(withIdentifier: "TextInputCell", for: indexPath) as! QuizAddViewCell
                // タイトル　TextView定義
                self.titleTextView = cell.InputTextView
                // タイトル TextViewに閉じるボタンを追加する
                variableParts?.textViewAddClose(textView: &titleTextView!)
                // セルを選択させないようにする
                cell.selectionStyle = .none
                return cell
            case 1:
                // セルの定義
                let cell = TableView.dequeueReusableCell(withIdentifier: "TextInputCell", for: indexPath) as! QuizAddViewCell
                // 説明 TextView定義
                descriptionTextView = cell.InputTextView
                // 説明 TextViewに閉じるボタンを追加する
                variableParts?.textViewAddClose(textView: &descriptionTextView!)
                // セルを選択させないようにする
                cell.selectionStyle = .none
                return cell
            case 2:
                // セルの定義
                let cell = TableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath)
                // カテゴリーラベルの表示
                cell.textLabel!.text = configString.QuizAddViewControllerString.category
                // 選択されているカテゴリーの表示
                cell.detailTextLabel!.text = common.convertCategoryString(categoryNumber: categoryNum)
                return cell
            default:
                // 本来は呼ばれない
                let cell : UITableViewCell? = nil
                return cell!
        }
    }
    
    // セルが押された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            // CategorySelectViewControllerを取得
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategorySelectView") as! CategorySelectViewController
            // QuizAddViewControllerを渡す
            secondViewController.quizAddViewController = self
            // CategorySelectViewControllerへ遷移する
            self.navigationController?.pushViewController(secondViewController, animated: true)
        default:
            break
        }
    }
}
