unit TimeTRackApi.AuthController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  System.Generics.Collections, System.JSON, MVCFramework.Swagger.Commons;

type
  TLoginUser = class
  private
    FUsername: string;
    FUser_ID: integer;
    Fis_confirmed: Boolean;
    Femail: string;
    Fis_active: Boolean;
    Fcreated_at: TDateTime;
    Ffirst_name: string;
    Fconfirmation_token: string;
    Flast_login: TDateTime;
    Fpassword: string;
    Faddress: string;
    Flast_name: string;
    procedure SetUser_ID(const Value: integer);
    procedure SetUsername(const Value: string);
    procedure Setaddress(const Value: string);
    procedure Setconfirmation_token(const Value: string);
    procedure Setcreated_at(const Value: TDateTime);
    procedure Setemail(const Value: string);
    procedure Setfirst_name(const Value: string);
    procedure Setis_active(const Value: Boolean);
    procedure Setis_confirmed(const Value: Boolean);
    procedure Setlast_login(const Value: TDateTime);
    procedure Setlast_name(const Value: string);
    procedure Setpassword(const Value: string);
  public
    property User_ID: integer read FUser_ID write SetUser_ID;
    property Username: string read FUsername write SetUsername;
    property email: string read Femail write Setemail;
    property password: string read Fpassword write Setpassword;
    property first_name: string read Ffirst_name write Setfirst_name;
    property last_name: string read Flast_name write Setlast_name;
    property address: string read Faddress write Setaddress;
    property is_confirmed: Boolean read Fis_confirmed write Setis_confirmed;
    property confirmation_token: string read Fconfirmation_token write Setconfirmation_token;
    property created_at: TDateTime read Fcreated_at write Setcreated_at;
    property last_login: TDateTime read Flast_login write Setlast_login;
    property is_active: Boolean read Fis_active write Setis_active;

  end;

type
  [MVCPath('/api/auth')]
  TAuthController = class(TMVCController)
  public
//    [MVCDoc('Registers a new user')]
    [MVCPath('/register')]
    [MVCSwagSummary('Authentication', 'registers a new user')]
    [MVCSwagResponses(201,'user registered')]
    [MVCSwagResponses(500,'Internal Server Error')]
    [MVCSwagResponses(409, 'user already exists')]
    [MVCSwagParam(plbody,'body', 'Kundendaten', ptstring)]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    [MVCHTTPMethod([httpPOST])]
    function RegisterUser: string;


    [MVCPath('/activate')]
    [MVCSwagSummary('Authentication', 'activates a new user')]
    [MVCSwagResponses(202,'user activated')]
    [MVCSwagResponses(500,'Internal Server Error')]
    [MVCSwagResponses(400, 'Unknown Authentication Token')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    [MVCHTTPMethod([httpPOST])]
    function ActivateUser: string;

    [MVCPath('/login')]
    [MVCSwagSummary('Authentication', 'logs user in')]
    [MVCSwagResponses(200,'login successful')]
    [MVCSwagResponses(500,'Internal Server Error')]
    [MVCSwagResponses(400, 'Unknown Authentication Token')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    [MVCHTTPMethod([httpPOST])]
    function LoginUser: string;

  end;

implementation

uses
  System.StrUtils, System.SysUtils, MVCFramework.Logger;


function TAuthController.ActivateUser: string;
begin
 //
end;

function TAuthController.LoginUser: string;
begin
//
end;

function TAuthController.RegisterUser: string;
var lJSON: TJSONObject;
begin
  lJSON:= TJSONValue.ParseJSONValue(Context.Request.Body) As TJSONObject;
  try
    Result:= 'hat funktioniert'
    //lJSON
  finally
    FreeAndNil(lJson);
  end;
end;

{ TLoginUser }

procedure TLoginUser.Setaddress(const Value: string);
begin
  Faddress := Value;
end;

procedure TLoginUser.Setconfirmation_token(const Value: string);
begin
  Fconfirmation_token := Value;
end;

procedure TLoginUser.Setcreated_at(const Value: TDateTime);
begin
  Fcreated_at := Value;
end;

procedure TLoginUser.Setemail(const Value: string);
begin
  Femail := Value;
end;

procedure TLoginUser.Setfirst_name(const Value: string);
begin
  Ffirst_name := Value;
end;

procedure TLoginUser.Setis_active(const Value: Boolean);
begin
  Fis_active := Value;
end;

procedure TLoginUser.Setis_confirmed(const Value: Boolean);
begin
  Fis_confirmed := Value;
end;

procedure TLoginUser.Setlast_login(const Value: TDateTime);
begin
  Flast_login := Value;
end;

procedure TLoginUser.Setlast_name(const Value: string);
begin
  Flast_name := Value;
end;

procedure TLoginUser.Setpassword(const Value: string);
begin
  Fpassword := Value;
end;

procedure TLoginUser.SetUsername(const Value: string);
begin
  FUsername := Value;
end;

procedure TLoginUser.SetUser_ID(const Value: integer);
begin
  FUser_ID := Value;
end;

end.
