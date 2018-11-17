import Foundation
import FMDB

class CommonDB {
    
    
    /// データベースまでのパスを取得する
    ///
    /// - Returns: データベースまでのパス
    func setPath()->(String){
        // /Documentsまでのパスを取得
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)
        // <Application>/Documents/test.db というパスを生成
        let _path = paths[0] + "/" + "Quiz.db"
        return _path
    }
    
    /// データベースを作成する
    func createDB() {
        if FileManager.default.fileExists(atPath: setPath()) == false {
            // テーブルを作成する
            let createSQL = "CREATE TABLE IF NOT EXISTS file_sequence (file_no INTEGER PRIMARY KEY AUTOINCREMENT);"
            _ = excecuteSQL(sql: createSQL, param: [])
            // 初期値を挿入
            let insertSQL = "INSERT INTO file_sequence (file_no) VALUES (?);"
            _ = excecuteSQL(sql: insertSQL, param: [1])
        }
    }
    
    /// シーケンスを取得する
    ///
    /// - Returns: シーケンス
    func getMakeFileNo() -> Int {
        let selectSQL = "SELECT file_no FROM file_sequence;"
        let resultList = excecuteSelect(sql: selectSQL, columns: ["file_no"])
        let fileNo = Int(resultList[0]["file_no"] as! String)!
        
        return fileNo
    }
    
    /// シーケンスを増加する
    func upSequence() {
        let selectSQL = "SELECT file_no FROM file_sequence;"
        let resultList = excecuteSelect(sql: selectSQL, columns: ["file_no"])
        let updateSQL = "UPDATE file_sequence SET file_no = ?;"
        let updateSequence:Int = Int(resultList[0]["file_no"] as! String)! + 1
        _ = excecuteSQL(sql: updateSQL, param: [updateSequence])
    }
    
    
    /// executeQueryを実行する
    ///
    /// - Parameters:
    ///   - sql: 実行したいSQL
    ///   - columns: 取り出したいカラム
    /// - Returns: 1次元にレコード、2次元にカラムの配列を返す
    func excecuteSelectWhere(sql: String, columns: [String]) -> [[String : Any]] {
        let db = FMDatabase(path: setPath())
        db.open()
        let results = db.executeQuery(sql, withArgumentsIn: columns)
        
        var resultList: [[String : Any]] = [[String : Any]]()
        while (results?.next())! {
            var tmpResultList: [String : Any] = [:]
            // カラム名を指定して値を取得する方法
            for colmun in columns {
                tmpResultList.updateValue(results?.string(forColumn: colmun) ?? "", forKey: colmun)
            }
            resultList.append(tmpResultList)
        }
        db.close()
        
        return resultList
    }
    
    /// excecuteQueryを実行する
    ///
    /// - Parameters:s
    ///   - sql: 実行するSQL文
    ///   - columns: 取得したいカラム
    /// - Returns: 取得結果
    func excecuteSelect(sql: String, columns: [String]) -> [[String : Any]] {
        let db = FMDatabase(path: setPath())
        db.open()
        let results = db.executeQuery(sql, withArgumentsIn: columns)
        
        var resultList: [[String : Any]] = [[String : Any]]()
        while (results?.next())! {
            var tmpResultList: [String : Any] = [:]
            // カラム名を指定して値を取得する方法
            for colmun in columns {
                tmpResultList.updateValue(results?.string(forColumn: colmun) ?? "", forKey: colmun)
            }
            resultList.append(tmpResultList)
        }
        db.close()
        
        return resultList
    }
    
    /// executeUpdateを実行する
    ///
    /// - Parameters:
    ///   - sql: 実行するSQL文
    ///   - param: パラメーター
    func excecuteSQL(sql: String, param: [Any]) -> Bool {
        let db = FMDatabase(path: setPath())
        // DBを開く
        db.open()
        // 実行
        let ret = db.executeUpdate(sql, withArgumentsIn: param)
        // DBを閉じる
        db.close()
        
        return ret
    }
}
