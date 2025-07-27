object dmDataAccess: TdmDataAccess
  Height = 510
  Width = 809
  PixelsPerInch = 144
  object DesignTimetrackConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=TimeTrack')
    ConnectedStoredUsage = [auDesignTime]
    LoginPrompt = False
    Left = 121
    Top = 67
  end
  object TimetrackConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=TimeTrack')
    LoginPrompt = False
    Left = 332
    Top = 67
  end
  object CommonQuery: TFDQuery
    Connection = TimetrackConnection
    Left = 307
    Top = 192
  end
  object FDQuery2: TFDQuery
    Connection = DesignTimetrackConnection
    Left = 115
    Top = 221
  end
end
