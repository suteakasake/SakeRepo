import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var HeadTextLabel: UILabel!
    @IBOutlet weak var TextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
