//2017.5.23 完成っぽい～ とりあえずダメージと射撃速度だけ実装
//メモ：
//Type_PenetrationPowerはKFWeapon.ucのGetInitialPenetrationPower関数に影響できないので廃案
//5.24 サーバー上でなぜかrateが動かないのでダメージだけになってしまった…
//
//追加すべきもの：リコイル？


//NetDamage in Mutator.ucからダメージを変えれる

//class WeaponConfig within RestrictPW
class WeaponConfig extends Object within RestrictPW
	config(RestrictPW);

/*
WeaponConfig=AssaultRifle_AK12::Pen_Def=1.0,Rate_Alt=1.5,Dmg_Hvy=3.0
P1
	(DT=Class'KFGameContent.KFDT_Ballistic_M4Shotgun',Multiplier=1.400000,DebugName="M4 Combat Shotgun")
*/

//<<---config用変数の定義--->>//
	var config bool bUseWeaponConfig;
	var config array<string> WeaponConfig;

//<<---global変数の定義--->>//
	//改変する対象 Type_Nullは正しく文字列が書かれていない場合の対処
		enum ModifyType {
			Type_Null,
			Type_InstantHitDamage,
//			Type_FireInterval
//			Type_PenetrationPower
		};
	//モードと倍率の指定
		struct ModifyData {
			var ModifyType MType;
			var byte FireMode;
			var float Multiplier;
		};
	//configから抽出されるデータ
		struct WeaponData {
			var string WeaponName;
			var array<ModifyData> MData;
		};
	//config関連
		var array<WeaponData> WD;
	//適用された武器の管理
		var array<KFWeapon> ModifiedWeap;
		var int ModifyCount;
	//ModifiedWeapのlengthが長くなりすぎないように調整(Find関数に時間がかかりそう)
		const ReModifyCountNum = 24; //8Playerが3種類の武器を使う想定
	
//<<---判別用文字列の定義--->>//

	const MTCode_InstantHitDamage	= "Dmg";
//	const MTCode_FireInterval		= "Rate";
//	const MTCode_PenetrationPower	= "Pen";
	
	const FMCode_Default	= "Def";
	const FMCode_AltFire	= "Alt";
	const FMCode_Bash		= "Bash";
	const FMCode_HeavyAtk	= "Hvy";
	
//<<---FireModeの定義--->>//
	
	const NULL_FIREMODE				= -1; //Null FireMode for my mod
	const DEFAULT_FIREMODE			= 0; //Def+C4
	const ALTFIRE_FIREMODE			= 1;
	const BASH_FIREMODE				= 3;
	const HEAVY_ATK_FIREMODE		= 5; // for melee weapons

//for test
	
	function ShowTestMessage(string s) {
		Outer.SendRestrictMessageStringAll(s);
		/*
		local KFPlayerController KFPC;
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
			KFPC.TeamMessage(KFPC.PlayerReplicationInfo,s,'Event');
		}
		*/
	}

//<<---初期化関数--->>//

	function InitConfigVar() {
		WeaponConfig.AddItem("");	//1行だけサンプルとして追加
		bUseWeaponConfig = false;
	}

//<<---初期化関数(ReadConfigString)--->>//
	
	//WeaponConfigを配列として読み込む
	function ReadConfigString(){
		local string buf;
		buf = ""; //警告対策
		foreach WeaponConfig(buf) {
			WD.AddItem(GetWeaponDataFromString(buf));
		}
	}
	
	//WeaponConfigを1行ずつ読み込む
	//WeaponConfig=AssaultRifle_AK12::Pen_Def=1.0,Rate_Alt=1.5,Dmg_Hvy=3.0
	function WeaponData GetWeaponDataFromString(string WDStr) {
		local WeaponData WDret;
		local string MDBuf;
		local array<string> SplitBuf,ModData;
		local class<Weapon> cWbuf;
		//読み込み失敗用の初期化
			WDret.WeaponName = "";
		//分割
			ParseStringIntoArray(WDStr,SplitBuf,"::",true);
			if (SplitBuf.length!=2) return WDret;
		//名前の処理
			cWbuf = Outer.GetWeapClassFromString("KFGameContent.KFWeap_"$SplitBuf[0]);
			if (cWbuf==None) return WDret;
			WDret.WeaponName = cWbuf.default.ItemName;
//ShowTestMessage("touroku::"$WDret.WeaponName);
		//Modifyの処理
			ParseStringIntoArray(SplitBuf[1],ModData,",",true);
			foreach ModData(MDBuf) {
				WDret.MData.AddItem(GetModifyDataFromString(MDBuf));
//ShowTestMessage("FMode:"$WDret.MData[WDret.MData.length-1].FireMode$" MType:"$WDret.MData[WDret.MData.length-1].MType$" Muti:"$WDret.MData[WDret.MData.length-1].Multiplier);
			}
		//処理の終了
			return WDret;
		//
	}
	
	//各WeaponConfigのModifyDataをバラしたものからデータを取得
	//Pen_Def=1.0 Rate_Alt=1.5 Dmg_Hvy=3.0
	function ModifyData GetModifyDataFromString(string MDStr) {
		local ModifyData MDret;
		local array<string> SplitBuf1,SplitBuf2;
		//読み込み失敗用の初期化
			MDret.MType = Type_Null;
		//分割
			ParseStringIntoArray(MDStr,SplitBuf1,"_",true);
			if (SplitBuf1.length!=2) return MDret;
			ParseStringIntoArray(SplitBuf1[1],SplitBuf2,"=",true);
			if (SplitBuf2.length!=2) return MDret;
		//FireModeの設定 **失敗時の返り値はType_Nullを必ず返すべし**
			MDret.FireMode = GetFireModeFromString(SplitBuf2[0]);
			if (MDret.FireMode==NULL_FIREMODE) return MDret; //MDret.ModifyType must be Type_Null; 
		//ModifyTypeの設定
			MDret.MType = GetModifyTypeFromString(SplitBuf1[0]);
			if (MDret.MType==Type_Null) return MDret; //Type_Nullのためこの後の処理は必要ない
		//Multiplierの設定 失敗の感知は不可能なのでfloat関数にまかせる
			MDret.Multiplier = float(SplitBuf2[1]);
		//
		return MDret;
	}
	
	//名称から実際のModifyTypeの番号を取得
	function ModifyType GetModifyTypeFromString(string MTStr){
		switch(MTStr) {
			case MTCode_InstantHitDamage:
				return Type_InstantHitDamage;
/*
			case MTCode_FireInterval:
				return Type_FireInterval;
			case MTCode_PenetrationPower:
				return Type_PenetrationPower;
*/
		}
		return Type_Null;
	}
	
	//名称から実際のFireModeの番号を取得
	function byte GetFireModeFromString(string FMStr){
		switch(FMStr) {
			case FMCode_Default:
				return DEFAULT_FIREMODE;
			case FMCode_AltFire:
				return ALTFIRE_FIREMODE;
			case FMCode_Bash:
				return BASH_FIREMODE;
			case FMCode_HeavyAtk:
				return HEAVY_ATK_FIREMODE;
		}
		return NULL_FIREMODE;
	}

//<<---コールバック関数(PostBeginPlay)--->>//

	function PostBeginPlay() {
//		Super.PostBeginPlay();
		//.iniの初期設定
			if (!Outer.bIWontInitThisConfig) InitConfigVar();
//		Hogeeeeeee.AddItem("bbb");
			SaveConfig();
		//config値をばらす
			ReadConfigString();
		//
	}
	
	event Tick() {
		local KFPlayerController KFPC;
		local KFWeapon Weap;
		//ウェーブが開始されていない場合はどうでもいい
			if (!(MyKFGI.MyKFGRI.WaveNum>=1)) return;
		//全プレイヤーについて、現在装備している武器の値を改造
			foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
				if (KFPC.Pawn==None) continue;
				Weap = KFWeapon(KFPC.Pawn.Weapon);
				if ( (Weap!=None) && (ModifiedWeap.Find(Weap)==-1) ) {
//				if(true) {
//ReadConfigString();
					//武器の値調整
						ModifyWeapon(Weap);
					//modifyされた武器の配列管理
						ModifiedWeap.Add(1);
						ModifiedWeap[ModifiedWeap.length-1] = Weap;
						if ( ModifyCount++ >= ReModifyCountNum ) {
							ModifiedWeap.Remove(0,ModifiedWeap.length);
							ModifyCount = 0;
						}
					//
				}
			}
		//
	}
	
	//武器の値をいじくる
	function ModifyWeapon(KFWeapon Weap) {
		local ModifyData MDBuf;
		local int Index;
		Index = WD.Find('WeaponName',Weap.ItemName);
		if (Index==-1) return;
//ShowTestMessage("SetItemNameIs"$Weap.ItemName);
		foreach WD[Index].MData(MDBuf){
			ApplyModifyData(Weap,MDbuf);
		}
	}
	
	//実際に武器に値を適用する
	function ApplyModifyData(KFWeapon Weap,ModifyData MD){
		//註：InstantHitDamage,FireInterval,PenetrationPowerはすべてarray<Float>なのでそのまま掛け算可能
		switch(MD.MType) {
			case Type_Null:
				return; //do nothing in case of Type_Null
			case Type_InstantHitDamage:
				Weap.InstantHitDamage[MD.FireMode]	= MD.Multiplier * Weap.Class.default.InstantHitDamage[MD.FireMode];
				//元ﾀﾞﾒｰｼﾞが1以上なら、ダメージの下限は1にする
				if (Weap.Class.default.InstantHitDamage[MD.FireMode]>0) {
					Weap.InstantHitDamage[MD.FireMode]	= max ( 1, Weap.InstantHitDamage[MD.FireMode] );
				}
//ShowTestMessage("Dmg::"$Weap.InstantHitDamage[MD.FireMode]);
				break;
/*
			case Type_FireInterval:
				Weap.FireInterval[MD.FireMode]		= MD.Multiplier * Weap.Class.default.FireInterval[MD.FireMode];
//ShowTestMessage("Rate::"$Weap.FireInterval[MD.FireMode]);
LogInternal("Rate::"$Weap.FireInterval[MD.FireMode]);
			break;
			case Type_PenetrationPower:
				Weap.PenetrationPower[MD.FireMode]	= MD.Multiplier * Weap.Class.default.PenetrationPower[MD.FireMode];
ShowTestMessage("Pen::"$Weap.PenetrationPower[MD.FireMode]);
				break;
*/
		}
		return;
	}
	

//

/*

		//KFWeapon.uc
			
			Weap.InstantHitDamage[ALTFIRE_FIREMODE]=400.0;
			FireInterval(DEFAULT_FIREMODE)=+1.0
			PenetrationPower(DEFAULT_FIREMODE)=0.0
			AmmoCost(DEFAULT_FIREMODE)=1

			//KFWeap_HealerBase
				HealSelfRechargeSeconds=15
				HealOtherRechargeSeconds=7.5

		//メディックに関しての
			//KFWeap_MedicBase
			    HealAmount=15
				HealFullRechargeSeconds=10
		//トレーダーに関わる項目はNG
			//KFWeapon.uc
				InventorySize=6
				GroupPriority=75
				InitialSpareMags[0]	= 2
				MagazineCapacity[0]	= 30
				SpareAmmoCapacity[0]= 210
				InitialSpareMags[1]	= 3
				MagazineCapacity[1]	= 1
				SpareAmmoCapacity[1]= 11
		//ショットガンの弾数は7固定？でいいや
			//KFWeap_ShotgunBase
				//NumPellets(DEFAULT_FIREMODE)=7

*/