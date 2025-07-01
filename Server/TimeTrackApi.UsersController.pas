unit TimeTrackApi.UsersController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons, System.Generics.Collections;

type
  [MVCPath('/api')]
  TUsersController = class(TMVCController)
  public
    [MVCPath('/users')]
    [MVCHTTPMethod([httpPost])]
    [MVCSwagResponses(201,'User has been created')]
    [MVCSwagResponses(403,'Insufficent permissions')]
    [MVCSwagResponses(500,'Internal Server error')]
    function AddUser: IMVCResponse;

    [MVCPath('/users/($ID)')]
    [MVCHTTPMethod([httpPut])]
    [MVCSwagResponses(202,'User has been updated')]
    [MVCSwagResponses(403,'Insufficent permissions')]
    [MVCSwagResponses(500,'Internal Server error')]
    [MVCSwagResponses(422 ,'ID not found')]
    function UpdateUser(ID: integer): IMVCResponse;

    [MVCPath('/users/($ID)')]
    [MVCHTTPMethod([httpGET])]
    function GetUser(ID: integer): IMVCResponse;

    [MVCPath('/users/($ID)')]
    [MVCHTTPMethod([httpPost])]
    function DeleteUser(ID: integer): IMVCResponse;
  end;

implementation

uses
  System.StrUtils, System.SysUtils, MVCFramework.Logger;


{ TUsersController }

function TUsersController.AddUser: IMVCResponse;
begin
   Result := NoContentResponse();
end;

function TUsersController.DeleteUser(ID: integer): IMVCResponse;
begin
   Result := NoContentResponse();
end;

function TUsersController.GetUser(ID: integer): IMVCResponse;
begin
    Result := NoContentResponse();
end;

function TUsersController.UpdateUser(ID: integer): IMVCResponse;
begin
  Result := NoContentResponse();
end;

end.
