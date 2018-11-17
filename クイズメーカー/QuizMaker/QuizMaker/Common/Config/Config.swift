import Foundation

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                                   共通設定クラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class Config {
    // 問題ファイルを格納するディレクトリ名
    let CONFIG : [String : String] = [
        "QUIZ_SAVE_DIRECTORY_NAME" : "QuizList"
    ]
    
    // カテゴリー一覧
    let CategoryList: [[Any]] = [
        [0 , "IT・科学"],
        [1 , "エンターテイメント"],
        [2 , "スポーツ"],
        [3 , "健康・医療"],
        [4 , "動物"],
        [5 , "生活文化"],
        [6 , "ニュース・社会経済"],
        [7 , "グルメ"],
        [8 , "旅行・観光"]
    ]
    
    // ファイル名のカテゴリー種類
    let CategoryNumber: [String] = [
        "01",   // IT・科学
        "02",   // エンターテイメント
        "03",   // スポーツ
        "04",   // 健康文化
        "05",   // 動物
        "06",   // 生活文化
        "07",   // ニュース・社会経済
        "08",   // グルメ
        "09",   // 旅行・観光
    ]
    
    // クイズタイプ
    let quizTypeConfig: [[Any]] = [
        [0 , "択一"],
        [1 , "複数"],
        [2 , "記述"]
    ]
    
    // StoryBoard Id
    let StroyBoardId: [String : String] = [
        "QuizListViewController" : "QuizListView",
        "QuizAddViewController" : "QuizAddView"
    ]
    
    // TableViewCell （Xib : identifity）
    let TableViewCellName: [String : String] = [
        "TextViewCell" : "TextViewCell",
        "TextFieldCell" : "TextInputCell",
        "RightDetailCell" : "RightDetailCell"
    ]
}
