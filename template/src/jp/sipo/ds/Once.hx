package jp.sipo.ds;
/**
 * １度使用した後に２重処理をさせないためのデータ型
 * 
 * @auther sipo
 */
enum Once<T>
{
	Before;
	Some(value:T);
	After;
}
