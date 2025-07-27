unit TimeTrackApi.AuthController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  System.Generics.Collections, System.JSON, MVCFramework.Swagger.Commons,
  TimeTrackApi.ApiTypes;


type
  [MVCPath('/api/auth')]
  TAuthController = class(TMVCController)
  private
    function GetActivationUrl(const username, activationcode: string): string;
  public
    [MVCPath('/register')]
    [MVCSwagSummary('Authentication', 'registers a new user')]
    [MVCSwagResponses(201,'user registered')]
    [MVCSwagResponses(500,'Internal Server Error')]
    [MVCSwagResponses(400, 'Invalid request')]
    [MVCSwagResponses(409, 'user already exists')]
    [MVCSwagParam(plbody, 'Benutzerdaten', 'Daten des neuen Nutzers', TimeTrackApi.ApiTypes.TNewUserData)]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    [MVCHTTPMethod([httpPOST])]
    procedure RegisterUser;

    [MVCPath('/activate/($UserName)/($ActivationCode)')]
    [MVCSwagSummary('Authentication', 'activates a new user')]
    [MVCSwagParam(plPath, 'UserName', 'Benutzername', ptString, true)]
    [MVCSwagParam(plPath, 'ActivationCode', 'Aktivierungscode', ptString, true)]
    [MVCSwagResponses(202,'user activated')]
    [MVCSwagResponses(500,'Internal Server Error')]
    [MVCSwagResponses(400, 'Unknown Authentication Token')]
    [MVCProduces(TMVCMediaType.TEXT_PLAIN)]
    [MVCHTTPMethod([httpPOST])]
    function ActivateUser(UserName:string; ActivationCode: string): string;

    // Die DMVC JWT-Middleware übernimmt automatisch:
    // 1. Parsen jwtusername/jwtpassword aus dem Header
    // 2. Aufruf von TAuthenticationImpl.OnAuthentication
    // 3. Token-Generierung bei erfolgreichem Login
    // 4. Rückgabe des Tokens im Authorization Header
    // Kein eigener endpunkt nötig
    // Wenn die URL api/auth/login aufgerufen wird, übernimmt die JWT-Middleware
    // Erfolgreiche Antwort (Token wird automatisch im Header gesetzt)
    //function LoginUser: string;
  end;

implementation

uses
  Windows, MVCFramework.JWT,
  System.StrUtils, System.SysUtils, MVCFramework.Logger, TimeTrackApi.DBAccess,
  TimeTrackApi.DataModule, TimeTrackApi.Model.Entities;

//(UserName:string; ActivationCode: string)
function TAuthController.ActivateUser(UserName:string; ActivationCode: string): string;
begin
//  var username :string := Context.Request.Params['UserName'];
//  var ActivationCode: string := Context.Request.Params['ActivationCode'];
  TdmDataAccess.DbActivateUser(Username,ActivationCode);
  Context.Response.StatusCode := 202;
  Context.Response.ReasonString := 'user activated';
  Result := 'Danke fuer die Aktivierung';
end;


function TAuthController.GetActivationUrl(const username, activationcode: string): string;
var
  baseUrl, pathInfo, hostInfo: string;
  serverPort : integer;
begin
  serverport := dotEnv.Env('dmvc.server.port',8080);
  hostInfo := dotEnv.Env('AppHost');
  pathInfo := Context.Request.PathInfo;
  // letzte Aktion abschneiden
  Delete(pathInfo,pathInfo.LastIndexOf('/')+1,Length(PathInfo));
  baseUrl := Format('%s:%d%s/activate/', [hostInfo,serverport,pathinfo]);
  Result := baseUrl + URLEncode(username)+'/'+UrlEncode(ActivationCode);
end;



procedure TAuthController.RegisterUser;
var
  response: TJSONObject;
  newUser: TNewUserData;
  activationcode : string;
begin
  // möglich : manuell parsen
  // var lJSOn : TJSONObject := TJSONObject.ParseJSONValue(Context.Request.Body) As TJSONObject;
  // if lJSON=nil  then
  // begin
  //  Context.Response.StatusCode := 400;
  //   Context.Response.ReasonString := 'kein gueltiges JSON';

  // schneller -> direkt parsen: wenn keine Daten/falscher Inhalt Felder leer
  try
    newUser := Context.Request.BodyAs<TNewUserData>;
    try
      if not NewUser.IsDataValid then
      begin
        { TODO 5 -oALL -coptimizations : Alternative : detailierte Fehler liefern zu required fields etc }
        Context.Response.StatusCode := 400;
        Context.Response.ReasonString := 'Username, Password oder Email fehlen';
      end
      else
        begin
          // mit dem internen record weiterarbeiten
          var userData := newUser.GetAsUserData;
          activationcode := TdmDataAccess.DbInsertUser(newUser.GetAsUserData);
          // url erzeugen für die Aktivierung
          var activationUrl : string := GetActivationUrl(newUser.Username, activationcode);

          // zum Testen ist die Url im Response günstiger als einen Aktvierungsmail
          response := TJSONObject.Create;
          response.AddPair('activationlink', activationUrl);
          { TODO -oALL -cOptimization : optional hier zusätzlich Aktivierungsmail erzeugen}
          Context.Response.Content := response.ToJSON;
          Context.Response.StatusCode := 201;
        end;
    finally
      FreeAndNil(newUser);
    end;
  except
    On E: Exception do
    begin
      { TODO 5 -oALL -coptimizations : logging und Details NUR im Dev-Modus, detaillierte Fehler sind Angriffsvektoren }
      {$IFDEF DEBUG}
        raise;
      {$ELSE}
      Context.Response.Content := 'Interner Serverfehler';
      Context.Response.StatusCode := 500;
      {$ENDIF}
    end;
  end;
end;

end.
