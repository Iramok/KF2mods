//2017.4.30 制作開始
//2017.5.2 gan氏kani氏とテスト
//2017.5.27 とうとう公開サーバーに…
//2017.10.23 なぜかMaxmonstersの仕様変更でここも更新……

class PvPMode extends KFGameInfo_Survival;

//const
const	TRADERTIME = 75; //トレーダーの時間
const	WAVE1WAITTIME = 60; //ゲーム開始時の待機時間
const	DOSHPERWAVE = 300; //10waveでの資金はこの10倍 これにwave長による比率がかかる
const	CUSTOMGAMELENGTH = -1; //カスタムゲーム長 0以下ならデフォルト
const	ZEDTIMELENGTH = 3.0f; //ZEDタイムの長さ
const	MAXARMOR = 25; //アーマーの最大値

const	CustomTimerLength_MyHUD  = 27.f; //敵アイコン非表示の時間
const	CustomTimerLength_TWIHUD = 3.f; //敵アイコン表示の時間

var const float	TimerLength_MyHUD; //敵アイコン非表示の時間
var const float	TimerLength_TWIHUD; //敵アイコン表示の時間

//pvpmain用
var bool bOpend;
var int livingnum_old;

//Wave1NoDamage用
var int CallCount;
var bool bForceNoDamage;

//ゲーム開始時に一度だけ呼ばれるっぽい～
event PostBeginPlay() {
	super.PostBeginPlay();
	//しょきか
		livingnum_old = 0;
	//たいまー
		SetTimer(0.016, true, nameof(pvpmain));
	//トレーダーの時間
		TimeBetweenWaves = TRADERTIME;
	//ゲーム長
		if (CUSTOMGAMELENGTH>0) MyKFGRI.WaveMax = CUSTOMGAMELENGTH;
	//
}

//アーマーの最大値を変更
function SetArmorCustomVal() {
	local KFPawn_Human Player;
	local KFPlayerController KFPC;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
		Player = KFPawn_Human(KFPC.Pawn);
		if (Player!=None) {
			Player.Armor = MAXARMOR;
			Player.MaxArmor = MAXARMOR;
		}
	}
}

/** Starts a new Wave */
function StartWave() {
	//しょきか
		super.StartWave();
	//zedがわかないようにする
		ZeroMob();
	//ウェーブ1開始時は無敵にし、それ以外は無敵を切る
		if (MyKFGRI.WaveNum==1) {
			CallCount = 0;
			bForceNoDamage = true;
			SetTimer(1.0,false,nameof(Wave1NoDamage));
		}
	//
}

//Wave1開始時の無敵
function Wave1NoDamage() {
	if (++CallCount==WAVE1WAITTIME) {
		SendMessageAllPlayers("PvP battle start !!!!!!");
		SetArmorCustomVal();
		bForceNoDamage = false;
	}else{
		SendMessageAllPlayers("PvP battle start in "$(WAVE1WAITTIME-CallCount)$"sec.");
		SetTimer(1.0,false,nameof(Wave1NoDamage));
	}
}

//ウェーブ毎に金を配る
function GiveMoneyAllPlayers () {
	local KFPlayerController KFPC;
	local int DoshToGive;
	DoshToGive = DOSHPERWAVE*MyKFGRI.WaveNum*11/MyKFGRI.WaveMax;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
		KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).AddDosh(-114514, true);
		KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).AddDosh(DoshToGive, true);
	}
}

//全員にメッセージを送る
function SendMessageAllPlayers(string Str) {
	local KFPlayerController KFPC;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
		SendMessagePlayer(KFPC,Str);
	}
}

//個人にメッセージを送る
function SendMessagePlayer(KFPlayerController KFPC,string Str) {
	KFPC.TeamMessage(KFPC.PlayerReplicationInfo,Str,'Event');
}

//無敵状態
function GivePlayerMaxHealth() {
	local KFPawn_Human Player;
	local KFPlayerController KFPC;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
		Player = KFPawn_Human(KFPC.Pawn);
		if (Player!=None) {
			Player.Health = Player.HealthMax;
			Player.Armor = Player.MaxArmor;
		}
	}
}

//メインループ
function pvpmain(){
	local int livingnum;
	//ゲームはじまっとらんがな
		if (!(MyKFGRI.WaveNum>=1)) return;
	//しょきか
		livingnum = GetLivingPlayerCount();
	//処理
		if (bForceNoDamage) GivePlayerMaxHealth();
		if (MyKFGRI.bTraderIsOpen) {
			//開店と同時に金を配る
			if (bOpend==false) GiveMoneyAllPlayers();
			GivePlayerMaxHealth();
		}else{
			//閉店直後 or 誰かが死ぬ
			if ( (bOpend==true) || (livingnum!=livingnum_old) ) {
				//zedタイム
					DramaticEvent(1.0,ZEDTIMELENGTH);
				//生き残ってるプレイヤーの数を表示
					SpawnManager.WaveTotalAI = livingnum;
					MyKFGRI.AIRemaining = livingnum;
					MyKFGRI.WaveTotalAICount = livingnum;
				//アーマーの処理
					SetArmorCustomVal();
				//
			}
		}
	//だいにゅー
		bOpend = MyKFGRI.bTraderIsOpen;
		livingnum_old = livingnum;
	//
}

//zedなんてなかった
function ZeroMob() {
	local int zeronum;
	zeronum = (MyKFGRI.WaveNum<MyKFGRI.WaveMax) ? 0 : 1;
//	zeronum = 0;
	
	//older
		/*
			SpawnManager.MaxMonstersSolo[int(GameDifficulty)] = zeronum;
			SpawnManager.MaxMonsters = zeronum;
		*/
	//newer v1056-
		SetMaxMonstersV1056(zeronum);
	//
}


//MMの設定 - KFmutator_MaxplayersV2よりコピペ v1056より難易度・人数毎にMMができたようだ
function SetMaxMonstersV1056(byte mm_v1056) {
	local int i,j;
	for (i = 0; i < SpawnManager.PerDifficultyMaxMonsters.length; i++) {
		for (j = 0; j < SpawnManager.PerDifficultyMaxMonsters[i].MaxMonsters.length ; j++) {
			SpawnManager.PerDifficultyMaxMonsters[i].MaxMonsters[j] = mm_v1056;
		}
	}
}

//死亡した時によばれる
function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
	local bool bRet;
	if (Killed==None) return false;
	bRet = false;
	if(KFPawn_Human(Killed)!=None) {
		if (Killed.Controller.PlayerReplicationInfo.bIsSpectator==false) {
//			RestartPlayer(Killed.Controller);
			//開始1分とトレーダー中は殺さない
			if ( (bForceNoDamage) || (MyKFGRI.bTraderIsOpen) ) {
				bRet = true;
			}else {
				if( GetLivingPlayerCount() <= 1 ) {
					if ( GetLivingPlayerCount() == 1 ) {
						SendMessageAllPlayers("Last stand player: "$Killer.PlayerReplicationInfo.PlayerName);
					}
					ScoreKill(Killer,Killed.Controller);
					if (MyKFGRI.WaveNum==MyKFGRI.WaveMax) {
						SendMessageAllPlayers("PvP Battle is end, GG!: ");
						//SendWinnerMessage();
					}else{
						//KFPlayerController(Killer).SpawnReconnectedPlayer();
					}
					WaveEnded(WEC_WaveWon);
					bRet=true;
				}
			}
		}
	}
//	if (bRet) 
	return bRet;
}

/*
function RespawnAllPlayer(KFPlayerController Killed) {
	local KFPlayerController KFPC;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
		if (KFPC!=Killed) 
		KFPC.SpawnReconnectedPlayer();
	}
}
*/

DefaultProperties
{
	HUDType=class'PvPmode_KFHUD'
	TimerLength_MyHUD = CustomTimerLength_MyHUD
	TimerLength_TWIHUD = CustomTimerLength_TWIHUD
}

//プレイヤーのアイコン非表示
/*
function ModifyPlayer(Pawn Other) {
	//スーパーの処理
		super.ModifyPlayer(Other);
	//HUDクラスの置き換え
		Other.Controller.ClientSetHUD();
	//
}
*/

/*
//勝利者を通知
function SendWinnerMessage() {
	local KFPlayerController KFPC;
	local int kill,Topkill;
	local string pName,TopkillerName;
	Topkill = -1;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
		pName = KFPC.PlayerReplicationInfo.PlayerName;
		kill = KFPC.PlayerReplicationInfo.Kills;
		if ( Topkill < kill ) {
			TopkillerName = pName;
		}else if ( Topkill == kill ) {
			TopkillerName $= ","$pName;
		}
	}
	SendMessageAllPlayers("Top Killer: "$TopkillerName);
}
*/

//ナニモシナイヨ…と思ったけど切るか
/*
function DiscardInventory( Pawn Other, optional controller Killer ) {
}
*/


/**
function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType) {
		super.Killed(Killer, KilledPlayer, KilledPawn, damageType);
	if (KilledPlayer!=None) {
		KilledPlayer.PlayerReplicationInfo.bIsSpectator = false;
		KilledPlayer.PlayerReplicationInfo.bIsSpectator = false;
		KilledPlayer.PlayerReplicationInfo.bOutOfLives = false;
		RestartPlayer(KilledPlayer);
	}else{
		super.Killed(Killer, KilledPlayer, KilledPawn, damageType);
	}
}

**/

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