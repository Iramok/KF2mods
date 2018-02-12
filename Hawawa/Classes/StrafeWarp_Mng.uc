//マネージャー
//ここに分ける人数が書いてある

class StrafeWarp_Mng extends KFmutator;

var NavigationPoint CurrentPlayerStartPoint;
var byte Warp_UseNumRemain;

//3人(33%)、2人(66%)ずつわける
function byte GetNextWarpUseNum() {
	return (Rand(3)==0) ? 3 : 2;
}

//スタート地点の取得
function NavigationPoint GetStartPoint(KFPlayerController KFPC) {
	//スタート地点の更新
		if (Warp_UseNumRemain<=0) ResetStartPoint(KFPC);
	//回数の消費
		Warp_UseNumRemain --;
	//
	return CurrentPlayerStartPoint;
}

//スタート地点の初期化
function ResetStartPoint(KFPlayerController KFPC) {
	CurrentPlayerStartPoint = ChoosePlayerStart(KFPC);
	Warp_UseNumRemain = GetNextWarpUseNum();
}

//新しい地点の取得
function PlayerStart ChoosePlayerStart( Controller Player, optional byte InTeam )
{
	local PlayerStart P, BestStart;
	local int navinum,selid,i;

//	local byte Team;
	// use InTeam if player doesn't have a team yet
//	Team = ( (Player != None) && (Player.PlayerReplicationInfo != None) && (Player.PlayerReplicationInfo.Team != None) )
//			? byte(Player.PlayerReplicationInfo.Team.TeamIndex)
//			: InTeam;
	foreach WorldInfo.AllNavigationPoints(class'PlayerStart', P) {
		navinum ++;
	}
	if (navinum==0) return None;
	selid = Rand(navinum);
	i = 0;
	// Find best playerstart
	foreach WorldInfo.AllNavigationPoints(class'PlayerStart', P) {
		if ( i++ == selid ) {
			BestStart = P;
			break;
		}
	}
	return BestStart;
}