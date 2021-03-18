//
//  CalendarViewController.swift
//  todo_calendar
//
//  Created by yano on 2021/02/19.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let myTodo = todoList[indexPath.row]
        cell.textLabel?.text = myTodo.todoTitle
        if myTodo.todoDone {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
    var todoList = [MyTodo]()
    var todo_notnil_list = [MyTodo]()
    var today_todolist = [MyTodo]()

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendar_tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定?
        self.calendar.dataSource = self
        self.calendar.delegate = self
        
        //日付どんな感じになってる？
        // 年月日の一致
        // 日付を同じ形にしたら、if == でとってこれる
        
        
        let userDefaults = UserDefaults.standard
        
        // UserDefaultsに保存された値を取得
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data{
            do {
                // シリアライズしてtodoListにappend
                if let unarchiveTodoList = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MyTodo.self], from: storedTodoList) as? [MyTodo] {
                    todoList.append(contentsOf: unarchiveTodoList)
                }
            }
            catch{
                // エラー処理なし
            }
        }
    }
    
    // CalendarViewControllerが描画される前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        todo_notnil_list = [] // 毎回描画時に配列をリセット
        today_todolist = []
        
        for task in todoList{
            if task.todoDate != nil{
                todo_notnil_list.append(task)
            }
        }
        print("todo_notnil_date :")
        print(todo_notnil_list)
        
        // 現在日時と合致しているタスクをtableviewに表示
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP") // Y/m/dになる

        // 現在日時をDateformatterに合わせて変形
        let todayString = dateFormatter.string(from: Date())
        
        print("todayString :" + todayString)
        
        for todo_notnil in todo_notnil_list{
            // 登録したタスクの日付がカレンダーの初期選択日（今日）と一致したら
            if todayString.split(separator: " ")[0] == todo_notnil.todoDate!.split(separator: " ")[0]{
                // tableviewに対象のtodo読み込み
                today_todolist.append(todo_notnil)
            }
        }
        // かくににょう
        for todolist in today_todolist{
            print(todolist.todoDone)
        }
        print("task icchi kazu")
        print(today_todolist.count)
    }
    
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        let selectDay = getDay(date)
        
    }
}
