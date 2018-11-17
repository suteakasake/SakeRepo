import UIKit

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                  タイトル、説明文を入力するTextViewを設置したUIViewクラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class SettingChangeTextView: UIView {
    
    @IBOutlet weak var EditTextView: UITextView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        // loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        // loadNib()
    }
    
    override func awakeFromNib() {
        // 枠のカラー
        EditTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        // 枠の幅
        EditTextView.layer.borderWidth = 1.0
//        let editView = Bundle.main.loadNibNamed("SettingChangeView", owner: self, options: nil)!.first! as! UIView
        
        // XIB読み込み
        // let view = Bundle.main.loadNibNamed("SettingChangeView", owner: self, options: nil)?.first as! UIView
        // XIB読み込み
        //EditTextView.delegate = self
    }
    
    
    func loadNib(){
//        let view:UIView = UINib(nibName: "SettingChangeView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
//        let editView = Bundle.main.loadNibNamed("SettingChangeView", owner: self, options: nil)!.first! as! SettingChangeTextView
//        editView.frame = self.bounds
//        self.addSubview(editView)
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                    カテゴリーを変更するPickerを設置したUIViewクラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class SettingChangeCategory: UIView {
    @IBOutlet weak var CategoryPicker: UIPickerView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        // loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        // loadNib()
    }
}






// 参考にする用
class MyCustomView: UIView {
    
    //コードから生成したときに通る初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    //InterfaceBulderで配置した場合に通る初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        //MyCustomView.xibファイルからViewを生成する。
        //File's OwnerはMyCustomViewなのでselfとする。
        // File's Ownerは、xibをロードするクラスのオブジェクトらしい
        guard let view = UINib(nibName: "MyCustomView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        //ここでちゃんとあわせておかないと、配置したUIButtonがタッチイベントを拾えなかったりする。
        view.frame = self.bounds
        
        //伸縮するように
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        //addする。viewオブジェクトの2枚重ねになる。
        self.addSubview(view)
    }
    
}
