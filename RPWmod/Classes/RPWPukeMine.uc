class RPWPukeMine extends KFProj_BloatPukeMine;

function SetExplodeTimer(float f_time) {
	SetTimer( f_time, false, nameOf(Timer_Explode) );
}