import Foundation
import UIKit

class CommonColor {
    
    var colorFlg: Int = 0
    
    /// コンストラクタ
    init (colorFlg: Int) {
        self.colorFlg = colorFlg
    }
    
    func getNavigationBarBackgroundColor() -> UIColor {
        // 背景色を変更する
        switch self.colorFlg {
        case 0:
            // 背景色
            return UIColor.NavigationBarBackgrounColor_Blue()
        case 1:
            return UIColor.NavigationBarBackgrounColor_Green()
        default:
            return UIColor.NavigationBarBackgrounColor_Blue()
        }
    }
    
    func getNavigationBarItemColor() -> UIColor {
        // 背景色を変更する
        switch self.colorFlg {
        case 0:
            // アイテムカラー
            return UIColor.NavigationBarItemColor()
        case 1:
            return UIColor.NavigationBarItemColor()
        default:
            return UIColor.NavigationBarItemColor()
        }
    }
}
