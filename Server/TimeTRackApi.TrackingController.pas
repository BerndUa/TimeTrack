unit TimeTrackApi.TrackingController;

interface

uses
  MVCFramework,
  MVCFramework.Commons,
  MVCFramework.Nullables,
  MVCFramework.Serializer.Commons,
  MVCFramework.Swagger.Commons,
  System.Generics.Collections;

type

  TTimeEntries = class(TObject);
  TTimeEntry = class(TObject);

  [MVCPath('/api/tracking')]
  TTrackingController = class(TMVCController)
  public
    [MVCPath('/stop')]
    [MVCHTTPMethod([httpPUT])]
    [MVCDoc('Stop time tracking')]
    [MVCSwagSummary('Tracking', 'stop time tracking for an Time Entry', 'addPause')]
    [MVCSwagParam(plBody, 'TimeEntryId', 'Time Entry ID', ptInteger, True)]
    [MVCSwagResponses(200, 'TimeEntry', TTimeEntry)]
    [MVCSwagResponses(404, 'Time Entry not found', TMVCErrorResponse)]
    procedure Stop(ATimeEntryId: Integer);

    [MVCPath('/addPause')]
    [MVCHTTPMethod([httpPUT])]
    [MVCDoc('Add pause to an time entry')]
    [MVCSwagSummary('Tracking', 'Add Pause to an Time Entry', 'addPause')]
    [MVCSwagParam(plBody, 'TimeEntryId', 'Time Entry ID', ptInteger, True)]
    [MVCSwagParam(plBody, 'PauseMinutes', 'Value for Pause in Minutes', ptInteger, True)]
    [MVCSwagResponses(200, 'TimeEntry', TTimeEntry)]
    [MVCSwagResponses(404, 'Time Entry not found', TMVCErrorResponse)]
    procedure AddPause(ATimeEntryId: Integer; APauseMinutes: Integer);
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public

  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  MVCFramework.Logger;

procedure TTrackingController.AddPause(ATimeEntryId: Integer; APauseMinutes: Integer);
begin
  //const TimeEntryId = Context.Request.Params['TimeEntryId'].ToInteger;
  //const Pause = Context.Request.Params['PauseMinutes'].ToInteger;
  //const TimeEntry = TimeEntryies.ById(ATimeEntryId);
  //TimeEntry.AddPause(Pause);
  //Render(TimeEntry);
  // Is Tracking Running?
end;

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

procedure TTrackingController.Stop(ATimeEntryId: Integer);
begin
  // TBD
  // Is Tracking Running?
end;

end.
