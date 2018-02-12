
class PvPmode_KFHUD extends KFGFxHudWrapper;

//PvPmode_KFHUD用
var bool bUsePvPHUD;
var float TimeLastChanged;

//前準備
simulated function  PostBeginPlay() {
	super.PostBeginPlay();
	//HUD
		bUsePvPHUD = true;
		TimeLastChanged = WorldInfo.TimeSeconds;
	//
}

//タイマーの長さを取得
function float GetTimerLength() {
	if (bUsePvPHUD) {
		return class'PvPMode'.default.TimerLength_MyHUD;
	}else{
		return class'PvPMode'.default.TimerLength_TWIHUD;
	}
}

//HUDの変更時間か監視
function CheckTimeToChangeHUD() {
	if (`TimeSince(TimeLastChanged) > GetTimerLength()) {
		TimeLastChanged = WorldInfo.TimeSeconds;
		bUsePvPHUD = bUsePvPHUD ? false : true;
//SendMessagePlayer("change:"$bUsePvPHUD);
	}
}

//プレイヤーの情報表示なんてなかった
simulated function bool DrawFriendlyHumanPlayerInfo( KFPawn_Human KFPH ) {
	return false;
//	CheckTimeToChangeHUD();
//	return ( bUsePvPHUD ? false : super.DrawFriendlyHumanPlayerInfo(KFPH) ) ;
}

//アイコン表示なんてなかった
function DrawHiddenHumanPlayerIcon( PlayerReplicationInfo PRI, vector IconWorldLocation ) {
	CheckTimeToChangeHUD();
	if (!bUsePvPHUD) super.DrawHiddenHumanPlayerIcon(PRI,IconWorldLocation);
}

//個人にメッセージを送る
function SendMessagePlayer(string Str) {
	KFPlayerOwner.TeamMessage(KFPlayerOwner.PlayerReplicationInfo,Str,'Event');
}