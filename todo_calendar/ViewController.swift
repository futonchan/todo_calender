//
//  ViewController.swift
//  todo_calendar
//
//  Created by yano on 2021/02/01.
//

import UIKit


// tableviewdatasource
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    // tableView関数の説明
    // tableView関数(tableView: 対象のテーブルビュー, どんな処理するか, indexPaht:選択セルのindex)
    
    // sectionごとのデータ返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // todoの配列の長さ返却、継承時に呼ばれるのでいる
        print("call numberOfRowsInSection")
        return todoList.count
    }
    
    // cellにテーブルの行ごとの情報詰めて返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todocell", for: indexPath)

        // 通常のUserDefaults使う時
        //        let todoTitle = todoList[indexPath.row]
        //        cell.textLabel?.text = todoTitle
        
        // 独自データのUserDefaults使うとき
        let myTodo = todoList[indexPath.row] // indexPath??
        cell.textLabel?.text = myTodo.todoTitle // セルのラベルにtodoのタイトルセット
        // todoDoneの値によってcellにチェックマークつけるか否か判定
        if myTodo.todoDone {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
    // cellをタップしたときの処理になる、tableView:didSelectRowAt
    // タップしたときにチェックマークonoff
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone{
            myTodo.todoDone = false
        }
        else{
            myTodo.todoDone = true
        }
        
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        do {
            // シリアライズ
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            // userdefaultに保存
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        }
        catch{
            //エラー握り潰し
        }
    }
    
    // セルが編集可能かどうか返す(セル削除の処理に必要
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除できるかみる
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // todoリストから削除
            todoList.remove(at: indexPath.row)
            // セル削除
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            // 削除されたのがなくなったtodoListを再度NSData型にarchive
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            }
            catch{
                // にぎりつぶす
            }
        }
    }
    
//    var todoList = [String]()
    // UserDefaultからtodoList読み込みするために、空のMyTodo配列を宣言
    var todoList = [MyTodo]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var button_tod: UIButton!
    @IBOutlet weak var button_cal: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
// UserDefaultsからTodolistのデータ引っ張ってくる
//        let userDefaults = UserDefaults.standard
//        if let storedTodoList = userDefaults.array(forKey: "todoList") as? [String] {
//            todoList.append(contentsOf: storedTodoList)
//        }

        // UserDefaults宣言
        let userDefaults = UserDefaults.standard
        // シリアライズされたデータ読みこみのときは、as? Data{} になる
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data{
            do {
                // 保存しているTODOlistの読み込み処理, 独自クラスなのでunarchiveする
                if let unarchiveTodoList = try NSKeyedUnarchiver.unarchivedObject(
                    ofClasses: [NSArray.self, MyTodo.self],
                    from: storedTodoList) as? [MyTodo] {
                    todoList.append(contentsOf: unarchiveTodoList)
                }
            }
            catch{
                // エラー握りつぶす
            }
        }
        
    }
    
    // +ボタンタップ
    @IBAction func tapAddButton(_ sender: Any) {
        // アラートインスタンス
        let alertController = UIAlertController(title: "タスク追加",
                                                message:"タスクを入力してください",
                                                preferredStyle: UIAlertController.Style.alert
                                                )
        // アラート画面にテキスト入力フィールド追加
        alertController.addTextField(configurationHandler: nil)
        
        // okボタン押したときのアクションの定義
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            // alertにタスクが入力されているとき
            if let textField = alertController.textFields?.first {

                // 通常のuserdefaultを使うとき
//                self.todoList.insert(textField.text!, at: 0) // textをindex0(先頭)に追加
                
                // 独自データのuserdefaultをインスタンス化
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text
                self.todoList.insert(myTodo, at: 0) // 先頭に挿入
                
                // UIテーブルビューに追加されたこと通知,これで再描画
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)],
                                          with: UITableView.RowAnimation.right)
                
                // userDefaults宣言
                let userDefaults = UserDefaults.standard
                // 通常のuserdefaultを使う時
//                userDefaults.set(self.todoList, forKey: "todoList")
//                userDefaults.synchronize()
            
                // self.todoListをNSData型にシリアライズ(archive)
                do {
                    let data = try NSKeyedArchiver.archivedData(
                        withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey: "todoList")
                    userDefaults.synchronize()
                }
                catch{
                    // エラー握り潰す
                }
            }
            
        }
        // アラートにokaction関連付け
        alertController.addAction(okAction)
        
        // cancelボタン押した時のアクション定義
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.cancel,
                                         handler: nil)
        // アラートにcancelaction関連付け
        alertController.addAction(cancelAction)
        
        // アラートダイアログ描画
        present(alertController, animated: true, completion: nil)

    }
}

// userDefaultsで独自データ保存するためにNSObjectで独自データをエンコード、デコードする定義
class MyTodo: NSObject, NSSecureCoding{
    
    static var supportsSecureCoding: Bool{
        return true
    }
    
    var todoTitle: String?
    var todoDone: Bool = false
    
    override init(){
    }
    
    // decode, 処理まる覚えでよさげ
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
    }
    
    //encode, 処理まる覚えでよさげ
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDone")
    }
}
