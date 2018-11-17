import Foundation

/* /////////////////////////////////////////////////////////////////////////////////
 *
 *                             FileSettingの値を格納するクラス
 *
 ///////////////////////////////////////////////////////////////////////////////// */
class QuestionSetting {
    // 共通
    var questionNo : Int = 0            // 問題番号
    var type : Int = 0              // 問題タイプ
    var question : String = ""          // 問題文
    var answer: [String] = []           // 解答一覧
    
    // 択一・複数
    var questionCount : Int = 0         // 問題数
    
    // 複数
    var answerCount: Int = 0            // 正解数
}
