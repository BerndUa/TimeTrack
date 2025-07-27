unit TimeTrackApi.ApiTypes;

interface

uses
  MVCFramework.Serializer.Commons,
  System.Generics.Collections,
  MVCFramework.Swagger.Commons,
  TimeTrackApi.Model.Entities;

type
  /// <summary>Klasse mit Benutzerdaten für Neuanmeldung
  /// Feldbeschreibungen mit MVCSwagJSONSchemaField beschreiben die einzelnen Felder für OpenAPI
  ///</summary>
  [MVCNameCase(ncLowerCase)]
  TNewUserData =  class
  private
    FLastName: string;
    FEmail: string;
    FPassword: string;
    FAddress: string;
    FFirstName: string;
    FUsername: string;
  public

    function IsDataValid : Boolean;

    function GetAsUserData : TUserData;

    [MVCSwagJSONSchemaField(stString, 'username', 'Username im System', false)]
    property Username: string read FUsername write FUsername;
    [MVCSwagJSONSchemaField(stString, 'email', 'Email des Users', false)]
    property Email: string read FEmail write FEmail;
    [MVCSwagJSONSchemaField(stString, 'password', 'gewünschtes Passwort', false)]
    property Password: string read FPassword write FPassword;
    [MVCSwagJSONSchemaField(stString, 'firstname', 'Vorname des Users', True)]
    property FirstName: string read FFirstName write FFirstName;
    [MVCSwagJSONSchemaField(stString, 'lastname', 'Nachname des Users', True)]
    property LastName: string read FLastName write FLastName;
    [MVCSwagJSONSchemaField(stString, 'address', 'Adresse des Users', True)]
    property Address: string read FAddress write FAddress;
  end;

  [MVCNameCase(ncLowerCase)]
  TJWTLoginRequest = class
  private
    FJwtUsername: string;
    FJwtPassword: string;
  public
    // WICHTIG: Diese Feldnamen werden von DMVC automatisch erkannt!
    [MVCSwagJSONSchemaField(stString, 'jwtusername', 'Benutzername für JWT', false)]
    property JwtUsername: string read FJwtUsername write FJwtUsername;
    [MVCSwagJSONSchemaField(stString, 'jwtpassword', 'Passwort für JWT', false)]
    property JwtPassword: string read FJwtPassword write FJwtPassword;
  end;

  TLoginResponse = class
  private
    FToken: string;
    FUsername: string;
    FUserId: Integer;
    FExpiresAt: TDateTime;
  public
    [MVCSwagJSONSchemaField(stString, 'token', 'JWT Token', false)]
    property Token: string read FToken write FToken;
    [MVCSwagJSONSchemaField(stString, 'username', 'Benutzername', false)]
    property Username: string read FUsername write FUsername;
    [MVCSwagJSONSchemaField(stInteger, 'user_id', 'Benutzer ID', false)]
    property UserId: Integer read FUserId write FUserId;
    [MVCSwagJSONSchemaField(stString, 'expires_at', 'Token Ablaufzeit', false)]
    property ExpiresAt: TDateTime read FExpiresAt write FExpiresAt;
  end;


 /// <summary>Projekt-Daten für API-Requests (Erstellen/Bearbeiten)</summary>
  [MVCNameCase(ncLowerCase)]
  TProjectData = class
  private
    FProjectName: string;
    FClientName: string;
    FDescription: string;
  public
    function IsDataValid: Boolean;
    function GetAsProjectRecord(UserId: Integer): TProject;
    [MVCSwagJSONSchemaField(stString, 'project_name', 'Name des Projekts', false)]
    property ProjectName: string read FProjectName write FProjectName;
    [MVCSwagJSONSchemaField(stString, 'client_name', 'Name des Clients', false)]
    property ClientName: string read FClientName write FClientName;
    [MVCSwagJSONSchemaField(stString, 'description', 'Projektbeschreibung', true)]
    property Description: string read FDescription write FDescription;
  end;

  /// <summary>Projekt-Response für API (Lesen)</summary>
  [MVCNameCase(ncLowerCase)]
  TProjectResponse = class
  private
    FProjectId: Integer;
    FProjectName: string;
    FClientName: string;
    FDescription: string;
    FCreatedAt: string;
    FIsActive: Boolean;
  public
    constructor CreateFromRecord(const AProject: TProject);
    [MVCSwagJSONSchemaField(stInteger, 'project_id', 'Eindeutige Projekt-ID', false)]
    property ProjectId: Integer read FProjectId write FProjectId;
    [MVCSwagJSONSchemaField(stString, 'project_name', 'Name des Projekts', false)]
    property ProjectName: string read FProjectName write FProjectName;
    [MVCSwagJSONSchemaField(stString, 'client_name', 'Name des Clients', false)]
    property ClientName: string read FClientName write FClientName;
    [MVCSwagJSONSchemaField(stString, 'description', 'Projektbeschreibung', true)]
    property Description: string read FDescription write FDescription;
    [MVCSwagJSONSchemaField(stString, 'created_at', 'Erstellungsdatum', false)]
    property CreatedAt: string read FCreatedAt write FCreatedAt;
    [MVCSwagJSONSchemaField(stBoolean, 'is_active', 'Projekt aktiv', false)]
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  /// <summary>Liste von Projekten für API-Response</summary>
  [MVCNameCase(ncLowerCase)]
  TProjectListResponse = class
  private
    FProjects: TObjectList<TProjectResponse>;
    function GetCount: Integer;  // Getter-Methode
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddProject(const AProject: TProject);
    [MVCSwagJSONSchemaField(stArray, 'projects', 'Liste der Projekte', false)]
    property Projects: TObjectList<TProjectResponse> read FProjects write FProjects;
    // Readonly-Property - Count wird automatisch aus der Liste berechnet
    [MVCSwagJSONSchemaField(stInteger, 'count', 'Anzahl Projekte', false)]
    property Count: Integer read GetCount;
  end;

  /// <summary>Request zum Starten eines Time-Trackings</summary>
  [MVCNameCase(ncLowerCase)]
  TStartTrackingRequest = class
  private
    FProjectId: Integer;
    FActivity: string;
    FStartTime: string; // Optional - ISO DateTime Format
  public
    function IsDataValid: Boolean;
    function GetStartDateTime: TDateTime;
    [MVCSwagJSONSchemaField(stInteger, 'project_id', 'ID des Projekts', false)]
    property ProjectId: Integer read FProjectId write FProjectId;
    [MVCSwagJSONSchemaField(stString, 'activity', 'Beschreibung der Tätigkeit', false)]
    property Activity: string read FActivity write FActivity;
    [MVCSwagJSONSchemaField(stString, 'start_time', 'Startzeit (optional, Format: YYYY-MM-DDTHH:MM:SS)', true)]
    property StartTime: string read FStartTime write FStartTime;
  end;

  /// <summary>Request zum Hinzufügen von Pausenzeit</summary>
  [MVCNameCase(ncLowerCase)]
  TAddPauseRequest = class
  private
    FPauseMinutes: Integer;
  public
    function IsDataValid: Boolean;
    [MVCSwagJSONSchemaField(stInteger, 'pause_minutes', 'Zusätzliche Pausenminuten', false)]
    property PauseMinutes: Integer read FPauseMinutes write FPauseMinutes;
  end;

  /// <summary>Response für Time-Entry (aktuell oder abgeschlossen)</summary>
  [MVCNameCase(ncLowerCase)]
  TTimeEntryResponse = class
  private
    FEntryId: Integer;
    FProjectId: Integer;
    FProjectName: string;
    FClientName: string;
    FActivity: string;
    FStartTime: string;
    FEndTime: string;
    FPauseMinutes: Integer;
    FDurationMinutes: Integer;
    FNetDurationMinutes: Integer;
    FIsActive: Boolean;
  public
    constructor CreateFromRecord(const ATimeEntry: TTimeEntry; const AProject: TProject);
    [MVCSwagJSONSchemaField(stInteger, 'entry_id', 'Eindeutige Entry-ID', false)]
    property EntryId: Integer read FEntryId write FEntryId;
    [MVCSwagJSONSchemaField(stInteger, 'project_id', 'Projekt-ID', false)]
    property ProjectId: Integer read FProjectId write FProjectId;
    [MVCSwagJSONSchemaField(stString, 'project_name', 'Projektname', false)]
    property ProjectName: string read FProjectName write FProjectName;
    [MVCSwagJSONSchemaField(stString, 'client_name', 'Client-Name', false)]
    property ClientName: string read FClientName write FClientName;
    [MVCSwagJSONSchemaField(stString, 'activity', 'Tätigkeit', false)]
    property Activity: string read FActivity write FActivity;
    [MVCSwagJSONSchemaField(stString, 'start_time', 'Startzeit', false)]
    property StartTime: string read FStartTime write FStartTime;
    [MVCSwagJSONSchemaField(stString, 'end_time', 'Endzeit (leer bei aktivem Tracking)', true)]
    property EndTime: string read FEndTime write FEndTime;
    [MVCSwagJSONSchemaField(stInteger, 'pause_minutes', 'Pausenminuten', false)]
    property PauseMinutes: Integer read FPauseMinutes write FPauseMinutes;
    [MVCSwagJSONSchemaField(stInteger, 'duration_minutes', 'Gesamtdauer in Minuten', false)]
    property DurationMinutes: Integer read FDurationMinutes write FDurationMinutes;
    [MVCSwagJSONSchemaField(stInteger, 'net_duration_minutes', 'Nettodauer (ohne Pausen) in Minuten', false)]
    property NetDurationMinutes: Integer read FNetDurationMinutes write FNetDurationMinutes;
    [MVCSwagJSONSchemaField(stBoolean, 'is_active', 'Tracking läuft noch', false)]
    property IsActive: Boolean read FIsActive write FIsActive;
  end;


   /// <summary>Response für Tracking-Status (Startmaske)</summary>
  [MVCNameCase(ncLowerCase)]
  TTrackingStatusResponse = class
  private
    FIsTracking: Boolean;
    FCurrentEntry: TTimeEntryResponse;
    FAvailableProjects: TObjectList<TProjectResponse>;
  public
    constructor Create;
    destructor Destroy; override;

    [MVCSwagJSONSchemaField(stBoolean, 'is_tracking', 'Tracking läuft gerade', false)]
    property IsTracking: Boolean read FIsTracking write FIsTracking;

    [MVCSwagJSONSchemaField(stObject, 'current_entry', 'Aktueller Eintrag (wenn tracking=true)', true)]
    property CurrentEntry: TTimeEntryResponse read FCurrentEntry write FCurrentEntry;

    [MVCSwagJSONSchemaField(stArray, 'available_projects', 'Verfügbare Projekte zum Starten', false)]
    property AvailableProjects: TObjectList<TProjectResponse> read FAvailableProjects write FAvailableProjects;
  end;

  /// <summary>Liste von Time-Entries für API-Response</summary>
  [MVCNameCase(ncLowerCase)]
  TTimeEntryListResponse = class
  private
    FEntries: TObjectList<TTimeEntryResponse>;
    FTotalMinutes: Integer;
    FTotalNetMinutes: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddTimeEntry(const ATimeEntry: TTimeEntry; const AProject: TProject);
    function GetCount: Integer;

    [MVCSwagJSONSchemaField(stArray, 'entries', 'Liste der Zeiteinträge', false)]
    property Entries: TObjectList<TTimeEntryResponse> read FEntries write FEntries;

    [MVCSwagJSONSchemaField(stInteger, 'count', 'Anzahl Einträge', false)]
    property Count: Integer read GetCount;

    [MVCSwagJSONSchemaField(stInteger, 'total_minutes', 'Gesamtminuten aller Einträge', false)]
    property TotalMinutes: Integer read FTotalMinutes write FTotalMinutes;

    [MVCSwagJSONSchemaField(stInteger, 'total_net_minutes', 'Netto-Gesamtminuten (ohne Pausen)', false)]
    property TotalNetMinutes: Integer read FTotalNetMinutes write FTotalNetMinutes;
  end;

  /// <summary>Request zum Bearbeiten eines Time-Entries</summary>
  [MVCNameCase(ncLowerCase)]
  TUpdateTimeEntryRequest = class
  private
    FActivity: string;
    FStartTime: string;
    FEndTime: string;
    FPauseMinutes: Integer;
  public
    function IsDataValid: Boolean;
    function GetStartDateTime: TDateTime;
    function GetEndDateTime: TDateTime;

    [MVCSwagJSONSchemaField(stString, 'activity', 'Beschreibung der Tätigkeit', false)]
    property Activity: string read FActivity write FActivity;

    [MVCSwagJSONSchemaField(stString, 'start_time', 'Startzeit (Format: YYYY-MM-DDTHH:MM:SS)', false)]
    property StartTime: string read FStartTime write FStartTime;

    [MVCSwagJSONSchemaField(stString, 'end_time', 'Endzeit (Format: YYYY-MM-DDTHH:MM:SS)', true)]
    property EndTime: string read FEndTime write FEndTime;

    [MVCSwagJSONSchemaField(stInteger, 'pause_minutes', 'Pausenminuten', false)]
    property PauseMinutes: Integer read FPauseMinutes write FPauseMinutes;
  end;


  /// <summary>Request für Zeitreport-Filter</summary>
  [MVCNameCase(ncLowerCase)]
  TTimeReportRequest = class
  private
    FStartDate: string;
    FEndDate: string;
    FProjectId: Integer;
    FGroupBy: string; // 'day', 'week', 'month', 'project'
  public
    function IsDataValid: Boolean;
    function GetStartDateTime: TDateTime;
    function GetEndDateTime: TDateTime;

    [MVCSwagJSONSchemaField(stString, 'start_date', 'Startdatum (YYYY-MM-DD)', false)]
    property StartDate: string read FStartDate write FStartDate;

    [MVCSwagJSONSchemaField(stString, 'end_date', 'Enddatum (YYYY-MM-DD)', false)]
    property EndDate: string read FEndDate write FEndDate;

    [MVCSwagJSONSchemaField(stInteger, 'project_id', 'Filter nach Projekt-ID (optional)', true)]
    property ProjectId: Integer read FProjectId write FProjectId;

    [MVCSwagJSONSchemaField(stString, 'group_by', 'Gruppierung: day, week, month, project', true)]
    property GroupBy: string read FGroupBy write FGroupBy;
  end;

  /// <summary>Projekt-Zusammenfassung für Reports</summary>
  [MVCNameCase(ncLowerCase)]
  TProjectSummary = class
  private
    FProjectId: Integer;
    FProjectName: string;
    FClientName: string;
    FTotalMinutes: Integer;
    FNetMinutes: Integer;
    FEntryCount: Integer;
    FLastActivity: string;
  public
    [MVCSwagJSONSchemaField(stInteger, 'project_id', 'Projekt-ID', false)]
    property ProjectId: Integer read FProjectId write FProjectId;

    [MVCSwagJSONSchemaField(stString, 'project_name', 'Projektname', false)]
    property ProjectName: string read FProjectName write FProjectName;

    [MVCSwagJSONSchemaField(stString, 'client_name', 'Client-Name', false)]
    property ClientName: string read FClientName write FClientName;

    [MVCSwagJSONSchemaField(stInteger, 'total_minutes', 'Gesamtminuten', false)]
    property TotalMinutes: Integer read FTotalMinutes write FTotalMinutes;

    [MVCSwagJSONSchemaField(stInteger, 'net_minutes', 'Netto-Minuten (ohne Pausen)', false)]
    property NetMinutes: Integer read FNetMinutes write FNetMinutes;

    [MVCSwagJSONSchemaField(stInteger, 'entry_count', 'Anzahl Einträge', false)]
    property EntryCount: Integer read FEntryCount write FEntryCount;

    [MVCSwagJSONSchemaField(stString, 'last_activity', 'Letzte Aktivität', false)]
    property LastActivity: string read FLastActivity write FLastActivity;
  end;

  /// <summary>Tages-Zusammenfassung für Reports</summary>
  [MVCNameCase(ncLowerCase)]
  TDailySummary = class
  private
    FDate: string;
    FTotalMinutes: Integer;
    FNetMinutes: Integer;
    FEntryCount: Integer;
    FProjects: TObjectList<TProjectSummary>;
  public
    constructor Create;
    destructor Destroy; override;

    [MVCSwagJSONSchemaField(stString, 'date', 'Datum (YYYY-MM-DD)', false)]
    property Date: string read FDate write FDate;

    [MVCSwagJSONSchemaField(stInteger, 'total_minutes', 'Gesamtminuten des Tages', false)]
    property TotalMinutes: Integer read FTotalMinutes write FTotalMinutes;

    [MVCSwagJSONSchemaField(stInteger, 'net_minutes', 'Netto-Minuten des Tages', false)]
    property NetMinutes: Integer read FNetMinutes write FNetMinutes;

    [MVCSwagJSONSchemaField(stInteger, 'entry_count', 'Anzahl Einträge', false)]
    property EntryCount: Integer read FEntryCount write FEntryCount;

    [MVCSwagJSONSchemaField(stArray, 'projects', 'Projekte des Tages', false)]
    property Projects: TObjectList<TProjectSummary> read FProjects write FProjects;
  end;

  /// <summary>Haupt-Report-Response</summary>
  [MVCNameCase(ncLowerCase)]
  TTimeReportResponse = class
  private
    FStartDate: string;
    FEndDate: string;
    FTotalMinutes: Integer;
    FNetMinutes: Integer;
    FTotalEntries: Integer;
    FDailySummaries: TObjectList<TDailySummary>;
    FProjectSummaries: TObjectList<TProjectSummary>;
    FGroupBy: string;
  public
    constructor Create;
    destructor Destroy; override;

    [MVCSwagJSONSchemaField(stString, 'start_date', 'Berichtszeitraum Start', false)]
    property StartDate: string read FStartDate write FStartDate;

    [MVCSwagJSONSchemaField(stString, 'end_date', 'Berichtszeitraum Ende', false)]
    property EndDate: string read FEndDate write FEndDate;

    [MVCSwagJSONSchemaField(stInteger, 'total_minutes', 'Gesamtminuten im Zeitraum', false)]
    property TotalMinutes: Integer read FTotalMinutes write FTotalMinutes;

    [MVCSwagJSONSchemaField(stInteger, 'net_minutes', 'Netto-Minuten im Zeitraum', false)]
    property NetMinutes: Integer read FNetMinutes write FNetMinutes;

    [MVCSwagJSONSchemaField(stInteger, 'total_entries', 'Gesamtzahl Einträge', false)]
    property TotalEntries: Integer read FTotalEntries write FTotalEntries;

    [MVCSwagJSONSchemaField(stArray, 'daily_summaries', 'Tages-Zusammenfassungen', false)]
    property DailySummaries: TObjectList<TDailySummary> read FDailySummaries write FDailySummaries;

    [MVCSwagJSONSchemaField(stArray, 'project_summaries', 'Projekt-Zusammenfassungen', false)]
    property ProjectSummaries: TObjectList<TProjectSummary> read FProjectSummaries write FProjectSummaries;

    [MVCSwagJSONSchemaField(stString, 'group_by', 'Gruppierung des Reports', false)]
    property GroupBy: string read FGroupBy write FGroupBy;
  end;

  /// <summary>Export-Request für CSV/PDF</summary>
  [MVCNameCase(ncLowerCase)]
  TExportRequest = class
  private
    FStartDate: string;
    FEndDate: string;
    FProjectId: Integer;
    FFormat: string; // 'csv', 'pdf'
    FIncludeDetails: Boolean;
  public
    function IsDataValid: Boolean;
    function GetStartDateTime: TDateTime;
    function GetEndDateTime: TDateTime;

    [MVCSwagJSONSchemaField(stString, 'start_date', 'Startdatum (YYYY-MM-DD)', false)]
    property StartDate: string read FStartDate write FStartDate;

    [MVCSwagJSONSchemaField(stString, 'end_date', 'Enddatum (YYYY-MM-DD)', false)]
    property EndDate: string read FEndDate write FEndDate;

    [MVCSwagJSONSchemaField(stInteger, 'project_id', 'Filter nach Projekt-ID (optional)', true)]
    property ProjectId: Integer read FProjectId write FProjectId;

    [MVCSwagJSONSchemaField(stString, 'format', 'Export-Format: csv oder pdf', false)]
    property Format: string read FFormat write FFormat;

    [MVCSwagJSONSchemaField(stBoolean, 'include_details', 'Detaillierte Einträge inkludieren', false)]
    property IncludeDetails: Boolean read FIncludeDetails write FIncludeDetails;
  end;


  /// <summary>Benutzer-Profil Response</summary>
  [MVCNameCase(ncLowerCase)]
  TUserProfileResponse = class
  private
    FUserId: Integer;
    FUsername: string;
    FEmail: string;
    FFirstName: string;
    FLastName: string;
    FAddress: string;
    FCreatedAt: string;
    FLastLogin: string;
    FIsActive: Boolean;
  public
    constructor CreateFromRecord(const AUser: TLoginUser);

    [MVCSwagJSONSchemaField(stInteger, 'user_id', 'Benutzer-ID', false)]
    property UserId: Integer read FUserId write FUserId;

    [MVCSwagJSONSchemaField(stString, 'username', 'Benutzername', false)]
    property Username: string read FUsername write FUsername;

    [MVCSwagJSONSchemaField(stString, 'email', 'E-Mail-Adresse', false)]
    property Email: string read FEmail write FEmail;

    [MVCSwagJSONSchemaField(stString, 'first_name', 'Vorname', true)]
    property FirstName: string read FFirstName write FFirstName;

    [MVCSwagJSONSchemaField(stString, 'last_name', 'Nachname', true)]
    property LastName: string read FLastName write FLastName;

    [MVCSwagJSONSchemaField(stString, 'address', 'Adresse', true)]
    property Address: string read FAddress write FAddress;

    [MVCSwagJSONSchemaField(stString, 'created_at', 'Registrierungsdatum', false)]
    property CreatedAt: string read FCreatedAt write FCreatedAt;

    [MVCSwagJSONSchemaField(stString, 'last_login', 'Letzter Login', true)]
    property LastLogin: string read FLastLogin write FLastLogin;

    [MVCSwagJSONSchemaField(stBoolean, 'is_active', 'Account aktiv', false)]
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  /// <summary>Request zum Aktualisieren des Profils</summary>
  [MVCNameCase(ncLowerCase)]
  TUpdateProfileRequest = class
  private
    FEmail: string;
    FFirstName: string;
    FLastName: string;
    FAddress: string;
  public
    function IsDataValid: Boolean;
    function GetAsUserData(UserId: Integer): TLoginUser;

    [MVCSwagJSONSchemaField(stString, 'email', 'E-Mail-Adresse', false)]
    property Email: string read FEmail write FEmail;

    [MVCSwagJSONSchemaField(stString, 'first_name', 'Vorname', true)]
    property FirstName: string read FFirstName write FFirstName;

    [MVCSwagJSONSchemaField(stString, 'last_name', 'Nachname', true)]
    property LastName: string read FLastName write FLastName;

    [MVCSwagJSONSchemaField(stString, 'address', 'Adresse', true)]
    property Address: string read FAddress write FAddress;
  end;

  /// <summary>Request zum Ändern des Passworts</summary>
  [MVCNameCase(ncLowerCase)]
  TChangePasswordRequest = class
  private
    FCurrentPassword: string;
    FNewPassword: string;
    FConfirmPassword: string;
  public
    function IsDataValid: Boolean;

    [MVCSwagJSONSchemaField(stString, 'current_password', 'Aktuelles Passwort', false)]
    property CurrentPassword: string read FCurrentPassword write FCurrentPassword;

    [MVCSwagJSONSchemaField(stString, 'new_password', 'Neues Passwort', false)]
    property NewPassword: string read FNewPassword write FNewPassword;

    [MVCSwagJSONSchemaField(stString, 'confirm_password', 'Passwort bestätigen', false)]
    property ConfirmPassword: string read FConfirmPassword write FConfirmPassword;
  end;

  /// <summary>Request zum Löschen des Accounts</summary>
  [MVCNameCase(ncLowerCase)]
  TDeleteAccountRequest = class
  private
    FPassword: string;
    FConfirmation: string;
  public
    function IsDataValid: Boolean;

    [MVCSwagJSONSchemaField(stString, 'password', 'Passwort zur Bestätigung', false)]
    property Password: string read FPassword write FPassword;

    [MVCSwagJSONSchemaField(stString, 'confirmation', 'Bestätigung (Text: "DELETE")', false)]
    property Confirmation: string read FConfirmation write FConfirmation;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;


{ TNewUserData }

function TNewUserData.GetAsUserData: TUserData;
begin
  Result.Username := Username;
  Result.Email := Email;
  Result.Password := Password;
  Result.FirstName := FirstName;
  Result.LastName := LastName;
  Result.Address := Address;

end;

function TNewUserData.IsDataValid: Boolean;
begin
  { TODO 5 -oALL -coptimizations : weitere Prüfungen, gültige Email o.ä. }
  Result := (FUsername<> string.Empty) AND
            (FEmail<> string.Empty) AND
            (FPassword <> string.Empty);
end;

// TProjectData Implementation
function TProjectData.IsDataValid: Boolean;
begin
  Result := (Trim(FProjectName) <> '') and (Trim(FClientName) <> '');
end;

function TProjectData.GetAsProjectRecord(UserId: Integer): TProject;
begin
  Result.Clear;
  Result.User_ID := UserId;
  Result.Project_Name := Trim(FProjectName);
  Result.Client_Name := Trim(FClientName);
  Result.Description := Trim(FDescription);
  Result.Created_At := Now;
  Result.Is_Active := True;
end;

// TProjectResponse Implementation
constructor TProjectResponse.CreateFromRecord(const AProject: TProject);
begin
  inherited Create;
  FProjectId := AProject.Project_ID;
  FProjectName := AProject.Project_Name;
  FClientName := AProject.Client_Name;
  FDescription := AProject.Description;
  FCreatedAt := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', AProject.Created_At);
  FIsActive := AProject.Is_Active;
end;

// TProjectListResponse Implementation
constructor TProjectListResponse.Create;
begin
  inherited Create;
  FProjects := TObjectList<TProjectResponse>.Create(True);
end;

destructor TProjectListResponse.Destroy;
begin
  FProjects.Free;
  inherited Destroy;
end;

function TProjectListResponse.GetCount: Integer;
begin
  Result := FProjects.Count;
end;

procedure TProjectListResponse.AddProject(const AProject: TProject);
begin
  FProjects.Add(TProjectResponse.CreateFromRecord(AProject));
end;

// TStartTrackingRequest Implementation
function TStartTrackingRequest.IsDataValid: Boolean;
begin
  Result := (FProjectId > 0) and (Trim(FActivity) <> '');
end;

function TStartTrackingRequest.GetStartDateTime: TDateTime;
begin
  if Trim(FStartTime) = '' then
    Result := Now
  else
    Result := ISO8601ToDate(FStartTime, False);
end;

// TAddPauseRequest Implementation
function TAddPauseRequest.IsDataValid: Boolean;
begin
  Result := FPauseMinutes > 0;
end;

// TTimeEntryResponse Implementation
constructor TTimeEntryResponse.CreateFromRecord(const ATimeEntry: TTimeEntry; const AProject: TProject);
begin
  inherited Create;
  FEntryId := ATimeEntry.Entry_ID;
  FProjectId := ATimeEntry.Project_ID;
  FProjectName := AProject.Project_Name;
  FClientName := AProject.Client_Name;
  FActivity := ATimeEntry.Activity;
  FStartTime := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', ATimeEntry.Start_Time);

  if ATimeEntry.End_Time > 0 then
    FEndTime := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', ATimeEntry.End_Time)
  else
    FEndTime := '';

  FPauseMinutes := ATimeEntry.Pause_Minutes;
  FDurationMinutes := ATimeEntry.GetDurationMinutes;
  FNetDurationMinutes := ATimeEntry.GetNetDurationMinutes;
  FIsActive := ATimeEntry.IsActive;
end;


// TTrackingStatusResponse Implementation
constructor TTrackingStatusResponse.Create;
begin
  inherited Create;
  FIsTracking := False;
  FCurrentEntry := nil;
  FAvailableProjects := TObjectList<TProjectResponse>.Create(True);
end;

destructor TTrackingStatusResponse.Destroy;
begin
  if Assigned(FCurrentEntry) then
    FCurrentEntry.Free;
  FAvailableProjects.Free;
  inherited Destroy;
end;

// TTimeEntryListResponse Implementation
constructor TTimeEntryListResponse.Create;
begin
  inherited Create;
  FEntries := TObjectList<TTimeEntryResponse>.Create(True);
  FTotalMinutes := 0;
  FTotalNetMinutes := 0;
end;

destructor TTimeEntryListResponse.Destroy;
begin
  FEntries.Free;
  inherited Destroy;
end;

procedure TTimeEntryListResponse.AddTimeEntry(const ATimeEntry: TTimeEntry; const AProject: TProject);
var
  entryResponse: TTimeEntryResponse;
begin
  entryResponse := TTimeEntryResponse.CreateFromRecord(ATimeEntry, AProject);
  FEntries.Add(entryResponse);

  // Summen aktualisieren
  FTotalMinutes := FTotalMinutes + entryResponse.DurationMinutes;
  FTotalNetMinutes := FTotalNetMinutes + entryResponse.NetDurationMinutes;
end;

function TTimeEntryListResponse.GetCount: Integer;
begin
  Result := FEntries.Count;
end;

// TUpdateTimeEntryRequest Implementation
function TUpdateTimeEntryRequest.IsDataValid: Boolean;
begin
  Result := (Trim(FActivity) <> '') and
            (Trim(FStartTime) <> '') and
            (FPauseMinutes >= 0);
end;

function TUpdateTimeEntryRequest.GetStartDateTime: TDateTime;
begin
  Result := ISO8601ToDate(FStartTime, False);
end;

function TUpdateTimeEntryRequest.GetEndDateTime: TDateTime;
begin
  if Trim(FEndTime) = '' then
    Result := 0
  else
    Result := ISO8601ToDate(FEndTime, False);
end;

// TTimeReportRequest Implementation
function TTimeReportRequest.IsDataValid: Boolean;
begin
  Result := (Trim(FStartDate) <> '') and (Trim(FEndDate) <> '');
  if Result and (Trim(FGroupBy) <> '') then
    Result := (FGroupBy = 'day') or (FGroupBy = 'week') or (FGroupBy = 'month') or (FGroupBy = 'project');
end;

function TTimeReportRequest.GetStartDateTime: TDateTime;
begin
  Result := ISO8601ToDate(FStartDate + 'T00:00:00', False);
end;

function TTimeReportRequest.GetEndDateTime: TDateTime;
begin
  Result := ISO8601ToDate(FEndDate + 'T23:59:59', False);
end;

// TDailySummary Implementation
constructor TDailySummary.Create;
begin
  inherited Create;
  FProjects := TObjectList<TProjectSummary>.Create(True);
end;

destructor TDailySummary.Destroy;
begin
  FProjects.Free;
  inherited Destroy;
end;

// TTimeReportResponse Implementation
constructor TTimeReportResponse.Create;
begin
  inherited Create;
  FDailySummaries := TObjectList<TDailySummary>.Create(True);
  FProjectSummaries := TObjectList<TProjectSummary>.Create(True);
end;

destructor TTimeReportResponse.Destroy;
begin
  FDailySummaries.Free;
  FProjectSummaries.Free;
  inherited Destroy;
end;

// TExportRequest Implementation
function TExportRequest.IsDataValid: Boolean;
begin
  Result := (Trim(FStartDate) <> '') and
            (Trim(FEndDate) <> '') and
            (Trim(FFormat) <> '') and
            ((FFormat = 'csv') or (FFormat = 'pdf'));
end;

function TExportRequest.GetStartDateTime: TDateTime;
begin
  Result := ISO8601ToDate(FStartDate + 'T00:00:00', False);
end;

function TExportRequest.GetEndDateTime: TDateTime;
begin
  Result := ISO8601ToDate(FEndDate + 'T23:59:59', False);
end;



// TUserProfileResponse Implementation
constructor TUserProfileResponse.CreateFromRecord(const AUser: TLoginUser);
begin
  inherited Create;
  FUserId := AUser.User_ID;
  FUsername := AUser.Username;
  FEmail := AUser.Email;
  FFirstName := AUser.First_Name;
  FLastName := AUser.Last_Name;
  FAddress := AUser.Address;
  FCreatedAt := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', AUser.Created_At);

  if AUser.Last_Login > 0 then
    FLastLogin := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', AUser.Last_Login)
  else
    FLastLogin := '';

  FIsActive := AUser.Is_Active;
end;

// TUpdateProfileRequest Implementation
function TUpdateProfileRequest.IsDataValid: Boolean;
begin
  // E-Mail ist Pflichtfeld, andere optional
  Result := (Trim(FEmail) <> '') and (Pos('@', FEmail) > 0);
end;

function TUpdateProfileRequest.GetAsUserData(UserId: Integer): TLoginUser;
begin
  Result.User_ID := UserId;
  Result.Email := Trim(FEmail);
  Result.First_Name := Trim(FFirstName);
  Result.Last_Name := Trim(FLastName);
  Result.Address := Trim(FAddress);
  // Andere Felder bleiben unverändert
end;

// TChangePasswordRequest Implementation
function TChangePasswordRequest.IsDataValid: Boolean;
begin
  Result := (Trim(FCurrentPassword) <> '') and
            (Trim(FNewPassword) <> '') and
            (Length(FNewPassword) >= 6) and  // Mindestlänge
            (FNewPassword = FConfirmPassword);
end;

// TDeleteAccountRequest Implementation
function TDeleteAccountRequest.IsDataValid: Boolean;
begin
  Result := (Trim(FPassword) <> '') and
            (UpperCase(Trim(FConfirmation)) = 'DELETE');
end;

end.
