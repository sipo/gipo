package jp.sipo.gipo.core.handler;
/**
 * リストなどへの追加方法を指定する関数
 * 
 * @auther sipo
 */
typedef AddBehavior<T> = Array<T> -> T -> Void;
