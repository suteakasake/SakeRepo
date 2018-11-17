import Foundation
import UIKit

class PageMenuCommon {
    
    let this: UIViewController  // UIViewController
    let commonColor: CommonColor = CommonColor(colorFlg: 0)
    
    
    /// コンストラクタ
    ///
    /// - Parameter viewController: UIViewController
    init(viewController: UIViewController) {
        self.this = viewController
    }
    
    
    /// PageMeneを作成する
    ///
    /// - Parameter vcList: 表示するUIViewController
    /// - Returns: PageMenu
    func getPageMenuView(vcList: [UIViewController]) -> PageMenuView {
        let option = getPageMenuOption()
        let pageMenu = PageMenuView(viewControllers: vcList, option: option)
        return pageMenu
    }
    
    /// PageMenuOptionを作成する
    ///
    /// - Returns: PageMenuOption
    func getPageMenuOption() -> PageMenuOption {
        let displaySizeList = getDisplayPartsSize(statusBar: true,
                                                  navBar: true,
                                                  tabBar: true)
        // バーの高さの合計を取得する
        var subtractionHeight: CGFloat = 0
        for size in displaySizeList {
            subtractionHeight += size.value
        }
        
        var option = PageMenuOption(
            frame: CGRect (
                x: 0,
                y: 30,
                width: self.this.view.frame.size.width,
                height: self.this.view.frame.size.height - subtractionHeight
            )
        )
        
        option.menuIndicatorColor = commonColor.getNavigationBarBackgroundColor()
        
        return option
    }
    
    /// ディスプレイサイズ
    ///
    /// - Returns: 画面部品のサイズ
    func getDisplayPartsSize(statusBar: Bool,
                             navBar: Bool,
                             tabBar: Bool) -> [String : CGFloat] {
        var sizeList: [String: CGFloat] = [:]
        if statusBar {
            // ステータスバーの高さを取得
            let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
            sizeList["statusBarHeight"] = statusBarHeight
        }
        
        if navBar {
            // ナビゲーションバーの高さを取得
            let navBarHeight = self.this.navigationController?.navigationBar.frame.size.height
            sizeList["navigationBarHeight"] = navBarHeight
        }
        
        if tabBar {
            // タブバーの高さ
            let tabheight = self.this.tabBarController?.tabBar.frame.size.height
            sizeList["tabBarHeight"] = tabheight
        }
        
        return sizeList
    }
}
