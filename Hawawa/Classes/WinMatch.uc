class WinMatch extends KFMutator;

//const VoteDuration = 6.f; //10分*60
const VoteDuration = 6000.f; //10分*60
const DieTime = 1.0f; //readyしてから死ぬまでの時間

function PostBeginPlay() {
	super.PostBeginPlay();
	//タイマー
		settimer(1.f ,true, nameof(DoPlayerReady));
	//Map投票の時間いじってオワリ
		MyKFGI.MapVoteDuration = VoteDuration;
	//
}

function DoPlayerReady() {
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;
	if (!MyKFGI.MyKFGRI.bMatchHasBegun) {
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
			KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
			KFPRI.SetPlayerReady(true);
		}
		//roop==false: 仮に自殺できなくてもzedに襲われるでしょ
		settimer(DieTime ,false, nameof(DoPlayerDie));
	}
}

function DoPlayerDie() {
	local KFPlayerController KFPC;
	if (MyKFGI.MyKFGRI.bMatchHasBegun) {
		//Readyの必要なし
			SetTimer(0.f ,false, nameof(DoPlayerReady));
		//
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
			KFPC.Pawn.FellOutOfWorld(none);
		}
	}
}