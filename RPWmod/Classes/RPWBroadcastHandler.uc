class RPWBroadcastHandler extends BroadcastHandler;

var RestrictPW MyRPW;

function InitRPWClass(RestrictPW NewRPW) {
	MyRPW = NewRPW;
}

function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type ) {
	super.BroadcastText(SenderPRI,Receiver,Msg,Type);
	if (MyRPW!=None) {
		if (SenderPRI!=None) {
			if (PlayerController(SenderPRI.Owner)==Receiver) {
				MyRPW.Broadcast(SenderPRI,Msg);
			}
		}
	}
}