unit TimeTrackApi.BaseController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  TimeTrackApi.ApiTypes, MVCFramework.Swagger.Commons,
  MVCFramework.Middleware.Authentication.RoleBasedAuthHandler,
  System.Generics.Collections;

type
  [MVCRequiresAuthentication]
  [MVCRequiresRole('registereduser')]
  [MVCSwagAuthentication(atJsonWebToken)]
  TBaseController = class(TMVCController)
  protected
    function GetCurrentUserId: Integer;
    function ParseDateParam(const ParamName: string; DefaultValue: TDateTime): TDateTime;
  end;

implementation

uses
  System.StrUtils, System.SysUtils, System.DateUtils,
  MVCFramework.Logger,
  TimeTrackApi.DataModule, TimeTrackApi.Model.Entities;

{ TBaseController }

function TBaseController.GetCurrentUserId: Integer;
var
  savedUserId : string;
begin
  // User-ID aus JWT-Token bzw. Session holen
  // Die JWT-Middleware setzt die User-ID in die Session
  if Assigned(Context.LoggedUser) and
     Assigned(Context.LoggedUser.CustomData) and
     Context.LoggedUser.CustomData.TryGetValue('userid',savedUserId) then
    Result := StrToIntDef(savedUserId, 0)
  else
    Result :=0;
end;


function TBaseController.ParseDateParam(const ParamName: string; DefaultValue: TDateTime): TDateTime;
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


end.
