unit TimeTrackApi.TrackingController;

interface

uses
  System.Generics.Collections,
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  MVCFramework.Swagger.Commons, MVCFramework.Middleware.Authentication.RoleBasedAuthHandler,
  TimeTrackApi.ApiTypes, TimeTrackApi.BaseController;


type
  [MVCPath('/api/tracking')]
  [MVCRequiresAuthentication]
  [MVCRequiresRole('registereduser')]
  [MVCSwagAuthentication(atJsonWebToken)]
  TTrackingController = class(TBaseController)
  public
    /// <summary>Aktuellen Tracking-Status des Benutzers abrufen</summary>
    [MVCPath('/status')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Tracking', 'Get current tracking status')]
    [MVCSwagResponses(200, 'Current tracking status', TTrackingStatusResponse)]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetTrackingStatus;

    /// <summary>Neue Zeiterfassung starten</summary>
    [MVCPath('/start')]
    [MVCHTTPMethod([httpPOST])]
    [MVCSwagSummary('Tracking', 'Start time tracking')]
    [MVCSwagParam(plBody, 'TrackingData', 'Tracking start data', TStartTrackingRequest)]
    [MVCSwagResponses(201, 'Tracking started successfully', TTimeEntryResponse)]
    [MVCSwagResponses(400, 'Invalid request data or tracking already active')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(404, 'Project not found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure StartTracking;

    /// <summary>Aktive Zeiterfassung stoppen</summary>
    [MVCPath('/stop')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Tracking', 'Stop active time tracking')]
    [MVCSwagResponses(200, 'Tracking stopped successfully', TTimeEntryResponse)]
    [MVCSwagResponses(400, 'No active tracking found')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure StopTracking;

    /// <summary>Pausenzeit zur aktiven Zeiterfassung hinzufügen</summary>
    [MVCPath('/pause')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Tracking', 'Add pause time to active tracking')]
    [MVCSwagParam(plBody, 'PauseData', 'Pause data', TAddPauseRequest)]
    [MVCSwagResponses(200, 'Pause added successfully', TTimeEntryResponse)]
    [MVCSwagResponses(400, 'No active tracking found or invalid pause data')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure AddPause;

    /// <summary>Aktive Zeiterfassung abrufen</summary>
    [MVCPath('/current')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Tracking', 'Get current active time entry')]
    [MVCSwagResponses(200, 'Active time entry', TTimeEntryResponse)]
    [MVCSwagResponses(204, 'No active tracking')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetCurrentTimeEntry;

    /// <summary>Spezifischen Zeiteintrag abrufen</summary>
    [MVCPath('/entries/($EntryId)')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Tracking', 'Get specific time entry')]
    [MVCSwagParam(plPath, 'EntryId', 'Time Entry ID', ptInteger, true)]
    [MVCSwagResponses(200, 'Time entry found', TTimeEntryResponse)]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(404, 'Time entry not found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetTimeEntry(EntryId: Integer);

    /// <summary>Zeiteinträge für einen bestimmten Zeitraum abrufen</summary>
    [MVCPath('/entries')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Tracking', 'Get time entries for date range')]
    [MVCSwagParam(plQuery, 'start_date', 'Start date (YYYY-MM-DD)', ptString, false)]
    [MVCSwagParam(plQuery, 'end_date', 'End date (YYYY-MM-DD)', ptString, false)]
    [MVCSwagParam(plQuery, 'project_id', 'Filter by project ID', ptInteger, false)]
    [MVCSwagResponses(200, 'Time entries retrieved', TTimeEntryListResponse)]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetTimeEntries;

    /// <summary>Zeiteneintrag nachträglich bearbeiten</summary>
    [MVCPath('/entries/($EntryId)')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Tracking', 'Update time entry')]
    [MVCSwagParam(plPath, 'EntryId', 'Time Entry ID', ptInteger, true)]
    [MVCSwagParam(plBody, 'EntryData', 'Updated entry data', TUpdateTimeEntryRequest)]
    [MVCSwagResponses(200, 'Time entry updated', TTimeEntryResponse)]
    [MVCSwagResponses(400, 'Invalid data')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(404, 'Time entry not found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure UpdateTimeEntry(EntryId: Integer);
  end;


implementation

uses
  System.SysUtils, System.StrUtils, System.DateUtils,
  MVCFramework.Logger, TimeTrackApi.DataModule, TimeTrackApi.Model.Entities;

{ TTrackingController }



procedure TTrackingController.GetTrackingStatus;
var
  userId: Integer;
  activeEntry: TTimeEntry;
  projects: TProjectArray;
  response: TTrackingStatusResponse;
  project: TProject;
  i: Integer;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    response := TTrackingStatusResponse.Create;
    try
      // Aktives Tracking prüfen
      activeEntry := TdmDataAccess.DBGetActiveTimeEntry(userId);
      response.IsTracking := activeEntry.Entry_ID > 0;

      if response.IsTracking then
      begin
        // Projekt-Daten für aktiven Eintrag laden
        project := TdmDataAccess.DBGetProject(activeEntry.Project_ID, userId);
        response.CurrentEntry := TTimeEntryResponse.CreateFromRecord(activeEntry, project);
      end;

      // Verfügbare Projekte laden
      projects := TdmDataAccess.DBGetUserProjects(userId);
      for i := Low(projects) to High(projects) do
        response.AvailableProjects.Add(TProjectResponse.CreateFromRecord(projects[i]));

      Render(response);

    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetTrackingStatus Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TTrackingController.StartTracking;
var
  userId: Integer;
  startRequest: TStartTrackingRequest;
  activeEntry: TTimeEntry;
  project: TProject;
  newEntry: TTimeEntry;
  newEntryId: Integer;
  response: TTimeEntryResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Prüfen ob bereits ein Tracking läuft
    activeEntry := TdmDataAccess.DBGetActiveTimeEntry(userId);
    if activeEntry.Entry_ID > 0 then
    begin
      Render(400, '{"error": "Tracking is already active. Stop current tracking first."}');
      Exit;
    end;

    // Request-Daten parsen
    startRequest := Context.Request.BodyAs<TStartTrackingRequest>;
    try
      // Eingabe validieren
      if not startRequest.IsDataValid then
      begin
        Render(400, '{"error": "Project ID and activity are required"}');
        Exit;
      end;

      // Projekt existiert und gehört User?
      project := TdmDataAccess.DBGetProject(startRequest.ProjectId, userId);
      if project.Project_ID = 0 then
      begin
        Render(404, '{"error": "Project not found"}');
        Exit;
      end;

      // Neuen Time-Entry erstellen
      newEntry.Clear;
      newEntry.User_ID := userId;
      newEntry.Project_ID := startRequest.ProjectId;
      newEntry.Activity := startRequest.Activity;
      newEntry.Start_Time := startRequest.GetStartDateTime;
      newEntry.Pause_Minutes := 0;

      // In Datenbank speichern
      newEntryId := TdmDataAccess.DBStartTimeEntry(newEntry);

      if newEntryId = 0 then
      begin
        Render(500, '{"error": "Failed to start tracking"}');
        Exit;
      end;

      // Gestarteten Eintrag laden für Response
      newEntry := TdmDataAccess.DBGetTimeEntry(newEntryId, userId);

      // Response erstellen
      response := TTimeEntryResponse.CreateFromRecord(newEntry, project);
      try
        Context.Response.StatusCode := 201;
        Render(response);
      finally
        response.Free;
      end;

    finally
      startRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('StartTracking Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TTrackingController.StopTracking;
var
  userId: Integer;
  activeEntry: TTimeEntry;
  project: TProject;
  success: Boolean;
  stoppedEntry: TTimeEntry;
  response: TTimeEntryResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Aktives Tracking finden
    activeEntry := TdmDataAccess.DBGetActiveTimeEntry(userId);
    if activeEntry.Entry_ID = 0 then
    begin
      Render(400, '{"error": "No active tracking found"}');
      Exit;
    end;

    // Tracking stoppen
    success := TdmDataAccess.DBStopTimeEntry(activeEntry.Entry_ID, userId);

    if not success then
    begin
      Render(500, '{"error": "Failed to stop tracking"}');
      Exit;
    end;

    // Gestoppten Eintrag laden für Response
    stoppedEntry := TdmDataAccess.DBGetTimeEntry(activeEntry.Entry_ID, userId);
    project := TdmDataAccess.DBGetProject(stoppedEntry.Project_ID, userId);

    // Response erstellen
    response := TTimeEntryResponse.CreateFromRecord(stoppedEntry, project);
    try
      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('StopTracking Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TTrackingController.AddPause;
var
  userId: Integer;
  pauseRequest: TAddPauseRequest;
  activeEntry: TTimeEntry;
  project: TProject;
  success: Boolean;
  updatedEntry: TTimeEntry;
  response: TTimeEntryResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Aktives Tracking finden
    activeEntry := TdmDataAccess.DBGetActiveTimeEntry(userId);
    if activeEntry.Entry_ID = 0 then
    begin
      Render(400, '{"error": "No active tracking to add pause to"}');
      Exit;
    end;

    // Request-Daten parsen
    pauseRequest := Context.Request.BodyAs<TAddPauseRequest>;
    try
      // Eingabe validieren
      if not pauseRequest.IsDataValid then
      begin
        Render(400, '{"error": "Pause minutes must be greater than 0"}');
        Exit;
      end;

      // Pause hinzufügen
      success := TdmDataAccess.DBAddPauseToTimeEntry(activeEntry.Entry_ID, userId, pauseRequest.PauseMinutes);

      if not success then
      begin
        Render(500, '{"error": "Failed to add pause"}');
        Exit;
      end;

      // Aktualisierten Eintrag laden für Response
      updatedEntry := TdmDataAccess.DBGetTimeEntry(activeEntry.Entry_ID, userId);
      project := TdmDataAccess.DBGetProject(updatedEntry.Project_ID, userId);

      // Response erstellen
      response := TTimeEntryResponse.CreateFromRecord(updatedEntry, project);
      try
        Render(response);
      finally
        response.Free;
      end;

    finally
      pauseRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('AddPause Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TTrackingController.GetCurrentTimeEntry;
var
  userId: Integer;
  activeEntry: TTimeEntry;
  project: TProject;
  response: TTimeEntryResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Aktives Tracking finden
    activeEntry := TdmDataAccess.DBGetActiveTimeEntry(userId);
    if activeEntry.Entry_ID = 0 then
    begin
      Context.Response.StatusCode := 204; // No Content
      Exit;
    end;

    // Projekt-Daten laden
    project := TdmDataAccess.DBGetProject(activeEntry.Project_ID, userId);

    // Response erstellen
    response := TTimeEntryResponse.CreateFromRecord(activeEntry, project);
    try
      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetCurrentTimeEntry Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TTrackingController.GetTimeEntry(EntryId: Integer);
var
  userId: Integer;
  timeEntry: TTimeEntry;
  project: TProject;
  response: TTimeEntryResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Time-Entry laden
    timeEntry := TdmDataAccess.DBGetTimeEntry(EntryId, userId);
    if timeEntry.Entry_ID = 0 then
    begin
      Render(404, '{"error": "Time entry not found"}');
      Exit;
    end;

    // Projekt-Daten laden
    project := TdmDataAccess.DBGetProject(timeEntry.Project_ID, userId);

    // Response erstellen
    response := TTimeEntryResponse.CreateFromRecord(timeEntry, project);
    try
      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetTimeEntry Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TTrackingController.GetTimeEntries;
var
  userId: Integer;
  startDate, endDate: TDateTime;
  projectId: Integer;
  timeEntries: TTimeEntryArray;
  projects: TProjectArray;
  response: TTimeEntryListResponse;
  i: Integer;
  project: TProject;
  projectsDict: TDictionary<Integer, TProject>;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Parameter parsen
    startDate := ParseDateParam('start_date', EncodeDate(YearOf(Now), MonthOf(Now), 1)); // Monatsanfang
    endDate := ParseDateParam('end_date', Now); // Heute
    projectId := StrToIntDef(Context.Request.QueryStringParam('project_id'), 0);

    // Zeiteinträge laden
    timeEntries := TdmDataAccess.DBGetTimeEntriesForPeriod(userId, startDate, endDate, projectId);

    // Alle Projekte des Users laden für Lookup (Performance-Optimierung)
    projects := TdmDataAccess.DBGetUserProjects(userId);
    projectsDict := TDictionary<Integer, TProject>.Create;
    try
      // Projekte in Dictionary für schnelle Suche
      for i := Low(projects) to High(projects) do
        projectsDict.Add(projects[i].Project_ID, projects[i]);

      response := TTimeEntryListResponse.Create;
      try
        // Zeiteinträge zur Response hinzufügen
        for i := Low(timeEntries) to High(timeEntries) do
        begin
          // Entsprechendes Projekt finden
          if projectsDict.TryGetValue(timeEntries[i].Project_ID, project) then
          begin
            response.AddTimeEntry(timeEntries[i], project);
          end
          else
          begin
            // Fallback: Projekt einzeln laden
            project := TdmDataAccess.DBGetProject(timeEntries[i].Project_ID, userId);
            response.AddTimeEntry(timeEntries[i], project);
          end;
        end;

        Render(response);

      finally
        response.Free;
      end;

    finally
      projectsDict.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetTimeEntries Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

// Vollständige UpdateTimeEntry-Implementation für TrackingController

procedure TTrackingController.UpdateTimeEntry(EntryId: Integer);
var
  userId: Integer;
  updateRequest: TUpdateTimeEntryRequest;
  existingEntry: TTimeEntry;
  updatedEntry: TTimeEntry;
  project: TProject;
  success: Boolean;
  response: TTimeEntryResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Prüfen ob Entry existiert und dem User gehört
    existingEntry := TdmDataAccess.DBGetTimeEntry(EntryId, userId);
    if existingEntry.Entry_ID = 0 then
    begin
      Render(404, '{"error": "Time entry not found"}');
      Exit;
    end;

    // Prüfen ob Entry noch aktiv ist (aktive Entries können nicht bearbeitet werden)
    if existingEntry.IsActive then
    begin
      Render(400, '{"error": "Cannot update active time entry. Stop tracking first."}');
      Exit;
    end;

    // Request-Daten parsen
    updateRequest := Context.Request.BodyAs<TUpdateTimeEntryRequest>;
    try
      // Eingabe validieren
      if not updateRequest.IsDataValid then
      begin
        Render(400, '{"error": "Invalid entry data. Activity and start time are required."}');
        Exit;
      end;

      // Aktualisiertes TimeEntry-Record erstellen
      updatedEntry := existingEntry; // Kopie der existierenden Daten
      updatedEntry.Activity := updateRequest.Activity;
      updatedEntry.Start_Time := updateRequest.GetStartDateTime;
      updatedEntry.End_Time := updateRequest.GetEndDateTime;
      updatedEntry.Pause_Minutes := updateRequest.PauseMinutes;

      // Validierung: End_Time muss nach Start_Time liegen
      if (updatedEntry.End_Time > 0) and (updatedEntry.End_Time <= updatedEntry.Start_Time) then
      begin
        Render(400, '{"error": "End time must be after start time"}');
        Exit;
      end;

      // In Datenbank aktualisieren
      success := TdmDataAccess.DBUpdateTimeEntry(updatedEntry);

      if not success then
      begin
        Render(500, '{"error": "Failed to update time entry"}');
        Exit;
      end;

      // Aktualisierten Eintrag laden (für korrekte TOTAL_MINUTES vom DB-Trigger)
      updatedEntry := TdmDataAccess.DBGetTimeEntry(EntryId, userId);
      project := TdmDataAccess.DBGetProject(updatedEntry.Project_ID, userId);

      // Response erstellen
      response := TTimeEntryResponse.CreateFromRecord(updatedEntry, project);
      try
        Render(response);
      finally
        response.Free;
      end;

    finally
      updateRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('UpdateTimeEntry Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

end.
