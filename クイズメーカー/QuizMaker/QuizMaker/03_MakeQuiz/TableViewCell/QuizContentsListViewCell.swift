import UIKit
import SwipeCellKit

class QuizContentsListViewCell: SwipeTableViewCell {

    // アウトレット接続
    @IBOutlet weak var QuizNoLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var QuizTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 複数業入力を可能にする
        questionLabel.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
