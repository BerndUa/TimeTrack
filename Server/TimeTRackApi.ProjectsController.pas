unit TimeTrackApi.ProjectsController;

interface

uses
  System.Generics.Collections,
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  MVCFramework.Swagger.Commons, MVCFramework.Middleware.Authentication.RoleBasedAuthHandler,
  TimeTrackApi.ApiTypes, TimeTrackApi.BaseController;



type
  [MVCPath('/api/projects')]
  [MVCRequiresAuthentication]
  [MVCRequiresRole('registereduser')]
  [MVCSwagAuthentication(atJsonWebToken)]
  TProjectsController = class(TBaseController)
  public
    /// <summary>Alle Projekte des angemeldeten Benutzers abrufen</summary>
    [MVCPath('')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Projects', 'Get all projects for current user')]
    [MVCSwagResponses(200, 'Projects retrieved successfully', TProjectListResponse)]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetProjects;

    /// <summary>Einzelnes Projekt abrufen</summary>
    [MVCPath('/($ProjectId)')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Projects', 'Get specific project by ID')]
    [MVCSwagParam(plPath, 'ProjectId', 'Project ID', ptInteger, true)]
    [MVCSwagResponses(200, 'Project retrieved successfully', TProjectResponse)]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(404, 'Project not found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetProject(ProjectId: Integer);

    /// <summary>Neues Projekt anlegen</summary>
    [MVCPath('')]
    [MVCHTTPMethod([httpPOST])]
    [MVCSwagSummary('Projects', 'Create new project')]
    [MVCSwagParam(plBody, 'ProjectData', 'Project data', TProjectData)]
    [MVCSwagResponses(201, 'Project created successfully', TProjectResponse)]
    [MVCSwagResponses(400, 'Invalid project data')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure CreateProject;

    /// <summary>Projekt aktualisieren</summary>
    [MVCPath('/($ProjectId)')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Projects', 'Update existing project')]
    [MVCSwagParam(plPath, 'ProjectId', 'Project ID', ptInteger, true)]
    [MVCSwagParam(plBody, 'ProjectData', 'Updated project data', TProjectData)]
    [MVCSwagResponses(200, 'Project updated successfully', TProjectResponse)]
    [MVCSwagResponses(400, 'Invalid project data')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(404, 'Project not found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure UpdateProject(ProjectId: Integer);

    /// <summary>Projekt löschen</summary>
    [MVCPath('/($ProjectId)')]
    [MVCHTTPMethod([httpDELETE])]
    [MVCSwagSummary('Projects', 'Delete project')]
    [MVCSwagParam(plPath, 'ProjectId', 'Project ID', ptInteger, true)]
    [MVCSwagResponses(204, 'Project deleted successfully')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(404, 'Project not found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    procedure DeleteProject(ProjectId: Integer);
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  MVCFramework.Logger,
  TimeTrackApi.DataModule, TimeTrackApi.Model.Entities;

{ TProjectsController }

procedure TProjectsController.GetProjects;
var
  userId: Integer;
  projects: TProjectArray;
  response: TProjectListResponse;
  i: Integer;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "Use JWT authentication"}');
      Exit;
    end;
    // Projekte aus Datenbank laden
    projects := TdmDataAccess.DBGetUserProjects(userId);
    // Response-Objekt erstellen
    response := TProjectListResponse.Create;
    try
      // Projekte zur Response hinzufügen
      for i := Low(projects) to High(projects) do
        response.AddProject(projects[i]);
      // Response zurückgeben
      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetProjects Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TProjectsController.GetProject(ProjectId: Integer);
var
  userId: Integer;
  project: TProject;
  response: TProjectResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
       Render(401, '{"error": "Use JWT authentication"}');
      Exit;
    end;

    // Projekt aus Datenbank laden
    project := TdmDataAccess.DBGetProject(ProjectId, userId);

    if project.Project_ID = 0 then
    begin
      Render(404, '{"error": "Project not found"}');
      Exit;
    end;

    // Response-Objekt erstellen
    response := TProjectResponse.CreateFromRecord(project);
    try
      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetProject Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TProjectsController.CreateProject;
var
  userId: Integer;
  projectData: TProjectData;
  project: TProject;
  newProjectId: Integer;
  response: TProjectResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Request-Daten parsen
    projectData := Context.Request.BodyAs<TProjectData>;
    try
      // Eingabe validieren
      if not projectData.IsDataValid then
      begin
        Render(400, '{"error": "Project name and client name are required"}');
        Exit;
      end;

      // Projekt-Record erstellen
      project := projectData.GetAsProjectRecord(userId);

      // In Datenbank speichern
      newProjectId := TdmDataAccess.DBInsertProject(project);

      if newProjectId = 0 then
      begin
        Render(500, '{"error": "Failed to create project"}');
        Exit;
      end;

      // Erstelltes Projekt laden für Response
      project := TdmDataAccess.DBGetProject(newProjectId, userId);

      // Response erstellen
      response := TProjectResponse.CreateFromRecord(project);
      try
        Context.Response.StatusCode := 201;
        Render(response);
      finally
        response.Free;
      end;

    finally
      projectData.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('CreateProject Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TProjectsController.UpdateProject(ProjectId: Integer);
var
  userId: Integer;
  projectData: TProjectData;
  existingProject: TProject;
  updatedProject: TProject;
  success: Boolean;
  response: TProjectResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Prüfen ob Projekt existiert und dem User gehört
    existingProject := TdmDataAccess.DBGetProject(ProjectId, userId);
    if existingProject.Project_ID = 0 then
    begin
      Render(404, '{"error": "Project not found"}');
      Exit;
    end;

    // Request-Daten parsen
    projectData := Context.Request.BodyAs<TProjectData>;
    try
      // Eingabe validieren
      if not projectData.IsDataValid then
      begin
        Render(400, '{"error": "Project name and client name are required"}');
        Exit;
      end;

      // Aktualisiertes Projekt-Record erstellen
      updatedProject := projectData.GetAsProjectRecord(userId);
      updatedProject.Project_ID := ProjectId;
      updatedProject.Created_At := existingProject.Created_At; // Original-Erstellungsdatum beibehalten

      // In Datenbank aktualisieren
      success := TdmDataAccess.DBUpdateProject(updatedProject);

      if not success then
      begin
        Render(500, '{"error": "Failed to update project"}');
        Exit;
      end;

      // Aktualisiertes Projekt laden für Response
      updatedProject := TdmDataAccess.DBGetProject(ProjectId, userId);

      // Response erstellen
      response := TProjectResponse.CreateFromRecord(updatedProject);
      try
        Render(response);
      finally
        response.Free;
      end;

    finally
      projectData.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('UpdateProject Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TProjectsController.DeleteProject(ProjectId: Integer);
var
  userId: Integer;
  existingProject: TProject;
  success: Boolean;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Prüfen ob Projekt existiert und dem User gehört
    existingProject := TdmDataAccess.DBGetProject(ProjectId, userId);
    if existingProject.Project_ID = 0 then
    begin
      Render(404, '{"error": "Project not found"}');
      Exit;
    end;

    // Projekt löschen (Soft Delete)
    success := TdmDataAccess.DBDeleteProject(ProjectId, userId);

    if not success then
    begin
      Render(500, '{"error": "Failed to delete project"}');
      Exit;
    end;

    // 204 No Content - erfolgreich gelöscht
    Context.Response.StatusCode := 204;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('DeleteProject Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

end.
