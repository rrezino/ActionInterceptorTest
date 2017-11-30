unit uCblActionObserver;

interface

uses
  Vcl.ActnList;

type
  IActionObserver = interface
    procedure OnBeforeExecute(const Sender: TAction);
    procedure OnAfterExecute(const Sender: TAction);
  end;

  procedure RegisterGlobalActionObserver(Observer: IActionObserver);
  procedure UnregisterGlobalActionObserver(Observer: IActionObserver);

implementation

uses
  Spring,
  Spring.Collections,

  Vcl.Controls,
  Vcl.Forms,

  Winapi.Windows;

type
  TGlobalActionObservable = class(TObject)
  private
    var FObservers: IList<IActionObserver>;
  protected
    procedure NotifyBeforeExecute(Sender: TAction);
    procedure NotifyAfterExecute(Sender: TAction);
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterObserver(Observer: IActionObserver);
    procedure UnregisterObserver(Observer: IActionObserver);
  end;

  TCblActionObserver = class(TAction)
  private
    function ExecuteEvent: Boolean;
  public
    function ExecuteObservable: Boolean;
  end;

  PJump = ^TJump;

  TJump = packed record
    OpCode: Byte;
    Distance: Pointer;
  end;

var
  ActionObservable: TGlobalActionObservable;

procedure RegisterGlobalActionObserver(Observer: IActionObserver);
begin
  if ActionObservable = nil then
    ActionObservable := TGlobalActionObservable.Create;

  ActionObservable.RegisterObserver(Observer);
end;

procedure UnregisterGlobalActionObserver(Observer: IActionObserver);
begin
  if ActionObservable = nil then
    ActionObservable := TGlobalActionObservable.Create;

  ActionObservable.UnregisterObserver(Observer);
end;

function GetMethodAddress(AStub: Pointer): Pointer;
const
  CALL_OPCODE = $E8;
begin
  if PBYTE(AStub)^ = CALL_OPCODE then
  begin
    Inc(Integer(AStub));
    Result := Pointer(Integer(AStub) + SizeOf(Pointer) + PInteger(AStub)^);
  end
  else
    Result := nil;
end;

procedure AddressPatch(const ASource, ADestination: Pointer);
const
  JMP_OPCODE = $E9;
  SIZE = SizeOf(TJump);
var
  NewJump: PJump;
  OldProtect: Cardinal;
begin
  if VirtualProtect(ASource, SIZE, PAGE_EXECUTE_READWRITE, OldProtect) then
  begin
    NewJump := PJump(ASource);
    NewJump.OpCode := JMP_OPCODE;
    NewJump.Distance := Pointer(Integer(ADestination) - Integer(ASource) - 5);

    FlushInstructionCache(GetCurrentProcess, ASource, SizeOf(TJump));
    VirtualProtect(ASource, SIZE, OldProtect, @OldProtect);
  end;
end;

function PatchCodeDWORD(ACode: PDWORD; AValue: DWORD): Boolean;
var
  LRestoreProtection, LIgnore: DWORD;
begin
  Result := False;
  if VirtualProtect(ACode, SizeOf(ACode^), PAGE_EXECUTE_READWRITE, LRestoreProtection) then
  begin
    Result := True;
    ACode^ := AValue;
    Result := VirtualProtect(ACode, SizeOf(ACode^), LRestoreProtection, LIgnore);

    if not Result then
      Exit;

    Result := FlushInstructionCache(GetCurrentProcess, ACode, SizeOf(ACode^));
  end;
end;

procedure DefaultCustomActionExecute;
asm
  call TAction.Execute;
end;

{ TCblActionObserver }

function TCblActionObserver.ExecuteEvent: Boolean;
begin
  if Assigned(OnExecute) then
  begin
    OnExecute(Self);
    Result := True;
  end
  else
    Result := False;
end;

function TCblActionObserver.ExecuteObservable: Boolean;
begin
  if Assigned(ActionObservable) then
    ActionObservable.NotifyBeforeExecute(Self);

  Result := False;
  if Suspended then
    Exit;
  Update;
  if Enabled and AutoCheck then
    if not Checked or Checked and (GroupIndex = 0) then
      Checked := not Checked;
  Result := Enabled;
  if Result then
  begin
    Result := ((ActionList <> nil) and ActionList.ExecuteAction(Self)) or (Application.ExecuteAction(Self)) or
      (ExecuteEvent) or (SendAppMessage(CM_ACTIONEXECUTE, 0, LPARAM(Self)) = 1);
  end;

  if Assigned(ActionObservable) then
    ActionObservable.NotifyAfterExecute(Self);
end;

{ TGlobalActionObservable }

constructor TGlobalActionObservable.Create;
begin
  inherited Create;
  ActionObservable := Self;
  FObservers := Spring.Collections.TCollections.CreateList<IActionObserver>();
end;

destructor TGlobalActionObservable.Destroy;
begin
  if ActionObservable = Self then
    ActionObservable := nil;

  inherited;
end;

procedure TGlobalActionObservable.NotifyAfterExecute(Sender: TAction);
begin
  FObservers.ForEach(
    procedure (const Observer: IActionObserver)
    begin
      Observer.OnAfterExecute(Sender);
    end);
end;

procedure TGlobalActionObservable.NotifyBeforeExecute(Sender: TAction);
begin
  FObservers.ForEach(
    procedure (const Observer: IActionObserver)
    begin
      Observer.OnBeforeExecute(Sender);
    end);
end;

procedure TGlobalActionObservable.RegisterObserver(Observer: IActionObserver);
begin
  FObservers.Add(Observer);
end;

procedure TGlobalActionObservable.UnregisterObserver(Observer: IActionObserver);
begin
  FObservers.Remove(Observer);
end;

initialization
  AddressPatch(GetMethodAddress(@DefaultCustomActionExecute), @TCblActionObserver.ExecuteObservable);

end.
