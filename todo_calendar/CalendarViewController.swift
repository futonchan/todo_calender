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
        cell.detailTextLabel?.text = myTodo.todoDate
        if myTodo.todoDone {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
    // class内に書いてるのでself.でとってこれる変数たち
    var todoList = [MyTodo]() // UserDefaultsからとってくる全体のTodolist
    var today_todolist = [MyTodo]() // Calendar画面で描画されるtodoList
    var datesWithEvent = [String]()

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
        self.todoList = [] // UserDefaultsからとってきたtodoList全体を格納する
        self.datesWithEvent = [] // selfつけるつけないはプログラムに影響なし、self付けた方がわかりやすい
        
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
//        print("today_todolist")
//        print(today_todolist)
        // 現在日時と合致しているタスクをtableviewに表示
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP") // Y/m/dになる

        // 現在日時をDateformatterに合わせて変形
        let todayString = dateFormatter.string(from: Date())
        
//        print("todayString :" + todayString)
        // todoListから今日の日付一致したものを検索
        for todo in todoList{
            if let _ =  todo.todoDate{
//                print(todo.todoTitle!)
//                print(todo.todoDate!.split(separator: " ")[0])
                datesWithEvent.append(String(todo.todoDate!.split(separator: " ")[0]))
                // todoListの日付がカレンダーの初期選択日（今日）と一致したら
                if todayString.split(separator: " ")[0] == todo.todoDate!.split(separator: " ")[0]{
                    // today_todolistにtodo追加
                    today_todolist.append(todo)
                }
            }

        }
//        print("task icchi kazu")
//        print(today_todolist.count)
        self.calendar_tableView.reloadData()
        
        
    }
    
    // ここの関数、明示的に呼び出したい
    // delegateメソッドと言われるもので、呼び出しは向こうが勝手に決めてるっぽい
    // タスクがある日を、カレンダー上へ設定した色で点をうつ
    // カレンダー動かすなど、動きをしないと新しいタスクの点が描画されない
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short //元データは時刻もある？
        dateFormatter.locale = Locale(identifier: "ja_JP") // Y/m/dになる
        let dateString = dateFormatter.string(from: date)
//        print("event point")
//        print(dateString)
//        print(datesWithEvent)
        // dateswitheventがイベント日がある配列
        if self.datesWithEvent.contains(String(dateString.split(separator: " ")[0])) {
           return 1 // Here, We have to assign JSON count key value based on duplication it will increase dot count UI.
        }
        return 0
    }
    
    // 現在選択している年月日をy/m/dで取得する
    func getDay(_ date:Date) -> String{
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return String(year) + "/" + String(month) + "/" + String(day)
    }
    
    // カレンダーの日時が選択されたときに呼び出される
    // 全体のtodoListから選択した日時のタスクのものをtableView上に表示する
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        
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
