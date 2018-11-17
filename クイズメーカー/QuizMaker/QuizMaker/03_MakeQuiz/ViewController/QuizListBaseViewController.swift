import UIKit
import YNDropDownMenu

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                   「フィルターをかける」押下時のドロップダウンを定義するクラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
extension QuizListBaseViewController {
    func setDropDownMenu() {
        
        // let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let ZBdropDownViews = Bundle.main.loadNibNamed("DropDownView", owner: nil, options: nil) as? [UIView]
        let FFA409 = UIColor.init(red: 255/255, green: 164/255, blue: 9/255, alpha: 1.0)
        
        let view = YNDropDownMenu(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30), dropDownViews: ZBdropDownViews!, dropDownViewTitles: ["フィルターをかける"])
        
        //view.setImageWhen(normal: UIImage(named: "arrow_nor"), selected: UIImage(named: "arrow_sel"), disabled: UIImage(named: "arrow_dim"))
        //view.setImageWhen(normal: UIImage(named: "arrow_nor"), selectedTintColor: FFA409, disabledTintColor: FFA409)
        //view.setImageWhen(normal: UIImage(named: "arrow_nor"), selectedTintColorRGB: "FFA409", disabledTintColorRGB: "FFA409")
        
        view.setLabelColorWhen(normal: .black, selected: FFA409, disabled: .gray)
        view.setLabelColorWhen(normalRGB: "000000", selectedRGB: "FFA409", disabledRGB: "FFA409")
        
        view.setLabelFontWhen(normal: .systemFont(ofSize: 12), selected: .boldSystemFont(ofSize: 12), disabled: .systemFont(ofSize: 12))
        //            view.setLabel(font: .systemFont(ofSize: 12))
        
        view.backgroundBlurEnabled = true
        //            view.bottomLine.backgroundColor = UIColor.black
        view.bottomLine.isHidden = false
        // Add custom blurEffectView
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        view.blurEffectView = backgroundView
        view.blurEffectViewAlpha = 0.7
        
        // Open and Hide Menu
        view.alwaysSelected(at: 0)
        //            view.disabledMenuAt(index: 2)
        //view.showAndHideMenuAt(index: 3)
        
        view.setBackgroundColor(color: UIColor.white)
        
        self.view.addSubview(view)
    }
}

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                          QuizLIstViewControllerの土台クラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class QuizListBaseViewController: UIViewController {
    
    // 共通クラス
    let common: Common = Common()
    let commonDB: CommonDB = CommonDB()
    let config: Config = Config()
    let commonString: ConfigString = ConfigString()
    
    // 可変変数
    var categoryNum: Int = 0                                    // カテゴリーナンバー
    var viewControllers: [QuizListViewController] = []          // 配列に初期化したViewControllerを格納
    
    /// 初期処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期化
        initSetting()
        // UI設定
        initUISetting()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 初期化処理
    func initSetting() {
        // データベースを作成する ※ 作成タイミングを変える方がいいかも・・
        commonDB.createDB()
        
        // カテゴリーの数だけ「QuizListViewController」を作成する
        self.viewControllers = getQuizListViewControllers()
        
        // フォルダーの場所（確認用）
        let documentDirPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(documentDirPath)
    }
    
    // UI初期化処理
    func initUISetting() {
        // ナビゲーションバーの共通設定
        common.navigationBarSetting(navigationController: self.navigationController!)
        
        // PageMenuViewを作成して、画面に表示する
        let pageMenuCommon: PageMenuCommon = PageMenuCommon(viewController: self)
        let pageMenu = pageMenuCommon.getPageMenuView(vcList: viewControllers)
        self.view.addSubview(pageMenu)
        
        // ナビゲーションバーの右に「＋」アイコンを設置する
        common.navigationIconSetting(this: self,
                               place: 1,
                               icon: UIBarButtonSystemItem.add,
                               selector: #selector(QuizListBaseViewController.makeQuiz))
        
        // ドロップダウンメニュー
        setDropDownMenu()
    }
    
    
    /// QuizListViewControllerを格納した配列を取得する
    ///
    /// - Returns: [QuizListViewController]
    func getQuizListViewControllers() -> [QuizListViewController] {
        
        var qlvcs: [QuizListViewController] = []    // ViewControllerを格納する配列
        
        // カテゴリーの数だけ「QuizListViewController」を作成する
        for category in config.CategoryList {
            // 「QuizListViewController」を作成する
            let vc = storyboard?.instantiateViewController(withIdentifier: "QuizListView") as! QuizListViewController
            // タイトルを設定する
            vc.title = category[1] as? String
            // カテゴリーを登録する
            vc.categoryNum = category[0] as! Int
            // ViewDidLoadを呼び出して、TableViewのメモリ確保を行う
            _ = vc.view
            // この画面の情報を「QuizListViewController」に渡す
            vc.quizListBaseViewController = self
            // 配列に格納する
            qlvcs.append(vc)
        }
        // keyの昇順にソートする
        qlvcs.sort(by: {$0.categoryNum < $1.categoryNum})
        
        return qlvcs
    }

    /// 指定したカテゴリーのテーブルを更新する
    ///
    /// - Parameter categoryNum: カテゴリーナンバー
    func updateTalbeView(categoryNum: Int) {
        viewControllers[categoryNum].updateTalbeView()
    }
    
    /// 追加アイコン押下時の処理
    @objc func makeQuiz() {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuizAddView") as! QuizAddViewController
        secondViewController.quizListBaseViewController = self
        // TableViewControllerに遷移する
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
