// *************************************************************************** }
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2025 Daniele Teti and the DMVCFramework Team
//
// https://github.com/danieleteti/delphimvcframework
//
// ***************************************************************************
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ***************************************************************************

unit TimeTrackApi.Entities;

interface

uses
  MVCFramework.Serializer.Commons,
  MVCFramework.Nullables,
  MVCFramework.ActiveRecord,
  System.Classes;

type

  [MVCNameCase(ncLowerCase)]
  [MVCTable('PROJECTS')]
  TProjects = class(TMVCActiveRecord)
  private
    [MVCTableField('PROJECT_ID')]
    fProjectId: Int32;
    [MVCTableField('PROJECT_NAME')]
    fProjectName: String;
    [MVCTableField('DESCRIPTION')]
    fDescription: NullableString;
    [MVCTableField('CLIENT_NAME')]
    fClientName: NullableString;
    [MVCTableField('CREATED_BY_USER_ID')]
    fCreatedByUserId: Int32;
    [MVCTableField('CREATED_AT')]
    fCreatedAt: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('IS_ACTIVE')]
    fIsActive: NullableString;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ProjectId: Int32 read fProjectId write fProjectId;
    property ProjectName: String read fProjectName write fProjectName;
    property Description: NullableString read fDescription write fDescription;
    property ClientName: NullableString read fClientName write fClientName;
    property CreatedByUserId: Int32 read fCreatedByUserId write fCreatedByUserId;
    property CreatedAt: NullableTDateTime {dtDateTimeStamp} read fCreatedAt write fCreatedAt;
    property IsActive: NullableString read fIsActive write fIsActive;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('TIME_ENTRIES')]
  TTimeEntries = class(TMVCActiveRecord)
  private
    [MVCTableField('ENTRY_ID')]
    fEntryId: Int32;
    [MVCTableField('USER_ID')]
    fUserId: Int32;
    [MVCTableField('PROJECT_ID')]
    fProjectId: Int32;
    [MVCTableField('ACTIVITY_DESCRIPTION')]
    fActivityDescription: String;
    [MVCTableField('START_TIME')]
    fStartTime: TDateTime {dtDateTimeStamp};
    [MVCTableField('END_TIME')]
    fEndTime: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('TOTAL_MINUTES')]
    fTotalMinutes: NullableInt32;
    [MVCTableField('PAUSE_MINUTES')]
    fPauseMinutes: NullableInt32;
    [MVCTableField('IS_RUNNING')]
    fIsRunning: NullableString;
    [MVCTableField('CREATED_AT')]
    fCreatedAt: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('MODIFIED_AT')]
    fModifiedAt: NullableTDateTime {dtDateTimeStamp};
  public
    constructor Create; override;
    destructor Destroy; override;
    property EntryId: Int32 read fEntryId write fEntryId;
    property UserId: Int32 read fUserId write fUserId;
    property ProjectId: Int32 read fProjectId write fProjectId;
    property ActivityDescription: String read fActivityDescription write fActivityDescription;
    property StartTime: TDateTime {dtDateTimeStamp} read fStartTime write fStartTime;
    property EndTime: NullableTDateTime {dtDateTimeStamp} read fEndTime write fEndTime;
    property TotalMinutes: NullableInt32 read fTotalMinutes write fTotalMinutes;
    property PauseMinutes: NullableInt32 read fPauseMinutes write fPauseMinutes;
    property IsRunning: NullableString read fIsRunning write fIsRunning;
    property CreatedAt: NullableTDateTime {dtDateTimeStamp} read fCreatedAt write fCreatedAt;
    property ModifiedAt: NullableTDateTime {dtDateTimeStamp} read fModifiedAt write fModifiedAt;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('USERS')]
  TUsers = class(TMVCActiveRecord)
  private
    [MVCTableField('USER_ID')]
    fUserId: Int32;
    [MVCTableField('USERNAME')]
    fUsername: String;
    [MVCTableField('EMAIL')]
    fEmail: String;
    [MVCTableField('PASSWORD_HASH')]
    fPasswordHash: String;
    [MVCTableField('FIRST_NAME')]
    fFirstName: NullableString;
    [MVCTableField('LAST_NAME')]
    fLastName: NullableString;
    [MVCTableField('ADDRESS')]
    fAddress: NullableString;
    [MVCTableField('IS_CONFIRMED')]
    fIsConfirmed: NullableString;
    [MVCTableField('CONFIRMATION_TOKEN')]
    fConfirmationToken: NullableString;
    [MVCTableField('CREATED_AT')]
    fCreatedAt: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('LAST_LOGIN')]
    fLastLogin: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('IS_ACTIVE')]
    fIsActive: NullableString;
  public
    constructor Create; override;
    destructor Destroy; override;
    property UserId: Int32 read fUserId write fUserId;
    property Username: String read fUsername write fUsername;
    property Email: String read fEmail write fEmail;
    property PasswordHash: String read fPasswordHash write fPasswordHash;
    property FirstName: NullableString read fFirstName write fFirstName;
    property LastName: NullableString read fLastName write fLastName;
    property Address: NullableString read fAddress write fAddress;
    property IsConfirmed: NullableString read fIsConfirmed write fIsConfirmed;
    property ConfirmationToken: NullableString read fConfirmationToken write fConfirmationToken;
    property CreatedAt: NullableTDateTime {dtDateTimeStamp} read fCreatedAt write fCreatedAt;
    property LastLogin: NullableTDateTime {dtDateTimeStamp} read fLastLogin write fLastLogin;
    property IsActive: NullableString read fIsActive write fIsActive;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('V_ACTIVE_TIME_ENTRIES')]
  TVActiveTimeEntries = class(TMVCActiveRecord)
  private
    [MVCTableField('ENTRY_ID')]
    fEntryId: NullableInt32;
    [MVCTableField('USER_ID')]
    fUserId: NullableInt32;
    [MVCTableField('USERNAME')]
    fUsername: NullableString;
    [MVCTableField('FIRST_NAME')]
    fFirstName: NullableString;
    [MVCTableField('LAST_NAME')]
    fLastName: NullableString;
    [MVCTableField('PROJECT_ID')]
    fProjectId: NullableInt32;
    [MVCTableField('PROJECT_NAME')]
    fProjectName: NullableString;
    [MVCTableField('CLIENT_NAME')]
    fClientName: NullableString;
    [MVCTableField('ACTIVITY_DESCRIPTION')]
    fActivityDescription: NullableString;
    [MVCTableField('START_TIME')]
    fStartTime: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('TOTAL_MINUTES')]
    fTotalMinutes: NullableInt32;
    [MVCTableField('PAUSE_MINUTES')]
    fPauseMinutes: NullableInt32;
    [MVCTableField('CURRENT_MINUTES')]
    fCurrentMinutes: NullableInt64;
  public
    constructor Create; override;
    destructor Destroy; override;
    property EntryId: NullableInt32 read fEntryId write fEntryId;
    property UserId: NullableInt32 read fUserId write fUserId;
    property Username: NullableString read fUsername write fUsername;
    property FirstName: NullableString read fFirstName write fFirstName;
    property LastName: NullableString read fLastName write fLastName;
    property ProjectId: NullableInt32 read fProjectId write fProjectId;
    property ProjectName: NullableString read fProjectName write fProjectName;
    property ClientName: NullableString read fClientName write fClientName;
    property ActivityDescription: NullableString read fActivityDescription write fActivityDescription;
    property StartTime: NullableTDateTime {dtDateTimeStamp} read fStartTime write fStartTime;
    property TotalMinutes: NullableInt32 read fTotalMinutes write fTotalMinutes;
    property PauseMinutes: NullableInt32 read fPauseMinutes write fPauseMinutes;
    property CurrentMinutes: NullableInt64 read fCurrentMinutes write fCurrentMinutes;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('V_TIME_REPORT')]
  TVTimeReport = class(TMVCActiveRecord)
  private
    [MVCTableField('ENTRY_ID')]
    fEntryId: NullableInt32;
    [MVCTableField('USER_ID')]
    fUserId: NullableInt32;
    [MVCTableField('USERNAME')]
    fUsername: NullableString;
    [MVCTableField('FIRST_NAME')]
    fFirstName: NullableString;
    [MVCTableField('LAST_NAME')]
    fLastName: NullableString;
    [MVCTableField('PROJECT_NAME')]
    fProjectName: NullableString;
    [MVCTableField('CLIENT_NAME')]
    fClientName: NullableString;
    [MVCTableField('ACTIVITY_DESCRIPTION')]
    fActivityDescription: NullableString;
    [MVCTableField('START_TIME')]
    fStartTime: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('END_TIME')]
    fEndTime: NullableTDateTime {dtDateTimeStamp};
    [MVCTableField('TOTAL_MINUTES')]
    fTotalMinutes: NullableInt32;
    [MVCTableField('PAUSE_MINUTES')]
    fPauseMinutes: NullableInt32;
    [MVCTableField('WORK_DATE')]
    fWorkDate: NullableTDate;
  public
    constructor Create; override;
    destructor Destroy; override;
    property EntryId: NullableInt32 read fEntryId write fEntryId;
    property UserId: NullableInt32 read fUserId write fUserId;
    property Username: NullableString read fUsername write fUsername;
    property FirstName: NullableString read fFirstName write fFirstName;
    property LastName: NullableString read fLastName write fLastName;
    property ProjectName: NullableString read fProjectName write fProjectName;
    property ClientName: NullableString read fClientName write fClientName;
    property ActivityDescription: NullableString read fActivityDescription write fActivityDescription;
    property StartTime: NullableTDateTime {dtDateTimeStamp} read fStartTime write fStartTime;
    property EndTime: NullableTDateTime {dtDateTimeStamp} read fEndTime write fEndTime;
    property TotalMinutes: NullableInt32 read fTotalMinutes write fTotalMinutes;
    property PauseMinutes: NullableInt32 read fPauseMinutes write fPauseMinutes;
    property WorkDate: NullableTDate read fWorkDate write fWorkDate;
  end;

implementation

constructor TProjects.Create;
begin
  inherited Create;
end;

destructor TProjects.Destroy;
begin
  inherited;
end;

constructor TTimeEntries.Create;
begin
  inherited Create;
end;

destructor TTimeEntries.Destroy;
begin
  inherited;
end;

constructor TUsers.Create;
begin
  inherited Create;
end;

destructor TUsers.Destroy;
begin
  inherited;
end;

constructor TVActiveTimeEntries.Create;
begin
  inherited Create;
end;

destructor TVActiveTimeEntries.Destroy;
begin
  inherited;
end;

constructor TVTimeReport.Create;
begin
  inherited Create;
end;

destructor TVTimeReport.Destroy;
begin
  inherited;
end;

initialization

ActiveRecordMappingRegistry.AddEntity('projects', TProjects);
ActiveRecordMappingRegistry.AddEntity('time_entries', TTimeEntries);
ActiveRecordMappingRegistry.AddEntity('users', TUsers);
ActiveRecordMappingRegistry.AddEntity('v_active_time_entries', TVActiveTimeEntries);
ActiveRecordMappingRegistry.AddEntity('v_time_report', TVTimeReport);

end.