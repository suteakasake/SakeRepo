import UIKit

class QuizListViewCell: UITableViewCell {
    
    var fileName: String = ""
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 複数行入力を可能にする
        DescriptionLabel.numberOfLines = 0
        //contentsのサイズに合わせてobujectのサイズを変える
        DescriptionLabel.sizeToFit()
        //単語の途中で改行されないようにする
        DescriptionLabel.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
