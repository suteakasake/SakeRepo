import UIKit

class NumberCountSelectViewController: UIViewController {
    
    var common:Common = Common()
    @IBOutlet weak var TableView: UITableView!
    
    // 選択肢か正解数を判定するフラグ
    var selectType: Int = 0
    // 問題形式を判定する
    var quizType: Int = 0
    // 選択肢数
    var choiseCount: Int = 0
    // 正解数
    var answerCount: Int = 0
    
    // 選択肢
    var countList: [Int] = []
    // 最小選択肢数
    var minChoiseCount = 2
    // 最大選択肢数
    var maxChoiseCount = 10
    
    var firstViewController: QuizContentsAddViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 問題形式を取得
        quizType = firstViewController.quizType
        
        // 表示する数値の値を取得する
        if quizType == 0 {  // 単一の場合
            for i in minChoiseCount...maxChoiseCount {
                countList.append(i)
            }
        } else if quizType == 1 {   // 複数の場合
            if selectType ==  0 {   // 選択肢の数
                answerCount = firstViewController.quizValueList[quizType].answerCount
                for i in answerCount...maxChoiseCount {     // 正解数 + 1 〜 最大選択肢数
                    countList.append(i)
                }
            } else if selectType == 1 { // 答えの数
                choiseCount = firstViewController.quizValueList[quizType].choiceCount
                for i in 2...choiseCount { // 2 〜 選択肢数
                    countList.append(i)
                }
            }
        }
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension NumberCountSelectViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        var cell: UITableViewCell!
        // セルの関連付け
        cell = TableView.dequeueReusableCell(withIdentifier: "NumberCountSelectCell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = String(countList[indexPath.row])
        
        return cell
    }
    
    // セルが押された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if quizType == 0 {  // 単一
            // 増減分構造体を変化させる
            firstViewController.changeChoiceValueCount(choiceCount: Int(countList[indexPath.row]))
        } else { // 複数
            if selectType == 0 {    // 選択肢の場合
                // 増減分構造体を変化させる
                firstViewController.changeChoiceValueCount(choiceCount: Int(countList[indexPath.row]))
            } else if selectType == 1 {
                // 正解数を変更する
                firstViewController.changeAnswerCount(answerCount: Int(countList[indexPath.row]))
            }
        }
        // テーブルを更新する
        firstViewController.tableReload()
        // ContactViewControllerに戻る
        self.navigationController?.popViewController(animated: true)
    }
}
