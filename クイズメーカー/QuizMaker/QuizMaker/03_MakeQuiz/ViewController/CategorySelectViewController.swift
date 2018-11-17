import UIKit

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                  カテゴリー選択画面
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class CategorySelectViewController: UIViewController {
    @IBOutlet weak var TableView: UITableView!
    
    // 固定変数
    var categoryList : [[Any]] = [[]]
    
    // 画面変数
    var quizAddViewController : QuizAddViewController!          // 画面情報
    
    // 共通クラス
    let common: Common = Common()
    let config: Config = Config()
    let commonString: ConfigString = ConfigString()

    /// 初期処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // カテゴリー一覧を取得
        categoryList = config.CategoryList
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                  カテゴリー選択画面
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension CategorySelectViewController : UITableViewDelegate, UITableViewDataSource {
    /// カテゴリーの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    /// セルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        var cell: UITableViewCell!
        // セルの関連付け
        cell = TableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = categoryList[indexPath.row][1] as? String
        
        return cell
    }
    
    ///
    // セルが押された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 新規問題作成画面のカテゴリーを変更する
        quizAddViewController.changeCategoryNumber(categoryNumber: categoryList[indexPath.row][0] as! Int)
        // 新規問題作成画面のテーブルを更新する
        quizAddViewController.updateTableView()
        // ContactViewControllerに戻る
        self.navigationController?.popViewController(animated: true)
    }
}
