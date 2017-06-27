//2017.5.18 なんやらかんやらでPowerZedsを再び統合することに…… (´・ω・`)
//6.1 要望のあった"FP(とおまけでSC)の速度を公式のものにする機能"を追加

class RGplay extends KFMutator

//<<---config用変数の定義--->>//
	config(RGplay);

	/* Init Config */
		var config bool bIWontInitThisConfig;
	/* Mode Select */
		var config bool bEnableMode_HeadShotOnly;
		var config bool bEnableMode_NoZedTime;
		var config bool bEnableMode_FastestSpawn;
		var config bool bEnableMode_ChangeZedHP;
		var config bool bEnableMode_PowerZeds;
	/* HeadShotOnly */
		var config bool bHeadShotOnly_DisableCrawler;
		var config bool bHeadShotOnly_DisableStalker;
		var config bool bHeadShotOnly_DisableHusk;
	/* ChangeZedHP */
		var config byte ChangeZedHP_FakePlayerNum;
	/* PowerZeds */
		var config byte PowerZeds_SpawnRate_Bloat;
		var config byte PowerZeds_SpawnRate_Husk;
		var config byte PowerZeds_SpawnRate_Stalker;
		var config byte PowerZeds_SpawnRate_Siren;
		var config byte PowerZeds_SpawnRate_Fleshpound;
		var config byte PowerZeds_SpawnRate_Crawler;
		var config byte PowerZeds_SpawnRate_Scrake;
	/* */

//<<---変数・定数の定義--->>//
	
	/* HeadShotOnly */
		const HSO_RatioBossPat		= 2.25f; //2.55f
		const HSO_RatioBossHans		= 1.65f;
	/* RGPlay::Global */
		var byte OldWaveNum;
		const Time_BeginWaveInterval = 5.0f; //original 5.0f
		var float Time_WaitForSpawn;
	/* PowerZeds */
		Struct PowerZedsSpawn {
			var byte SpawnRate;
			var class<KFPawn_Monster> NormalClass;
			var class<KFPawn_Monster> PowerClass;
		};
		var array<PowerZedsSpawn> PZS;
		var float TimeNextSpawn;
	/* */

//<<---初期化関数--->>//

	function InitConfigVar() {
		/* Init Config */
			bIWontInitThisConfig = true;
		/* Mode Select */
			bEnableMode_HeadShotOnly = false;
			bEnableMode_NoZedTime = false;
			bEnableMode_FastestSpawn = false;
			bEnableMode_ChangeZedHP = false;
			bEnableMode_PowerZeds = false;
		/* HeadShotOnly */
			bHeadShotOnly_DisableCrawler = false;
			bHeadShotOnly_DisableStalker = false;
			bHeadShotOnly_DisableHusk = false;
		/* ChangeZedHP */
			ChangeZedHP_FakePlayerNum = 0;
		/* PowerZeds */
			PowerZeds_SpawnRate_Bloat = 0;
			PowerZeds_SpawnRate_Husk = 0;
			PowerZeds_SpawnRate_Stalker = 0;
			PowerZeds_SpawnRate_Siren = 0;
			PowerZeds_SpawnRate_Fleshpound = 0;
			PowerZeds_SpawnRate_Crawler = 0;
			PowerZeds_SpawnRate_Scrake = 0;
		/* */
	}

//<<---タイマー関数--->>//

	function PostBeginPlay() {
		Super.PostBeginPlay();
		//ini config関連
			if (!bIWontInitThisConfig) InitConfigVar();
			SaveConfig();
		//PowerZeds用タイマーの初期化
			if (bEnableMode_PowerZeds) PowerZeds_Init();
		//
	}
	
	function Tick( float DeltaTime ) {
		super.Tick(DeltaTime);
		RGPlay_Update();
	}

//<<---コールバック関数--->>//

	function ModifyAI(Pawn AIPawn) {
		super.ModifyAI( AIPawn );
		if (bEnableMode_HeadShotOnly) HeadShotOnly_ModifyAI(AIPawn);
		if (bEnableMode_ChangeZedHP) ChangeZedHP_SetMonsterDefaults(KFPawn_Monster(AIPawn));
	}
	
	function ModifyZedTime( out float out_TimeSinceLastEvent, out float out_ZedTimeChance, out float out_Duration ) {
		super.ModifyZedTime(out_TimeSinceLastEvent,out_ZedTimeChance,out_Duration);
		if (bEnableMode_NoZedTime) NoZedTime_ModifyZedTime(out_TimeSinceLastEvent,out_ZedTimeChance,out_Duration);
	}
	
//<<---HeadShotOnly--->>//
	
	//HSonlyの処理
	function HeadShotOnly_ModifyAI(Pawn AIPawn) {
		local KFPawn KFP;
		local int i;
		//head以外の倍率を0に
			KFP = KFPawn(AIPawn);
			if (KFPawn_Monster(KFP)==None) return; //一応モンスターか判別
			if (HeadShotOnly_IsDisableMonster(KFP)) return; //蜘蛛ストーカーハスクの除外
			for (i=0;i<KFP.HitZones.Length;++i) {
				if (i!=HZI_HEAD) {
					KFP.HitZones[i].DmgScale = 0.f;
				}
			}
		//ボスのhead倍率を上昇
			if (KFPawn_ZedHans(KFP)!=None) {
				KFP.HitZones[HZI_HEAD].DmgScale *= HSO_RatioBossHans;
			}
			if (KFPawn_ZedPatriarch(KFP)!=None) {
				KFP.HitZones[HZI_HEAD].DmgScale *= HSO_RatioBossPat;
			}
		//
	}
	
	//その敵がHSonlyの対象でないか
	function bool HeadShotOnly_IsDisableMonster(KFPawn KFP) {
		if (bHeadShotOnly_DisableCrawler) {
			if (KFPawn_ZedCrawler(KFP)!=None) return true;
			if (KFPawn_ZedCrawlerKing(KFP)!=None) return true;
		}
		if (bHeadShotOnly_DisableStalker) {
			if (KFPawn_ZedStalker(KFP)!=None) return true;
		}
		if (bHeadShotOnly_DisableHusk) {
			if (KFPawn_ZedHusk(KFP)!=None) return true;
		}
		return false;
	}
	
//<<---NoZedTime--->>//
	
	//ZEDTIMEなんてなかった
	function NoZedTime_ModifyZedTime( out float out_TimeSinceLastEvent, out float out_ZedTimeChance, out float out_Duration ) {
		out_ZedTimeChance = 0;
		out_Duration = 0;
	}

//<<---ChangeZedHP--->>//

	//In KFGameInfo.uc function SetMonsterDefaults
	function ChangeZedHP_SetMonsterDefaults(KFPawn_Monster P) {
		local float HealthMod,HeadHealthMod;
		local int LivingPlayerCount;
		//ボスについては無効
			if (	(KFPawn_ZedHans(P)		!=None) 
				||	(KFPawn_ZedPatriarch(P)	!=None) ) {
				return;
			}
		//しょきか
			LivingPlayerCount = MyKFGI.GetLivingPlayerCount() + ChangeZedHP_FakePlayerNum;
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

//<<---RGplay::Global--->>//
	
	//自作スポーン関連
	function RGPlay_Update() {
		local array<class<KFPawn_Monster> > SpawnList;
		if (!MyKFGI.IsWaveActive()) return;
		if ( MyKFGI.MyKFGRI.WaveNum < MyKFGI.MyKFGRI.WaveMax ) {
			//ウェーブ開始時の処理
				if (MyKFGI.MyKFGRI.WaveNum!=OldWaveNum) {
					//最初のスポーンは5.0f秒ほど待つ
						Time_WaitForSpawn = WorldInfo.TimeSeconds+Time_BeginWaveInterval;
					//通常タイマーを被らないようにするために少し遅らせる 実質+1秒？
						MyKFGI.SpawnManager.TimeUntilNextSpawn += 0.05f;
					//
				}
			//PZmod用の処理
				if (`TimeSince(Time_WaitForSpawn)>0) {
					if (RGPlay_ShouldAddAI()) {
						MyKFGI.SpawnManager.TimeUntilNextSpawn = 1000; //通常タイマーを無効にする
						SpawnList = RGPlay_GetNextSpawnList();
						MyKFGI.NumAISpawnsQueued += MyKFGI.SpawnManager.SpawnSquad( SpawnList );
						//PowerZeds用のタイマーを更新
						if (bEnableMode_PowerZeds) PowerZeds_UpdateSpawnTimer();
					}
				}
			//
		}
		OldWaveNum = MyKFGI.MyKFGRI.WaveNum;
	}
	
	//スポーンすべき隊列の取得
	function array< class<KFPawn_Monster> > RGPlay_GetNextSpawnList() {
		if (bEnableMode_PowerZeds) return PowerZeds_GetNextSpawnList();
		return MyKFGI.SpawnManager.GetNextSpawnList();
	}
	
	//隊列を用意する時間かどうか どちらのモードもONでない場合はスポーンは必要ない
	function bool RGPlay_ShouldAddAI() {
		if ( (bEnableMode_FastestSpawn)	&& (FastestSpawn_ShouldAddAI())	) return true;
		if ( (bEnableMode_PowerZeds)	&& (PowerZeds_ShouldAddAI())	) return true;
		return false;
	}
	
//<<---FastestSpawn--->>//
	
	function bool FastestSpawn_ShouldAddAI() {
		return ( (!MyKFGI.SpawnManager.IsFinishedSpawning()) && (MyKFGI.SpawnManager.GetNumAINeeded()>0) );
	}

//<<---PowerZeds--->>//
	
	//PowerZedsの初期化
	function PowerZeds_Init() {
		//タイマーの初期化
			TimeNextSpawn = WorldInfo.TimeSeconds;
		//各スポーン確率の設定
			PowerZeds_SetSpawnRate(PowerZeds_SpawnRate_Bloat		,class'KFPawn_ZedBloat'			,class'PowerZeds_KFP_Bloat'			);
			PowerZeds_SetSpawnRate(PowerZeds_SpawnRate_Husk			,class'KFPawn_ZedHusk'			,class'PowerZeds_KFP_Husk'			);
			PowerZeds_SetSpawnRate(PowerZeds_SpawnRate_Stalker		,class'KFPawn_ZedStalker'		,class'PowerZeds_KFP_Stalker'		);
			PowerZeds_SetSpawnRate(PowerZeds_SpawnRate_Siren		,class'KFPawn_ZedSiren'			,class'PowerZeds_KFP_Siren'			);
			PowerZeds_SetSpawnRate(PowerZeds_SpawnRate_Crawler		,class'KFPawn_ZedCrawler'		,class'PowerZeds_KFP_Crawler'		);
			PowerZeds_SetSpawnRate(PowerZeds_SpawnRate_Scrake		,class'KFPawn_ZedScrake'		,class'PowerZeds_KFP_Scrake'		);
			PowerZeds_SetSpawnRate(PowerZeds_SpawnRate_Fleshpound	,class'KFPawn_ZedFleshpound'	,class'PowerZeds_KFP_Fleshpound'	);
		//
	}
	
	//スポーン設定
	function PowerZeds_SetSpawnRate(byte SpawnRate,class<KFPawn_Monster> NormalClass,class<KFPawn_Monster> PowerClass) {
		local PowerZedsSpawn PZSbuf;
		if (SpawnRate==0) return;
		PZSbuf.SpawnRate = SpawnRate;
		PZSbuf.NormalClass = NormalClass;
		PZSbuf.PowerClass = PowerClass;
		PZS.AddItem(PZSbuf);
	}
	
	//タイマーの更新
	function PowerZeds_UpdateSpawnTimer() {
		TimeNextSpawn = WorldInfo.TimeSeconds + MyKFGI.SpawnManager.CalcNextGroupSpawnTime();
	}
		
	//パワーゼッド用隊列を取得
	function array< class<KFPawn_Monster> > PowerZeds_GetNextSpawnList() {
		local array<class<KFPawn_Monster> > SpawnList;
		local int i;
		local PowerZedsSpawn PZSbuf;
		//オリジナルの隊列を取得
			SpawnList = MyKFGI.SpawnManager.GetNextSpawnList();
		//隊列の変換
		for (i=0;i<SpawnList.length;++i) {
/*
if (rand(2)==0) {
	SpawnList[i] = class'KFPawn_ZedScrake';
}else{
	SpawnList[i] = class'KFPawn_ZedFleshpound';
}
*/
				foreach PZS(PZSbuf) {
					if (IsSameClassBased(SpawnList[i],PZSbuf.NormalClass)) {
						//抽選で当たったらパワーゼッドへ変換
							if (Rand(100)<PZSbuf.SpawnRate) {
								SpawnList[i] = PZSbuf.PowerClass;
							}
						//
						break;
					}
				}
//SpawnList[i] = class'PowerZeds_KFP_Bloat';
//SpawnList[i] = class'PowerZeds_KFP_Siren';
//SpawnList[i] = class'PowerZeds_KFP_Husk';
				
			}
		//
		return SpawnList;
	}
	
	function bool IsSameClassBased (class<KFPawn_Monster> SpawnClass,class<KFPawn_Monster> PowerClass) {
		if (class<KFPawn_ZedScrake>(SpawnClass)!=None) {
			return ( class'KFPawn_ZedScrake' == PowerClass );
		}
		if (class<KFPawn_ZedFleshpound>(SpawnClass)!=None) {
			return ( class'KFPawn_ZedFleshpound' == PowerClass );
		}
		if (class<KFPawn_ZedCrawler>(SpawnClass)!=None) {
			return ( class'KFPawn_ZedCrawler' == PowerClass );
		}
		return ( SpawnClass == PowerClass ) ;
	}
	
	function bool PowerZeds_ShouldAddAI() {
		local KFAISpawnManager SM;
		SM = MyKFGI.SpawnManager;
		if( ( SM.LeftoverSpawnSquad.Length > 0 || `TimeSince(TimeNextSpawn) > 0 ) && !SM.IsFinishedSpawning() ) {
			return SM.GetNumAINeeded() > 0;
		}
		return false;
	}

//<<---F4ckTheTemple--->>//
	
	//normal
	//Husk,Siren,Bloat,GoreFiend からランダム1,2種
	//wave3-6 1種 wave7-10 3種
	
	//boss
	//FPFPFPFPFP
	//SirenAndBloat
	
	
	
//<<---EOF--->>//


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
