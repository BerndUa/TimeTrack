unit TimeTRackApi.ProjectsController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  Projects, System.Generics.Collections;

type
  [MVCPath('/api')]
  TProjectsController = class(TMVCController)
    //Sample CRUD Actions for a "People" entity
    [MVCPath('/projects')]
    [MVCHTTPMethod([httpGET])]
    function GetProjects([MVCInject] ProjectList: TProjectList): IMVCResponse;

    [MVCPath('/projects/($ID)')]
    [MVCSwagSummary('Get Project', 'API Projects')]
    [MVCSwagResponses(200, 'Success', INDEX_JSON_SCHEMA)]
    [MVCSwagResponses(404, 'Not found')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    [MVCHTTPMethod([httpGET])]
    function GetProject(ID: Integer): TProject;

    [MVCPath('/projects')]
    [MVCSwagSummary('Create Project', 'API Projects')]
    [MVCSwagResponses(201, 'Created', INDEX_JSON_SCHEMA)]
    [MVCSwagResponses(400, 'Error found')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    [MVCHTTPMethod([httpPOST])]
    function CreateProject([MVCFromBody] Project: TProject): IMVCResponse;

    [MVCPath('/projects/($ID)')]
    [MVCHTTPMethod([httpPUT])]
    function UpdateProject(ID: Integer; [MVCFromBody] Project: TProject): IMVCResponse;

    [MVCPath('/projects/($ID)')]
    [MVCHTTPMethod([httpDELETE])]
    function DeleteProject(ID: Integer): IMVCResponse;

  end;

implementation

uses
  System.StrUtils, System.SysUtils, MVCFramework.Logger;


{ TProjectsController }

function TProjectsController.CreateProject(Project: TProject): IMVCResponse;
begin

end;

function TProjectsController.DeleteProject(ID: Integer): IMVCResponse;
begin

end;

function TProjectsController.GetProject(ID: Integer): TProject;
begin
  Result := TProject.Create;
end;

function TProjectsController.GetProjects(ProjectList: TProjectList): IMVCResponse;
begin

end;

function TProjectsController.UpdateProject(ID: Integer; Project: TProject): IMVCResponse;
begin

end;

end.
