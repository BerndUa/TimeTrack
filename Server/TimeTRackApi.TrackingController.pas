unit TimeTRackApi.TrackingController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Nullables, MVCFramework.Serializer.Commons,
  System.Generics.Collections, MVCFramework.Swagger.Commons;

type
  TTimeEntry = class
  end;

  [MVCPath('/api/tracking')]
  TTrackingController = class(TMVCController)
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public
    [MVCPath('/start/($projectId)')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Tracking', 'Start Tracking', 'startTracking')]
    [MVCSwagParam(plPath, 'projectId', 'Project ID', ptInteger, True)]
    [MVCSwagResponses(201, 'Created', TTimeEntry, False)]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure StartTracking(const projectId: Integer);

    [MVCPath('/($timeEntryId)')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Tracking', 'Get Time Entry', 'getTimeEntry')]
    [MVCSwagParam(plPath, 'timeEntryId', 'Time Entry ID', ptInteger, True)]
    [MVCSwagResponses(200, 'Success', TTimeEntry, False)]
    [MVCSwagResponses(404, 'Not Found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetTimeEntry(const timeEntryId: Integer);
  end;

implementation

uses
  System.StrUtils, System.SysUtils, MVCFramework.Logger;


procedure TTrackingController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TTrackingController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

procedure TTrackingController.StartTracking(const projectId: Integer);
var
  LTracking: TTimeEntry;
begin
  LTracking := TTimeEntry.Create;
  Render(201, LTracking);
end;

procedure TTrackingController.GetTimeEntry(const timeEntryId: Integer);
begin
  Render(404);
end;

end.
