# QRCodeSample
文字列からQRコードの作成、読み取り機能を実装したサンプルアプリです。
## 1. サンプル概要
文字列からQRコードを作成して、アルバムへの保存、SNSへのシェアをすることができます。

QRコードから文字列を読み込んで一覧に追加することができます。
### 1-1. 画像キャプチャ
![QRCodeSample 001](https://github.com/tibita11/QRCodeSample/assets/108079580/72097d33-6156-43af-baa1-4a91f06cbd9d)
## 2. 実装ポイント
### 2-1. TableView操作はRxDataSourcesを使用してシンプルに
繁雑になりやすいTableView操作は、RxDataSourcesを使用してシンプルに書けるようにしました。
### 2-2. RxRealmを使用してリアルタイムに
RxRealmを使用して、データベース内の変更に対してリアルタイムに反応し、必要な処理を実行するようにしました。
### 2-3. DBにはRealmを使用してローカル環境で保存
Realmを選択した理由はローカル環境で行いたく、かつ実績のあるライブラリであると判断したためです。
### 2-4. インメモリなRealmを使用してユニットテストを実行
Realmへの保存処理をテストし、コードの品質をあげることを目的に、インメモリなRealmを使用して、テストコードを記載しました。
### 2-5. CIFilterを使用してQRコードを作成
### 2-6. PHPhotoLibraryを使用してアルバムに保存
### 2-7. UIActivityViewControllerを使用してシェア機能を実装
### 2-8. LPLinkMetadataを使用してシェア画面にQRコードとタイトルを表示
デフォルトの状態だと、アプリのアイコンが表示されていますが、それだとシェアしているものが不確かなので、QRコードの画像と、シェアする際に送られる文がシェア画面上で見れるように設定しました。
### 2-9. CIDetectorを使用して画像からQRコードを検出
### 2-10. AVFoundationを使用してカメラからQRコードを読み取り
### 2-11. ユニットテストができない箇所についてはUIテストを実施
カメラやフォトの許可アラートについては、ユニットテストが難しいので、UIテストで実施するようにしました。
その際に、一度setUpメソッドでresetAuthorizationStatusメソッドを実行し、初回起動時と同じ処理が行われるようにしました。
### 2-12. アーキテクチャはMVVMを使用してFatにならないように
RxSwiftを使用してMVVMアーキテクチャで実装をしました。
View処理とModel処理を分けることでテストのし易さや可読性を意識してコードを書きました。



