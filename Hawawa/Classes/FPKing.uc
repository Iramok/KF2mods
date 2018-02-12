class FPKing extends KFMutator;

//const SpawnDuaration_Mini = 300.f; //5分にwave/3+1体
//const SpawnDuaration_King = 900.f; //15分に1体
const SpawnDuaration_Mini = 30.f; //5分にwave/3+1体
const SpawnDuaration_King = 90.f; //15分に1体

var float TimeKing;
var float TimeMini;

function PostBeginPlay() {
	super.PostBeginPlay();
	ResetTimer(0);
	ResetTimer(1);
	Settimer( 1.0f, true, nameof(Main) );
}

function ResetTimer(byte FPID) {
	if (FPID==0) {
		TimeMini = SpawnDuaration_Mini + Worldinfo.TimeSeconds;
	}
	if (FPID==1) {
		TimeKing = SpawnDuaration_King + Worldinfo.TimeSeconds;
	}
}

function Main() {
	//Return
		if (!MyKFGI.MyKFGRI.bMatchHasBegun) return;
		if (MyKFGI.MyKFGRI.bTraderIsOpen) return;
	//MainTimer
		if (`TimeSince(TimeMini)>0) {
			ResetTimer(0);
			SpawnFP(class'KFPawn_ZedFleshpoundMini',MyKFGI.MyKFGRI.WaveNum/3+1);
			SendMessageAllPlayers("mini");
		}
		if (`TimeSince(TimeKing)>0) {
			return;
			ResetTimer(1);
			SpawnFP(class'KFPawn_ZedFleshpoundKing',1);
			SendMessageAllPlayers("king");
		}
	//
}

function SpawnFP(class<KFPawn_Monster> cKFP,byte SpawnNum) {
	local byte i;
	local int final;
	local array<class<KFPawn_Monster> > SpawnList;
	local KFSpawnVolume KFSV;
	final = 0;
//	SpawnList.Add(SpawnNum);
	for(i=0;i<SpawnNum;++i) {
		SpawnList[i] = cKFP;
	}
	SendMessageAllPlayers("addlen: "$SpawnList.Length);
	MyKFGI.SpawnManager.DesiredSquadType = EST_Large;//set spawn location
	KFSV = MyKFGI.SpawnManager.GetBestSpawnVolume(SpawnList);
	if(KFSV!=None) final = KFSV.SpawnWave(SpawnList,true);
//	MyKFGI.SpawnManager.SpawnSquad( SpawnList );
//	final = MyKFGI.SpawnManager.SpawnSquad( SpawnList );
//	MyKFGI.NumAISpawnsQueued += final;
	SendMessageAllPlayers("final: "$final);
}


/*
    			VolumeAmount = KFSV.SpawnWave(AIToSpawn, true);
                LastAISpawnVolume = KFSV;

			FakeSpawnList.AddItem( KFPawn_M );
	}

	if( KFGameInfo(WorldInfo.Game) != None)
	{
	}
*/


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