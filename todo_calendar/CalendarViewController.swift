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
        return today_todolist.count
    }
    
    // cellforrowat セルの内容作って返す, 細かい処理はtableviewがやってくれる！返す値を渡すだけ
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let myTodo = today_todolist[indexPath.row]
        cell.textLabel?.text = myTodo.todoTitle
        if myTodo.todoDone {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
    var todoList = [MyTodo]() // UserDefaultsからとってくる全体のTodolist
    var today_todolist = [MyTodo]() // Calendar画面で描画されるtodoList

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendar_tableView: UITableView!
    
    // 初回の一回のみ実行
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定?
        self.calendar.dataSource = self
        self.calendar.delegate = self
    }
    
    // CalendarViewControllerが描画される前に毎回呼び出される（画面遷移したときなど）
    override func viewWillAppear(_ animated: Bool) {
        todoList = [] // UserDefaultsからとってきたtodoList全体を格納する

        // UserDefaultsから値取得する処理
        let userDefaults = UserDefaults.standard
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
        today_todolist = []
        print("today_todolist")
        print(today_todolist)
        // 現在日時と合致しているタスクをtableviewに表示
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP") // Y/m/dになる

        // 現在日時をDateformatterに合わせて変形
        let todayString = dateFormatter.string(from: Date())
        
        print("todayString :" + todayString)
        // todoListから今日の日付一致したものを検索
        for todo in todoList{
            if let _ =  todo.todoDate{
                print(todo.todoTitle!)
                print(todo.todoDate!.split(separator: " ")[0])
                // todoListの日付がカレンダーの初期選択日（今日）と一致したら
                if todayString.split(separator: " ")[0] == todo.todoDate!.split(separator: " ")[0]{
                    // today_todolistにtodo追加
                    today_todolist.append(todo)
                }
            }

        }
        print("task icchi kazu")
        print(today_todolist.count)
        self.calendar_tableView.reloadData()
        
    }
    
    func getDay(_ date:Date) -> String{
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return String(year) + "/" + String(month) + "/" + String(day)
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
//        let selectDay = getDay(date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let selectDay = dateFormatter.string(from: date).split(separator: " ")[0]
        
        today_todolist = []
        // todoListから今日の日付一致したものを検索
        for todo in todoList{
            if let _ =  todo.todoDate{
                // todoListの日付がカレンダーの初期選択日（今日）と一致したら
                if selectDay == todo.todoDate!.split(separator: " ")[0]{
                    // today_todolistにtodo追加
                    today_todolist.append(todo)
                }
            }
        }
        
        self.calendar_tableView.reloadData()
    }
}
