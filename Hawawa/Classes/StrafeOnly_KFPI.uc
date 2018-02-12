class StrafeOnly_KFPI extends KFPlayerInput;

// Overridden to not double apply FOV scaling
event PlayerInput( float DeltaTime )
{
	//トレーダータイムはカニ歩き解除
		if (IsTraderOpened()) {
			Super.PlayerInput(DeltaTime);
			return;
		}
	//走りを強制的に無効
		if (bRun!=0) {
			GamepadSprintRelease();
		}
	//強制的にしゃがませる
		if (!Pawn.bIsCrouched) {
			StartCrouch();
		}
	//従来の入力処理後、強制的に前後方向の入力を無効化
		Super.PlayerInput(DeltaTime);
		aForward	= 0.f;
		//Pawn.Health = 42;
}

/** Abort/Cancel crouch when jumping */
exec function Jump(){
	//ZEDタイム及びトレーダータイムはカニ歩き解除
	if ( (WorldInfo.TimeDilation<1.f) || (IsTraderOpened()) ) {
		Super.Jump();
		return;
	}
}

function bool IsTraderOpened() {
	local KFTraderTrigger KFTT;
	KFTT = KFGameReplicationInfo(WorldInfo.GRI).OpenedTrader;
	if (KFTT==None) return false;
	return KFTT.bOpened;
}