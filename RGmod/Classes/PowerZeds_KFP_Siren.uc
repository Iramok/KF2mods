class PowerZeds_KFP_Siren extends KFPawn_ZedSiren_Versus;

simulated function PostBeginPlay() {
	super.PostBeginPlay();
	SetTimer( 0.01f, true, nameof(ChangeKFAICstate) );
}

function ChangeKFAICstate() {
	if (Controller!=None) {
		KFAIController_ZedSiren(Controller).ScreamCooldown = 0.0;
		if (IsTimerActive(nameof(ChangeKFAICstate))) {
			ClearTimer( nameof(ChangeKFAICstate) );
		}
	}
}

defaultproperties
{
    SprintSpeed=430.0f  //450
    SprintStrafeSpeed=380.f
    GroundSpeed=350.0f //200
}