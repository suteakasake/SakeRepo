import UIKit
import YNDropDownMenu

class LocalDropDownMenu : YNDropDownView {
    var sortFlg: Int = 0
    
    @IBOutlet var tradeTypeSegmentControl: UISegmentedControl!
    
    @IBAction func button1(_ sender: Any) {
        sortFlg = 0
        print(sortFlg)
    }
    
    @IBAction func button2(_ sender: Any) {
        sortFlg = 1
        print(sortFlg)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.initViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initViews()
        // self.setRadio()
    }
    
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        self.normalSelected(at: 1)
        self.hideMenu()
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        //        self.changeMenu(title: "Changed", at: 1)
        //        self.changeMenu(title: "Changed", status: .selected, at: 0)
        self.alwaysSelected(at: 1)
        //        self.alwaysSelected(at: 2)
        //        self.alwaysSelected(at: 3)
        self.hideMenu()
        
    }
    
    override func dropDownViewOpened() {
        print("dropDownViewOpened")
    }
    
    override func dropDownViewClosed() {
        print("dropDownViewClosed")
    }
    
    func initViews() {
        
    }
}
