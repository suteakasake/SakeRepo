import UIKit
import SwiftReorder
import SwipeCellKit

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                         クイズファイルの問題文を一覧表示する画面
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class QuizContentsListViewController: UIViewController {
    
    // 可変変数
    var fileName = ""                               // 選択されているファイル名を格納
    var questionSettingList: [QuestionSetting]!     // 問題一覧を格納するクラス
    
    // アウトレット接続
    @IBOutlet weak var TableView: UITableView!
    
    // 共通クラス
    let common: Common = Common()
    let commonJson: CommonJson = CommonJson()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 指定したファイルの問題を取得する
        questionSettingList = commonJson.getQuestionSettingJson(jsonFile: self.fileName)
        
        // 念のため問題Noの昇順にソートする
        questionSettingList.sort(by: {$0.questionNo < $1.questionNo})
        
        // テーブルビューの共通設定
        common.tableViewSetting(TableView: TableView,
                                ViewController: self,
                                DelegateDatasource: true,
                                SeparatorNot: true,
                                SeparatorMax: true,
                                TopMargin: 0,
                                AppBackgroundColor: true,
                                ClearBackgroundColor: false,
                                CellHeightVariable: false)
        
        // ナビゲーションバーの右に「＋」アイコンを設置する
        common.navigationIconSetting(
            this: self,
            place: 1,
            icon: UIBarButtonSystemItem.add,
            selector: #selector(QuizContentsListViewController.makeQuiz)
        )
        
        // 並び替えのためのデリゲート設定
        TableView.reorder.delegate = self
    }
    
    /// 追加アイコン押下時の処理
    @objc func makeQuiz() {
        // 問題作成画面の情報を取得
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuizContentsAddView") as! QuizContentsAddViewController
        // 問題作成画面に自身の情報を渡す
        secondViewController.quizContentsListViewController = self
        // 問題作成画面に遷移する
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                              問題を並び替えるクラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizContentsListViewController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 掴んだセルの要素を取得する
        let item = questionSettingList[sourceIndexPath.row]
        
        // ドラッグしているセルの問題番号を取得
        let dragNo = questionSettingList[sourceIndexPath.row].questionNo
        // ドロップしたセルの問題番号を取得
        let dropNo = questionSettingList[destinationIndexPath.row].questionNo
        
        // ドロップしたセルの問題番号を、ドラッグしたセルの問題番号に格納する
        questionSettingList[sourceIndexPath.row].questionNo = dropNo
        // ドラッグしたセルの問題番号を、ドロップしたセルの問題に格納する
        questionSettingList[destinationIndexPath.row].questionNo = dragNo
        
        // 配列から削除する
        questionSettingList.remove(at: sourceIndexPath.row)
        // 配列に格納する
        questionSettingList.insert(item, at: destinationIndexPath.row)
    }
    
    /// 入れ替え完了後に呼ばれる
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        // --------------- 入力データを元にJsonデータを作成する処理 -----------------
        // FileSettingクラスを取得
        let fileSettig = commonJson.getFileSettingJson(jsonFile: self.fileName)
        
        // --------------- Jsonファイルへの書き込み処理 ------------------
        commonJson.EditJsonTest(jsonFileName: self.fileName,
                                fileSetting: fileSettig,
                                questionSettingLista: self.questionSettingList)
        
        // テーブルビューを更新する
        tableView.reloadData()
    }
}


/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                              問題をスワイプで削除するクラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizContentsListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            // --------- 配列の更新 ---------
            // 削除するセルの行番号を取得
            let deleteRow = indexPath.row + 1
            // 削除するセルより後のセルの「問題番号」を詰める
            for i in deleteRow..<self.questionSettingList.count {
                self.questionSettingList[i].questionNo = self.questionSettingList[i].questionNo - 1
            }
            
            // --------- テーブルビュー更新 ----------
            // セルを更新
            for i in deleteRow..<self.questionSettingList.count {
                tableView.reloadRows(at: [NSIndexPath(row: i, section: 0) as IndexPath], with: UITableViewRowAnimation.fade)
            }
            // 先にデータを更新する
            self.questionSettingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [NSIndexPath(row: indexPath.row, section: 0) as IndexPath], with: UITableViewRowAnimation.fade)
            
            // ---------- Jsonデータ更新 -----------
            // FileSettingクラスを取得
            let fileSettig = self.commonJson.getFileSettingJson(jsonFile: self.fileName)
            
            // Jsonファイルへの書き込み処理
            self.commonJson.EditJsonTest(jsonFileName: self.fileName,
                                         fileSetting: fileSettig,
                                         questionSettingLista: self.questionSettingList)
        }
        
        return [deleteAction]
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                      テーブルビュー
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizContentsListViewController : UITableViewDelegate, UITableViewDataSource {
    
    /// 問題数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionSettingList.count
    }
    
    /// セルの情報を設定する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ドラッグされているセルを返す
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizContentsListCell") as! QuizContentsListViewCell
        // セルに表示する値を設定する
        cell.QuizNoLabel.text = String(questionSettingList[indexPath.row].questionNo)   // 問題番号
        cell.questionLabel.text = questionSettingList[indexPath.row].question           // 問題文
        cell.QuizTypeLabel.text = common.getQuizTypeString(                             // 問題形式
            quizType: questionSettingList[indexPath.row].type
        )
        // セルのデリゲートを設定する
        cell.delegate = self
        
        return cell
    }
    
    /// セルが押された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuizContentsAddView") as! QuizContentsAddViewController
        // 画面の情報を渡す
        secondViewController.quizContentsListViewController = self
        // 押されたセルの番号を取得する
        secondViewController.tapQuestionNo = questionSettingList[indexPath.row].questionNo
        // TableViewControllerに遷移する
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    /// テーブルを更新する
    func tableReload() {
        questionSettingList = commonJson.getQuestionSettingJson(jsonFile: self.fileName)
        self.TableView.reloadData()
    }
}
