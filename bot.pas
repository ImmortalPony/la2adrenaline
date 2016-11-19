unit Quest;

interface

type
	TNPC = class
	private
		FName : string;
		FLocation : TPoint;
		type
			TAnswer
	public
		procedure Talk( Answer : TAnswer );
		
		property Name : read FName ;
		procedure 
	end;
	
	TAccount = class
	
	
	TQuest = class
	private
		FDone : Boolean;
		FName : string;
		procedure MoveToNPC( NPC : TNPC );
		procedure TalkToNPC( NPC : TNPC, Answer : TAnswer );
	public
		property Name : read FName ;
		function IsDone : Boolean;
		procedure Reset;
		procedure Complete; virtual; abstract;
		constructor Create;
	end;
	
	THumanStart = class(TQuest)
	private
		type
			TStage = (
				Done,
				NearNPC1,
				Moving1,
				DiamondHunt,
				Moving2,
				NearNPC2
			);
		function GetStage : TQuestStage;
	public
		constructor Create;
		procedure Complete; override;
	end;

implementation

procedure TQuest.Reset;
begin
	FDone := false;
end;

function TQuest.IsDone : Boolean;
begin
	Result := FDone;
end;



function GetStage : TQuestStage;
begin
	if QuestStatus = Done
		Result := Done;
	if QuestStatus = Stage2
		if NearNPC('NPCName');
			Result := NpcTalked1;
		else
			Result := Move1;
	if QuestStatus = Stage3
		if QuestItem 
			if NearNPC('NPCName2');
				Result := NearNPC2;
			else
				Result := MoveToNPC2;
		else
			if OnSpot('Gremlins')'
				Result := DiamondHunt; 
			else
				Result := MoveToGremlins; 
end;	

procedure Complete;
begin
	case Stage of
		Done:
		Stages['Moving to the tutor...']:
			User.MoveTo( Base.NPCs['Tutor'].Location );
		Stages['Getting quest...']:
			User.DialogWith( Base.NPCs['Tutor'].Dialogs['get right name'] );
		Stages['Move to the spot...']:
			User.MoveTo( Base.Spots['Gremlins'].Location );
		Stages['Hunting for diamond...']:
			User.Hunt( Base.Spots['Gremlins'] );
		Stages['Giving diamond to the tutor...']:
			User.DialogWith( Base.NPCs['Tutor'].Dialogs['give diamond'] );
	else Print('QuestHumanStart Error');
  end;
end;

end.