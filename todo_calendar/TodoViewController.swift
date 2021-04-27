//
//  TodoViewController.swift
//  todo_calendar
//
//  Created by yano on 2021/02/19.
//

import UIKit

class TodoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // 要求があったとき、todoListの行数返す
    // アローは関数、func 関数名(引数) -> 返り値{ 処理 }
    // TableView使うのに必須の関数１
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    // 要求があったとき、todoListの行ごとの内容を返す
    // TableView使うのに必須の関数２
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let myTodo = todoList[indexPath.row]
        cell.textLabel?.text = myTodo.todoTitle
        cell.detailTextLabel?.text = myTodo.todoDate
        if myTodo.todoDone {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
    // tableViewの項目をタップした時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let alertController = UIAlertController(title: "タスク編集", message: "タスクを編集できます.                                          　--" , preferredStyle: UIAlertController.Style.alert)
        
        // datapickerの時間の初期値が現在の時間になってしまうのを修正
        // datepicker設定
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.frame = CGRect(x: 15, y: 60, width: 280, height: 30)
        myDatePicker.preferredDatePickerStyle = .compact
        myDatePicker.timeZone = NSTimeZone.local
        myDatePicker.locale = Locale(identifier: "ja_JP")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")

        // タスク編集初期状態のdatepickerの時間を保存
        let init_picker_dateformat = dateFormatter.string(from:myDatePicker.date)
        print("init picker date")
        print(init_picker_dateformat)
        print(todoList[indexPath.row].todoDate ?? "nil dayo")

        // もし前回、タスクの時間を設定していたら、その時間をUIDatePickerの初期設定時間とする
        if let tododate = todoList[indexPath.row].todoDate {
            myDatePicker.date = dateFormatter.date(from: tododate)!
        }
        
        // alertに設定したdatepickerを設置, date自体はUTCで、使用時にlocale読んで変換する
        alertController.view.addSubview(myDatePicker)
        
        // self.todolist??
        // クロージャ,関数？
        // 宣言 :     関数名 = { (引数) -> 返り値の型 in 処理}
        // 呼び出し:   関数名()
        alertController.addTextField{ (textField) -> Void in
            textField.text = self.todoList[indexPath.row].todoTitle! // 強制アンラップ
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                
                // タスク作成して値を入れる
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                
                // ok押した時のdatepickerの時間と、初期時間を比較
                print(dateFormatter.string(from: myDatePicker.date))
                if init_picker_dateformat != dateFormatter.string(from: myDatePicker.date){
                    myTodo.todoDate = dateFormatter.string(from: myDatePicker.date)
                }
                else{
                    myTodo.todoDate = nil
                }

                // ？？ todoList入れてもtableViewには関係ないのでここで更新する意味？
                self.todoList[indexPath.row] = myTodo
                self.tableView.reloadData()
                
                let userDefaults = UserDefaults.standard
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey: "todoList")
                    userDefaults.synchronize()
                }
                catch {
                    // エラー処理なし
                }
            }
        }
        alertController.addAction(okAction)
        
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
        
        
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        }
        catch{
            // エラー処理なし
        }
    }
    
    // 削除可能なタスクを表示
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) ->  Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == UITableViewCell.EditingStyle.delete {
            todoList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
                let userDefault = UserDefaults.standard
                userDefault.set(data, forKey: "todoList")
                userDefault.synchronize()
            }
            catch{
                // エラー処理なし
            }
        }
    }

    var todoList = [MyTodo]()
    var datePicker: UIDatePicker = UIDatePicker()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data{
            do {
                if let unarchiveTodoList = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MyTodo.self], from: storedTodoList) as? [MyTodo] {
                    todoList.append(contentsOf: unarchiveTodoList)
                }
            }
            catch{
                // エラー処理なし
            }
        }
    }
    
    // ビューが閉じられる寸前に実行される
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewdiddisapper")
        // UserDefaultにtodolist項目を格納したい
        let userDefaults = UserDefaults.standard
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
            print("saved to userdefault to:")
            print(self.todoList.count)
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        }
        catch {
            // エラー処理なし
        }
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        let alertController = UIAlertController(title: "タスク追加", message: "タスクを入力してください", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default){ (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
                
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.right)
                
                let userDefaults = UserDefaults.standard
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey: "todoList")
                    userDefaults.synchronize()
                }
                catch {
                    // エラー処理なし
                }
            }
        }
        alertController.addAction(okAction)
        
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// オブジェクトとstandard
// NSObject, NSSecureCoding継承
class MyTodo: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool{
        return true
    }
    
    var todoTitle: String?
    var todoDone: Bool = false
    var todoDate : String?
    
    
    override init(){
    }
    
    //　required init...init関数を強制オーバーライド
    required init?(coder aDecoder: NSCoder) {
        // UserDefault -> Stringに変換
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
        todoDate = aDecoder.decodeObject(forKey: "todoDate") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        // String -> UserDefaultに変換
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDone")
        aCoder.encode(todoDate, forKey: "todoDate")
    }
    
}
