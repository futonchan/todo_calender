## やること
- [x] TodoList, Calenderボタンが表示されない
- [x] カレンダー表示
- [x] カレンダー画面側TodoListを機能させる
カレンダーの選択した日時取得
- [ ] カレンダー見やすくする（曜日）
デザインの話、後回し
- [x] タスク編集機能（日付、内容の編集）
- [x] カレンダーとタスク日付の連動（日付とタスクの有無）
タスクに日付設定ができてから→できた、todoDate
流れ... カレンダー読み込み時にタスク一覧読み込んでから、タスクを一つずつ見ていって、
カレンダー読み込んでる日付の分だけとって、カレンダーのタスクがある日の色を帰る
カレンダータップ時に、その日付を読み込んで、listに表示する

- [x] カレンダー側TodoListがデータロード元指定してないのに読み込んでいる
謎、プログラムを読む -> 俺のTableViewの理解が足りなかった  
データロードしてるのは必須メソッドになってる2つ、更新するとデータとってきてくれる

- [x] カレンダー初期設定時の日付のtodolistに、todolist画面でのタスクが読み込まれていない。これはカレンダー画面側でシリアライズされた情報を読み取っているため。解決策は、シリアライズのタイミングを画面遷移時に行うか、画面間でtodolist変数の受け渡しをするか。次はこれやったほうが良さそう
- [ ] UserDefaultにデータ全部保存してるので、RealmみたいなDBにタスク保存できたらいいね
- [ ] カレンダーのイベントの点がカレンダー動かさないと更新されない。。。
- [ ] タスクのぱーせんと表記
- [ ] 締切管理に焦点あてる
- [ ] 親子機能、大項目、中項目、小項目

# 構成
- XCode
- Swift
- Storyboard
- FSCalendar

## 覚書
- .xcworkspaceから起動しないとカレンダー読み込まれない
- class宣言時に、カレンダー使うさいには、カレンダーに関連したクラスを継承する必要がある
- Date比較は、Stringで比較しないほうがいい
- DateFormatterは何もしないと標準で、.locale決めてから、dataformatterがcallされてはじめて+09:00されて日本の時間になる
- とりあえず初手Apple Developer Document読む
- cocoapod = pipみたいなパッケージ管理、podfileに入れたいもの書いて、pod installでインストールされる
- UserDefault,iOSのアップデートでデータ消える？
 
# わからないこと
- CalendarViewのTableViewがどこからデータを撮ってきているのか  
予想：必須メソッドの「numberOfRowsInSection」と「cellForRowAt」。更新（self.tableview.reload, self.tableview.insertrowsも？）を行うことで、必須メソッドが実行されてtableViewにデータが反映される。

- なんでコードのみで関係性が表示できないのか
- tableView使う上で必須の関数2つの名前はtableViewと決まっているみたいだが、すでに変数でtableViewが使われていることには関係ないのか？（多分関係ない）
- self.tableViewなどはどこから使い出して、どこで宣言されたのか？  
self.〜は、class内の変数を使えるもの。tableViewはドラッグして@IB Outlet?になってるから、いじりたいときself.がいる。
シリアライズ関係では末尾に.selfついたりするのあり、別物

- tableViewの必須メソッドいじっただけでtableView使ってない処理結果もが変わった  
最初のtableViewの予想があってたらこれもわかる

- アプリの全体像、ビューとの関係性がわからない
- Control + ドラッグでビューを関連づける意味は？何がしたくてやっている？
- ↑の関連づけの際にDelegateもチェック入れるように言われるけどどこで使っているかがわからない
- 構文が長い、メソッドが長い

メモった、C言語の間接参照みたいに、Optional変数宣言のときの「？」と、それ以外の「？」は別物。  
神解説 :https://qiita.com/maiki055/items/b24378a3707bd35a31a8
- 

# 参考サイト
- https://qiita.com/Koutya/items/f5c7c12ab1458b6addcd
- https://qiita.com/maiki055/items/b24378a3707bd35a31a8
- https://developer.apple.com/documentation/uikit/uidatepicker
- https://qiita.com/ytakzk/items/d7bb8182d43cdfc9b580#comment-99f594634ebe7d219b11
