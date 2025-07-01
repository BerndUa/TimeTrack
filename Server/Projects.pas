unit Projects;

interface

uses
  System.Generics.Collections;

type
  TProject = class
    ProjectID: integer;
    ProjectName: string;
    Description: string;
    ClientName: string;
    CreatedByUserID: integer;
    CreatedAt: TDateTime;
    IsActive: boolean;
  end;

  TProjectList = TObjectList<TProject>;

implementation

end.
