class PowerZeds_KFP_Husk extends KFPawn_ZedHusk;

const MyTimeBetweenFireBalls = 0.0f; //0.25f

simulated function PostBeginPlay() {
	super.PostBeginPlay();
	SetTimer( 0.01f, true, nameof(ChangeKFAICstate) );
}

function ChangeKFAICstate() {
	if (Controller!=None) {
		KFAIController_ZedHusk(Controller).MaxDistanceForFireBall=2750;	//4000
		if (IsTimerActive(nameof(ChangeKFAICstate))) {
			ClearTimer( nameof(ChangeKFAICstate) );
		}
	}
}

/** If true, assign custom player controlled skin when available */
simulated event bool UsePlayerControlledZedSkin() {
	return true;
}

//火球発射間隔の設定
simulated event Tick( float DeltaTime ) {
	super.Tick( DeltaTime );
	if (Controller!=None) {
		KFAIController_ZedHusk(Controller).TimeBetweenFireBalls = MyTimeBetweenFireBalls;
//		MyController.TimeBetweenFireBalls = MyTimeBetweenFireBalls;
	}
}

defaultproperties
{
	//ヘルス関連
/*
	Normal
		Health=462 // KF1=600
    	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=200, DmgScale=1.001, SkinID=1)  // KF1=200     //154
		HitZones[3]       =(ZoneName=heart,	   BoneName=Spine2,		  Limb=BP_Special,  GoreHealth=75, DmgScale=1.5, SkinID=2)    //0.5
		HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20,  DmgScale=0.5, SkinID=3)
	VS
*/
		Health=600 // KF1=600 //450
		HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=200, DmgScale=1.001, SkinID=1)  // KF1=200     //154
		HitZones[3]       =(ZoneName=heart,	   BoneName=Spine2,		  Limb=BP_Special,  GoreHealth=75,  DmgScale=1.1, SkinID=2)    //0.5 //1.5
		HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20,  DmgScale=0.5, SkinID=3)
	//自前
	    GroundSpeed=350.0f //170
	
	//Versus コピペ
	
	    // Faster sprint
	    SprintSpeed=364364.f //500
	    SprintStrafeSpeed=364364.f //250
//	    GroundSpeed=250.0f //170
		
	    DoshValue=20.0 // default because they have the same health as survival
	    XPValues(0)=30 // 2x default because they are harder to hit/kill
	
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.8)))  //3.0
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.7)))  //1.0 //0.5
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.5)))  //0.9
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.6)))  //1.01  0.4
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.65)))  //0.76  0.5
		DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.8)))  //0.5
		DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.8)))  //0.5
		DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.5)))  //0.8 //0.1
		DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(1.0)))  //0.25
		DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.5)))  //0.85  0.35
		DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.4)))   //1.0
		DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.30)))  //0.88
		// special case
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.0))
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(1.1)))  //0.9
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(0.85)))  //0.9  0.75
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.75)))  //0.9   0.65
	    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.6)))  //0.9
	    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.5)))  //0.9
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.75)))  //0.9  0.7
		DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(0.7)))  //0.9 //0.2
		DamageTypeModifiers.Add((DamageType=class'KFDT_ExplosiveSubmunition_HX25', 	 DamageScale=(0.6)))  //0.9
		DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_EvisceratorProj', 	 DamageScale=(0.4)))  //0.9
		DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Eviscerator', 	     DamageScale=(0.3)))  //0.9
		DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_DragonsBreath', 	 DamageScale=(1.1)))  //0.9
		DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon_Crovel', 	    	 DamageScale=(1.2)))  //0.8
		IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 0.5, 0.1, 0.1, 0.1), Cooldown=3.0, Duration=2.0)
		IncapSettings(AF_Knockdown)=(Vulnerability=(0.3),                     Cooldown=10.0)  //3.0
		IncapSettings(AF_Stumble)=	(Vulnerability=(0.2),                     Cooldown=3.0)
		IncapSettings(AF_GunHit)=	(Vulnerability=(1.0),                     Cooldown=0.75)
		IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                     Cooldown=0.5)
		IncapSettings(AF_Poison)=	(Vulnerability=(1),                       Cooldown=5.0, Duration=2.0)
		IncapSettings(AF_Microwave)=(Vulnerability=(1.0),                     Cooldown=5.0, Duration=2.0)
		IncapSettings(AF_FirePanic)=(Vulnerability=(0.1),                     Cooldown=8.0, Duration=3)
		IncapSettings(AF_EMP)=		(Vulnerability=(0.8),                     Cooldown=5.0, Duration=3.0)  //1.0
		IncapSettings(AF_Freeze)=	(Vulnerability=(0.6),                     Cooldown=1.5, Duration=2.0) //1.0
		IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
		// Backpack/Suicide Explosion
		Begin Object Class=KFGameExplosion Name=ExploTemplate0
			Damage=125
			DamageRadius=600
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
		ExplosionTemplate=ExploTemplate0
			
	//ここまでコピペ
}