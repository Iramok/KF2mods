class PowerZeds_KFP_Crawler extends KFPawn_ZedCrawlerKing;
 //   hidecategories(Navigation);
//class PowerZeds_KFP_Crawler extends KFPawn_ZedCrawler;

var float TimeLastSM;
const TimeSMInterval = 1.0f;

simulated function PostBeginPlay() {
	super.PostBeginPlay();
//	IntendedHeadScale=2.0;
//	CurrentHeadScale=1.0;
//	SetVisualScale(2.00);
}

DefaultProperties
{
	IntendedBodyScale=1.0;
	CurrentBodyScale=2.0;
	BodyScaleChangePerSecond=0.0;
	
	ElitePawnClass=class'PowerZeds_KFP_Crawler' //確率で白クローラーに変わるのでその対策
	TimeLastSM=0

	GroundSpeed=500.f //400.f
	SprintSpeed=650.f //500.f
	
/*
	GroundSpeed=600.f //400.f
	SprintSpeed=725.f //500.f
*/
	
	Begin Object Class=KFGameExplosion Name=ExploTemplate1
	//ダメージをクローラー(4ダメ)から少しあげる
		Damage=16
	//
		DamageRadius=450
		DamageFalloffExponent=1.f
		DamageDelay=0.f
	//盆踊りするからクローラーのものに変更
		MyDamageType=class'KFDT_Toxic_PlayerCrawlerSuicide'
	//
		//bIgnoreInstigator is set to true in PrepareExplosionTemplate

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.Nuke_Explosion'
		ExplosionSound=AkEvent'WW_GLO_Runtime.Play_WEP_Nuke_Explo'
		MomentumTransferScale=1.f

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	DeathExplosionTemplate=ExploTemplate1
	
}

//husk
	/*
	// Explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=245,G=190,B=140,A=255)
	End Object
	
	//爆発の変更
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=10
		DamageRadius=5000
		DamageFalloffExponent=0.5f
		DamageDelay=0.f
		bFullDamageToAttachee=true

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_HuskSuicide'
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.HuskSuicide_Explosion'
		ExplosionSound=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Suicide_Explode'
		MomentumTransferScale=1.f

		// Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.5

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.HuskSuicide'
		CamShakeInnerRadius=450
		CamShakeOuterRadius=900
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	DeathExplosionTemplate=ExploTemplate0
	*/


/*
//見た目はVSにしない
simulated event bool UsePlayerControlledZedSkin() {
	return false;
}
*/

/*
//ぴょんぴょんするんじゃ＾～
simulated event Tick( float DeltaTime ){
	super.Tick( DeltaTime );
	if ( (TimeLastSM==0) || (`TimeSince(TimeLastSM)>TimeSMInterval) ) {
		DoSpecialMove(SM_Evade);
		DoJump(Rand(2)==0 ? true : false);
		TimeLastSM = WorldInfo.TimeSeconds + TimeSMInterval;
	}
}
*/

//大きさの変更は本体でやる
/*

DefaultProperties
{
//	VisualScale=2.25
	DoshValue=100 //Original:10
	Health=550 //Original:55
	GroundSpeed=300.f //Original:400
	SprintSpeed=375.f //Original:500
	//Original:20
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=200, DmgScale=1.1, SkinID=1)
}

*/
