unit TimeTrackApi.AuthenticationImpl;

interface

uses
  MVCFramework,
  System.Generics.Collections;

type
  TAuthenticationImpl = class(TInterfacedObject, IMVCAuthenticationHandler)
  public
    procedure OnRequest(const AContext: TWebContext;
      const AControllerQualifiedClassName: string; const AActionName: string;
      var AAuthenticationRequired: Boolean);
    procedure OnAuthentication(const AContext: TWebContext;
      const AUserName: string; const APassword: string;
      AUserRoles: TList<String>;
      var AIsValid: Boolean;
      const ASessionData: TDictionary<string, string>);
    procedure OnAuthorization(const AContext: TWebContext;
      AUserRoles: TList<string>;
      const AControllerQualifiedClassName: string; const AActionName: string;
      var AIsAuthorized: Boolean);
  end;

implementation

uses
  System.StrUtils, System.SysUtils,  TimeTrackApi.DataModule, TimeTrackApi.Model.Entities;

{ AuthenticationImpl }

procedure TAuthenticationImpl.OnAuthentication(const AContext: TWebContext;
  const AUserName, APassword: string; AUserRoles: TList<string>;
  var AIsValid: Boolean;
  const ASessionData: TDictionary<String, String>);
var
  userId: Integer;
  userData: TLoginUser;
begin
// Benutzer authentifizieren
  userId := TdmDataAccess.DBGetUserId(AUserName, APassword);

  if userId > 0 then
  begin
    // Vollständige Benutzerdaten laden für Validierungen
    userData := TdmDataAccess.DBGetUserData(userId);

    // Prüfen ob Benutzer aktiviert und aktiv ist
    if userData.Is_Confirmed and userData.Is_Active then
    begin
      // Rollen setzen
      AUserRoles.Add('registereduser');

      // Custom Claims für JWT-Token setzen
      // Diese werden automatisch in den Token eingebaut
      ASessionData.Add('userid', userId.ToString);
      ASessionData.Add('first_name', IfThen(Trim(userData.First_Name)='',ausername,userData.First_Name));
      { TODO -oALL -cErgänzungen : weitere Daten einbauen, die am User hängen und in den Claims gesendet werden sollen }

      // Last Login aktualisieren
      try
        TdmDataAccess.DBUpdateLastLogin(userId);
      except
        // Fehler beim Last-Login-Update ignorieren
      end;

      AIsValid := True;
    end
    else
    begin
      // Benutzer existiert, aber ist nicht aktiviert oder deaktiviert
      AIsValid := False;
    end;
  end
  else
  begin
    // Ungültige Anmeldedaten
    AIsValid := False;
  end;
end;

procedure TAuthenticationImpl.OnAuthorization(const AContext: TWebContext;
  AUserRoles: System.Generics.Collections.TList<String>;
  const AControllerQualifiedClassName, AActionName: string;
  var AIsAuthorized: Boolean);
begin
  AIsAuthorized := AUserRoles.Contains('registereduser');
  
end;

procedure TAuthenticationImpl.OnRequest(const AContext: TWebContext;
  const AControllerQualifiedClassName, AActionName: string;
  var AAuthenticationRequired: Boolean);
begin
  // authenticationRequired ist über Attribute vorbelegt
  if AControllerQualifiedClassName.Contains('TAuthController') then
    AAuthenticationRequired := false
  //else
  //  AAuthenticationRequired := true;
end;

end.


