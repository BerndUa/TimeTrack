unit TimeEntry;

interface

uses
  MVCFramework.ActiveRecord, MVCFramework.Commons, System.SysUtils;

type
  [MVCNameCase(ncLowerCase)]
  [Table('time_entries')]
  TTimeEntry = class(TObject)
  private
    FEntryID: Integer;
    FUserID: Integer;
    FProjectID: Integer;
    FActivityDescription: string;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
    FTotalMinutes: Integer;
    FPauseMinutes: Integer;
    FIsRunning: string;
    FCreatedAt: TDateTime;
    FModifiedAt: TDateTime;
  public
    [MVCColumn('entry_id')]
    [MVCPrimaryKey]
    property EntryID: Integer read FEntryID write FEntryID;

    [MVCColumn('user_id')]
    property UserID: Integer read FUserID write FUserID;

    [MVCColumn('project_id')]
    property ProjectID: Integer read FProjectID write FProjectID;

    [MVCColumn('activity_description')]
    property ActivityDescription: string read FActivityDescription write FActivityDescription;

    [MVCColumn('start_time')]
    property StartTime: TDateTime read FStartTime write FStartTime;

    [MVCColumn('end_time')]
    property EndTime: TDateTime read FEndTime write FEndTime;

    [MVCColumn('total_minutes')]
    property TotalMinutes: Integer read FTotalMinutes write FTotalMinutes;

    [MVCColumn('pause_minutes')]
    property PauseMinutes: Integer read FPauseMinutes write FPauseMinutes;

    [MVCColumn('is_running')]
    property IsRunning: string read FIsRunning write FIsRunning;

    [MVCColumn('created_at')]
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;

    [MVCColumn('modified_at')]
    property ModifiedAt: TDateTime read FModifiedAt write FModifiedAt;
  end;

implementation

end.
