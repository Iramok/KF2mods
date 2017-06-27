class PowerZeds_KFP_Bloat extends KFPawn_ZedBloat_Versus;

const MineNum = 5;
const MaxPukeCount = 1;
var array<rotator> DeathPukeMineRotations_Mine;
var byte PukeCount;

simulated function PostBeginPlay(){
	local int i;
	super.PostBeginPlay();
	DeathPukeMineRotations_Mine.Add(MineNum);
	for (i=0;i<MineNum;++i) {
		DeathPukeMineRotations_Mine[i].Pitch = 8190;
		DeathPukeMineRotations_Mine[i].Yaw = (2*32768)*i/MineNum-32768;
		DeathPukeMineRotations_Mine[i].Roll = 0;
	}
	PukeCount = 0;
}

/** This pawn has died. */
function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	My_Puke();
	return super.Died( Killer, damageType, HitLocation );
}

function Puke() {
	super.Puke();
	if (PukeCount++<MaxPukeCount) {
		My_Puke();
	}
}

//Ž©ìƒQƒ“Š‰ºŠÖ”
function My_Puke(){
	local rotator DPMR;
	foreach DeathPukeMineRotations_Mine(DPMR) {
		SpawnPukeMine(Location,DPMR);
	}
}