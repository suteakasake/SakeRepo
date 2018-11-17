import UIKit

class QuizTypeSelectViewCell: UITableViewCell {
    
    // クイズ追加画面の情報
    var quizContentsAddViewController: QuizContentsAddViewController!
    
    // アウトレット接続
    @IBOutlet weak var QuizTypeSegmentControl: UISegmentedControl!
    
    // 共通クラス
    let common:Common = Common()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // セグメントコントローラーに動作を加える
        QuizTypeSegmentControl.addTarget(self, action: #selector(QuizTypeSelectViewCell.segmentAction(sender:)), for: .valueChanged)
    }
    
    /// セグメントコントローラーのアクション
    ///
    /// - Parameter sender: sender
    @objc func segmentAction(sender: Any) {
        // セグメントのインデックス番号を取得
        let selectedIndex = (sender as AnyObject).selectedSegmentIndex
        // 問題形式を取得
        let quizType: Int = common.getQuizTypeNumber(quizType: selectedIndex!)  // 切り替え後の問題形式
        let beforeQuizType: Int = quizContentsAddViewController.quizType
        // 切り替えフラグを立てる
        quizContentsAddViewController.segmentedChangeFlg = true
        // クイズタイプを変更する
        quizContentsAddViewController.quizType = quizType
        quizContentsAddViewController.beforeQuizType = beforeQuizType
        // テーブルをリロードする
        quizContentsAddViewController.tableReload()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
