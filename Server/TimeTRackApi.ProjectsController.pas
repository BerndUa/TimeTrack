unit TimeTRackApi.ProjectsController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons, System.Generics.Collections;

type
  [MVCPath('/api')]
  TProjectsController = class(TMVCController)
  end;

implementation

uses
  System.StrUtils, System.SysUtils, MVCFramework.Logger;


end.
