#再現ログのフォーマット

基本的にはhaxe.Serializerの直列化文字列を使用する

データはいつ途切れるかわからないため、データを細かい単位に分けて保存する。１つのデータをParcelと呼ぶ。Parcelのフォーマットは以下Parcelクラスの直列化文字列を「;_」で区切る。
ただし、直列化文字列内に「;」が存在する場合（今のところ存在しないと思われるが）、「;;」に変換する。

また、最初のデータにはバージョンを含んだヘッダ情報を持たせる。