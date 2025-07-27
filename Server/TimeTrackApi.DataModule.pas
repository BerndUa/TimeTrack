unit TimeTrackApi.DataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, TimeTrackApi.Model.Entities;

type
  TdmDataAccess = class(TDataModule)
    DesignTimetrackConnection: TFDConnection;
    TimetrackConnection: TFDConnection;
    CommonQuery: TFDQuery;
    FDQuery2: TFDQuery;
  private
    procedure SetupFirebirdConnection;
    function InsertUser(const newUser: TUserData): string;
    procedure ActivateUser(UserName:string; ActivationCode: string);
    function GetUserId(const Username, Password :string): integer;
    function GetUserData(UserId: Integer): TLoginUser;
    procedure UpdateLastLogin(UserId: Integer);
    // Projekt-Methoden
    function InsertProject(const AProject: TProject): Integer;
    function GetUserProjects(UserId: Integer): TProjectArray;
    function GetProject(ProjectId, UserId: Integer): TProject;
    function UpdateProject(const AProject: TProject): Boolean;
    function DeleteProject(ProjectId, UserId: Integer): Boolean;

    // Time-Entry-Methoden
    function StartTimeEntry(const ATimeEntry: TTimeEntry): Integer;
    function GetActiveTimeEntry(UserId: Integer): TTimeEntry;
    function StopTimeEntry(EntryId, UserId: Integer): Boolean;
    function AddPauseToTimeEntry(EntryId, UserId: Integer; PauseMinutes: Integer): Boolean;
    function GetTimeEntry(EntryId, UserId: Integer): TTimeEntry;

    function GetTimeEntriesForPeriod(UserId: Integer; StartDate, EndDate: TDateTime; ProjectId: Integer = 0): TTimeEntryArray;
    function UpdateTimeEntry(const ATimeEntry: TTimeEntry): Boolean;

    function UpdateUserProfile(const AUser: TLoginUser): Boolean;
    function ChangeUserPassword(UserId: Integer; const CurrentPassword, NewPassword: string): Boolean;
    function DeleteUserAccount(UserId: Integer; const Password: string): Boolean;
    function DeactivateUserAccount(UserId: Integer): Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    class function DBGetUserId(const Username, Password :string): integer;

    class function DbInsertUser(const newUser: TUserData): string;
    class procedure DbActivateUser(UserName:string; ActivationCode: string);
    class function DBGetUserData(UserId: Integer): TLoginUser;
    class procedure DBUpdateLastLogin(UserId: Integer);
    // Projekt CRUD-Operationen
    class function DBInsertProject(const AProject: TProject): Integer;
    class function DBGetUserProjects(UserId: Integer): TProjectArray;
    class function DBGetProject(ProjectId, UserId: Integer): TProject;
    class function DBUpdateProject(const AProject: TProject): Boolean;
    class function DBDeleteProject(ProjectId, UserId: Integer): Boolean;

    // Time-Entry-Operationen
    class function DBStartTimeEntry(const ATimeEntry: TTimeEntry): Integer;
    class function DBGetActiveTimeEntry(UserId: Integer): TTimeEntry;
    class function DBStopTimeEntry(EntryId, UserId: Integer): Boolean;
    class function DBAddPauseToTimeEntry(EntryId, UserId: Integer; PauseMinutes: Integer): Boolean;
    class function DBGetTimeEntry(EntryId, UserId: Integer): TTimeEntry;

    class function DBGetTimeEntriesForPeriod(UserId: Integer; StartDate, EndDate: TDateTime; ProjectId: Integer = 0): TTimeEntryArray;
    class function DBUpdateTimeEntry(const ATimeEntry: TTimeEntry): Boolean;

    class function DBUpdateUserProfile(const AUser: TLoginUser): Boolean;
    class function DBChangeUserPassword(UserId: Integer; const CurrentPassword, NewPassword: string): Boolean;
    class function DBDeleteUserAccount(UserId: Integer; const Password: string): Boolean;
    class function DBDeactivateUserAccount(UserId: Integer): Boolean;
  end;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  MVCFramework.Commons, TimeTrackApi.PasswordUtils;


constructor TdmDataAccess.Create(AOwner: TComponent);
begin
  inherited;
  SetupFirebirdConnection;
end;


class procedure TdmDataAccess.DbActivateUser(UserName, ActivationCode: string);
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    dm.ActivateUser(Username, ActivationCode);
  finally
    dm.Free;
  end;
end;

procedure TdmDataAccess.ActivateUser(UserName, ActivationCode: string);
var
  lsql : string;
begin
  lsql := 'Update users SET IS_CONFIRMED=''Y'' '+
          'WHERE (CONFIRMATION_TOKEN=:token) AND (USERNAME = :username)';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('username').AsString := Username;
    CommonQuery.ParamByName('token').AsString := ActivationCode;
    CommonQuery.Execute;

  finally
    CommonQuery.Close;
  end;
end;

class function TdmDataAccess.DbInsertUser(const newUser: TUserData): string;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    result := dm.InsertUser(newUser);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DbGetUserId(const Username,
  Password: string): Integer;
begin
  var dm := TdmDataAccess.Create(nil);
  try
    result := dm.GetUserId(Username, Password);
  finally
    dm.Free;
  end;
end;

function TdmDataAccess.InsertUser(const newUser: TUserData): string;
var
  lsql : string;
  ltoken : string;
  lhash: string;
begin
  ltoken := TGuid.NewGuid.ToString;
  lhash := TPasswordUtils.CreatePasswordHash(newUser.Password);

  lSQL := 'INSERT INTO users (USERNAME, EMAIL, FIRST_NAME, LAST_NAME, ADDRESS, IS_CONFIRMED, PASSWORD_HASH, CONFIRMATION_TOKEN) ' +
            'VALUES (:username, :email, :firstname, :lastname, :address, '+ QuotedStr('N')+ ', :hash, :token)';
  try
    try
      CommonQuery.SQL.Text := lSQL;
      CommonQuery.ParamByName('username').AsString := newUser.Username;
      CommonQuery.ParamByName('email').AsString := newUser.Email;
      CommonQuery.ParamByName('firstname').AsString := newUser.FirstName;
      CommonQuery.ParamByName('lastname').AsString := newUser.LastName;
      CommonQuery.ParamByName('address').AsString := newUser.Address;
      CommonQuery.ParamByName('hash').AsString := lhash;
      CommonQuery.ParamByName('token').AsString := ltoken;
      CommonQuery.Execute;
      Result := ltoken;
    finally
      CommonQuery.Close;
    end;
  except
    { TODO -oALL -cVervollständigung : Verletzung PK prüfen und mit spezieller Exception doppelten User zurückmelden }
    raise
  end;
end;

procedure TdmDataAccess.SetupFirebirdConnection();
begin
  TimetrackConnection.Params.Clear;
  TimetrackConnection.Params.Add('DriverId=FB');
  TimetrackConnection.Params.Add('Protocol=TCPIP');
  TimetrackConnection.Params.Add('Database=' + dotEnv.Env('DBPath'));
  TimetrackConnection.Params.Add('Server=' + dotEnv.Env('DBServer'));
  TimetrackConnection.Params.Add('Port=' + dotEnv.Env('DBPort'));
  TimetrackConnection.Params.Add('User_Name=' + dotEnv.Env('DBUser'));
  TimetrackConnection.Params.Add('Password=' + dotEnv.Env('DBPassword'));
  TimetrackConnection.Params.Add('CharacterSet=UTF8');
  TimetrackConnection.Params.Add('Pooled=False');
end;


function TdmDataAccess.GetUserId(const Username,Password: string): Integer;
var
  lsql : string;
begin
  Result := 0;
  lSQL := 'Select USER_ID, PASSWORD_HASH from USERS ' +
          'Where IS_CONFIRMED=''Y''And USERNAME=:username';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('username').AsString := Username;
    CommonQuery.Open();
    if not CommonQuery.Eof then
    begin
      var dbHash : string := CommonQuery.Fields[1].AsString;
      if (dbHash<>'') and TPasswordUtils.VerifyPassword(Password,dbHash) then
      begin
        Result := CommonQuery.Fields[0].AsInteger;
      end;
    end;
  finally
    CommonQuery.Close;
  end;
end;


function TdmDataAccess.GetUserData(UserId: Integer): TLoginUser;
var
  lSQL: string;
begin
  // Record initialisieren
  Result := Default(TLoginUser);
  Result.User_ID := 0;

  lSQL := 'SELECT USER_ID, USERNAME, EMAIL, FIRST_NAME, LAST_NAME, ADDRESS, ' +
          'IS_CONFIRMED, CONFIRMATION_TOKEN, CREATED_AT, LAST_LOGIN, IS_ACTIVE ' +
          'FROM USERS WHERE USER_ID = :userid';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('userid').AsInteger := UserId;
    CommonQuery.Open();

    if not CommonQuery.Eof then
    begin
      Result.User_ID := CommonQuery.FieldByName('USER_ID').AsInteger;
      Result.Username := CommonQuery.FieldByName('USERNAME').AsString;
      Result.Email := CommonQuery.FieldByName('EMAIL').AsString;
      Result.First_Name := CommonQuery.FieldByName('FIRST_NAME').AsString;
      Result.Last_Name := CommonQuery.FieldByName('LAST_NAME').AsString;
      Result.Address := CommonQuery.FieldByName('ADDRESS').AsString;
      Result.Is_Confirmed := CommonQuery.FieldByName('IS_CONFIRMED').AsString = 'Y';
      Result.Confirmation_Token := CommonQuery.FieldByName('CONFIRMATION_TOKEN').AsString;
      Result.Created_At := CommonQuery.FieldByName('CREATED_AT').AsDateTime;

      if not CommonQuery.FieldByName('LAST_LOGIN').IsNull then
        Result.Last_Login := CommonQuery.FieldByName('LAST_LOGIN').AsDateTime;

      Result.Is_Active := CommonQuery.FieldByName('IS_ACTIVE').AsString = 'Y';
    end;
  finally
    CommonQuery.Close;
  end;
end;
procedure TdmDataAccess.UpdateLastLogin(UserId: Integer);
var
  lSQL: string;
begin
  lSQL := 'UPDATE USERS SET LAST_LOGIN = CURRENT_TIMESTAMP WHERE USER_ID = :userid';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('userid').AsInteger := UserId;
    CommonQuery.Execute;
  finally
    CommonQuery.Close;
  end;
end;


class function TdmDataAccess.DBGetUserData(UserId: Integer): TLoginUser;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.GetUserData(UserId);
  finally
    dm.Free;
  end;
end;

class procedure TdmDataAccess.DBUpdateLastLogin(UserId: Integer);
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    dm.UpdateLastLogin(UserId);
  finally
    dm.Free;
  end;
end;

function TdmDataAccess.InsertProject(const AProject: TProject): Integer;
var
  lSQL: string;
begin
  Result := 0;
  lSQL := 'INSERT INTO PROJECTS (PROJECT_NAME, CLIENT_NAME, DESCRIPTION, CREATED_BY_USER_ID, IS_ACTIVE) ' +
          'VALUES (:project_name, :client_name, :description, :user_id, ''Y'') ' +
          'RETURNING PROJECT_ID';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := AProject.User_ID;
    CommonQuery.ParamByName('project_name').AsString := AProject.Project_Name;
    CommonQuery.ParamByName('client_name').AsString := AProject.Client_Name;
    CommonQuery.ParamByName('description').AsString := AProject.Description;
    CommonQuery.Open;

    if not CommonQuery.Eof then
      Result := CommonQuery.FieldByName('PROJECT_ID').AsInteger;
  finally
    CommonQuery.Close;
  end;
end;


function TdmDataAccess.GetUserProjects(UserId: Integer): TProjectArray;
var
  lSQL: string;
  position: Integer;
begin
  lSQL := 'SELECT PROJECT_ID, PROJECT_NAME, CLIENT_NAME, DESCRIPTION, ' +
          'CREATED_BY_USER_ID, CREATED_AT, IS_ACTIVE FROM PROJECTS ' +
          'WHERE CREATED_BY_USER_ID = :user_id AND IS_ACTIVE = ''Y'' ' +
          'ORDER BY PROJECT_NAME';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Open;
    SetLength(Result, CommonQuery.RecordCount);
    position:= 0;
    while not CommonQuery.Eof do
    begin
      Result[position].Project_ID := CommonQuery.FieldByName('PROJECT_ID').AsInteger;
      Result[position].User_ID := CommonQuery.FieldByName('CREATED_BY_USER_ID').AsInteger;
      Result[position].Project_Name := CommonQuery.FieldByName('PROJECT_NAME').AsString;
      Result[position].Client_Name := CommonQuery.FieldByName('CLIENT_NAME').AsString;
      Result[position].Description := CommonQuery.FieldByName('DESCRIPTION').AsString;
      Result[position].Created_At := CommonQuery.FieldByName('CREATED_AT').AsDateTime;
      Result[position].Is_Active := CommonQuery.FieldByName('IS_ACTIVE').AsString = 'Y';
      Inc(position);
      CommonQuery.Next;
    end;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.GetProject(ProjectId, UserId: Integer): TProject;
var
  lSQL: string;
begin
  Result.Clear;
  lSQL := 'SELECT PROJECT_ID, PROJECT_NAME, CLIENT_NAME, DESCRIPTION, ' +
          'CREATED_BY_USER_ID, CREATED_AT, IS_ACTIVE FROM PROJECTS ' +
          'WHERE PROJECT_ID = :project_id AND CREATED_BY_USER_ID = :user_id';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('project_id').AsInteger := ProjectId;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Open;

    if not CommonQuery.Eof then
    begin
      Result.Project_ID := CommonQuery.FieldByName('PROJECT_ID').AsInteger;
      Result.User_ID := CommonQuery.FieldByName('CREATED_BY_USER_ID').AsInteger;
      Result.Project_Name := CommonQuery.FieldByName('PROJECT_NAME').AsString;
      Result.Client_Name := CommonQuery.FieldByName('CLIENT_NAME').AsString;
      Result.Description := CommonQuery.FieldByName('DESCRIPTION').AsString;
      Result.Created_At := CommonQuery.FieldByName('CREATED_AT').AsDateTime;
      Result.Is_Active := CommonQuery.FieldByName('IS_ACTIVE').AsString = 'Y';
    end;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.UpdateProject(const AProject: TProject): Boolean;
var
  lSQL: string;
begin
  lSQL := 'UPDATE PROJECTS SET PROJECT_NAME = :project_name, ' +
          'CLIENT_NAME = :client_name, DESCRIPTION = :description ' +
          'WHERE PROJECT_ID = :project_id AND CREATED_BY_USER_ID = :user_id';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('project_name').AsString := AProject.Project_Name;
    CommonQuery.ParamByName('client_name').AsString := AProject.Client_Name;
    CommonQuery.ParamByName('description').AsString := AProject.Description;
    CommonQuery.ParamByName('project_id').AsInteger := AProject.Project_ID;
    CommonQuery.ParamByName('user_id').AsInteger := AProject.User_ID;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.DeleteProject(ProjectId, UserId: Integer): Boolean;
var
  lSQL: string;
begin
  lSQL := 'UPDATE PROJECTS SET IS_ACTIVE = ''N'' ' +
          'WHERE PROJECT_ID = :project_id AND CREATED_BY_USER_ID = :user_id';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('project_id').AsInteger := ProjectId;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.StartTimeEntry(const ATimeEntry: TTimeEntry): Integer;
var
  lSQL: string;
begin
  Result := 0;
  lSQL := 'INSERT INTO TIME_ENTRIES (USER_ID, PROJECT_ID, ACTIVITY_DESCRIPTION, START_TIME, PAUSE_MINUTES) ' +
          'VALUES (:user_id, :project_id, :activity, :start_time, 0) ' +
          'RETURNING ENTRY_ID';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := ATimeEntry.User_ID;
    CommonQuery.ParamByName('project_id').AsInteger := ATimeEntry.Project_ID;
    CommonQuery.ParamByName('activity').AsString := ATimeEntry.Activity;
    CommonQuery.ParamByName('start_time').AsDateTime := ATimeEntry.Start_Time;
    CommonQuery.Open;

    if not CommonQuery.Eof then
      Result := CommonQuery.FieldByName('ENTRY_ID').AsInteger;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.GetActiveTimeEntry(UserId: Integer): TTimeEntry;
var
  lSQL: string;
begin
  Result.Clear;

  lSQL := 'SELECT ENTRY_ID, USER_ID, PROJECT_ID, ACTIVITY_DESCRIPTION, START_TIME, ' +
          'END_TIME, PAUSE_MINUTES, CREATED_AT FROM TIME_ENTRIES ' +
          'WHERE USER_ID = :user_id AND END_TIME IS NULL ' +
          'ORDER BY START_TIME DESC FIRST 1';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Open;

    if not CommonQuery.Eof then
    begin
      Result.Entry_ID := CommonQuery.FieldByName('ENTRY_ID').AsInteger;
      Result.User_ID := CommonQuery.FieldByName('USER_ID').AsInteger;
      Result.Project_ID := CommonQuery.FieldByName('PROJECT_ID').AsInteger;
      Result.Activity := CommonQuery.FieldByName('ACTIVITY_DESCRIPTION').AsString;
      Result.Start_Time := CommonQuery.FieldByName('START_TIME').AsDateTime;

      if not CommonQuery.FieldByName('END_TIME').IsNull then
        Result.End_Time := CommonQuery.FieldByName('END_TIME').AsDateTime;

      Result.Pause_Minutes := CommonQuery.FieldByName('PAUSE_MINUTES').AsInteger;
      Result.Created_At := CommonQuery.FieldByName('CREATED_AT').AsDateTime;
    end;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.StopTimeEntry(EntryId, UserId: Integer): Boolean;
var
  lSQL: string;
begin
  lSQL := 'UPDATE TIME_ENTRIES SET END_TIME = CURRENT_TIMESTAMP ' +
          'WHERE ENTRY_ID = :entry_id AND USER_ID = :user_id AND END_TIME IS NULL';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('entry_id').AsInteger := EntryId;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.AddPauseToTimeEntry(EntryId, UserId: Integer; PauseMinutes: Integer): Boolean;
var
  lSQL: string;
begin
  lSQL := 'UPDATE TIME_ENTRIES SET PAUSE_MINUTES = PAUSE_MINUTES + :pause_minutes ' +
          'WHERE ENTRY_ID = :entry_id AND USER_ID = :user_id';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('pause_minutes').AsInteger := PauseMinutes;
    CommonQuery.ParamByName('entry_id').AsInteger := EntryId;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.GetTimeEntry(EntryId, UserId: Integer): TTimeEntry;
var
  lSQL: string;
begin
  Result.Clear;

  lSQL := 'SELECT ENTRY_ID, USER_ID, PROJECT_ID, ACTIVITY_DESCRIPTION, START_TIME, ' +
          'END_TIME, PAUSE_MINUTES, CREATED_AT FROM TIME_ENTRIES ' +
          'WHERE ENTRY_ID = :entry_id AND USER_ID = :user_id';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('entry_id').AsInteger := EntryId;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Open;

    if not CommonQuery.Eof then
    begin
      Result.Entry_ID := CommonQuery.FieldByName('ENTRY_ID').AsInteger;
      Result.User_ID := CommonQuery.FieldByName('USER_ID').AsInteger;
      Result.Project_ID := CommonQuery.FieldByName('PROJECT_ID').AsInteger;
      Result.Activity := CommonQuery.FieldByName('ACTIVITY_DESCRIPTION').AsString;
      Result.Start_Time := CommonQuery.FieldByName('START_TIME').AsDateTime;

      if not CommonQuery.FieldByName('END_TIME').IsNull then
        Result.End_Time := CommonQuery.FieldByName('END_TIME').AsDateTime;

      Result.Pause_Minutes := CommonQuery.FieldByName('PAUSE_MINUTES').AsInteger;
      Result.Created_At := CommonQuery.FieldByName('CREATED_AT').AsDateTime;
    end;
  finally
    CommonQuery.Close;
  end;
end;

class function TdmDataAccess.DBInsertProject(const AProject: TProject): Integer;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.InsertProject(AProject);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBGetUserProjects(UserId: Integer): TProjectArray;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.GetUserProjects(UserId);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBGetProject(ProjectId, UserId: Integer): TProject;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.GetProject(ProjectId, UserId);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBUpdateProject(const AProject: TProject): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.UpdateProject(AProject);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBDeleteProject(ProjectId, UserId: Integer): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.DeleteProject(ProjectId, UserId);
  finally
    dm.Free;
  end;
end;

// TIME-ENTRY Class-Wrapper:

class function TdmDataAccess.DBStartTimeEntry(const ATimeEntry: TTimeEntry): Integer;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.StartTimeEntry(ATimeEntry);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBGetActiveTimeEntry(UserId: Integer): TTimeEntry;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.GetActiveTimeEntry(UserId);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBStopTimeEntry(EntryId, UserId: Integer): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.StopTimeEntry(EntryId, UserId);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBAddPauseToTimeEntry(EntryId, UserId: Integer; PauseMinutes: Integer): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.AddPauseToTimeEntry(EntryId, UserId, PauseMinutes);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBGetTimeEntry(EntryId, UserId: Integer): TTimeEntry;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.GetTimeEntry(EntryId, UserId);
  finally
    dm.Free;
  end;
end;


function TdmDataAccess.GetTimeEntriesForPeriod(UserId: Integer; StartDate, EndDate: TDateTime; ProjectId: Integer): TTimeEntryArray;
var
  lSQL: string;
  position : Integer;
begin
  // SQL mit optionalem Projekt-Filter
  lSQL := 'SELECT ENTRY_ID, USER_ID, PROJECT_ID, ACTIVITY_DESCRIPTION, START_TIME, ' +
          'END_TIME, TOTAL_MINUTES, PAUSE_MINUTES, CREATED_AT, MODIFIED_AT ' +
          'FROM TIME_ENTRIES ' +
          'WHERE USER_ID = :user_id ' +
          'AND CAST(START_TIME AS DATE) BETWEEN :start_date AND :end_date ';

  if ProjectId > 0 then
    lSQL := lSQL + 'AND PROJECT_ID = :project_id ';
  lSQL := lSQL + 'ORDER BY START_TIME DESC';

  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.ParamByName('start_date').AsDate := StartDate;
    CommonQuery.ParamByName('end_date').AsDate := EndDate;
    if ProjectId > 0 then
      CommonQuery.ParamByName('project_id').AsInteger := ProjectId;
    CommonQuery.Open;
    position := 0;
    SetLength(Result,CommonQuery.RecordCount);
    while not CommonQuery.Eof do
    begin
      Result[position].Entry_ID := CommonQuery.FieldByName('ENTRY_ID').AsInteger;
      Result[position].User_ID := CommonQuery.FieldByName('USER_ID').AsInteger;
      Result[position].Project_ID := CommonQuery.FieldByName('PROJECT_ID').AsInteger;
      Result[position].Activity := CommonQuery.FieldByName('ACTIVITY_DESCRIPTION').AsString;
      Result[position].Start_Time := CommonQuery.FieldByName('START_TIME').AsDateTime;
      if not CommonQuery.FieldByName('END_TIME').IsNull then
        Result[position].End_Time := CommonQuery.FieldByName('END_TIME').AsDateTime
      else
        Result[position].End_Time := 0;

      if not CommonQuery.FieldByName('TOTAL_MINUTES').IsNull then
        Result[position].Pause_Minutes := CommonQuery.FieldByName('TOTAL_MINUTES').AsInteger
      else
        Result[position].Pause_Minutes := 0;

      Result[position].Pause_Minutes := CommonQuery.FieldByName('PAUSE_MINUTES').AsInteger;
      Result[position].Created_At := CommonQuery.FieldByName('CREATED_AT').AsDateTime;

      Inc(position);
      CommonQuery.Next;
    end;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.UpdateTimeEntry(const ATimeEntry: TTimeEntry): Boolean;
var
  lSQL: string;
begin
  lSQL := 'UPDATE TIME_ENTRIES SET ' +
          'ACTIVITY_DESCRIPTION = :activity, ' +
          'START_TIME = :start_time, ' +
          'END_TIME = :end_time, ' +
          'PAUSE_MINUTES = :pause_minutes ' +
          'WHERE ENTRY_ID = :entry_id AND USER_ID = :user_id';
  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('activity').AsString := ATimeEntry.Activity;
    CommonQuery.ParamByName('start_time').AsDateTime := ATimeEntry.Start_Time;

    if ATimeEntry.End_Time > 0 then
      CommonQuery.ParamByName('end_time').AsDateTime := ATimeEntry.End_Time
    else
      CommonQuery.ParamByName('end_time').Clear;

    CommonQuery.ParamByName('pause_minutes').AsInteger := ATimeEntry.Pause_Minutes;
    CommonQuery.ParamByName('entry_id').AsInteger := ATimeEntry.Entry_ID;
    CommonQuery.ParamByName('user_id').AsInteger := ATimeEntry.User_ID;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;
  finally
    CommonQuery.Close;
  end;
end;

// 4. Class-Wrapper Methoden:

class function TdmDataAccess.DBGetTimeEntriesForPeriod(UserId: Integer; StartDate, EndDate: TDateTime; ProjectId: Integer): TTimeEntryArray;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.GetTimeEntriesForPeriod(UserId, StartDate, EndDate, ProjectId);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBUpdateTimeEntry(const ATimeEntry: TTimeEntry): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.UpdateTimeEntry(ATimeEntry);
  finally
    dm.Free;
  end;
end;


function TdmDataAccess.UpdateUserProfile(const AUser: TLoginUser): Boolean;
var
  lSQL: string;
begin
  lSQL := 'UPDATE USERS SET ' +
          'EMAIL = :email, ' +
          'FIRST_NAME = :first_name, ' +
          'LAST_NAME = :last_name, ' +
          'ADDRESS = :address ' +
          'WHERE USER_ID = :user_id AND IS_ACTIVE = ''Y''';

  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('email').AsString := AUser.Email;
    CommonQuery.ParamByName('first_name').AsString := AUser.First_Name;
    CommonQuery.ParamByName('last_name').AsString := AUser.Last_Name;
    CommonQuery.ParamByName('address').AsString := AUser.Address;
    CommonQuery.ParamByName('user_id').AsInteger := AUser.User_ID;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;
  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.ChangeUserPassword(UserId: Integer; const CurrentPassword, NewPassword: string): Boolean;
var
  lSQL: string;
  currentHash, newHash: string;
begin
  Result := False;

  // Zunächst aktuelles Passwort prüfen
  lSQL := 'SELECT PASSWORD_HASH FROM USERS WHERE USER_ID = :user_id AND IS_ACTIVE = ''Y''';

  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Open;

    if CommonQuery.Eof then
      Exit; // User nicht gefunden

    currentHash := CommonQuery.FieldByName('PASSWORD_HASH').AsString;
    CommonQuery.Close;

    // Aktuelles Passwort validieren
    if not TPasswordUtils.VerifyPassword(CurrentPassword, currentHash) then
      Exit; // Falsches aktuelles Passwort

    // Neues Passwort hashen
    newHash := TPasswordUtils.CreatePasswordHash(NewPassword);

    // Passwort in DB aktualisieren
    lSQL := 'UPDATE USERS SET PASSWORD_HASH = :new_hash WHERE USER_ID = :user_id';

    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('new_hash').AsString := newHash;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;

  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.DeleteUserAccount(UserId: Integer; const Password: string): Boolean;
var
  lSQL: string;
  storedHash: string;
begin
  Result := False;

  // Zunächst Passwort prüfen
  lSQL := 'SELECT PASSWORD_HASH FROM USERS WHERE USER_ID = :user_id AND IS_ACTIVE = ''Y''';

  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Open;

    if CommonQuery.Eof then
      Exit; // User nicht gefunden

    storedHash := CommonQuery.FieldByName('PASSWORD_HASH').AsString;
    CommonQuery.Close;

    // Passwort validieren
    if not TPasswordUtils.VerifyPassword(Password, storedHash) then
      Exit; // Falsches Passwort

    // SOFT DELETE: Account deaktivieren statt physisch löschen
    // (Erhält Datenintegrität für Time-Entries)
    lSQL := 'UPDATE USERS SET ' +
            'IS_ACTIVE = ''N'', ' +
            'EMAIL = EMAIL || ''_deleted_'' || USER_ID, ' +  // E-Mail eindeutig machen
            'USERNAME = USERNAME || ''_deleted_'' || USER_ID ' + // Username eindeutig machen
            'WHERE USER_ID = :user_id';

    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;

  finally
    CommonQuery.Close;
  end;
end;

function TdmDataAccess.DeactivateUserAccount(UserId: Integer): Boolean;
var
  lSQL: string;
begin
  // Account deaktivieren ohne Passwort-Prüfung (für Admin-Funktionen)
  lSQL := 'UPDATE USERS SET IS_ACTIVE = ''N'' WHERE USER_ID = :user_id';

  try
    CommonQuery.SQL.Text := lSQL;
    CommonQuery.ParamByName('user_id').AsInteger := UserId;
    CommonQuery.Execute;

    Result := CommonQuery.RowsAffected > 0;
  finally
    CommonQuery.Close;
  end;
end;

// 4. Class-Wrapper Methoden:

class function TdmDataAccess.DBUpdateUserProfile(const AUser: TLoginUser): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.UpdateUserProfile(AUser);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBChangeUserPassword(UserId: Integer; const CurrentPassword, NewPassword: string): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.ChangeUserPassword(UserId, CurrentPassword, NewPassword);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBDeleteUserAccount(UserId: Integer; const Password: string): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.DeleteUserAccount(UserId, Password);
  finally
    dm.Free;
  end;
end;

class function TdmDataAccess.DBDeactivateUserAccount(UserId: Integer): Boolean;
var
  dm: TdmDataAccess;
begin
  dm := TdmDataAccess.Create(nil);
  try
    Result := dm.DeactivateUserAccount(UserId);
  finally
    dm.Free;
  end;
end;
end.
