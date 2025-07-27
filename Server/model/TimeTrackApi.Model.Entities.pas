unit TimeTrackApi.Model.Entities;

interface

uses
  System.Generics.Collections;

type
  /// <summary>internen Record mit Benutzerdaten</summary>
  TUserData =  record
   LastName: string;
   Email: string;
   Password: string;
   Address: string;
   FirstName: string;
   Username: string;
  end;

  /// <summary>Record für vollständige Benutzerdaten aus der Datenbank</summary>
  TLoginUser = record
    User_ID: Integer;
    Username: string;
    Email: string;
    Password: string;
    First_Name: string;
    Last_Name: string;
    Address: string;
    Is_Confirmed: Boolean;
    Confirmation_Token: string;
    Created_At: TDateTime;
    Last_Login: TDateTime;
    Is_Active: Boolean;
  end;

  /// <summary>Record für Projekt-Daten aus der Datenbank</summary>
  TProject = record
    Project_ID: Integer;
    User_ID: Integer;
    Project_Name: string;
    Client_Name: string;
    Description: string;
    Created_At: TDateTime;
    Is_Active: Boolean;
    procedure Clear;
    function IsValid: Boolean;
  end;

  /// <summary>Record für Time-Entry-Daten aus der Datenbank</summary>
  TTimeEntry = record
    Entry_ID: Integer;
    User_ID: Integer;
    Project_ID: Integer;
    Activity: string;
    Start_Time: TDateTime;
    End_Time: TDateTime;
    Pause_Minutes: Integer;
    Created_At: TDateTime;

    procedure Clear;
    function IsValid: Boolean;
    function IsActive: Boolean;
    function GetDurationMinutes: Integer;
    function GetNetDurationMinutes: Integer; // Ohne Pausen
  end;

  /// <summary>Array von Projekten</summary>
  TProjectArray = TArray<TProject>;

  /// <summary>Array von Time-Entries</summary>
  TTimeEntryArray = TArray<TTimeEntry>;

implementation

uses
  System.SysUtils;

{ TProject }

procedure TProject.Clear;
begin
  Project_ID := 0;
  User_ID := 0;
  Project_Name := '';
  Client_Name := '';
  Description := '';
  Created_At := 0;
  Is_Active := False;
end;

function TProject.IsValid: Boolean;
begin
  Result := (Trim(Project_Name) <> '') and
            (Trim(Client_Name) <> '') and
            (User_ID > 0);
end;

{ TTimeEntry }

procedure TTimeEntry.Clear;
begin
  Entry_ID := 0;
  User_ID := 0;
  Project_ID := 0;
  Activity := '';
  Start_Time := 0;
  End_Time := 0;
  Pause_Minutes := 0;
  Created_At := 0;
end;

function TTimeEntry.IsValid: Boolean;
begin
  Result := (User_ID > 0) and
            (Project_ID > 0) and
            (Trim(Activity) <> '') and
            (Start_Time > 0);
end;

function TTimeEntry.IsActive: Boolean;
begin
  Result := (Start_Time > 0) and (End_Time = 0);
end;

function TTimeEntry.GetDurationMinutes: Integer;
var
  EndTime: TDateTime;
begin
  if End_Time > 0 then
    EndTime := End_Time
  else
    EndTime := Now;

  Result := Round((EndTime - Start_Time) * 24 * 60);
end;

function TTimeEntry.GetNetDurationMinutes: Integer;
begin
  Result := GetDurationMinutes - Pause_Minutes;
  if Result < 0 then
    Result := 0;
end;

end.
