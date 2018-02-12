class Miniature extends KFMutator;

const SizeRate_Zed		= 0.5; //0.55 for KF-TinyTown
//const SizeRate_Human	= 0.25; //0.10 for KF-TinyTown

function ModifyAI(Pawn AIPawn) {
	//スーパーの処理
		super.ModifyAI( AIPawn );
	//ちっちゃくないよ！
		MySetVisualScale(KFPawn(AIPawn),SizeRate_Zed);
//		KFPawn(AIPawn).SetVisualScale(SizeRate_Zed);
	//
}

function MySetVisualScale(KFPawn KFP,float Scale) {
	//for solo
//			KFP.BodyScaleChangePerSecond = 0.f;
//			KFP.UpdateBodyScale(Scale);
	/*
    KFP.bReinitPhysAssetOnDeath = true;
    KFP.CurrentBodyScale = Scale;
    KFP.Mesh.SetScale( KFP.CurrentBodyScale);
    KFP. PitchAudio( KFP.CurrentBodyScale);
    KFP.SetBaseEyeheight();
	*/
	local float NewScale;
	NewScale = Scale + 1.5*FRand();
	if (Rand(100)==0) {
		NewScale = 11.4514;
	}
	KFP.IntendedHeadScale = NewScale;
	KFP.SetHeadScale(NewScale,KFP.CurrentHeadScale);
	KFP.HitZones[HZI_HEAD].DmgScale /= NewScale;
}

/*
function ModifyPlayer(Pawn Other) {
	//スーパーの処理
		super.ModifyPlayer(Other);
	//ちっちゃくないよ！
		MySetVisualScale(KFPawn(Other),SizeRate_Human);
//		KFPawn(Other).SetVisualScale(SizeRate_Human);
	//
}
*/



//				memo				//


/*

function PostBeginPlay() {
	super.PostBeginPlay();
	Settimer( 0.5f, true, nameof(Main) );
}

function Main() {
	if (!(MyKFGI.MyKFGRI.WaveNum>=1)) return;
	SetAllPawnScale();
}

function SetAllPawnScale() {
	local KFPawn_Monster KFPM;
	local KFPawn_Human KFPH;
	foreach WorldInfo.AllPawns(class'KFPawn_Monster', KFPM ) {
		SetPawnScale(KFPM,SizeRate_Zed);
	}
	foreach WorldInfo.AllPawns(class'KFPawn_Human', KFPH) {
		SetPawnScale(KFPH,SizeRate_Human);
	}
}

function SetPawnScale(KFPawn KFP,float Scale) {
	KFP.BodyScaleChangePerSecond = 0.f;
	KFP.UpdateBodyScale(Scale);
	KFP.SetHeadScale(Scale,KFP.CurrentHeadScale);
}


*/