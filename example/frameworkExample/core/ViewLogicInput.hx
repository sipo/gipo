package frameworkExample.core;
/**
 * View→Logicのユーザー入力などの通知設定
 * 
 * @auther sipo
 */
import jp.sipo.ds.Point;
enum ViewLogicInput
{
	Common(value:ViewLogicInputCommon);
	Scene(value:EnumValue);
}
/**
 * 全体で共通のViewの入力種類
 */
enum ViewLogicInputCommon
{
	/** マウスの共通演出用。ボタンの入力はこれとは別に個別に飛ぶ */
	MouseDown(point:Point<Int>);
	MouseDrag(point:Point<Int>);
	MouseUp(point:Point<Int>);
	/**
	 * 再現時にマウスの位置を表示するためのガイド。
	 * MouseOver時に1秒に１回ほど更新される。
	 * PCでのみ意味があり、スマホ端末では使用しないはず。
	 * 最もデータが重くなるので、場合によってはもっと間引く
	 */
	MouseGuide(point:Point<Int>);
}
