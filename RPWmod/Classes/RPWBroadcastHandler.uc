class RPWBroadcastHandler extends BroadcastHandler;

var RestrictPW MyRPW;

function InitRPWClass(RestrictPW NewRPW) {
	MyRPW = NewRPW;
}

function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type )
{
	super.BroadcastText(SenderPRI,Receiver,Msg,Type);
	if (MyRPW!=None) {
		MyRPW.Broadcast(SenderPRI,Msg);
	}
}

function BroadcastLocalized( Actor Sender, PlayerController Receiver, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	super.BroadcastLocalized(Sender,Receiver,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

/*
	function SendRestrictMessageStringAll(string Msg) {
		local KFPlayerController KFPC;
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC) {
			KFPC.TeamMessage(KFPC.PlayerReplicationInfo,Msg,'Event');
		}
	}
*/