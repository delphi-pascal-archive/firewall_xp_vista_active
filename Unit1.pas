// Jean Ressouche 15/04/07
// Démo de manipulation du FireWall XP/Vista
// Sources : MSDN http://msdn2.microsoft.com/en-us/library/aa366415.aspx
// Principalement une adaptation des exemples VB de la MSDN

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, Variants,
  ComObj, ActiveX, ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Button2: TButton;
    StatusBar1: TStatusBar;
    Edit1: TEdit;
    Edit2: TEdit;
    PC: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    LB: TListBox;
    LB1: TListBox;
    LB2: TListBox;
    procedure Edit1Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function CheckIfFirewallActif: Boolean;
    procedure AjouteUpdateException(Nom, Exe: string; Active: Boolean);
    //function VerifierStatus(Exe: string): Boolean;
    function VerifierStatus(Exe: string): Boolean;
    procedure ListerLesExceptionsAuth;
    procedure ListerLesExceptionsDesServices;
    procedure ListerLesExceptionsDesPorts;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  NET_FW_IP_VERSION_V4 = 0;
  NET_FW_IP_VERSION_V6 = 1;
  NET_FW_IP_VERSION_ANY = 2;
  NET_FW_IP_PROTOCOL_UDP = 17;
  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_PROFILE_DOMAIN = 0;
  NET_FW_PROFILE_STANDARD = 1;
  NET_FW_SCOPE_ALL = 0;
  TestApp = 'c:\program files\icq\icq.exe';
  TestAppName = 'icq';

implementation

{$R *.dfm}

function TForm1.CheckIfFirewallActif: Boolean;
var
  FwMgr, Profile: OleVariant;
begin
  try
    FwMgr := CreateOLEObject('HNetCfg.FwMgr');
    Profile := FwMgr.LocalPolicy.CurrentProfile;
    Result := Profile.FirewallEnabled;
    if Result then
      if Profile.NotificationsDisabled then
        StatusBar1.Panels[0].Text := 'Notifications désactivées';
  finally
    Profile := VarNull;
    FwMgr := VarNull;
  end;
end;

{TForm1.VerifierStatus(Exe: string): Boolean;
var
  FwMgr: OleVariant;
  Allowed, Restricted: Boolean;
begin
  try
    Allowed := False;
    Restricted := False;
    FwMgr := CreateOLEObject('HNetCfg.FwMgr');
    FwMgr.IsPortAllowed(Exe, NET_FW_IP_VERSION_V4, 0, '0.0.0.0', NET_FW_IP_PROTOCOL_TCP, Allowed, Restricted);
    // TODO: Je ne pige pas pourquoi ca marche pas... d'apres la msdn ca semble etre bon ..
    if Allowed then begin
      MessageDlg('Allowed!', mtWarning, [mbOK], 0);
      CheckBox1.Checked := True;
    end;
    if Restricted then begin
      MessageDlg('Restricted!', mtWarning, [mbOK], 0);
      CheckBox1.Checked := False;
    end;
    Result := Allowed and not Restricted;
  finally
    FwMgr := VarNull;
  end;
end;}

function TForm1.VerifierStatus(Exe: string): Boolean;
var
  FwMgr, Profile: OleVariant;
  Apps: IEnumVariant;
  Element: OleVariant;
  Fetched: Cardinal;
begin
  try
    Result := False;
    FwMgr := CreateOLEObject('HNetCfg.FwMgr');
    Profile := FwMgr.LocalPolicy.CurrentProfile;
    Apps := IUnKnown(Profile.AuthorizedApplications._NewEnum) as IEnumVariant;
    while (Apps.Next(1, Element, Fetched) = S_OK) do begin
      if UpperCase(Element.ProcessImageFileName) = UpperCase(Exe) then
        if Element.Enabled then begin
          Result := True;
          Break;
        end;
    end;
  finally
    Profile := VarNull;
    FwMgr := VarNull;
  end;
end;

procedure TForm1.AjouteUpdateException(Nom, Exe: string; Active: Boolean);
var
  FwMgr, Profile, App: OleVariant;
begin
  try
    FwMgr := CreateOleObject('HNetCfg.FwMgr');
    Profile := FwMgr.LocalPolicy.CurrentProfile;
    if profile.ExceptionsNotAllowed then begin
      MessageDlg('Exceptions non autorisées ! Impossible donc d''en ajouter une...', mtWarning, [mbOK], 0);
      Exit;
    end;
    App := CreateOleObject('HNetCfg.FwAuthorizedApplication');
    App.Name := Nom;
    App.ProcessImageFileName := Exe;
    App.IpVersion := NET_FW_IP_VERSION_ANY; // IpV4 + IpV6
    App.RemoteAddresses := '*'; // Ok sur toute les adresses
    App.Scope := NET_FW_SCOPE_ALL;  // Portée des adresses
    App.Enabled := Active;
    Profile.AuthorizedApplications.Add(app);
    ListerLesExceptionsAuth; // Refresh de la liste pour visualisation
  finally
    App := VarNull;
    Profile := VarNull;
    FwMgr := VarNull;
  end;
end;

procedure TForm1.ListerLesExceptionsAuth;
var
  FwMgr, Profile: OleVariant;
  Apps: IEnumVariant;
  Element: OleVariant;
  Fetched: Cardinal;
  i: integer;
begin
  LB.Items.Clear;
  try
    FwMgr := CreateOLEObject('HNetCfg.FwMgr');
    Profile := FwMgr.LocalPolicy.CurrentProfile;
    PC.Pages[0].Caption := 'Exceptions Applications: ' + IntToStr(Profile.AuthorizedApplications.Count);
    Apps := IUnKnown(Profile.AuthorizedApplications._NewEnum) as IEnumVariant;
    i := 0;
    while (Apps.Next(1, Element, Fetched) = S_OK) do begin
      inc(i);
      LB.Items.Add(Format('%d = %s [%s] -> %s', [i, Element.name, Element.ProcessImageFileName, ifthen(Element.Enabled, 'Active', 'Inactive')]));
    end;
  finally
    Profile := VarNull;
    FwMgr := VarNull;
    Element := VarNull;
  end;
end;

procedure TForm1.ListerLesExceptionsDesServices;
var
  FwMgr, Profile: OleVariant;
  Svcs: IEnumVariant;
  Element: OleVariant;
  Fetched: Cardinal;
  i: integer;
begin
  LB1.Items.Clear;
  try
    FwMgr := CreateOLEObject('HNetCfg.FwMgr');
    Profile := FwMgr.LocalPolicy.CurrentProfile;
    PC.Pages[1].Caption := 'Exceptions Services: ' + IntToStr(Profile.Services.Count);
    Svcs := IUnKnown(Profile.Services._NewEnum) as IEnumVariant;
    i := 0;
    while (Svcs.Next(1, Element, Fetched) = S_OK) do begin
      inc(i);
      LB1.Items.Add(Format('%d = %s -> %s', [i, Element.name, ifthen(Element.Enabled, 'Active', 'Inactive')]));
    end;
  finally
    Profile := VarNull;
    FwMgr := VarNull;
    Element := VarNull;
  end;
end;

procedure TForm1.ListerLesExceptionsDesPorts;
var
  FwMgr, Profile: OleVariant;
  Svcs: IEnumVariant;
  Element: OleVariant;
  Fetched: Cardinal;
  i: integer;
begin
  LB2.Items.Clear;
  try
    FwMgr := CreateOLEObject('HNetCfg.FwMgr');
    Profile := FwMgr.LocalPolicy.CurrentProfile;
    PC.Pages[2].Caption := 'Exceptions Ports: ' + IntToStr(Profile.GloballyOpenPorts.Count);
    Svcs := IUnKnown(Profile.GloballyOpenPorts._NewEnum) as IEnumVariant;
    i := 0;
    while (Svcs.Next(1, Element, Fetched) = S_OK) do begin
      inc(i);
      LB2.Items.Add(Format('%d = %d (%s) -> %s', [i, Element.Port, Element.name, ifthen(Element.Enabled, 'Active', 'Inactive')]));
    end;
  finally
    Profile := VarNull;
    FwMgr := VarNull;
    Element := VarNull;
  end;
end;

// -----------------------------------------------------------------------------

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := TestAppName;
  Edit2.Text := TestApp;
  Button1.Caption := 'Add/Update rule ' + Edit1.Text;
  if CheckIfFirewallActif then begin
    Caption := 'FireWall XP/Vista Active';
    CheckBox1.Checked := VerifierStatus(Edit2.Text);
    ListerLesExceptionsAuth;
    ListerLesExceptionsDesServices;
    ListerLesExceptionsDesPorts;
  end else begin
    Caption := 'FireWall XP/Vista Inactive';
    PC.Enabled := False;
    Button1.Enabled := False;
    Button2.Enabled := False;
    CheckBox1.Enabled := False;
    Edit1.Enabled := False;
    Edit2.Enabled := False;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  AjouteUpdateException(Edit1.Text, Edit2.Text, CheckBox1.Checked);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  CheckBox1.Checked := VerifierStatus(Edit2.Text);
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  Button1.Caption := 'Add/Update rule ' + Edit1.Text;
end;

end.

