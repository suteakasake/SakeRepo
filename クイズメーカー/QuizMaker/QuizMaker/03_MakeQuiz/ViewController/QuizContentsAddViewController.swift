import UIKit

/// 入力値を格納するための構造体
struct QuizValue {
    var question: String = ""       // 問題文
    var choiceCount: Int = 0        // 選択肢の数
    var answerCount: Int = 0        // 答えの数
    var choiceValue: [String] = []  // 選択肢の文字
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                 問題を作成する画面
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class QuizContentsAddViewController: UIViewController {
     // ------------ 前画面から値を取得する変数 ----------------
    // 前画面の情報
    var quizContentsListViewController: QuizContentsListViewController!
    // 押されたセルの番号
    var tapQuestionNo: Int = 0
    
    // ------------ 固定文字なので、後でcommonStringとconfigに移す ----------------
    // セクション名
    let sectionStr: [String] = ["問題形式", "問題文", "選択肢"]
    // 使用するXib名
    let xibList: [String : String] = [
        "RightDetailCell" : "RightDetailCell",
        "TextViewCell" : "TextViewCell",
        "TextFieldCell" : "TextFieldCell"
    ]
    
    // ------------ 可変変数 ----------------
    // 問題形式ごとの構造体を格納する排列
    var quizValueList: [QuizValue]!
    // 編集するファイル名
    var fileName: String = ""
    // クイズタイプ（0: 単一, 1: 複数, 2: 記述）
    var quizType: Int = 0
    // セグメント切り替え関連の変数
    var segmentedChangeFlg: Bool = false        // セグメントが切り替わったことを検知する変数
    var beforeQuizType: Int = 0                 // セグメント切り替え前の問題形式
    
    // ------------- 初期値（変更はしない） ----------------
    // 選択肢数
    var choiceCount: [Int] = [4, 4, 1]
    // 固定設定項目数
    var fixedCount: [Int] = [1, 2, 0]
    // 解答数
    var answerCount = 2
    
    // ------------- その他 ----------------
    // 共通クラス
    let common: Common = Common()
    let commonJson: CommonJson = CommonJson()
    // アウトレット接続
    @IBOutlet weak var TableView: UITableView!
    
    // -------------- キーボードとの重なりを検知する変数 ----------------
    @IBOutlet var parentView: UIView!
    // 重なっている高さ
    var overlap: CGFloat = 0.0
    var lastOffsetY: CGFloat = 0.0
    var cellFrame:CGRect!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期処理を行う
        initSetting()
        
        // 編集モードの場合
        if tapQuestionNo != 0 {
            initStructSetting()                 // 構造体の初期化
            editSetting(tapNo: tapQuestionNo)   // 編集の場合は、値を取得して格納する
        } else {    // 編集モード以外の場合
            initStructSetting()                 // 構造体の初期化
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 初期処理
    func initSetting() {
        // 編集するファイル名を取得
        fileName = quizContentsListViewController.fileName
        
        // QuizValueを配列に格納する
        quizValueList = [
            QuizValue(),
            QuizValue(),
            QuizValue()
        ]
        
        // テーブルビューの共通設定
        common.tableViewSetting(TableView: TableView,
                                ViewController: self,
                                DelegateDatasource: true,
                                SeparatorNot: true,
                                SeparatorMax: true,
                                TopMargin: 30,
                                AppBackgroundColor: true,
                                ClearBackgroundColor: false,
                                CellHeightVariable: true,
                                RegistarXib: xibList)
        
        // ナビゲーションバーに追加する、「+」アイコンを作成
        let rightSearchBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(QuizContentsAddViewController.makeQuiz))
        // ナビゲーションバーの右側に、「+」アイコンをセットする
        self.navigationItem.setRightBarButtonItems([rightSearchBarButtonItem], animated: true)
        
        // キーボード出現検知のオブザーブを登録する
        setNotification()
    }
    
    
    /* /////////////////////////////////////////////////////////////////////////////////
     *
     *                                 問題を作成する画面
     *
     ///////////////////////////////////////////////////////////////////////////////// */
    /// 構造体初期化処理
    func initStructSetting() {
        // 問題形式ごとの構造体を初期化する
        for i in 0..<quizValueList.count {
            // 問題文
            quizValueList[i].question = ""
            // 選択肢の数
            quizValueList[i].choiceCount = self.choiceCount[i]
            // 構造体の選択肢の値に空値を格納する
            for _ in 0..<choiceCount[i] {
                quizValueList[i].choiceValue.append("")
            }
            // 複数問題の場合は「答えの数」を格納する
            if i == 1 {
                quizValueList[i].answerCount = self.answerCount
            }
        }
    }
    
    /// 編集モードの場合の初期化
    ///
    /// - Parameter tapNo: タップされたセルの問題番号
    func editSetting(tapNo: Int) {
        // QuestionSettinクラスを取得する
        let questionSetting: [QuestionSetting] = commonJson.getQuestionSettingJson(jsonFile: fileName)
        // 問題形式を判別する
        // 構造体に格納する
        for value in questionSetting {
            if value.questionNo == tapQuestionNo {
                // 問題形式を取得
                quizType = common.getQuizTypeNumber(quizType: value.type)
                // 問題形式が「択一」か「複数」の場合は問題数とセルの個数を変化させる
                // 構造体に初期値を格納する
                initStructSet(quizValue: &quizValueList[quizType], questionSetting: value)
                break
            }
        }
    }
    
    /// 編集モードのquizValueの初期化
    ///
    /// - Parameters:
    ///   - quizValue:          入力値を格納する構造体
    ///   - questionSetting:    問題文を格納したクラス
    func initStructSet(quizValue:inout QuizValue, questionSetting: QuestionSetting) {
        quizValue.question = questionSetting.question           // 問題文を格納する
        quizValue.choiceCount = questionSetting.questionCount   // 問題数を格納
        quizValue.answerCount = questionSetting.answerCount     // 正解数を格納
        quizValue.choiceValue = questionSetting.answer          // 選択肢の値を格納する
    }

    /***************************************************************
     *    追加アイコン押下時の処理
     *
     */
    @objc func makeQuiz() {
        // デリゲートを起動するために明示的にキーボードを閉じる処理を書く
        self.view.endEditing(true)
        
        // --------------- 入力データを元にJsonデータを作成する処理 -----------------
        // FileSettingクラスを取得
        let fileSettig = commonJson.getFileSettingJson(jsonFile: fileName)
        // QuestionSettingクラスを格納した配列を取得
        var questionSettingList = commonJson.getQuestionSettingJson(jsonFile: fileName)
        // 入力された内容を元に、questionSettingクラスを作成する
        let questionSetting: [Any] = [
            tapQuestionNo != 0 ? tapQuestionNo : questionSettingList.count + 1,
            quizType,
            quizValueList[quizType].question,
            quizValueList[quizType].choiceValue,
            quizValueList[quizType].choiceCount,
            quizValueList[quizType].answerCount
        ]
        // QuestionSettingクラスから、Json保存用変数を作成する
        let newQuestionSetting = commonJson.getQuestionSetting(value: questionSetting)
        // 問題をQuestionSettingListに格納する
        if tapQuestionNo != 0 {     // 編集モードの場合
            // タップされたNoの位置に挿入する
            for (index, value) in questionSettingList.enumerated() {
                if value.questionNo == tapQuestionNo {
                    questionSettingList[index] = newQuestionSetting
                    break
                }
            }
        } else {                    // 新規追加の場合
            questionSettingList.append(newQuestionSetting)
        }
        
        // --------------- Jsonファイルへの書き込み処理 ------------------
        commonJson.EditJsonTest(jsonFileName: fileName,
                                fileSetting: fileSettig,
                                questionSettingLista: questionSettingList)
        
        // ------------------------ 後処理 ----------------------------
        // 前画面のテーブルをリロードする
        quizContentsListViewController.tableReload()
        // 前画面に戻る
        self.navigationController?.popViewController(animated: true)
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                    テーブルビュー
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizContentsAddViewController : UITableViewDelegate, UITableViewDataSource {
    
    // スクロールの開始を検知する
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // キーボードを閉じる
        // self.view.endEditing(true)
        
        TableView.keyboardDismissMode = .onDrag
    }
    
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionStr.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    // ヘッダーの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // ヘッダーViewの高さを返す
        return 25
    }
    // セクションのタイトル
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // パディングラベルを作成する
        let frame = CGRect(origin: CGPoint(x: 50, y: 10), size: CGSize(width: 200, height: 40))
        let paddingLabel = PaddingLabel(frame: frame)
        paddingLabel.textColor = .black
        paddingLabel.text = sectionStr[section]
        paddingLabel.font = UIFont.systemFont(ofSize: 15)
        
        return paddingLabel
    }
    
    /*
     セルの高さを設定
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }
        
        if indexPath.section == 2 {
            if quizType == 2 {
                return 120
            } else {
                return 50
            }
        }
        return 120
    }
    
    // セクションに表示するセル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 「選択肢」セクションの場合
        if section == 2 {
            return quizValueList[quizType].choiceValue.count + fixedCount[quizType]
        } else {
            return 1
        }
    }
    
    // セル設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:     // 問題形式
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTypeSelectCell") as! QuizTypeSelectViewCell
            cell.quizContentsAddViewController = self
            // セグメントの初期位置を変更する
            cell.QuizTypeSegmentControl.selectedSegmentIndex = quizType
            // セルを選択させないようにする
            cell.selectionStyle = .none
            return cell
        case 1:     // 問題文
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            // セルを選択させないようにする
            cell.selectionStyle = .none
            // 問題文を表示する
            cell.TextView.text = quizValueList[quizType].question
            // 問題文のTextViewのデリゲートを設定する
            cell.TextView.delegate = self
            // タグをセットする
            cell.TextView.tag = 0
            
            return cell
        case 2:     // 選択肢
            if quizType == 0 {          // 単一
                let cell = singleType(tableView: tableView, indexPath: indexPath)
                return cell
            } else if quizType == 1 {   // 複数
                let cell = multiType(tableView: tableView, indexPath: indexPath)
                return cell
            } else if quizType == 2 {   // 記述
                let cell = writeType(tableView: tableView, indexPath: indexPath)
                return cell
            }
        default:
            break
        }
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTypeSelectCell") as! QuizTypeSelectViewCell
        return cell
    }
    
    // 単一タイプ
    func singleType(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailCell
            cell.textLabel?.text = "選択肢の数"
            cell.detailTextLabel?.text = String(quizValueList[0].choiceCount)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            // ラベルの値を変える
            if indexPath.row == 1 {
                cell.HeadTextLabel.text = "正解"
            } else {
                // 連番をラベルに表示する
                cell.HeadTextLabel.text = String(indexPath.row - fixedCount[0])
            }
            // セルを選択させないようにする
            cell.selectionStyle = .none
            
            // 入力値をTextFieldに格納する
            cell.TextField.text = quizValueList[0].choiceValue[indexPath.row - fixedCount[0]]
            
            // テキストフィールドのデリゲート設定する
            cell.TextField.delegate = self
            // タグをセットする
            cell.TextField.tag = indexPath.row - fixedCount[0]
            
            return cell
        }
    }
    
    // 複数タイプ
    func multiType(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailCell
            cell.textLabel?.text = "選択肢の数"
            cell.detailTextLabel?.text = String(quizValueList[1].choiceCount)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailCell
            cell.textLabel?.text = "正解数"
            cell.detailTextLabel?.text = String(quizValueList[1].answerCount)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            if quizValueList[1].answerCount > indexPath.row - fixedCount[1] {
                cell.HeadTextLabel.text = "正解" + String(indexPath.row - 1)
            } else {
                cell.HeadTextLabel.text = String(indexPath.row - quizValueList[1].answerCount - 1)
            }
            // セルを選択させないようにする
            cell.selectionStyle = .none
            
            // 入力値をTextFieldに格納する
            cell.TextField.text = quizValueList[1].choiceValue[indexPath.row - fixedCount[1]]

            // テキストフィールドのデリゲート設定する
            cell.TextField.delegate = self
            // タグをセットする
            cell.TextField.tag = indexPath.row - fixedCount[1]
            
            return cell
        }
    }
    
    // 記述タイプ
    func writeType(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
        // デリゲートをセット
        cell.TextView.delegate = self
        // タグをセットする
        cell.TextView.tag = 1
        // セルを選択させないようにする
        cell.selectionStyle = .none
        // 入力値をTextViewに表示する
        for value in quizValueList[quizType].choiceValue {
            cell.TextView.text = value
        }
        
        return cell
    }
    
    // セルが押された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {  // 選択肢のセルがタップされた場合
        case 2:
            // CategorySelectViewControllerを取得
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "NumberCountSelectView") as! NumberCountSelectViewController
            // QuizAddViewControllerを渡す
            secondViewController.firstViewController = self
            
            if indexPath.row == 0 && quizType == 0 {            // 単一タイプ
                // 選択肢か正解数のどちらか判定
                secondViewController.selectType = 0
                // CategorySelectViewControllerへ遷移する
                self.navigationController?.pushViewController(secondViewController, animated: true)
            } else if indexPath.row == 0 && quizType == 1 {     // 複数タイプ 選択肢
                if quizValueList[1].answerCount != 10 {                          // 解答数が10以外
                    // 選択肢か正解数のどちらか判定
                    secondViewController.selectType = 0
                    // CategorySelectViewControllerへ遷移する
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }
            } else if indexPath.row == 1 && quizType == 1 {     // 複数タイプ 解答数
                // 選択肢か正解数のどちらか判定
                secondViewController.selectType = 1
                // CategorySelectViewControllerへ遷移する
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
        default:
            break
        }
    }
    
    /// 構造体の「選択肢の数」「入力値」を変動させる
    // 「選択肢の数」「入力値の数」を構造体に格納する
    func changeChoiceValueCount(choiceCount: Int) {
        // 「選択肢の数」「入力値」を構造体に格納する
        if quizValueList[quizType].choiceCount < choiceCount {
            for _ in quizValueList[quizType].choiceCount..<choiceCount {
                quizValueList[quizType].choiceValue.append("")
            }
            // 「選択肢の数」を変更する
            quizValueList[quizType].choiceCount = choiceCount
        } else if quizValueList[quizType].choiceCount > choiceCount  {
            for index in (choiceCount..<quizValueList[quizType].choiceCount).reversed() {
                quizValueList[quizType].choiceValue.remove(at: index)
            }
            // 「選択肢の数」を変更する
            quizValueList[quizType].choiceCount = choiceCount
        }
    }
    
    // 「答えの数」を構造体に格納する
    func changeAnswerCount(answerCount: Int) {
        quizValueList[quizType].answerCount = answerCount
    }
    
    /// テーブルをリロードする
    func tableReload() {
        // テーブルリロード
        self.TableView.reloadData()
    }
}

extension QuizContentsAddViewController {
    func setNotification() {
        let notification = NotificationCenter.default
        
        notification.addObserver(self,
                                 selector: #selector(QuizContentsAddViewController.keyboardChangeFrame(_:)),
                                 name: NSNotification.Name.UIKeyboardDidChangeFrame,
                                 object: nil)
        // キーボードが登場した
        notification.addObserver(self,
                                 selector: #selector(QuizContentsAddViewController.keyboardWillShow(_:)),
                                 name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // キーボードが退場した
        notification.addObserver(self,
                                 selector: #selector(QuizContentsAddViewController.keyboardDidHide(_:)),
                                 name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    // キーボードのframeを調べる
    @objc func keyboardChangeFrame(_ notification: Notification) {
        print("aaaaaaa")
    }
    
    // キーボードが登場する通知を受けた
    @objc func keyboardWillShow(_ notification: Notification) {
        // セルのフレームがセットされている場合
        guard let cf = self.cellFrame else {
            return
        }
        
        // 現在のスクロール量を保存しておく
        lastOffsetY = TableView.contentOffset.y
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        // ビューの座標を取得
        let txtLimit = cf.origin.y + cf.height + 8.0 - TableView.contentOffset.y // セルの下辺の
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.minY + 5     // キーボードの上辺y座標を取得
        // セルの位置から、キーボードの位置を引いた値を取得
        overlap = txtLimit - kbdLimit
        
        print("in offset= \(TableView.contentOffset)")
        // キーボードよりしたにある場合
        if overlap > 0 {
            // 重なっている分だけスクロールする
            overlap += TableView.contentOffset.y
            TableView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
        }
        

    }
    
    // キーボードが退場した通知を受けた
    @objc func keyboardDidHide(_ notification: Notification) {
        // 元に戻すスクロール量を決める
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        var baseline =  myBoundSize.height -  TableView.bounds.height + lastOffsetY
        baseline = overlap + lastOffsetY
        
        print(overlap)
        print("out offset= \(baseline)")
        print("out offset= \(lastOffsetY)")
        lastOffsetY = min(baseline, lastOffsetY)
        // スクロールを元に戻す
        TableView.setContentOffset(CGPoint(x: 0, y: -(overlap)), animated: true)
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                      タイトル・説明文を入力するTextViewのデリゲート
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizContentsAddViewController : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // 問題形式を格納
        var tmpQuizType: Int = self.quizType
        
        // セグメントが切り替わった場合は、前の問題形式を取得する
        if segmentedChangeFlg {
            tmpQuizType = self.beforeQuizType
            segmentedChangeFlg = false
        }
        
        // 入力されたTextViewのtagで判別する
        if (textView.tag == 0) {
            // 編集されたTextFieldに対応する配列の場所に入力値を格納する
            quizValueList[tmpQuizType].question = textView.text
        } else if (textView.tag == 1) {
            // 編集されたTextFieldに対応する配列の場所に入力値を格納する
            quizValueList[tmpQuizType].choiceValue[0] = textView.text
        }
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                         カテゴリーを変更するTextFieldのデリゲート
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizContentsAddViewController : UITextFieldDelegate {
    
    // 編集開始
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 編集するセルを取得
        if let cell = TableView.cellForRow(at: NSIndexPath(row: textField.tag + fixedCount[self.quizType],
                                                           section: 2) as IndexPath) {
            // 編集するセルの座標を格納する
            self.cellFrame = cell.frame
        }
     }
    
    // 改行入力のデリゲートメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを下げる
        view.endEditing(true)
        // 改行コードは入力しない
        return false
    }
    
    // 編集終了後に呼ばれる
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 問題形式
        var tmpQuizType: Int = self.quizType
        
        // セグメントが切り替わっていた場合は、前の問題形式を取得
        if segmentedChangeFlg {
            // 以前の問題形式を取得
            tmpQuizType = self.beforeQuizType
            // セグメント切り替えフラグを切る
            segmentedChangeFlg = false
        }
        
        // 編集されたTextFieldに対応する配列の場所に入力値を格納する
        quizValueList[tmpQuizType].choiceValue[textField.tag] = textField.text!
        
        self.cellFrame = .zero
    }
}
