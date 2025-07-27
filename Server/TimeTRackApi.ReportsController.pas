unit TimeTrackApi.ReportsController;

interface

uses
  System.Generics.Collections,
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  MVCFramework.Swagger.Commons, MVCFramework.Middleware.Authentication.RoleBasedAuthHandler,
  TimeTrackApi.ApiTypes, TimeTrackApi.Model.Entities, TimeTrackApi.BaseController;

type
  [MVCPath('/api/reports')]
  [MVCRequiresAuthentication]
  [MVCRequiresRole('registereduser')]
  [MVCSwagAuthentication(atJsonWebToken)]
  TReportsController = class(TBaseController)
  private
    function ParseDateParam(const ParamName: string; DefaultValue: TDateTime = 0): TDateTime;
    function GenerateTimeReport(UserId: Integer; StartDate, EndDate: TDateTime; ProjectId: Integer; GroupBy: string): TTimeReportResponse;
    function CreateCSVContent(const TimeEntries: TTimeEntryArray; const Projects: TProjectArray): string;
    function FormatMinutesAsHours(Minutes: Integer): string;
  public
    /// <summary>Zeitreport für angegebenen Zeitraum generieren</summary>
    [MVCPath('')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Reports', 'Generate time report for date range')]
    [MVCSwagParam(plQuery, 'start_date', 'Start date (YYYY-MM-DD)', ptString, true)]
    [MVCSwagParam(plQuery, 'end_date', 'End date (YYYY-MM-DD)', ptString, true)]
    [MVCSwagParam(plQuery, 'project_id', 'Filter by project ID', ptInteger, false)]
    [MVCSwagParam(plQuery, 'group_by', 'Group by: day, week, month, project', ptString, false)]
    [MVCSwagResponses(200, 'Report generated successfully', TTimeReportResponse)]
    [MVCSwagResponses(400, 'Invalid date parameters')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetTimeReport;

    /// <summary>Detaillierter Zeitreport mit POST-Request</summary>
    [MVCPath('/detailed')]
    [MVCHTTPMethod([httpPOST])]
    [MVCSwagSummary('Reports', 'Generate detailed time report')]
    [MVCSwagParam(plBody, 'ReportRequest', 'Report parameters', TTimeReportRequest)]
    [MVCSwagResponses(200, 'Detailed report generated', TTimeReportResponse)]
    [MVCSwagResponses(400, 'Invalid request data')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetDetailedTimeReport;

    /// <summary>Projekt-Übersicht mit Zeitstatistiken</summary>
    [MVCPath('/projects')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Reports', 'Get project overview with time statistics')]
    [MVCSwagParam(plQuery, 'start_date', 'Start date (YYYY-MM-DD)', ptString, false)]
    [MVCSwagParam(plQuery, 'end_date', 'End date (YYYY-MM-DD)', ptString, false)]
    [MVCSwagResponses(200, 'Project overview generated', TProjectListResponse)]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetProjectOverview;

    /// <summary>Tages-Statistiken</summary>
    [MVCPath('/daily')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Reports', 'Get daily time statistics')]
    [MVCSwagParam(plQuery, 'start_date', 'Start date (YYYY-MM-DD)', ptString, false)]
    [MVCSwagParam(plQuery, 'end_date', 'End date (YYYY-MM-DD)', ptString, false)]
    [MVCSwagResponses(200, 'Daily statistics generated')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetDailyStatistics;

    /// <summary>Export als CSV</summary>
    [MVCPath('/export/csv')]
    [MVCHTTPMethod([httpPOST])]
    [MVCSwagSummary('Reports', 'Export time report as CSV')]
    [MVCSwagParam(plBody, 'ExportRequest', 'Export parameters', TExportRequest)]
    [MVCSwagResponses(200, 'CSV file generated')]
    [MVCSwagResponses(400, 'Invalid export parameters')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces('text/csv')]
    procedure ExportAsCSV;

    /// <summary>Benutzer-Statistiken</summary>
    [MVCPath('/stats')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Reports', 'Get user statistics overview')]
    [MVCSwagResponses(200, 'User statistics retrieved')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetUserStatistics;
  end;

implementation

uses
  System.StrUtils, System.SysUtils, System.DateUtils, System.Math, System.JSON,
  MVCFramework.Logger,
  TimeTrackApi.DataModule;

{ TReportsController }


function TReportsController.ParseDateParam(const ParamName: string; DefaultValue: TDateTime): TDateTime;
var
  dateStr: string;
begin
  dateStr := Context.Request.QueryStringParam(ParamName);
  if Trim(dateStr) = '' then
    Result := DefaultValue
  else
  begin
    try
      Result := ISO8601ToDate(dateStr + 'T00:00:00', False);
    except
      Result := DefaultValue;
    end;
  end;
end;

function TReportsController.FormatMinutesAsHours(Minutes: Integer): string;
var
  Hours: Integer;
  Mins: Integer;
begin
  Hours := Minutes div 60;
  Mins := Minutes mod 60;
  Result := Format('%d:%02d', [Hours, Mins]);
end;

function TReportsController.GenerateTimeReport(UserId: Integer; StartDate, EndDate: TDateTime; ProjectId: Integer; GroupBy: string): TTimeReportResponse;
var
  timeEntries: TTimeEntryArray;
  projects: TProjectArray;
  projectsDict: TDictionary<Integer, TProject>;
  i: Integer;
//  currentDate: TDateTime;
//  dailySummary: TDailySummary;
  projectSummariesDict: TDictionary<Integer, TProjectSummary>;
  projectSummary: TProjectSummary;
  project: TProject;
begin
  Result := TTimeReportResponse.Create;

  try
    // Basis-Daten laden
    timeEntries := TdmDataAccess.DBGetTimeEntriesForPeriod(UserId, StartDate, EndDate, ProjectId);
    projects := TdmDataAccess.DBGetUserProjects(UserId);

    // Projekte in Dictionary für Performance
    projectsDict := TDictionary<Integer, TProject>.Create;
    try
      for i := Low(projects) to High(projects) do
        projectsDict.Add(projects[i].Project_ID, projects[i]);

      // Report-Header setzen
      Result.StartDate := FormatDateTime('yyyy-mm-dd', StartDate);
      Result.EndDate := FormatDateTime('yyyy-mm-dd', EndDate);
      Result.GroupBy := GroupBy;
      Result.TotalEntries := Length(timeEntries);

      // Projekt-Summaries erstellen
      projectSummariesDict := TDictionary<Integer, TProjectSummary>.Create;
      try
        // Durch alle Zeiteinträge iterieren
        for i := Low(timeEntries) to High(timeEntries) do
        begin
          if projectsDict.TryGetValue(timeEntries[i].Project_ID, project) then
          begin
            // Gesamtsummen
            Result.TotalMinutes := Result.TotalMinutes + timeEntries[i].GetDurationMinutes;
            Result.NetMinutes := Result.NetMinutes + timeEntries[i].GetNetDurationMinutes;

            // Projekt-Summary aktualisieren
            if not projectSummariesDict.TryGetValue(project.Project_ID, projectSummary) then
            begin
              projectSummary := TProjectSummary.Create;
              projectSummary.ProjectId := project.Project_ID;
              projectSummary.ProjectName := project.Project_Name;
              projectSummary.ClientName := project.Client_Name;
              projectSummary.TotalMinutes := 0;
              projectSummary.NetMinutes := 0;
              projectSummary.EntryCount := 0;
              projectSummariesDict.Add(project.Project_ID, projectSummary);
              Result.ProjectSummaries.Add(projectSummary);
            end;

            projectSummary.TotalMinutes := projectSummary.TotalMinutes + timeEntries[i].GetDurationMinutes;
            projectSummary.NetMinutes := projectSummary.NetMinutes + timeEntries[i].GetNetDurationMinutes;
            projectSummary.EntryCount := projectSummary.EntryCount + 1;
            projectSummary.LastActivity := timeEntries[i].Activity;
          end;
        end;

      finally
        projectSummariesDict.Free;
      end;

    finally
      projectsDict.Free;
    end;

  except
    Result.Free;
    raise;
  end;
end;

procedure TReportsController.GetTimeReport;
var
  userId: Integer;
  startDate, endDate: TDateTime;
  projectId: Integer;
  groupBy: string;
  response: TTimeReportResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Parameter parsen
    startDate := ParseDateParam('start_date', EncodeDate(YearOf(Now), MonthOf(Now), 1));
    endDate := ParseDateParam('end_date', Now);
    projectId := StrToIntDef(Context.Request.QueryStringParam('project_id'), 0);
    groupBy := Context.Request.QueryStringParam('group_by');

    if Trim(groupBy) = '' then
      groupBy := 'day';

    // Validierung
    if startDate > endDate then
    begin
      Render(400, '{"error": "Start date must be before end date"}');
      Exit;
    end;

    // Report generieren
    response := GenerateTimeReport(userId, startDate, endDate, projectId, groupBy);
    try
      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetTimeReport Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TReportsController.GetDetailedTimeReport;
var
  userId: Integer;
  reportRequest: TTimeReportRequest;
  response: TTimeReportResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    reportRequest := Context.Request.BodyAs<TTimeReportRequest>;
    try
      if not reportRequest.IsDataValid then
      begin
        Render(400, '{"error": "Invalid report request data"}');
        Exit;
      end;

      response := GenerateTimeReport(
        userId,
        reportRequest.GetStartDateTime,
        reportRequest.GetEndDateTime,
        reportRequest.ProjectId,
        reportRequest.GroupBy
      );
      try
        Render(response);
      finally
        response.Free;
      end;

    finally
      reportRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetDetailedTimeReport Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TReportsController.GetProjectOverview;
var
  userId: Integer;
  //startDate, endDate: TDateTime;
  projects: TProjectArray;
  response: TProjectListResponse;
  i: Integer;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;


    //startDate := ParseDateParam('start_date', EncodeDate(YearOf(Now), MonthOf(Now), 1));
    //endDate := ParseDateParam('end_date', Now);
    { TODO -oALL -cErweiterung : zusätzliche Zeiteinschränkung einbauen }
    projects := TdmDataAccess.DBGetUserProjects(userId);

    response := TProjectListResponse.Create;
    try
      for i := Low(projects) to High(projects) do
        response.AddProject(projects[i]);

      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetProjectOverview Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TReportsController.GetDailyStatistics;
var
  userId: Integer;
  startDate, endDate: TDateTime;
  timeEntries: TTimeEntryArray;
  dailyStats: TDictionary<string, TDailySummary>;
  response: TObjectList<TDailySummary>;
  i: Integer;
  dateKey: string;
  dailySummary: TDailySummary;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    startDate := ParseDateParam('start_date', EncodeDate(YearOf(Now), MonthOf(Now), 1));
    endDate := ParseDateParam('end_date', Now);

    timeEntries := TdmDataAccess.DBGetTimeEntriesForPeriod(userId, startDate, endDate, 0);

    dailyStats := TDictionary<string, TDailySummary>.Create;
    response := TObjectList<TDailySummary>.Create(True);
    try
      // Durch Zeiteinträge gruppieren nach Datum
      for i := Low(timeEntries) to High(timeEntries) do
      begin
        dateKey := FormatDateTime('yyyy-mm-dd', timeEntries[i].Start_Time);

        if not dailyStats.TryGetValue(dateKey, dailySummary) then
        begin
          dailySummary := TDailySummary.Create;
          dailySummary.Date := dateKey;
          dailyStats.Add(dateKey, dailySummary);
          response.Add(dailySummary);
        end;

        dailySummary.TotalMinutes := dailySummary.TotalMinutes + timeEntries[i].GetDurationMinutes;
        dailySummary.NetMinutes := dailySummary.NetMinutes + timeEntries[i].GetNetDurationMinutes;
        dailySummary.EntryCount := dailySummary.EntryCount + 1;
      end;

      Render(response);

    finally
      dailyStats.Free;
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetDailyStatistics Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

function TReportsController.CreateCSVContent(const TimeEntries: TTimeEntryArray; const Projects: TProjectArray): string;
var
  csv: TStringBuilder;
  i, j: Integer;
  project: TProject;
  projectFound: Boolean;
begin
  csv := TStringBuilder.Create;
  try
    // CSV Header
    csv.AppendLine('Date,Start Time,End Time,Project,Client,Activity,Duration (Hours),Net Duration (Hours),Pause (Min)');

    // Datenzeilen
    for i := Low(TimeEntries) to High(TimeEntries) do
    begin
      // Projekt finden
      projectFound := False;
      for j := Low(Projects) to High(Projects) do
      begin
        if Projects[j].Project_ID = TimeEntries[i].Project_ID then
        begin
          project := Projects[j];
          projectFound := True;
          Break;
        end;
      end;

      if not projectFound then
      begin
        project.Project_Name := 'Unknown Project';
        project.Client_Name := 'Unknown Client';
      end;

      csv.Append(FormatDateTime('yyyy-mm-dd', TimeEntries[i].Start_Time));
      csv.Append(',');
      csv.Append(FormatMinutesAsHours(TimeEntries[i].GetDurationMinutes));
      csv.Append(',');
      csv.Append(FormatMinutesAsHours(TimeEntries[i].GetNetDurationMinutes));
      csv.Append(',');
      csv.Append(TimeEntries[i].Pause_Minutes.ToString);
      csv.AppendLine;
    end;

    Result := csv.ToString;
  finally
    csv.Free;
  end;
end;

procedure TReportsController.ExportAsCSV;
var
  userId: Integer;
  exportRequest: TExportRequest;
  timeEntries: TTimeEntryArray;
  projects: TProjectArray;
  csvContent: string;
  fileName: string;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    exportRequest := Context.Request.BodyAs<TExportRequest>;
    try
      if not exportRequest.IsDataValid then
      begin
        Render(400, '{"error": "Invalid export request data"}');
        Exit;
      end;

      if exportRequest.Format <> 'csv' then
      begin
        Render(400, '{"error": "This endpoint only supports CSV format"}');
        Exit;
      end;

      // Daten laden
      timeEntries := TdmDataAccess.DBGetTimeEntriesForPeriod(
        userId,
        exportRequest.GetStartDateTime,
        exportRequest.GetEndDateTime,
        exportRequest.ProjectId
      );

      projects := TdmDataAccess.DBGetUserProjects(userId);

      // CSV generieren
      csvContent := CreateCSVContent(timeEntries, projects);

      // Dateiname generieren
      fileName := Format('timetracking_%s_%s.csv', [
        FormatDateTime('yyyymmdd', exportRequest.GetStartDateTime),
        FormatDateTime('yyyymmdd', exportRequest.GetEndDateTime)
      ]);

      // Response headers setzen
      Context.Response.ContentType := 'text/csv';
      Context.Response.CustomHeaders.Values['Content-Disposition'] :=
        'attachment; filename="' + fileName + '"';

      Render(csvContent);

    finally
      exportRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('ExportAsCSV Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TReportsController.GetUserStatistics;
var
  userId: Integer;
  currentMonth, lastMonth: TDateTime;
  currentMonthEntries, lastMonthEntries: TTimeEntryArray;
  projects: TProjectArray;
  stats: TJSONObject;
  currentMonthMinutes, lastMonthMinutes: Integer;
  i: Integer;
  hasActiveTracking: Boolean;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Zeiträume definieren
    currentMonth := EncodeDate(YearOf(Now), MonthOf(Now), 1);
    lastMonth := IncMonth(currentMonth, -1);

    // Daten laden
    currentMonthEntries := TdmDataAccess.DBGetTimeEntriesForPeriod(userId, currentMonth, Now, 0);
    lastMonthEntries := TdmDataAccess.DBGetTimeEntriesForPeriod(userId, lastMonth, IncMonth(lastMonth, 1) - 1, 0);
    projects := TdmDataAccess.DBGetUserProjects(userId);

    // Aktives Tracking prüfen
    hasActiveTracking := TdmDataAccess.DBGetActiveTimeEntry(userId).Entry_ID > 0;

    // Minuten berechnen
    currentMonthMinutes := 0;
    for i := Low(currentMonthEntries) to High(currentMonthEntries) do
      currentMonthMinutes := currentMonthMinutes + currentMonthEntries[i].GetNetDurationMinutes;

    lastMonthMinutes := 0;
    for i := Low(lastMonthEntries) to High(lastMonthEntries) do
      lastMonthMinutes := lastMonthMinutes + lastMonthEntries[i].GetNetDurationMinutes;

    // JSON Response erstellen
    stats := TJSONObject.Create;
    try
      stats.AddPair('total_projects', Length(projects));
      stats.AddPair('current_month_minutes', currentMonthMinutes);
      stats.AddPair('current_month_hours', FormatMinutesAsHours(currentMonthMinutes));
      stats.AddPair('last_month_minutes', lastMonthMinutes);
      stats.AddPair('last_month_hours', FormatMinutesAsHours(lastMonthMinutes));
      stats.AddPair('current_month_entries', Length(currentMonthEntries));
      stats.AddPair('last_month_entries', Length(lastMonthEntries));
      stats.AddPair('has_active_tracking', hasActiveTracking);

      if currentMonthMinutes > 0 then
        stats.AddPair('average_minutes_per_day', Round(currentMonthMinutes / DayOf(Now)))
      else
        stats.AddPair('average_minutes_per_day', 0);

      Render(stats.ToJSON);
    finally
      stats.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetUserStatistics Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

end.
