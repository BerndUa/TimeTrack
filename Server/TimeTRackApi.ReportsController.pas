unit TimeTRackApi.ReportsController;

interface

uses
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons, System.Generics.Collections;

type
  [MVCPath('/api')]
  TreportsController = class(TMVCController)
  end;

implementation

uses
  System.StrUtils, System.SysUtils, MVCFramework.Logger;


end.
