import Foundation
import SwiftyJSON

class CommonJson {
    
    let config: Config = Config()           //  共通設定クラス
    let common: Common = Common()           //  共通クラス
    let commonDB: CommonDB = CommonDB()     //  共通DBクラス
    
    var directoryName: String = ""
    
    /// コンストラクタ
    init() {
        // フォルダ名を取得
        directoryName = config.CONFIG["QUIZ_SAVE_DIRECTORY_NAME"]!
        // フォルダを作成する
        makeDirectory()
    }
    
    /// フォルダを作成する
    func makeDirectory() {
        var docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        docDir = docDir + "/" + directoryName
        
        // フォルダの存在可否を取得
        let fileExist = FileManager.default.fileExists(atPath: docDir)
        // フォルダが存在しなければ作成する
        if fileExist == false {
            // Documents内にTestのディレクトリを作成
            do {
                try FileManager.default.createDirectory(atPath: docDir, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // エラー
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    //                                      表示用
    
    //////////////////////////////////////////////////////////////////////////////////////
    /// テキストとしてDocuments内にあるjson文字列を取得する（表示用）
    ///
    /// - Parameter jsonFileName: Jsonファイル名
    /// - Returns:  Jsonファイルのテキスト
    func jsonRead(jsonFileName: String) -> String {
        let file_name = jsonFileName
        
        // 読み取り
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let path_file_name = dir.appendingPathComponent( "/" + directoryName + "/" + file_name )
            
            do {
                let text = try String( contentsOf: path_file_name, encoding: String.Encoding.utf8 )
                return text
            } catch {
                //エラー処理
            }
        }
        
        return ""
    }
    
    /// Documentsディレクトリの指定したカテゴリのファイル名を配列で返す
    ///
    /// - Parameter category: カテゴリー種類（01, 02・・・）
    /// - Returns: ファイル名一覧を格納した配列
    func getDocumentsDirectoryFileList(category: Int) -> [String] {
        var docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        docDir = docDir + "/" + directoryName
        
        var items : [String] = []
        var retListItem: [String] = []
        do {
            items = try FileManager.default.contentsOfDirectory(atPath: docDir)
            // jsonファイル以外ははじく
            for item in items {
                // jsonファイルの場合
                if item.contains(".json") {
                    // ファイル名からFileSettingクラス内のカテゴリーを取得
                    let categoryNum = getFileSettingJson(jsonFile: item).category

                    if (category == categoryNum) {
                        retListItem.append(item)
                    }
                }
            }
        } catch {
            print(error)
        }
        
        return retListItem
    }
    
    /// 指定したカテゴリーのFileSettingクラス一覧を配列にして返す
    ///
    /// - Parameter categoryNum: カテゴリーナンバー（0, 1, 2・・・）
    /// - Returns: FileSettingクラスを格納した配列
    func getFileSettingList(categoryNum: Int) -> [FileSetting] {
        var fileSettingList : [FileSetting] = []
        // Documentsディレクトリ内の指定したカテゴリーのjsonファイルを全て取得する
        let fileList: [String] = getDocumentsDirectoryFileList(category: categoryNum)
        // FileSettingを作成して配列に格納する
        for file in fileList {
            // 取得したjsonデータをFileSettingクラスに格納する
            let fileSetting = getFileSettingJson(jsonFile: file)
            fileSettingList.append(fileSetting)
        }
        return fileSettingList
    }
    
    /// FileSettingクラスを取得する
    ///
    /// - Parameter jsonFile: Jsonファイル名
    /// - Returns:  FileSettingクラス
    func getFileSettingJson(jsonFile: String) -> FileSetting {
        // 取得したjsonファイルを文字列として展開する
        let jsonStr = jsonRead(jsonFileName: jsonFile)
        // json形式にエンコードしてFileSettingクラスに格納して取得する
        let fileSetting : FileSetting = jsonEncodeFileSetting(jsonStr: jsonStr)
        // FileSettingクラスにファイル名を格納する
        fileSetting.fileName = jsonFile
        
        return fileSetting
    }
    
    /// QuestionSettingクラスを取得する
    ///
    /// - Parameter jsonFile: Jsonファイル名
    /// - Returns: QuestionSettingクラスを格納した配列
    func getQuestionSettingJson(jsonFile: String) -> [QuestionSetting] {
        // 取得したjsonファイルを文字列として展開する
        let jsonStr = jsonRead(jsonFileName: jsonFile)
        // jsonデータにエンコードして、QuestionSettingクラスを格納した配列を返す
        let questionSettingList: [QuestionSetting] = jsonEncodeQuestionSetting(jsonStr: jsonStr)
        
        return questionSettingList
    }
    

    //////////////////////////////////////////////////////////////////////////////////////
    
    //                           Jsonデータにエンコードして取得する用
    
    //////////////////////////////////////////////////////////////////////////////////////
    /// jsonデータにエンコードして、FileSettingクラスを取得する
    ///
    /// - Parameter jsonStr: json文字列
    /// - Returns: FileSettingクラス
    func jsonEncodeFileSetting(jsonStr: String) -> FileSetting {
        // jsonデータにエンコードする
        let lecturerData: Data =  jsonStr.data(using: String.Encoding.utf8)!
        // fileSettingクラスの作成
        let fileSetting : FileSetting = FileSetting()
        do {
            // jsonデータを取得
            let json = try JSON(data: lecturerData)
            let tmpJson = json["data"]["fileSetting"]
            
            // fileSettingクラスに値を格納する
            fileSetting.fileNo = tmpJson["fileNo"].intValue
            fileSetting.title = tmpJson["title"].stringValue
            fileSetting.description = tmpJson["description"].stringValue
            fileSetting.category = tmpJson["category"].intValue
        } catch {
            print(error) // パースに失敗したときにエラーを表示
        }
        
        return fileSetting
    }
    
    /// jsonデータにエンコードして、QuestionSettingクラスを格納した配列を取得する
    ///
    /// - Parameter jsonStr: json文字列
    /// - Returns: QuestionSettingクラスを格納した配列
    func jsonEncodeQuestionSetting(jsonStr: String) -> [QuestionSetting] {
        // jsonデータにエンコードする
        let lecturerData: Data =  jsonStr.data(using: String.Encoding.utf8)!
        
        var questionSettingList: [QuestionSetting] = []
        do {
            // jsonデータを取得
            let json = try JSON(data: lecturerData)
            let tmpJson = json["data"]["questionSetting"]
            
            for i in 0..<tmpJson.count {
                // fileSettingクラスの作成
                let questionSetting: QuestionSetting = QuestionSetting()
                questionSetting.questionNo = tmpJson[i]["questionNo"].intValue
                questionSetting.type = tmpJson[i]["type"].intValue
                questionSetting.question = tmpJson[i]["question"].stringValue
                questionSetting.answer = tmpJson[i]["answer"].arrayObject as! [String]
                if tmpJson[i]["questionCount"] != JSON.null {
                    questionSetting.questionCount = tmpJson[i]["questionCount"].intValue
                }
                if tmpJson[i]["answerCount"] != JSON.null {
                    questionSetting.answerCount = tmpJson[i]["answerCount"].intValue
                }
                
                questionSettingList.append(questionSetting)
            }
            
            
        } catch {
            print(error) // パースに失敗したときにエラーを表示
        }
        
        return questionSettingList
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    //                                  作成・編集処理
    
    //////////////////////////////////////////////////////////////////////////////////////
    // 問題ファイルを作成する（新規作成）
    func makeQuizFile(fileSettingValue: [Any]) {
        let fileNo = String(format: "%07d", fileSettingValue[0] as! CVarArg)
        let file_name = "/" + directoryName + "/" + "\(fileNo).json"
        
        // fileSetting要素の作成
        let fileSettingList = makeFileSettingList(
            value:
            [
                fileSettingValue[0],
                fileSettingValue[1],
                fileSettingValue[2],
                fileSettingValue[3]
            ]
        )
        
        // jsonDataに追加
        // fileSettingの要素を追加する
        var jsonData = Dictionary<String, Any>()
        jsonData["fileSetting"] = fileSettingList
        jsonData["questionSetting"] = []
        // トップオブジェクトの生成
        var param = Dictionary<String, Any>()
        param["data"] = jsonData
        
        // 書き込み
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let path_file_name = dir.appendingPathComponent( file_name )
            
            do {
                let data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                let jsonStr = String(bytes: data, encoding: .utf8)!
                try jsonStr.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
                commonDB.upSequence()
            } catch {
                //エラー処理
            }
        }
    }
    
    // 編集
    func EditJsonTest(jsonFileName: String,
                      fileSetting: FileSetting,
                      questionSettingLista: [QuestionSetting]) {
        let file_name = "/" + directoryName + "/" + jsonFileName
        
        // fileSettingの要素を追加する
        var jsonData = Dictionary<String, Any>()
        
        // fileSetting要素の作成
        var fileSettingList: [String : Any] = [:]
        fileSettingList = makeFileSettingList(
            value:
            [
                fileSetting.fileNo,
                fileSetting.title,
                fileSetting.description,
                fileSetting.category
            ]
        )
        
        // jsonDataに追加
        // FileSetting
        jsonData["fileSetting"] = fileSettingList
        // QuestionSetting
        jsonData["questionSetting"] = makeQuestionSetting(value: questionSettingLista)
        // トップオブジェクトの生成
        var param4 = Dictionary<String, Any>()
        param4["data"] = jsonData
        
        // 書き込み
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let path_file_name = dir.appendingPathComponent( file_name )
            
            do {
                let data = try JSONSerialization.data(withJSONObject: param4, options: .prettyPrinted)
                let jsonStr = String(bytes: data, encoding: .utf8)!
                try jsonStr.write( to: path_file_name, atomically: false, encoding: String.Encoding.utf8 )
            } catch {
                //エラー処理
            }
        }
    }
    
    // fileSettingを作成する（Jsonデータ作成用）
    func makeFileSettingList(value: [Any]) -> [String : Any] {
        // fileSetting要素の作成
        var fileSettingList: [String : Any] = [:]
        fileSettingList["fileNo"] = value[0]
        fileSettingList["title"] = value[1]
        fileSettingList["description"] = value[2]
        fileSettingList["category"] = value[3]
        
        return fileSettingList
    }
    
    // QuestionSetting配列を作成する（Jsonデータ作成用）
    func makeQuestionSetting(value: [QuestionSetting]) -> Array<Any> {
        var questionSettingList = Array<Any>() // var tags = Array<Dictionary<String,  Any>>() でもよい
        
        for qs in value {
            var questionSetting = Dictionary<String, Any>()
            questionSetting["questionNo"] = qs.questionNo
            questionSetting["type"] = qs.type
            questionSetting["question"] = qs.question
            questionSetting["answer"] = qs.answer
            if qs.questionCount != 0 {
                questionSetting["questionCount"] = qs.questionCount
            }
            if qs.answerCount != 0 {
                questionSetting["answerCount"] = qs.answerCount
            }
            // 配列に追加
            questionSettingList.append(questionSetting)
        }
        return questionSettingList
    }
    
    // fileSettingクラスを作成する
    func getFileSetting(value: [Any]) -> FileSetting {
        // fileSettingクラスの作成
        let fileSetting : FileSetting = FileSetting()
        
        // fileSettingクラスに値を格納する
        fileSetting.fileNo = value[0] as! Int
        fileSetting.title = value[1] as! String
        fileSetting.description = value[2] as! String
        fileSetting.category = value[3] as! Int
        
        return fileSetting
    }
    
    /// questionSettingクラスを作成する
    ///
    /// - Parameter value: 第1引数 questionNo      : Int
    ///                    第2引数 type            : String
    ///                    第3引数 question        : String
    ///                    第4引数 answer          : [String]
    ///                    第5引数 questionCount   : Int
    ///                    第6引数 answerCount     : Int
    /// - Returns: QuestionSettingクラス
    func getQuestionSetting(value: [Any]) -> QuestionSetting {
        // 新規にQuestionSettingクラスを作成する
        let questionSetting: QuestionSetting = QuestionSetting()
        
        // QuestionSettingクラスに値を格納する
        questionSetting.questionNo = value[0] as! Int
        questionSetting.type = value[1] as! Int
        questionSetting.question = value[2] as! String
        questionSetting.answer = value[3] as! [String]
        questionSetting.questionCount = value[4] as! Int
        questionSetting.answerCount = value[5] as! Int
        
        return questionSetting
    }
}

