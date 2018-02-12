//2017.4.16 制作開始
//4.17 禁止パークの判定、ウェーブ数の判定はできた(・ω・)
//4.18 禁止武器が難しいのでカニ歩き部分を先に
//4.19 多分完成
//4.30 RGplayに統合してみたり
//
//6.13 イベントに向けてワープを入れてみる
//

//***STATE***
//strafe 蟹歩き
//シャガミ時のみ横移動のみ入力受けつけ
//移動速度はダッシュの速度くらいにあげる

//※継承するクラスはMutatorでない方が良い
//  Mutatorにできたとしても実質GameInfoをいじっているので
//  競合する可能性がある上、何をいじっているのかわかりづらい

class StrafeOnly extends KFGameInfo_Survival;

var bool bOpend;
var StrafeWarp SW;

//ゲーム開始時に一度だけ呼ばれるっぽい～
event PostBeginPlay() {
	super.PostBeginPlay();
	//初期化
		SW = Spawn(class'StrafeWarp');
		SW.Init();
		bOpend = true;
		SetTimer(0.5, true, nameof(pvpmain));
	//
}

//メインループ
function pvpmain(){
	//ゲームはじまっとらんがな
		if (!(MyKFGRI.WaveNum>=1)) return;
	//閉店直後
		if ( (!MyKFGRI.bTraderIsOpen) && (bOpend==true) ) {
			WarpAllPC();
		}
	//だいにゅー
		bOpend = MyKFGRI.bTraderIsOpen;
	//
}

//ランダム地点へPCを飛ばす
function WarpAllPC() {
	local KFPlayerController KFPC;
	local bool bInit;
	bInit = false;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
		//最後のワープ先を使いまわさない
			if (bInit==false) {
				SW.ResetStartPoint(KFPC);
				bInit = true;
			}
		//
		SW.WarpPC(KFPC);
	}
}

defaultproperties
{
	PlayerControllerClass=class'StrafeOnly_KFPC'
	DefaultPawnClass=class'StrafeOnly_KFPH'
}


//以下駄文


	/**
	//ゲーム開始時に一度だけ呼ばれる？
	function PostBeginPlay() {
		//1.0秒ごとに特定の関数を呼ぶ bool値は繰り返し呼ぶかどうか
		SetTimer(1.0, true, nameof(SetPlayersKaniWalk));
	}
	//プレイヤーをカニ歩きにv@_@v
	function SetPlayersKaniWalk() {
		local KFPlayerController KFPC;
		local Pawn Player;
	//			MoveForwardSpeed
		//トレーダータイム中と終了後何秒かに速度を更新
		if (false) {
			return;
		}
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
			if (KFPC.Pawn != None) {
				Player = KFPC.Pawn;
				if (KFPC.InputClass==class'KFPlayerInput2') {
	//				Player.Health = 21;
				}else{
	//				Player.Health = 35;
					KFPC.InputClass = class'KFPlayerInput2';
				}
			}
		}
	}
	*/