//2017.4.16 制作開始
//4.17 禁止パークの判定、ウェーブ数の判定はできた(・ω・)
//4.18 禁止武器が難しいのでカニ歩き部分を先に → キャストーッ！禁止武器もカニ歩きもできた！
//4.19 configェ…とりあえず形にはなったぞい。
//4.20 武器に関しては即殺でなく投げるという形に変更。DOSHによる分岐,メッセージを追加。
//4.22 なんやら注文が殺到している・・・
//4.25 初期武器に四苦八苦、ようやく形になるか…？
//4.27 ラグの原因なんじゃろな(ゲー'A`ェ) このmodのせいなのかも怪しいが、軽減処理はしておこう
//4.28 相変わらず鯖のラグはとれず とりあえずアーマーとグレの補充機能をつけてみる
//5.16 制作開始からはや一ヶ月…今日も今日とて更新です traderdashつけてみた
//6.03 トレーダー中のパーク変更し放題は無理でしたgg

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
	/* Player Settings */
		var config bool bStartingWeapon_AmmoFull;
		var config bool bPlayer_SpawnWithFullArmor;
		var config bool bPlayer_SpawnWithFullGrenade;
		var config bool bEnableTraderDash;
		var config bool bDisableTeamCollisionWithTraderDash;
	/* Wave Settings */
		var config byte MaxPlayer_TotalZedsCount;
		var config byte MaxPlayer_ZedHealth;
		var config string MaxMonsters;
		var config string SpawnTwoBossesName;
		var config bool bFixZedHealth_6P;
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
	//SendRestrictMessageString用
		var KFPlayerController RMPC;
		var string RMStr;
	//IsWeaponRestricted用
		var array<string> aDisableWeapons,aDisableWeapons_Boss;
	//CheckTraderState用
		var bool bOpened;
	//SetCustomMaxMonsters用
		var bool bUseMaxMonsters;
	//FillArmorOrGrenades アーマー・グレネードの予約補充用
		var array<KFPawn_Human> PlayerToFillArmGre;
	//RestrictMessage用
		struct RestrictMessageInfo {
			var KFPlayerController KFPC;
			var string Msg;
		};
		var array<RestrictMessageInfo> RMI;
	//CheckSpawnTwoBossSquad用
		var bool bSpawnTwoBossSquad;
	//
	
//<<---定数の定義--->>//

	//制限パーク使用時のライフ減少値（トレーダータイム）
		const VALUEFORDEAD = 10;
	//ModifyTraderTimePlayerState用
		const TraderGroundSpeed = 364364.0f;
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
		/* Player Settings */
			bStartingWeapon_AmmoFull = false;
			bPlayer_SpawnWithFullArmor = false;
			bPlayer_SpawnWithFullGrenade = false;
			bEnableTraderDash = false;
			bDisableTeamCollisionWithTraderDash = false;
		/* Wave Settings */
			MaxPlayer_TotalZedsCount = 0;
			MaxPlayer_ZedHealth = 0;
			MaxMonsters = "";
			SpawnTwoBossesName = "";
			bFixZedHealth_6P = false;
		/* */
	}
	
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
		InitDisableWeaponClass(DisableWeapons,aDisableWeapons);
		InitDisableWeaponClass(DisableWeapons_Boss,aDisableWeapons_Boss);
		SetArrayMM(_MaxMonsters,MaxMonsters);
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
		//SetCustomMaxMonsters用
			bUseMaxMonsters = (MaxMonsters!="");
		//1.0秒ごとに特定の関数を呼ぶ bool値は繰り返し呼ぶかどうか
			SetTimer(1.0, true, nameof(JudgePlayers));
			SetTimer(0.25, true, nameof(CheckTraderState));
			SetTimer(1.0, true, nameof(CheckSpawnTwoBossSquad));
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
		//処理終了
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
	
	//2体目のボスを召喚 1.0秒ごとに呼び出し
	function CheckSpawnTwoBossSquad() {
		local byte Curwave;
		//初期化
			Curwave = MyKFGI.MyKFGRI.WaveNum;
		//ウェーブが開始されていない場合はどうでもいい
			if (!(Curwave>=1)) return;
		//強制的にボスウェーブにするテストコード
//			if (Curwave<MyKFGI.MyKFGRI.WaveMax) KFGameInfo_Survival(MyKFGI).WaveEnded(WEC_WaveWon);
		//ボス2体の召喚処理
			if (Curwave==MyKFGI.MyKFGRI.WaveMax) {
				if (bSpawnTwoBossSquad) {
					MyKFGI.SpawnManager.TimeUntilNextSpawn = 10;
					SetTimer(5.0, false, nameof(SpawnTwoBosses));
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
		if (SpawnTwoBossesName=="") {
			MyKFGI.SpawnManager.TimeUntilNextSpawn = 0;
			return;
		}
		ParseStringIntoArray(SpawnTwoBossesName,SplitBuf,",",true);
		foreach SplitBuf(Buf) {
			if (Buf=="Rand") {
				if (Rand(2)==0) {
					Buf = "Hans";
				}else{
					Buf = "Pat";
				}
			}
			if (Buf=="Hans") SpawnList.AddItem(class'KFPawn_ZedHans');
			if (Buf=="Pat") SpawnList.AddItem(class'KFPawn_ZedPatriarch');
//			SendRestrictMessageStringAll(Buf);
		}
		MyKFGI.NumAISpawnsQueued += MyKFGI.SpawnManager.SpawnSquad( SpawnList );
		MyKFGI.SpawnManager.TimeUntilNextSpawn = MyKFGI.SpawnManager.CalcNextGroupSpawnTime();
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
						//人数過多の場合はTotalZedを減らす bosswave以外でのみ実行
							if ( (MaxPlayer_TotalZedsCount>0) 
								&& (PlayerCount>MaxPlayer_TotalZedsCount)
								&& (MyKFGI.MyKFGRI.WaveNum<MyKFGI.MyKFGRI.WaveMax) ) {
									SetCustomTotalAICount(PlayerCount);
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
	//ウェーブで沸くMOB数の調整 参考先 'KFAISpawnManager.uc' func: SetupNextWave
	function SetCustomTotalAICount(byte PlayerCount) {
		local int OldAIcount,AIcount;
		OldAIcount = MyKFGI.SpawnManager.WaveTotalAI;
		AIcount = 	MyKFGI.SpawnManager.WaveSettings.Waves[ MyKFGI.MyKFGRI.WaveNum-1 ].MaxAI *
					MyKFGI.DifficultyInfo.GetPlayerNumMaxAIModifier( MaxPlayer_TotalZedsCount ) *
					MyKFGI.DifficultyInfo.GetDifficultyMaxAIModifier();
		MyKFGI.SpawnManager.WaveTotalAI = AIcount;
		MyKFGI.MyKFGRI.AIRemaining = AIcount;
		MyKFGI.MyKFGRI.WaveTotalAICount = AIcount;
		SendRestrictMessageStringAll("::SetTotalZedsCount "$OldAIcount$"->"$AIcount);
	}
	
	//同時沸き数の調整
	function SetCustomMaxMonsters(byte PlayerCount) {
		local int MaxZeds;
		MaxZeds = min ( 255, _MaxMonsters[min( PlayerCount-1, _MaxMonsters.length-1 )] );
		MyKFGI.SpawnManager.MaxMonstersSolo[int(MyKFGI.GameDifficulty)] = byte(MaxZeds);
		MyKFGI.SpawnManager.MaxMonsters = byte(MaxZeds);
		SendRestrictMessageStringAll("::SetMaxMonsters "$byte(MaxZeds));
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
				if (!IsBotPlayer(KFPC)) {
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
		//パークのレベル制限にひっかかっている トレーダーが開いているならHPを減らす そうでなければ殺す
			if (IsPerkLevelRestricted(KFPC.GetPerk().GetPerkClass(), KFPC.GetPerk().GetLevel(),eWT )) {
				if (MyKFGI.MyKFGRI.bTraderIsOpen) {
					Player.Health = max(Player.Health-VALUEFORDEAD,1);
				}else if (Player.Health>=0) {
					SendRestrictMessageString();
					player.FellOutOfWorld(none);
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
	
/////////////////////////////////////////<<---EOF--->>/////////////////////////////////////////
