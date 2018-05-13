//2017.4.16 制作開始
//4.17 禁止パークの判定、ウェーブ数の判定はできた(・ω・)
//4.18 禁止武器が難しいのでカニ歩き部分を先に → キャストーッ！禁止武器もカニ歩きもできた！
//4.19 configェ…とりあえず形にはなったぞい。
//4.20 武器に関しては即殺でなく投げるという形に変更。DOSHによる分岐,メッセージを追加。
//4.22 なんやら注文が殺到している・・・
//4.25 初期武器に四苦八苦、ようやく形になるか…？
//4.27 ラグの原因なんじゃろな('A`) このmodのせいなのかも怪しいが、軽減処理はしておこう
//4.28 相変わらず鯖のラグはとれず とりあえずアーマーとグレの補充機能をつけてみる
//5.16 制作開始からはや一ヶ月…今日も今日とて更新です traderdashつけてみた
//6.03 トレーダー中のパーク変更し放題は無理でしたgg
//7.20 namさんの要望で開始時のdosh変更を追加してみる
//9.15 かなり久々の更新 namさんの要望だったfakeplayersを追加してみる
//9.16 WaveSizeFakesに名前を変更
//10.23 公式によるmaxmonstersの変更の煽りを受ける
//10.25 2bossesを3bossesにしてみる
//10.29 proの要望でその場でトレーダー開けるようになった
//11.03 chatcommand実装！やったぜ！
//11.10 コンソールメッセージがサーバーでは動かなかった どうせ日本語表示されないしいいか :o
//2018.2.11	2Bossの整形、復活はならず　予備弾倉が2マガジンを切ったら自動購入、エヴィス君は特別な処理
//02.12	SetTimer(1.0, true, nameof(HackBroadcastHandler));を消してた……／(^o^)＼ﾅﾝﾃｺｯﾀｲ

class RestrictPW extends KFMutator
	config(RestrictPW);

//<<---config用変数の定義--->>//

	/* Init Config */
		//configファイル存在の確認
		var config bool bIWontInitThisConfig;
	/* Perk Settings */
		var config string MinPerkLevel_Berserker;
		var config string MinPerkLevel_Commando;
		var config string MinPerkLevel_Support;
		var config string MinPerkLevel_FieldMedic;
		var config string MinPerkLevel_Demolitionist;
		var config string MinPerkLevel_Firebug;
		var config string MinPerkLevel_Gunslinger;
		var config string MinPerkLevel_Sharpshooter;
		var config string MinPerkLevel_Survivalist;
		var config string MinPerkLevel_Swat;
		var config string DisablePerkSkills;
	/* Weapon Settings */
		var config string StartingWeapons_Berserker;
		var config string StartingWeapons_Commando;
		var config string StartingWeapons_Support;
		var config string StartingWeapons_FieldMedic;
		var config string StartingWeapons_Demolitionist;
		var config string StartingWeapons_Firebug;
		var config string StartingWeapons_Gunslinger;
		var config string StartingWeapons_Sharpshooter;
		var config string StartingWeapons_Survivalist;
		var config string StartingWeapons_Swat;
		var config string DisableWeapons;
		var config string DisableWeapons_Boss;
		var config bool bAutoAmmoBuying;
	/* Player Settings */
		var config bool bStartingWeapon_AmmoFull;
		var config bool bPlayer_SpawnWithFullArmor;
		var config bool bPlayer_SpawnWithFullGrenade;
		var config bool bEnableTraderDash;
		var config bool bDisableTeamCollisionWithTraderDash;
		var config int StartingDosh;
	/* Wave Settings */
		var config byte MaxPlayer_TotalZedsCount;
		var config byte MaxPlayer_ZedHealth;
		var config string MaxMonsters;
		var config string WaveSizeFakes;
		var config string SpawnTwoBossesName;
		var config bool bFixZedHealth_6P;
	/* ChatCommand Settings */
		var config bool bDisableChatCommand_OpenTrader;
		var config bool bDontShowOpentraderCommandInChat;
	/* */

//<<---global変数の定義--->>//
	//WeaponConfigクラス
		var WeaponConfig WeapCfg;
	//ウェーブタイプ判別のenum型の定義
		enum eWaveType{
			WaveType_Normal,
			WaveType_Boss
		};
	//string -> byte 変換用
		var array<byte> _MinPerkLevel_Berserker;
		var array<byte> _MinPerkLevel_Commando;
		var array<byte> _MinPerkLevel_Support;
		var array<byte> _MinPerkLevel_FieldMedic;
		var array<byte> _MinPerkLevel_Demolitionist;
		var array<byte> _MinPerkLevel_Firebug;
		var array<byte> _MinPerkLevel_Gunslinger;
		var array<byte> _MinPerkLevel_Sharpshooter;
		var array<byte> _MinPerkLevel_Survivalist;
		var array<byte> _MinPerkLevel_Swat;
		var array<int> _MaxMonsters;
		var array<int> _WaveSizeFakes;
	//DisablePerkSkills用
		var array<int> aDisablePerkSkills;
		var bool bUseDisablePerkSkills;
	//SendRestrictMessageString用
		var KFPlayerController RMPC;
		var string RMStr;
	//IsWeaponRestricted用
		var array<string> aDisableWeapons,aDisableWeapons_Boss;
	//CheckTraderState用
		var bool bOpened;
	//MaxPlayer_TotalZedsCount用
		var bool bUseMaxPlayer_TotalZedsCount;
	//MaxMonsters用
		var bool bUseMaxMonsters;
	//WaveSizeFakes用
		var bool bUseWaveSizeFakes;
	//FillArmorOrGrenades アーマー・グレネードの予約補充用
		var array<KFPawn_Human> PlayerToFillArmGre;
	//StartingDosh予約補充用
		var array<KFPlayerReplicationInfo> PlayerToChangeStartingDosh;
	//RestrictMessage用
		struct RestrictMessageInfo {
			var KFPlayerController KFPC;
			var string Msg;
		};
		var array<RestrictMessageInfo> RMI;
	//CheckSpawnTwoBossSquad用
		var bool bSpawnTwoBossSquad;
	//!dappunが有効かどうか
		var string EnableDappun;
	//
	
//<<---定数の定義--->>//

	//制限パーク使用時のライフ減少値（トレーダータイム）
		const VALUEFORDEAD = 10;
	//ModifyTraderTimePlayerState用
		const TraderGroundSpeed = 364364.0f;
	//GetPerkClassFromPerkCode用
		const PerkCode_Berserker = 0;
		const PerkCode_Commando = 1;
		const PerkCode_Support = 2;
		const PerkCode_FieldMedic = 3;
		const PerkCode_Demolitionist = 4;
		const PerkCode_Firebug = 5;
		const PerkCode_Gunslinger = 6;
		const PerkCode_Sharpshooter = 7;
		const PerkCode_Survivalist = 8;
		const PerkCode_Swat = 9;
	//
	
//<<---メッセージ関数--->>//

	function SetRestrictMessagePC(KFPlayerController KFPC) {
		RMPC = KFPC;
	}
	
	function SetRestrictMessageString(string s) {
		RMStr = s;
	}
	
	//セットされたメッセージを一人に送る
	function SendRestrictMessageString() {
		local string PlayerName;
		PlayerName = RMPC.PlayerReplicationInfo.PlayerName;
		ReserveRestrictMessage(RMPC,PlayerName$RMStr);
	}
	
	//メッセージを一人に送る
	function SendRestrictMessageStringPC(KFPlayerController KFPC,string s) {
		SetRestrictMessagePC(KFPC);
		SetRestrictMessageString(s);
		SendRestrictMessageString();
	}
	
	//メッセージを全員に送る
	function SendRestrictMessageStringAll(string s) {
		local KFPlayerController KFPC;
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
			ReserveRestrictMessage(KFPC,"RPWmod"$s);
		}
	}
	
	//メッセージの予約
	function ReserveRestrictMessage(KFPlayerController KFPC,string s) {
		local RestrictMessageInfo addbuf;
		addbuf.KFPC = KFPC;
		addbuf.Msg = s;
		RMI.AddItem(addbuf);
		SetTimer(0.5, false, nameof(SendReserveRestrictMessageTimer));
	}
	
	//タイマーによるメッセージの発行
	function SendReserveRestrictMessageTimer() {
		local int i;
		//リスト内のメッセージを順次送信
			for (i=0;i<RMI.length;++i) {
				RMI[i].KFPC.TeamMessage(RMI[i].KFPC.PlayerReplicationInfo,RMI[i].Msg,'Event');
			}
		//処理が終わったメッセージを削除
			RMI.Remove(0,RMI.length);
		//
	}
	
	//コンソールへメッセージを送信要請
	function SendRestrictMessageStringConsoleAll(string s) {
//		SendConsoleMessage("RPWmod"$s);
		SendConsoleMessage(s);
	}
	
	//コンソールへ空のメッセージを送信要請
	function SendEmptyMessageStringConsoleAll() {
		SendConsoleMessage("");
	}
	
	//コンソールへメッセージを送信・・・したかったがまた今度
	reliable client function SendConsoleMessage(string s) {
		SendRestrictMessageStringAll(s);
/*
		local KFGameViewportClient GVC;
		local KFPlayerController KFPC;
		local RPWPlayerController RPWPC;
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
			GVC = class'GameEngine'.static.GetEngine().GameViewport;
			LocalPlayer(KFPC.Player).ViewportClient.ViewportConsole.OutputText(s);
		}
*/
	}


//<<---初期化関数--->>//

	function InitConfigVar() {
		/* Init Config */
			bIWontInitThisConfig = true;
		/* Perk Settings */
			MinPerkLevel_Berserker = "0,0";
			MinPerkLevel_Commando = "0,0";
			MinPerkLevel_Support = "0,0";
			MinPerkLevel_FieldMedic = "0,0";
			MinPerkLevel_Demolitionist = "0,0";
			MinPerkLevel_Firebug = "0,0";
			MinPerkLevel_Gunslinger = "0,0";
			MinPerkLevel_Sharpshooter = "0,0";
			MinPerkLevel_Survivalist = "0,0";
			MinPerkLevel_Swat = "0,0";
			DisablePerkSkills = "";
		/* Weapon Settings */
			StartingWeapons_Berserker = "";
			StartingWeapons_Commando = "";
			StartingWeapons_Support = "";
			StartingWeapons_FieldMedic = "";
			StartingWeapons_Demolitionist = "";
			StartingWeapons_Firebug = "";
			StartingWeapons_Gunslinger = "";
			StartingWeapons_Sharpshooter = "";
			StartingWeapons_Survivalist = "";
			StartingWeapons_Swat = "";
			DisableWeapons = "";
			DisableWeapons_Boss = "";
			bAutoAmmoBuying = false;
		/* Player Settings */
			bStartingWeapon_AmmoFull = false;
			bPlayer_SpawnWithFullArmor = false;
			bPlayer_SpawnWithFullGrenade = false;
			bEnableTraderDash = false;
			bDisableTeamCollisionWithTraderDash = false;
			StartingDosh = 0;
		/* Wave Settings */
			MaxPlayer_TotalZedsCount = 0;
			MaxPlayer_ZedHealth = 0;
			MaxMonsters = "";
			WaveSizeFakes = "";
			SpawnTwoBossesName = "";
			bFixZedHealth_6P = false;
		/* ChatCommand Settings */
			bDisableChatCommand_OpenTrader = false;
			bDontShowOpentraderCommandInChat = false;
		/* */
	}
	
	//config変数から内部で保持しておく変数への変換
	function InitVarFromConfigVar() {
		SetArrayMPL(_MinPerkLevel_Berserker		,MinPerkLevel_Berserker		);
		SetArrayMPL(_MinPerkLevel_Commando		,MinPerkLevel_Commando		);
		SetArrayMPL(_MinPerkLevel_Support		,MinPerkLevel_Support		);
		SetArrayMPL(_MinPerkLevel_FieldMedic	,MinPerkLevel_FieldMedic	);
		SetArrayMPL(_MinPerkLevel_Demolitionist	,MinPerkLevel_Demolitionist	);
		SetArrayMPL(_MinPerkLevel_Firebug		,MinPerkLevel_Firebug		);
		SetArrayMPL(_MinPerkLevel_Gunslinger	,MinPerkLevel_Gunslinger	);
		SetArrayMPL(_MinPerkLevel_Sharpshooter	,MinPerkLevel_Sharpshooter	);
		SetArrayMPL(_MinPerkLevel_Survivalist	,MinPerkLevel_Survivalist)	;
		SetArrayMPL(_MinPerkLevel_Swat			,MinPerkLevel_Swat			);
		InitDisablePerkSkills(DisablePerkSkills,aDisablePerkSkills);
		InitDisableWeaponClass(DisableWeapons,aDisableWeapons);
		InitDisableWeaponClass(DisableWeapons_Boss,aDisableWeapons_Boss);
		SetArrayMM(_MaxMonsters,MaxMonsters);
		SetArrayMM(_WaveSizeFakes,WaveSizeFakes);
	}
	
	//InitVarFromConfigVarのサブ関数0
	function InitDisablePerkSkills(string DPS,out array<int> aDPS) {
		local string buf;
		local array<String> splitbuf;
		if ( DPS == "" ) return;
		bUseDisablePerkSkills = true;
		ParseStringIntoArray(DPS,splitbuf,",",true);
		foreach splitbuf(buf) {
			aDPS.AddItem(int(buf));
		}
	}
	
	//InitVarFromConfigVarのサブ関数1
	function SetArrayMPL(out array<byte> _MPL,String MPL) {
		local array<String> splitbuf;
		ParseStringIntoArray(MPL,splitbuf,",",true);
		_MPL[WaveType_Normal] = byte(splitbuf[0]);
		_MPL[WaveType_Boss] = byte(splitbuf[1]);
	};
	
	//InitVarFromConfigVarのサブ関数2
	function SetArrayMM(out array<int> _MM,String MM) {
		local string buf;
		local array<String> splitbuf;
		ParseStringIntoArray(MM,splitbuf,",",true);
		foreach splitbuf(buf) {
			_MM.AddItem(int(buf));
		}
	}
	
	//IsWeaponRestricted用の初期化関数
	function InitDisableWeaponClass(string StrDW,out array<string> aStrDW) {
		local string buf;
		local array<String> splitbuf;
		local class<Weapon> cWbuf;
		ParseStringIntoArray(StrDW,splitbuf,",",true);
		foreach splitbuf(buf) {
			cWbuf = GetWeapClassFromString("KFGameContent.KFWeap_" $buf);
			if (cWbuf!=None) aStrDW.AddItem(cWbuf.default.ItemName);
		}
	}

//<<---タイマー関数--->>//

	
	event Tick( float DeltaTime ) {
		super.Tick(DeltaTime);
		if (WeapCfg!=None) {
			if (WeapCfg.bUseWeaponConfig) WeapCfg.Tick();
		}
	}

//<<---コールバック関数(PostBeginPlay)--->>//

	//ゲーム開始時に一度だけ呼ばれるっぽい～
	function PostBeginPlay() {
		Super.PostBeginPlay();
		//WeaponConfig
//			WeapCfg = Spawn(class'WeaponConfig');
			WeapCfg = New(Self) class'WeaponConfig';
			WeapCfg.PostBeginPlay();
//			SetTimer(5.0f,true,nameof(test));
		//.iniの初期設定
			if (!bIWontInitThisConfig) InitConfigVar();
			SaveConfig();
			InitVarFromConfigVar();
		//CheckTraderState用
			bOpened = true;
		//MaxPlayer_TotalZedsCount用
			bUseMaxPlayer_TotalZedsCount = (MaxPlayer_TotalZedsCount>0);
		//MaxMonsters用
			bUseMaxMonsters = (MaxMonsters!="");
		//WaveSizeFakes用
			bUseWaveSizeFakes = (WaveSizeFakes!="");
		//1.0秒ごとに特定の関数を呼ぶ bool値は繰り返し呼ぶかどうか
			SetTimer(1.0, true, nameof(JudgePlayers));
			SetTimer(0.25, true, nameof(CheckTraderState));
			//SetTimer(1.0, true, nameof(CheckSpawnTwoBossSquad));
			SetTimer(1.0, true, nameof(HackBroadcastHandler));
			if (bAutoAmmoBuying) SetTimer(1.0, true, nameof(CheckAutoAmmoBuying));
		//!dappunは通常無効化
			 EnableDappun = "False";
		//
	}
	
//<<---コールバック関数(ModifyAIEnemy)--->>//
	
	/**
	
	//Controller.uc内 var Pawn Enemy
	function ModifyAIEnemy( AIController AI, Pawn Enemy ) {
		//スーパーの処理
			super.ModifyAIEnemy(AI,Enemy);
		//
		local bool bDisableSwitchEnemysTarget;
		bDisableSwitchEnemysTarget = false;
		bDisableSwitchEnemysTarget = true;
		
		if (bDisableSwitchEnemysTarget) {
			super.ModifyAIEnemy( AI, (AI.Enemy==None) ? Enemy : AI.Enemy );
		}
	}
	
	**/
	
//<<---コールバック関数(ModifyAI)--->>//
	
	function ModifyAI(Pawn AIPawn) {
		//スーパーの処理
			super.ModifyAI( AIPawn );
		//一応モンスターか判別
			if (KFPawn_Monster(AIPawn)==None) return;
		//HPを変更
			if (MaxPlayer_ZedHealth>0) {
				SetMonsterDefaultsMut(KFPawn_Monster(AIPawn),
					min( MyKFGI.GetLivingPlayerCount(), MaxPlayer_ZedHealth ));
			}
		//固定HPの方が優先度が高い
			if (bFixZedHealth_6P) {
				//ボスに関しては無効
				if ( (KFPawn_ZedHans(AIPawn)!=None) || (KFPawn_ZedPatriarch(AIPawn)!=None) ) {
					return;
				}
				SetMonsterDefaultsMut(KFPawn_Monster(AIPawn),6);
			}
		//
	}
	
	//In KFGameInfo.uc function SetMonsterDefaults
	function SetMonsterDefaultsMut(KFPawn_Monster P,byte LivingPlayer) {
		local float HealthMod,HeadHealthMod;
		local int LivingPlayerCount;
		//しょきか
			LivingPlayerCount = LivingPlayer;
			HealthMod = 1.0;
			HeadHealthMod = 1.0;
		// Scale health and damage by game conductor values for versus zeds
			if( P.bVersusZed ) {
				MyKFGI.DifficultyInfo.GetVersusHealthModifier(P, LivingPlayerCount, HealthMod, HeadHealthMod);
				HealthMod *= MyKFGI.GameConductor.CurrentVersusZedHealthMod;
				HeadHealthMod *= MyKFGI.GameConductor.CurrentVersusZedHealthMod;
			}else{
				MyKFGI.DifficultyInfo.GetAIHealthModifier(P, MyKFGI.GameDifficulty, LivingPlayerCount, HealthMod, HeadHealthMod);
			}
		// Scale health by difficulty
			P.Health = P.default.Health * HealthMod;
			if( P.default.HealthMax == 0 ){
			   	P.HealthMax = P.default.Health * HealthMod;
			}else{
			   	P.HealthMax = P.default.HealthMax * HealthMod;
			}
			P.ApplySpecialZoneHealthMod(HeadHealthMod);
			P.GameResistancePct = MyKFGI.DifficultyInfo.GetDamageResistanceModifier(LivingPlayerCount);
		//
	}


//<<---コールバック関数(ModifyPlayer)--->>//

	//プレイヤーが生成されたときに一度だけ呼ばれる
	function ModifyPlayer(Pawn Other) {
		local KFPawn Player;
		local KFPlayerController KFPC;
		local KFPlayerReplicationInfo KFPRI;
		local class<KFPerk> cKFP;
		local class<Weapon> cRetW;
		local Inventory Inv;
		local bool bFound;
		//スーパーの処理
			super.ModifyPlayer(Other);
		//代入
			Player = KFPawn_Human(Other);
			KFPC = KFPlayerController(Player.Controller);
			cKFP = KFPC.GetPerk().GetPerkClass();
			KFPRI = KFPlayerReplicationInfo(Player.PlayerReplicationInfo);
		//SpawnHumanPawnに関しては無視
			if (IsBotPlayer(KFPC)) return;
		//初期装備の変更先の情報を取得 変更される場合のみ処理
			cRetW = GetStartingWeapClassFromPerk(cKFP);
			if (cRetW!=None) {
				//プレイヤーから初期装備をはく奪 サバイバリストを考慮して全パーク武器で判定
					bFound = False;
					for(Inv=Player.InvManager.InventoryChain;Inv!=None;Inv=Inv.Inventory) {
						switch(Inv.ItemName) {
							case class'KFGameContent.KFWeap_Blunt_Crovel'.default.ItemName:
							case class'KFGameContent.KFWeap_AssaultRifle_AR15'.default.ItemName:
							case class'KFGameContent.KFWeap_Shotgun_MB500'.default.ItemName:
							case class'KFGameContent.KFWeap_Pistol_Medic'.default.ItemName:
							case class'KFGameContent.KFWeap_GrenadeLauncher_HX25'.default.ItemName:
							case class'KFGameContent.KFWeap_Flame_CaulkBurn'.default.ItemName:
							case class'KFGameContent.KFWeap_Revolver_DualRem1858'.default.ItemName:
							case class'KFGameContent.KFWeap_Rifle_Winchester1894'.default.ItemName:
							case class'KFGameContent.KFWeap_SMG_MP7'.default.ItemName:
								Player.InvManager.RemoveFromInventory(Inv);
								bFound = True;
								break;
						}
						if (bFound) break;
					}
				//武器のとーにゅー
					Player.Weapon = Weapon(Player.CreateInventory(cRetW,Player.Weapon!=None));
				//武器の装備
					Player.InvManager.ServerSetCurrentWeapon(Player.Weapon);
				//弾薬の補充 
					if (bStartingWeapon_AmmoFull) FillWeaponAmmo(KFWeapon(Player.Weapon));
				//アーマー・グレネードの補充予約 対処療法的なのでバグる可能性もあるが… そうなった場合はKFPerk側のInitを阻止するしかなくなる
					PlayerToFillArmGre.AddItem(KFPawn_Human(Other));
					SetTimer(0.25, false, nameof(FillArmorOrGrenades)); //呼び出しは1回なのでfalse
				//
			}
		//開始時のDoshの設定
			if (StartingDosh>0) {
				PlayerToChangeStartingDosh.AddItem(KFPRI);
				SetTimer(0.25, false, nameof(SetStartingDosh)); //呼び出しは1回なのでfalse
			}
		//処理終了
	}
	
	//StartingDoshの予約変更
	function SetStartingDosh() {
		local int i;
		//変更対象者のリストを漁る
			for (i=0;i<PlayerToChangeStartingDosh.length;++i) {
				if (PlayerToChangeStartingDosh[i]!=None) {
					PlayerToChangeStartingDosh[i].Score = StartingDosh;
				}
			}
		//予約リストの初期化
			PlayerToChangeStartingDosh.Remove(0,PlayerToChangeStartingDosh.length);
		//
	}
	
	//だんやくほじゅー
	function FillWeaponAmmo(KFWeapon W) {
		if ( W.AddAmmo(114514) != 0 ) FillWeaponAmmo(W);
		if ( W.AddSecondaryAmmo(114514) != 0 ) FillWeaponAmmo(W);
	}
	
	//グレとアーマーの（予約）ほじゅー
	function FillArmorOrGrenades() {
		local KFPawn_Human Player;
		local int i;
		//補充対象者のリストを漁る
			for (i=0;i<PlayerToFillArmGre.length;++i) {
				Player = PlayerToFillArmGre[i];
				if (Player==None) continue;
				//アーマーの補充
					if (bPlayer_SpawnWithFullArmor) Player.GiveMaxArmor();
				//グレネードの補充
					if (bPlayer_SpawnWithFullGrenade) FillGrenades(KFInventoryManager(Player.InvManager));
				//
			}
		//処理が終わったプレイヤーを削除
			PlayerToFillArmGre.Remove(0,PlayerToFillArmGre.length);
		//
	}
	
	//グレ補充用
	function FillGrenades(KFInventoryManager KFIM) {
		if (KFIM.AddGrenades(1)) FillGrenades(KFIM);
	}
	
	//Are you SpawnHumanPawn?
	function bool IsBotPlayer(KFPlayerController KFPC){
		return (KFPC.PlayerReplicationInfo.PlayerName=="Braindead Human");
	}

//<<---開始武器の乗っ取り--->>//
	
	//現在のパークからクラスの取得。
	function class<Weapon> GetStartingWeapClassFromPerk(class<KFPerk> Perk) {
		local string SendStr;
		local array<String> SplitBuf;
		SendStr = "";
		switch(Perk) {
			case class'KFPerk_Berserker':
				SendStr = StartingWeapons_Berserker;
				break;
			case class'KFPerk_Commando':
				SendStr = StartingWeapons_Commando;
				break;
			case class'KFPerk_Support':
				SendStr = StartingWeapons_Support;
				break;
			case class'KFPerk_FieldMedic':
				SendStr = StartingWeapons_FieldMedic;
				break;
			case class'KFPerk_Demolitionist':
				SendStr = StartingWeapons_Demolitionist;
				break;
			case class'KFPerk_Firebug':
				SendStr = StartingWeapons_Firebug;
				break;
			case class'KFPerk_Gunslinger':
				SendStr = StartingWeapons_Gunslinger;
				break;
			case class'KFPerk_Sharpshooter':
				SendStr = StartingWeapons_Sharpshooter;
				break;
			case class'KFPerk_Survivalist':
				SendStr = StartingWeapons_Survivalist;
				break;
			case class'KFPerk_Swat':
				SendStr = StartingWeapons_Swat;
				break;
		}
		if (SendStr=="") return None;
		ParseStringIntoArray(SendStr,SplitBuf,",",true);
		SendStr = "KFGameContent.KFWeap_" $ SplitBuf[Rand(SplitBuf.length)];
		return GetWeapClassFromString(SendStr);
	}
	
	//文字列からクラスの取得。
	function class<Weapon> GetWeapClassFromString(string str) {
		return class<Weapon>(DynamicLoadObject(str, class'Class'));
	}
	
//<<---メイン関数(CheckSpawnTwoBossSquad)--->>//

/*

	//2体目のボスを召喚 1.0秒ごとに呼び出し
	function CheckSpawnTwoBossSquad() {
		local byte Curwave;
		//初期化
			Curwave = MyKFGI.MyKFGRI.WaveNum;
		//ウェーブが開始されていない場合はどうでもいい
			if (!(Curwave>=1)) return;
//強制的にボスウェーブにするテストコード
//		if (Curwave<MyKFGI.MyKFGRI.WaveMax) KFGameInfo_Survival(MyKFGI).WaveEnded(WEC_WaveWon);
		//ボス2体の召喚処理
			if (Curwave==MyKFGI.MyKFGRI.WaveMax) {
				if (bSpawnTwoBossSquad) {
					MyKFGI.SpawnManager.TimeUntilNextSpawn = 10;
					SetTimer(5.0, false, nameof(SpawnTwoBosses));
					SetTimer(15.0, false, nameof(SpawnTwoBosses));
					bSpawnTwoBossSquad = false;
				}
			}else{
				bSpawnTwoBossSquad = true;
			}
		//
	}
	
	function SpawnTwoBosses() {
		local array<class<KFPawn_Monster> > SpawnList;
		local array<String> SplitBuf;
		local string Buf;
		//Add 2018.02.11
			local array<class<KFPawn_Monster> > Bosses_Class;
			local array<String> Bosses_Name;
			local byte i,Bosses_Len;
			Bosses_Name.AddItem("Hans");	Bosses_Class.AddItem(class'KFPawn_ZedHans');
			Bosses_Name.AddItem("Pat");		Bosses_Class.AddItem(class'KFPawn_ZedPatriarch');
			Bosses_Name.AddItem("KFP");		Bosses_Class.AddItem(class'KFPawn_ZedFleshpoundKing');
			Bosses_Name.AddItem("KBlt");	Bosses_Class.AddItem(class'KFPawn_ZedBloatKing');
			Bosses_Len = Bosses_Name.Length;
		//
		if (SpawnTwoBossesName=="") {
			MyKFGI.SpawnManager.TimeUntilNextSpawn = 0;
			return;
		}
		ParseStringIntoArray(SpawnTwoBossesName,SplitBuf,",",true);
		foreach SplitBuf(Buf) {
			//Change 2018.02.11
				if (Buf=="Rand") {
					SpawnList.AddItem(Bosses_Class[Rand(Bosses_Len)]);
				}else{
					for(i=0;i<Bosses_Len-1;i++) {
						if (Buf==Bosses_Name[i]) SpawnList.AddItem(Bosses_Class[i]);
					}
				}
//SendRestrictMessageStringAll(Buf);	//test 
		}
		MyKFGI.NumAISpawnsQueued += MyKFGI.SpawnManager.SpawnSquad( SpawnList );
		MyKFGI.SpawnManager.TimeUntilNextSpawn = MyKFGI.SpawnManager.CalcNextGroupSpawnTime();
//	SendRestrictMessageStringAll("キューの数：" $ MyKFGI.NumAISpawnsQueued $ "  ___  " $ MyKFGI.SpawnManager.TimeUntilNextSpawn	);
	}

*/

//<<---メイン関数(CheckAutoAmmoBuying)--->>//

	//全プレイヤーについて弾薬の補充を確認する
	function CheckAutoAmmoBuying() {
		local KFPlayerController KFPC;
		//ウェーブが開始されていない場合はどうでもいい
			if (!(MyKFGI.MyKFGRI.WaveNum>=1)) return;
		//全PCに対して判定 SpawnHumanPawnに関しては無視
			foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
				if ( (KFPC!=None) && (!IsBotPlayer(KFPC)) ) {
					AutoAmmoBuy(KFPC);
				}
			}
		//
	}
	
	//弾薬自動チャージ 2018.02.10
	function AutoAmmoBuy(KFPlayerController KFPC) {
		local KFPlayerReplicationInfo KFPRI;
		local KFWeapon KFWeap;
		local int BASH_FIREMODE,i,price,WeapMC;
		local class<KFWeaponDefinition> WDClass;
		local bool bEvisAlt;
		BASH_FIREMODE = 3;
		KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
		KFWeap = KFWeapon(KFPC.Pawn.Weapon);
		bEvisAlt = false;
		if (KFWeap==None) return;
		//メイン・サブマガジンそれぞれについて見る
		for (i=0;i<2;i++) {
			//予備弾倉が2マガジンを切ったら購入
			WeapMC = KFWeap.MagazineCapacity[i];
			if (KFWeap.SpareAmmoCount[i] < 2 * WeapMC) {
				//弾薬の価格を調べたいが、KFWeapからKFWeapDefを直接取りに行けないので、KFDTを経由
					WDClass = class<KFDamageType>(KFWeap.class.default.InstantHitDamageTypes[BASH_FIREMODE]).default.WeaponDef;
					price = (i==0 ? WDClass.default.AmmoPricePerMag : WDClass.default.SecondaryAmmoMagPrice);
					//マガジン増量に対応 増加してた場合その分お金とろうね
						if (KFWeap.class.default.MagazineCapacity[i] != 0 ) {
							price = (price * KFWeap.MagazineCapacity[i]) / KFWeap.class.default.MagazineCapacity[i];
						}
					//
					if (price<=0) continue; //買えないものもある
					if (KFPRI.Score<price) continue; //お金が足りないよ！
				//買うと予備弾倉ハミる場合は拒否
					if (KFWeap.SpareAmmoCapacity[i] < KFWeap.SpareAmmoCount[i] + WeapMC) {
						//エヴィスくんのオルトファイアは別なんだ……
						if ( (KFWeap_Eviscerator(KFWeap)!=None) && (i==1) ) {
							WeapMC = WDClass.default.SecondaryAmmoMagSize; //10ずつ買える
							bEvisAlt = ( KFWeap.AmmoCount[1] < 2* WeapMC ); //オルトの弾倉が20を切ってるなら購入
						}
						if (!bEvisAlt) continue;
					}
				//補充と購入処理
//SendRestrictMessageStringAll("less::" $ (i==0?"Main":"Sub"));
					if (bEvisAlt) {
						KFWeap.AmmoCount[1] += WeapMC;
					}else{
						KFWeap.SpareAmmoCount[i] += WeapMC;
					}
					KFPRI.Score -= price;
				//
			}
		}
//		KFWeap.SpareAmmoCount[0] = KFWeap.SpareAmmoCapacity[0];
//		KFWeap.SpareAmmoCapacity[0] = 99999;
//		KFWeap.SpareAmmoCount[1] = KFWeap.SpareAmmoCapacity[1];
	}

//<<---メイン関数(CheckTraderState)--->>//
	
	function CheckTraderState() {
		local byte PlayerCount;
		//ウェーブが開始されていない場合はどうでもいい
			if (!(MyKFGI.MyKFGRI.WaveNum>=1)) return;
		//お店がしまりました～♪
			if ( (MyKFGI.MyKFGRI.bTraderIsOpen==false) && (bOpened==true) ) {
				//TotalAICount,Maxmonsters 先にJudge関数をよんで死人分の負荷をパーティにかけないようにする
					JudgePlayers();
					PlayerCount = MyKFGI.GetLivingPlayerCount();
					if (PlayerCount>0) {
						//bosswave以外でのみ実行
							if (MyKFGI.MyKFGRI.WaveNum<MyKFGI.MyKFGRI.WaveMax) {
								//TotalZedを減らす
									if (bUseMaxPlayer_TotalZedsCount) SetMaxPlayer_TotalZedsCount(PlayerCount);
								//WaveSizeFakes
									if (bUseWaveSizeFakes) SetWaveSizeFakes(PlayerCount);
								//
							}
						//同時沸き数を変更
							if (bUseMaxMonsters) SetCustomMaxMonsters(PlayerCount);
						//
					}
				//走る速度を元に戻す
					ModifyTraderTimePlayerState(false);
				//
			}
		//お店があいてます～♪
			if ( MyKFGI.MyKFGRI.bTraderIsOpen==true ) {
				ModifyTraderTimePlayerState(true);
			}
		//状態の保存
			bOpened = MyKFGI.MyKFGRI.bTraderIsOpen;
		//
	}
	
	//WaveSizeFakesの設定
	function SetWaveSizeFakes(byte PlayerCount) {
		local byte WSF;
//		WSF = _WaveSizeFakes[min( PlayerCount-1+30, _WaveSizeFakes.length-1 )];
//		SetCustomTotalAICount(PlayerCount+WSF,true);
		WSF = _WaveSizeFakes[min( PlayerCount-1, _WaveSizeFakes.length-1 )];
		if (WSF>0) {
			SetCustomTotalAICount(PlayerCount+WSF,false);
			SendRestrictMessageStringAll("::SetWaveSizeFakes "$WSF);
		}
	}
	
	//MaxPlayer_TotalZedsCountの設定 人数過多の場合減らす
	function SetMaxPlayer_TotalZedsCount(byte PlayerCount) {
		if (PlayerCount>MaxPlayer_TotalZedsCount) {
			SetCustomTotalAICount(MaxPlayer_TotalZedsCount,true);
		}
	}

	//ウェーブで沸くMOB数の調整 参考先 'KFAISpawnManager.uc' func: SetupNextWave
	function SetCustomTotalAICount(byte PlayerCount,bool bOutPutLog) {
		local int OldAIcount,AIcount;
		OldAIcount = MyKFGI.SpawnManager.WaveTotalAI;
		AIcount = 	MyKFGI.SpawnManager.WaveSettings.Waves[ MyKFGI.MyKFGRI.WaveNum-1 ].MaxAI *
					MyKFGI.DifficultyInfo.GetPlayerNumMaxAIModifier( PlayerCount ) *
					MyKFGI.DifficultyInfo.GetDifficultyMaxAIModifier();
		MyKFGI.SpawnManager.WaveTotalAI = AIcount;
		MyKFGI.MyKFGRI.AIRemaining = AIcount;
		MyKFGI.MyKFGRI.WaveTotalAICount = AIcount;
		if (bOutPutLog) SendRestrictMessageStringAll("::SetTotalZedsCount "$OldAIcount$"->"$AIcount);
	}
	
	//同時沸き数の調整
	function SetCustomMaxMonsters(byte PlayerCount) {
		local int MaxZeds;
		MaxZeds = min ( 255, _MaxMonsters[min( PlayerCount-1, _MaxMonsters.length-1 )] );
//this is old ver
//		MyKFGI.SpawnManager.MaxMonstersSolo[int(MyKFGI.GameDifficulty)] = byte(MaxZeds);
//		MyKFGI.SpawnManager.MaxMonsters = byte(MaxZeds);
//for v1056
		SetMaxMonstersV1056(byte(MaxZeds));
//
		SendRestrictMessageStringAll("::SetMaxMonsters "$byte(MaxZeds));
	}
	
	//MMの設定 - KFmutator_MaxplayersV2よりコピペ v1056より難易度・人数毎にMMができたようだ
	function SetMaxMonstersV1056(byte mm_v1056) {
		local int i,j;
		for (i = 0; i < MyKFGI.SpawnManager.PerDifficultyMaxMonsters.length; i++) {
			for (j = 0; j < MyKFGI.SpawnManager.PerDifficultyMaxMonsters[i].MaxMonsters.length ; j++) {
				MyKFGI.SpawnManager.PerDifficultyMaxMonsters[i].MaxMonsters[j] = mm_v1056;
			}
		}
	}
	
	//トレーダー開店及び閉店時のプレイヤーの状態の変更
	function ModifyTraderTimePlayerState(bool bOpenTrader) {
		local KFPlayerController KFPC;
		local KFPawn Player;
/*		//トレーダー中のパーク変更に関する設定
			if (bAllowChangingPerkAnytimeInTraderTime && bOpenTrader ) {
					foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
						if (KFPC!=None) KFPC.SetHaveUpdatePerk(false);
//KFPC.TeamMessage(KFPC.PlayerReplicationInfo,"No,match::?"$KFGameReplicationInfo(KFPC.WorldInfo.GRI).bMatchHasBegun,'Event');
					}
				}
			}*/
//
		//トレーダーダッシュに関する設定
			if (bEnableTraderDash) {
				foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
					Player = KFPawn(KFPC.Pawn);
					if (Player!=None) {
						SetCustomSpeedAndCollision(Player,bOpenTrader);
					}
				}
			}
		//
	}
	
	//移動速度とコリジョンの変更
	function SetCustomSpeedAndCollision(KFPawn Player,bool bOpenTrader) {
		//スピードの変更 (ナイフを持ってる時)
			if ( bOpenTrader && IsPlayerKnifeOut(Player) ) {
				Player.GroundSpeed = TraderGroundSpeed;
			}else{
				Player.UpdateGroundSpeed();
			}
		//コリジョンの有無
			if (bDisableTeamCollisionWithTraderDash) {
				Player.bIgnoreTeamCollision = bOpenTrader ? true : MyKFGI.bDisableTeamCollision;
			}
		//
	}

	//ナイフを持っているか
	function bool IsPlayerKnifeOut(KFPawn Player) {
		return (KFWeap_Edged_Knife(Player.Weapon)!=None);
	}

//<<---メイン関数(JudgePlayers)--->>//

	
	//プレイヤーに裁きを！
	function JudgePlayers() {
		local KFPlayerController KFPC;
		local eWaveType eWT;
		//ウェーブが開始されていない場合はどうでもいい
			if (!(MyKFGI.MyKFGRI.WaveNum>=1)) return;
		//現在ウェーブが通常かボスか WaveNumが現在のウェーブ、WaveMaxは最大ウェーブ
			eWT =  ( MyKFGI.MyKFGRI.WaveNum < MyKFGI.MyKFGRI.WaveMax - ( MyKFGI.MyKFGRI.bTraderIsOpen ? 1 : 0 ) ) ? WaveType_Normal : WaveType_Boss;
		//全PCに対して判定 SpawnHumanPawnに関しては無視
			foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
				if ( (KFPC!=None) && (!IsBotPlayer(KFPC)) ) {
					JudgeSpecificPlayer(KFPC,eWT);
				}
			}
		//
	}
	
	//JudgePlayersのサブ関数
	function JudgeSpecificPlayer(KFPlayerController KFPC,eWaveType eWT) {
		local Pawn Player;
		local Weapon CurWeapon;
		//存在しないプレイヤーﾀﾞﾖ
			if (KFPC.Pawn==None) return;
		//下準備
			Player = KFPC.Pawn;
			CurWeapon = Player.Weapon;
		//メッセージの送信先をこのプレイヤーに設定
			SetRestrictMessagePC(KFPC);
		//禁止武器を使用している場合は強制的に消滅させる Old: KFPC.ServerThrowOtherWeapon(CurWeapon);
			if (IsWeaponRestricted(CurWeapon,eWT)) {
				SendRestrictMessageString();
				CurWeapon.Destroyed();
			}
		//パークのレベル制限orスキル制限	トレーダーが開いているならHPを減らす そうでなければ殺す
			if ( IsPerkLevelRestricted(KFPC.GetPerk().GetPerkClass(), KFPC.GetPerk().GetLevel(),eWT)
																|| IsUsingRestrictedPerkSkill(KFPC,eWT) ) {
				if (MyKFGI.MyKFGRI.bTraderIsOpen) {
					Player.Health = max(Player.Health-VALUEFORDEAD,1);
				}else if (Player.Health>=0) {
					SendRestrictMessageString();
					Player.FellOutOfWorld(none);
				}
			}
		//
	}

//<<---制限判定関数--->>//
		
	//パークレベルが下限を満たしているかどうか
	function bool IsPerkLevelRestricted(class<KFPerk> Perk,byte PerkLevel,eWaveType eWT) {
		switch(Perk) {
			case class'KFPerk_Berserker':
				return IsBadPerkLevel(_MinPerkLevel_Berserker[eWT],PerkLevel,Perk);
			case class'KFPerk_Commando':
				return IsBadPerkLevel(_MinPerkLevel_Commando[eWT],PerkLevel,Perk);
			case class'KFPerk_Support':
				return IsBadPerkLevel(_MinPerkLevel_Support[eWT],PerkLevel,Perk);
			case class'KFPerk_FieldMedic':
				return IsBadPerkLevel(_MinPerkLevel_FieldMedic[eWT],PerkLevel,Perk);
			case class'KFPerk_Demolitionist':
				return IsBadPerkLevel(_MinPerkLevel_Demolitionist[eWT],PerkLevel,Perk);
			case class'KFPerk_Firebug':
				return IsBadPerkLevel(_MinPerkLevel_Firebug[eWT],PerkLevel,Perk);
			case class'KFPerk_Gunslinger':
				return IsBadPerkLevel(_MinPerkLevel_Gunslinger[eWT],PerkLevel,Perk);
			case class'KFPerk_Sharpshooter':
				return IsBadPerkLevel(_MinPerkLevel_Sharpshooter[eWT],PerkLevel,Perk);
			case class'KFPerk_Survivalist':
				return IsBadPerkLevel(_MinPerkLevel_Survivalist[eWT],PerkLevel,Perk);
			case class'KFPerk_Swat':
				return IsBadPerkLevel(_MinPerkLevel_Swat[eWT],PerkLevel,Perk);
		}
		return false;
	}
	
	//IsPerkLevelRestrictedのサブ関数
	function bool IsBadPerkLevel(byte MinPerkLevel,byte PerkLevel,class<KFPerk> Perk) {
		local string perkname;
		if (!(MinPerkLevel<=PerkLevel)) {
			perkname = Perk.default.PerkName;
			if (MinPerkLevel<=25) {
				SetRestrictMessageString("::FellOutOfWorld::"$perkname$"::NeedLevel"$MinPerkLevel$"(You:"$PerkLevel$")");
			}else{
				SetRestrictMessageString("::FellOutOfWorld::"$perkname$"::RestrictedPerk");
			}
			return true;
		}else{
			return false;
		}
	}
		
//----------------testcodes----------------//

	//使用禁止武器かどうか
	function bool IsWeaponRestricted(Weapon Weap,eWaveType eWT) {
		local array<string> aDWName;
		local string WName,DWName;
		//前処理
			if (KFWeapon(Weap)==None) return false;
			WName = Weap.ItemName;
			if (eWT==WaveType_Normal)	aDWName = aDisableWeapons;
			if (eWT==WaveType_Boss)		aDWName = aDisableWeapons_Boss;
		//各武器毎の判定。
			foreach aDWName(DWName) {
				if (WName==DWName) {
					SetRestrictMessageString("::DestroyWeapon::"$WName$"::RestrictedWeapon");
					return true;
				}
			}
		//
		return false;
	}
	
	//使用禁止スキルを使っているかどうか
	function bool IsUsingRestrictedPerkSkill(KFPlayerController KFPC,eWaveType eWT) {
		local int val,wavecodeongame,PerkCode,SkillCode,WaveCode;
		local string skillinfo;
		if (!bUseDisablePerkSkills) return false;
		if (eWT==WaveType_Normal) wavecodeongame = 0;
		if (eWT==WaveType_Boss) wavecodeongame = 1;
		foreach aDisablePerkSkills(val) {
			PerkCode	= (val/100)	%10;
			SkillCode	= (val/10)	%10;
			WaveCode	= (val)		%10;
			//PerkCode SkillCode WaveCode
			if ( ( GetPerkClassFromPerkCode(PerkCode) == KFPC.GetPerk().GetPerkClass() ) &&
				 ( KFPC.GetPerk().PerkSkills[SkillCode].bActive ) &&
				 ( WaveCode == wavecodeongame ) ) {
				skillinfo = GetSkillInfo(KFPC.GetPerk().GetPerkClass(),SkillCode);
				SetRestrictMessageString("::FellOutOfWorld::"$skillinfo$"::RestrictedSkill");
				return true;
			}
		}
		return false;
	}
	
	//スキルの情報
	function string GetSkillInfo(class<KFPerk> Perk,byte SkillCode) {
		local string AdditionalInfo;
		AdditionalInfo = "(Lv"$(5*((SkillCode/2)+1));
		AdditionalInfo $= ( SkillCode%2 == 0 ) ? "L" : "R";
		AdditionalInfo $= ")";
		return ( Perk.default.PerkSkills[SkillCode].Name $ AdditionalInfo );
	}
	
	//PerkCodeからPerkクラスを取得
	function class<KFPerk> GetPerkClassFromPerkCode(byte pcode) {
		switch(pcode) {
			case PerkCode_Berserker:
				return class'KFPerk_Berserker';
			case PerkCode_Commando:
				return class'KFPerk_Commando';
			case PerkCode_Support:
				return class'KFPerk_Support';
			case PerkCode_FieldMedic:
				return class'KFPerk_FieldMedic';
			case PerkCode_Demolitionist:
				return class'KFPerk_Demolitionist';
			case PerkCode_Firebug:
				return class'KFPerk_Firebug';
			case PerkCode_Gunslinger:
				return class'KFPerk_Gunslinger';
			case PerkCode_Sharpshooter:
				return class'KFPerk_Sharpshooter';
			case PerkCode_Survivalist:
				return class'KFPerk_Survivalist';
			case PerkCode_Swat:
				return class'KFPerk_Swat';
		}
	}
	

//<<---チャットコマンド関連(ChatCommands)--->>//

	//chatの乗っ取り
	function HackBroadcastHandler() {
		if (RPWBroadcastHandler(MyKFGI.BroadcastHandler)==None) {
			MyKFGI.BroadcastHandler = spawn(class'RPWBroadcastHandler');
			RPWBroadcastHandler(MyKFGI.BroadcastHandler).InitRPWClass(Self);
		 	ClearTimer(nameof(HackBroadcastHandler));
		}
	}
	
	//PRIからKFPCの取得
	function KFPlayerController GetKFPCFromPRI(PlayerReplicationInfo PRI) {
		return KFPlayerController(KFPlayerReplicationInfo(PRI).Owner);
	}
	
	//chat内容のフック 返り値はそのテキストを非表示にするかどうか
	function Broadcast(PlayerReplicationInfo SenderPRI,coerce string Msg) {
		local string MsgHead,MsgBody;
		local array<String> splitbuf;
		//split message:
			ParseStringIntoArray(Msg,splitbuf," ",true);
			MsgHead = splitbuf[0];
			MsgBody = splitbuf[1];
		//メッセージ内容で分岐
			switch(MsgHead) {
				case "!rpwdebug":
					Broadcast_Debug(GetKFPCFromPRI(SenderPRI));
					break;
				case "!OpenTrader":
				case "!OT":
					if (bDisableChatCommand_OpenTrader) break;
					if (MsgBody=="") Broadcast_OpenTrader(GetKFPCFromPRI(SenderPRI));
					break;
				case "!WaveSizeFakes":
					Broadcast_WaveSizeFakes(MsgBody);
					break;
				case "!RPWInfo":
					if (MsgBody=="") Broadcast_RPWInfo();
					break;
				case "!hawawa":
					Broadcast_Special(MsgBody);
					break;
				case "!dappun":
				 	Broadcast_Puke(GetKFPCFromPRI(SenderPRI),MsgBody);
					break;
			}
		//
	}
	
	function bool StopBroadcast(string Msg) {
		local string MsgHead,MsgBody;
		local array<String> splitbuf;
		//split message:
			ParseStringIntoArray(Msg,splitbuf," ",true);
			MsgHead = splitbuf[0];
			MsgBody = splitbuf[1];
		//"!opentrader"と"!ot"の消去
			switch(MsgHead) {
				case "!OpenTrader":
				case "!OT":
					if (MsgBody=="") return bDontShowOpentraderCommandInChat;
					break;
			}
		//通常はそのままテキストを表示
			return false;
		//
	}
	
	//!rpwdebug: mod作成補助
	function Broadcast_Debug(KFPlayerController KFPC) {
	}
	
	//!OpenTrader: 強制開店
	function Broadcast_OpenTrader(KFPlayerController KFPC) {
		if (MyKFGI.MyKFGRI.bTraderIsOpen) KFPC.OpenTraderMenu();
	}
	
	//!WaveSizeFakes: WSFの機能の使用切り替え
	function Broadcast_WaveSizeFakes(string Msg) {
		if (Msg=="true") {
			bUseWaveSizeFakes = true;
			SendRestrictMessageStringAll("::WaveSizeFakes::Enable");
		}
		if (Msg=="false") {
			bUseWaveSizeFakes = false;
			SendRestrictMessageStringAll("::WaveSizeFakes::Disable");
		}
	}
	
	//!RPWInfo: RPWmodの情報
	function Broadcast_RPWInfo() {
		local string InfoBuf;
		//情報の送信開始
//			SendRestrictMessageStringAll("::RPWInfo in console.");
//			SendEmptyMessageStringConsoleAll();
			SendRestrictMessageStringConsoleAll("::RPWInfo");
		//パークレベル
			InfoBuf $= "MinPerkLevel(1w-10w,Boss)// ";
			Broadcast_RPWInfo_AddPerkInfo(InfoBuf);
			SendRestrictMessageStringConsoleAll("::"$InfoBuf);
		//禁止スキル
			if (bUseDisablePerkSkills) {
				InfoBuf = "DisableSkills// ";
				Broadcast_RPWInfo_AddSkillsInfo(InfoBuf);
				SendRestrictMessageStringConsoleAll("::"$InfoBuf);
			}
		//禁止武器
			if (DisableWeapons!="") {
				InfoBuf = "DisableWeap// ";
				Broadcast_RPWInfo_AddWeapInfo(InfoBuf,aDisableWeapons);
				SendRestrictMessageStringConsoleAll("::"$InfoBuf);
			}
		//禁止武器Boss
			if (DisableWeapons_Boss!="") {
				InfoBuf = "DisableWeap(Boss)// ";
				Broadcast_RPWInfo_AddWeapInfo(InfoBuf,aDisableWeapons_Boss);
				SendRestrictMessageStringConsoleAll("::"$InfoBuf);
			}
		//複数ボスの名前
			/*
			if (SpawnTwoBossesName!="") {
				InfoBuf = "BossName// "$SpawnTwoBossesName;
				SendRestrictMessageStringConsoleAll("::"$InfoBuf);
			}
			*/
		//
	}
	
	//RPWInfoにパークレベルの情報を書き込み
	function Broadcast_RPWInfo_AddPerkInfo(out string InfoBuf) {
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Berserker)		$"("$MinPerkLevel_Berserker$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Commando)		$"("$MinPerkLevel_Commando$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Support)		$"("$MinPerkLevel_Support$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_FieldMedic)		$"("$MinPerkLevel_FieldMedic$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Demolitionist)	$"("$MinPerkLevel_Demolitionist$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Firebug)		$"("$MinPerkLevel_Firebug$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Gunslinger)		$"("$MinPerkLevel_Gunslinger$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Sharpshooter)	$"("$MinPerkLevel_Sharpshooter$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Survivalist)	$"("$MinPerkLevel_Survivalist$") ";
		InfoBuf $= GetPerkNameFromPerkCode(PerkCode_Swat)			$"("$MinPerkLevel_Swat$") ";
	}
	
	//PerkCodeから（独自の）パークの名前を取得
	function string GetPerkNameFromPerkCode(int PerkCode) {
		switch(PerkCode) {
			case PerkCode_Berserker:
				return "Zerk";
			case PerkCode_Commando:
				return "Com";
			case PerkCode_Support:
				return "Sup";
			case PerkCode_FieldMedic:
				return "Med";
			case PerkCode_Demolitionist:
				return "Demo";
			case PerkCode_Firebug:
				return "Bug";
			case PerkCode_Gunslinger:
				return "GS";
			case PerkCode_Sharpshooter:
				return "SS";
			case PerkCode_Survivalist:
				return "Suv";
			case PerkCode_Swat:
				return "Swat";
		}
		return "NullPerk?[ERROR@GetPerkNameFromPerkCode]";
	}

	//RPWInfoに禁止スキルの情報を書き込み
	function Broadcast_RPWInfo_AddSkillsInfo(out string InfoBuf) {
		local bool nl; //new line
		local int val,PerkCode,SkillCode,WaveCode;
		nl = false;
		foreach aDisablePerkSkills(val) {
			//前準備
				PerkCode	= (val/100)	%10;
				SkillCode	= (val/10)	%10;
				WaveCode	= (val)		%10;
			//Info書き込み
				if (nl) InfoBuf $= " ";
//				InfoBuf $= "[";
				InfoBuf $= GetPerkNameFromPerkCode(PerkCode)$"[";
				InfoBuf $= GetSkillInfo(GetPerkClassFromPerkCode(PerkCode),SkillCode)$"]";
				if (wavecode==1) InfoBuf $= "(Boss)";
//				InfoBuf $= "]";
			//
			nl = true;
		}
	}
	
	//RPWInfoに武器の名前を書く
	function Broadcast_RPWInfo_AddWeapInfo(out string InfoBuf,array<string> aWeapName) {
		local string WName;
		local bool nl; //new line
		nl = false;
		foreach aWeapName(WName) {
			if (nl) InfoBuf $= ",";
			InfoBuf $= WName;
			nl = true;
		}
	}
	
	//!hawawa: スペシャルな何かを実装する・・・かも？
	function Broadcast_Special(string Msg) {
		local bool nonemeg;
		nonemeg = (Msg=="");
		switch (Msg) {
			case "=o":
				SendRestrictMessageStringAll("::ふにゃあーーっ？！");
				break;
			case ":o":
				SendRestrictMessageStringAll("::はわわわ、びっくりしたのです！");
				break;
			case ":)":
				SendRestrictMessageStringAll("::ありがとう、なのです！");
				break;
			case ":(":
				SendRestrictMessageStringAll("::はわわっ！？恥ずかしいよぉ");
				break;
			default:
				if (nonemeg) {
					SendRestrictMessageStringAll("::はにゃあーっ？！");
				}else{
					SendRestrictMessageStringAll("::そんな装備で大丈夫なのです？");
				}
				break;
		}
	}

	//!dappun: お遊び その2
	function Broadcast_Puke(KFPlayerController KFPC,string Msg) {
		local KFPawn_Human KFPH;
		local byte i,MineNum;
		local float ExplodeTimer;
		local rotator DPMR; //DeathPukeMineRotations_Mine
		local KFProjectile PukeMine;
		//有効な場合のみ処理
		if (EnableDappun != "True") {
			//有効化フラグの設定　一度Disableになるとそのゲーム中で有効になることはない
			if (Msg=="Enable") EnableDappun = "True";
			if (Msg=="Disable") EnableDappun = "Disable";
			return;
		}
		//このコマンドは5秒に1回だけ有効
		EnableDappun = "False";
		SetTimer(5.0, false, nameof(Broadcast_Puke_ReserveEnable));
		//処理開始
		KFPH = KFPawn_Human(KFPC.Pawn);
		MineNum = 5;
		ExplodeTimer = 5.0f;
		for (i=0;i<MineNum;++i) {
			DPMR.Pitch = 8190;
			DPMR.Yaw = (2*32768)*i/MineNum-32768;
			DPMR.Roll = 0;
			PukeMine = Spawn(class'RPWPukeMine', KFPH,, KFPH.Location, DPMR,, true);
			if( PukeMine != none ) {
				PukeMine.Init( vector(DPMR) );
			}
			RPWPukeMine(PukeMine).SetExplodeTimer(ExplodeTimer);
		}
		SendRestrictMessageStringAll("::糞まみれになろうや。");
	}

	//!dappunの管理
	function Broadcast_Puke_ReserveEnable() {
		if (EnableDappun=="False") EnableDappun = "True";
	}
	
/////////////////////////////////////////<<---EOF--->>/////////////////////////////////////////
