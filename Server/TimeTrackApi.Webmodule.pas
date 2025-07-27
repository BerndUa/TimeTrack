unit TimeTrackApi.Webmodule;

interface

uses 
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  MVCFramework;

type
  TTimetrackModul = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
  private
    fMVC: TMVCEngine;
  end;

var
  WebModuleClass: TComponentClass = TTimetrackModul;

implementation

{$R *.dfm}

uses
  TimeTRackApi.AuthController,
  System.IOUtils,
  MVCFramework.Commons,
  MVCFramework.Swagger.Commons,
  MVCFramework.JWT,   MVCFramework.Middleware.JWT,
//  MVCFramework.Middleware.ActiveRecord,
  MVCFramework.Middleware.Swagger,
  MVCFramework.Middleware.Session,
  MVCFramework.Middleware.Redirect,
  MVCFramework.Middleware.StaticFiles,
  MVCFramework.Middleware.Analytics,
  MVCFramework.Middleware.Trace,
  MVCFramework.Middleware.CORS,
  MVCFramework.Middleware.ETag,
  MVCFramework.Middleware.Authentication,
  MVCFramework.Middleware.Compression,
  TimeTrackApi.ProjectsController,
  TimeTrackApi.ReportsController,
  TimeTrackApi.TrackingController,
  TimeTrackApi.UsersController, TimeTrackApi.AuthenticationImpl;

procedure TTimetrackModul.WebModuleCreate(Sender: TObject);
var
   LSwagInfo: TMVCSwaggerInfo;
begin
  fMVC := TMVCEngine.Create(Self,
    procedure(Config: TMVCConfig)
    begin
      //default content-type
      Config[TMVCConfigKey.DefaultContentType] := dotEnv.Env('dmvc.default.content_type', TMVCConstants.DEFAULT_CONTENT_TYPE);
      //default content charset
      Config[TMVCConfigKey.DefaultContentCharset] := dotEnv.Env('dmvc.default.content_charset', TMVCConstants.DEFAULT_CONTENT_CHARSET);
      //unhandled actions are permitted?
      Config[TMVCConfigKey.AllowUnhandledAction] := dotEnv.Env('dmvc.allow_unhandled_actions', 'false');
      //enables or not system controllers loading (available only from localhost requests)
      Config[TMVCConfigKey.LoadSystemControllers] := dotEnv.Env('dmvc.load_system_controllers', 'true');
      //default view file extension
      Config[TMVCConfigKey.DefaultViewFileExtension] := dotEnv.Env('dmvc.default.view_file_extension', 'html');
      //view path
      Config[TMVCConfigKey.ViewPath] := dotEnv.Env('dmvc.view_path', 'templates');
      //use cache for server side views (use "false" in debug and "true" in production for faster performances
      Config[TMVCConfigKey.ViewCache] := dotEnv.Env('dmvc.view_cache', 'false');
      //Max Record Count for automatic Entities CRUD
      Config[TMVCConfigKey.MaxEntitiesRecordCount] := dotEnv.Env('dmvc.max_entities_record_count', IntToStr(TMVCConstants.MAX_RECORD_COUNT));
      //Enable Server Signature in response
      Config[TMVCConfigKey.ExposeServerSignature] := dotEnv.Env('dmvc.expose_server_signature', 'false');
      //Enable X-Powered-By Header in response
      Config[TMVCConfigKey.ExposeXPoweredBy] := dotEnv.Env('dmvc.expose_x_powered_by', 'true');
      // Max request size in bytes
      Config[TMVCConfigKey.MaxRequestSize] := dotEnv.Env('dmvc.max_request_size', IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE));
    end);

  LSwagInfo.Title := 'Codecamp Swagger API';
  LSwagInfo.Version := 'v1';
  LSwagInfo.TermsOfService := 'http://www.apache.org/licenses/LICENSE-2.0.txt';
  LSwagInfo.Description := 'Swagger Documentation Example';
  LSwagInfo.ContactName := 'kein Kontakt';
  LSwagInfo.ContactEmail := 'nomail@coldmail.com';
  LSwagInfo.ContactUrl := 'auch nich';
  LSwagInfo.LicenseName := 'Apache License - Version 2.0, January 2004';
  LSwagInfo.LicenseUrl := 'http://www.apache.org/licenses/LICENSE-2.0';

  // Controllers
  fMVC.AddController(TAuthController);
  fMVC.AddController(TUsersController);
  fMVC.AddController(TProjectsController);
  fMVC.AddController(TTrackingController);
  fMVC.AddController(TreportsController);

  fMVC.AddMiddleware(TMVCSwaggerMiddleware.Create
     (fMVC, LSwagInfo, '/api/swagger.json','Beispiel Doku', False));

  // Controllers - END

  // Middleware
  // To use memory session uncomment the following line
  fMVC.AddMiddleware(UseMemorySessionMiddleware);
  // To use file based session uncomment the following line
  // fMVC.AddMiddleware(UseFileSessionMiddleware);
  //
  // To use database based session uncomment the following lines,
  // configure you firedac db connection and create table dmvc_sessions
  // fMVC.AddMiddleware(TMVCActiveRecordMiddleware.Create('firedac_con_def_name'));
  // fMVC.AddMiddleware(UseDatabaseSessionMiddleware);
   var lConfigClaims: TJWTClaimsSetup := procedure(const JWT: TJWT)
    begin
     // Standard Claims
     JWT.Claims.Issuer := 'TimeTrackAPI';
     JWT.Claims.Audience := 'TimeTrackClients';
     JWT.Claims.ExpirationTime := Now + EncodeTime(1, 0, 0, 0); // 1 Stunde
     JWT.Claims.NotBefore := Now - EncodeTime(0, 5, 0, 0); // 5 Minuten Toleranz
     JWT.Claims.IssuedAt := Now;
     JWT.Claims.JWT_ID := TGuid.NewGuid.ToString;

     // Custom Claims werden automatisch aus ASessionData übernommen
     // Die in TAuthenticationImpl.OnAuthentication gesetzten Werte werden
     // automatisch als Custom Claims eingebaut

    end;

  // JWT-Middleware mit korrekter Konfiguration
  fMVC.AddMiddleware(TMVCJWTAuthenticationMiddleware.Create(
  TAuthenticationImpl.Create,
  lConfigClaims,
  'mys3cr37',      // JWT Secret (TODO: aus .env laden)
  '/auth/login',  // Login-Endpoint - nicht implementiert, macht die JWT Middöeware automatisch
  [TJWTCheckableClaim.ExpirationTime, TJWTCheckableClaim.NotBefore, TJWTCheckableClaim.IssuedAt],
  300              // Session Timeout in Sekunden
));

// NOTIZ: Der vollständige Login-Pfad wird automatisch konstruiert:
// Controller-Path ("/api/auth") + Login-Action-Path ("/login") = "/api/auth/login"


  fMVC.AddMiddleware(TMVCStaticFilesMiddleware.Create(
     '/swagger',  { StaticFilesPath }
     '.\www',     { DocumentRoot }
     'index.html' { IndexDocument }
   ));

end;

procedure TTimetrackModul.WebModuleDestroy(Sender: TObject);
begin
  fMVC.Free;
end;

end.
