//2017.6.11 ganさん案でワープテスト、成功

class StrafeWarp extends KFmutator;

var StrafeWarp_Mng SWMng;

//仲介
function ResetStartPoint(KFPlayerController KFPC) {
	SWMng.ResetStartPoint(KFPC);
}

//

//初期化
function Init() {
	SWMng = Spawn(class'StrafeWarp_Mng');
}

function WarpPC(KFPlayerController KFPC) {
	local NavigationPoint StartSpot;
//		StartSpot = MyKFGI.FindPlayerStart(KFPC);
//		StartSpot = MyKFGI.ChoosePlayerStart(KFPC);
	StartSpot = SWMng.GetStartPoint(KFPC);
	if (StartSpot!=None) {
		KFPC.Pawn.SetLocation(StartSpot.Location);
SendMessagePlayer(KFPC,"Warp! XD");
	}else{
//SendMessagePlayer(KFPC,"NonE!!!!!!!");
	}
//MyKFGI.SpawnManager.WaveTotalAI = 1;
//MyKFGI.MyKFGRI.AIRemaining = 1;
//MyKFGI.MyKFGRI.WaveTotalAICount = 1;
//SendMessagePlayer(KFPC,"test"$" remain::"$SWMng.Warp_UseNumRemain);
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