class RPWBroadcastHandler extends BroadcastHandler;

var RestrictPW MyRPW;

function InitRPWClass(RestrictPW NewRPW) {
	MyRPW = NewRPW;
}

function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type ) {
	if (MyRPW!=None) {
		if (SenderPRI!=None) {
			if (PlayerController(SenderPRI.Owner)==Receiver) {
				MyRPW.Broadcast(SenderPRI,Msg);
			}
		}
	}
	//特殊なメッセージはチャットに表示しない
		if (MyRPW.StopBroadcast(Msg)) return;
	//通常メッセージ内容は表示される
		super.BroadcastText(SenderPRI,Receiver,Msg,Type);
	//
}