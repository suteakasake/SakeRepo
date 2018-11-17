import Foundation
import UIKit
import PopupDialog

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                      カラー
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    // アプリの背景色
    class func ApplicationBackgrounColor() -> UIColor {
        return UIColor.rgb(r: 239, g: 239, b: 244, alpha: 1.0)
    }
    // ナビゲーションバーの背景色（水色）
    class func NavigationBarBackgrounColor_Blue() -> UIColor {
        return UIColor.rgb(r: 118, g: 213, b: 255, alpha: 1.0)
    }
    // ナビゲーションバーの背景色（緑色）
    class func NavigationBarBackgrounColor_Green() -> UIColor {
        return UIColor.rgb(r: 84, g: 197, b: 1, alpha: 1.0)
    }
    // ナビゲーションバーのアイテムカラー（白色）
    class func NavigationBarItemColor() -> UIColor {
        return UIColor.rgb(r: 255, g: 255, b: 255, alpha: 1.0)
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                パディングラベル
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class PaddingLabel: UILabel {
    
    @IBInspectable var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                  ダイアログ
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class CommonPopupDialog {
    var this: UIViewController!
    var vc: UIViewController!
    var buttonAlign: Int!
    var okFunc: DefaultButton!
    var ngFunc: DefaultButton!
    
    let popup:PopupDialog!
    
    /// PopupDialogの初期化
    ///
    /// - Parameters:
    ///   - vc: ダイアログに表示するビューコントローラー
    ///   - buttonAlign: ボタンの並び 0: horizon, 1: vertical
    ///   - okFunc: 「OK」ボタンを押された際のコールバックメソッド
    ///   - ngFunc: 「NG」ボタンを押された際のコールバックメソッド
    init (this: UIViewController,
          vc: UIViewController,
          buttonAlign: Int,
          okFunc: DefaultButton,
          ngFunc: DefaultButton) {
        
        self.this = this
        self.vc = vc
        self.buttonAlign = buttonAlign
        self.okFunc = okFunc
        self.ngFunc = ngFunc
        
        // 表示したいビューコントローラーを指定してポップアップを作る
        self.popup = PopupDialog(viewController: vc)
        self.popup.buttonAlignment = .horizontal
        
        // ポップアップにボタンを追加
        popup.addButtons([ngFunc, okFunc])
    }
    
    func showPopupDialog() {
        // 作成したポップアップを表示する
        this.present(popup, animated: true, completion: nil)
    }
}

class VariousParts {
    
    var this:UIViewController?
    
    init(this:UIViewController) {
        self.this = this
    }
    
    /**********************************************************************************************
     *                                キーボードに閉じるボタンを追加する
     **********************************************************************************************/
    func textViewAddClose( textView : inout UITextView) {
        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                     target: self,
                                     action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
                                           target: self,
                                           action: #selector(VariousParts.commitButtonTapped))
        kbToolBar.items = [spacer, commitButton]
        textView.inputAccessoryView = kbToolBar
    }
    
    @objc func commitButtonTapped() {
        self.this?.view.endEditing(true)
    }
}

//閉じるボタンの付いたキーボード
class KeyBoard: UITextField{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(KeyBoard.closeButtonTapped))
        tools.items = [spacer, closeButton]
        self.inputAccessoryView = tools
    }
    
    @objc func closeButtonTapped(){
        self.endEditing(true)
        self.resignFirstResponder()
    }
}
