unit TimeTrackApi.UsersController;

interface

uses
  System.Generics.Collections,
  MVCFramework, MVCFramework.Commons, MVCFramework.Serializer.Commons,
  MVCFramework.Swagger.Commons, MVCFramework.Middleware.Authentication.RoleBasedAuthHandler,
  TimeTrackApi.ApiTypes, TimeTrackApi.BaseController;

type
  [MVCPath('/api/users')]
  [MVCRequiresAuthentication]
  [MVCRequiresRole('registereduser')]
  [MVCSwagAuthentication(atJsonWebToken)]
  TUsersController = class(TBaseController)
  public
    /// <summary>Eigenes Benutzer-Profil abrufen</summary>
    [MVCPath('/profile')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Users', 'Get current user profile')]
    [MVCSwagResponses(200, 'User profile retrieved', TUserProfileResponse)]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(404, 'User not found')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetUserProfile;

    /// <summary>Eigenes Benutzer-Profil aktualisieren</summary>
    [MVCPath('/profile')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Users', 'Update current user profile')]
    [MVCSwagParam(plBody, 'ProfileData', 'Updated profile data', TUpdateProfileRequest)]
    [MVCSwagResponses(200, 'Profile updated successfully', TUserProfileResponse)]
    [MVCSwagResponses(400, 'Invalid profile data')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(409, 'Email already exists')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure UpdateUserProfile;

    /// <summary>Passwort ändern</summary>
    [MVCPath('/change-password')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Users', 'Change user password')]
    [MVCSwagParam(plBody, 'PasswordData', 'Password change data', TChangePasswordRequest)]
    [MVCSwagResponses(200, 'Password changed successfully')]
    [MVCSwagResponses(400, 'Invalid password data or current password incorrect')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure ChangePassword;

    /// <summary>Account löschen</summary>
    [MVCPath('/delete-account')]
    [MVCHTTPMethod([httpDELETE])]
    [MVCSwagSummary('Users', 'Delete user account')]
    [MVCSwagParam(plBody, 'DeleteData', 'Account deletion confirmation', TDeleteAccountRequest)]
    [MVCSwagResponses(200, 'Account deleted successfully')]
    [MVCSwagResponses(400, 'Invalid deletion request or incorrect password')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCConsumes(TMVCMediaType.APPLICATION_JSON)]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure DeleteAccount;

    /// <summary>Account deaktivieren (temporär)</summary>
    [MVCPath('/deactivate')]
    [MVCHTTPMethod([httpPUT])]
    [MVCSwagSummary('Users', 'Deactivate user account')]
    [MVCSwagResponses(200, 'Account deactivated successfully')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure DeactivateAccount;

    /// <summary>Benutzer-Statistiken (Dashboard-Info)</summary>
    [MVCPath('/stats')]
    [MVCHTTPMethod([httpGET])]
    [MVCSwagSummary('Users', 'Get user account statistics')]
    [MVCSwagResponses(200, 'User statistics retrieved')]
    [MVCSwagResponses(401, 'Unauthorized')]
    [MVCSwagResponses(500, 'Internal Server Error')]
    [MVCProduces(TMVCMediaType.APPLICATION_JSON)]
    procedure GetUserStatistics;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  System.DateUtils,
  System.JSON,
  MVCFramework.Logger,
  TimeTrackApi.DataModule, TimeTrackApi.Model.Entities,
  TimeTrackApi.PasswordUtils;

{ TUsersController }

procedure TUsersController.GetUserProfile;
var
  userId: Integer;
  userData: TLoginUser;
  response: TUserProfileResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Benutzer-Daten laden
    userData := TdmDataAccess.DBGetUserData(userId);

    if userData.User_ID = 0 then
    begin
      Render(404, '{"error": "User not found"}');
      Exit;
    end;

    // Response erstellen
    response := TUserProfileResponse.CreateFromRecord(userData);
    try
      Render(response);
    finally
      response.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetUserProfile Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TUsersController.UpdateUserProfile;
var
  userId: Integer;
  updateRequest: TUpdateProfileRequest;
  currentUser: TLoginUser;
  updatedUser: TLoginUser;
  success: Boolean;
  response: TUserProfileResponse;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Aktuelles Profil laden
    currentUser := TdmDataAccess.DBGetUserData(userId);
    if currentUser.User_ID = 0 then
    begin
      Render(404, '{"error": "User not found"}');
      Exit;
    end;

    // Request-Daten parsen
    updateRequest := Context.Request.BodyAs<TUpdateProfileRequest>;
    try
      // Eingabe validieren
      if not updateRequest.IsDataValid then
      begin
        Render(400, '{"error": "Invalid profile data. Valid email is required."}');
        Exit;
      end;

      // Aktualisierte Benutzerdaten erstellen
      updatedUser := updateRequest.GetAsUserData(userId);

      // Felder übernehmen, die nicht geändert werden
      updatedUser.Username := currentUser.Username; // Username nicht änderbar
      updatedUser.Created_At := currentUser.Created_At;
      updatedUser.Is_Confirmed := currentUser.Is_Confirmed;
      updatedUser.Is_Active := currentUser.Is_Active;

      // In Datenbank aktualisieren
      success := TdmDataAccess.DBUpdateUserProfile(updatedUser);

      if not success then
      begin
        Render(500, '{"error": "Failed to update profile"}');
        Exit;
      end;

      // Aktualisierte Daten laden für Response
      updatedUser := TdmDataAccess.DBGetUserData(userId);

      // Response erstellen
      response := TUserProfileResponse.CreateFromRecord(updatedUser);
      try
        Render(response);
      finally
        response.Free;
      end;

    finally
      updateRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('UpdateUserProfile Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TUsersController.ChangePassword;
var
  userId: Integer;
  passwordRequest: TChangePasswordRequest;
  success: Boolean;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Request-Daten parsen
    passwordRequest := Context.Request.BodyAs<TChangePasswordRequest>;
    try
      // Eingabe validieren
      if not passwordRequest.IsDataValid then
      begin
        Render(400, '{"error": "Invalid password data. New password must be at least 6 characters and match confirmation."}');
        Exit;
      end;

      // Passwort in Datenbank ändern
      success := TdmDataAccess.DBChangeUserPassword(
        userId,
        passwordRequest.CurrentPassword,
        passwordRequest.NewPassword
      );

      if not success then
      begin
        Render(400, '{"error": "Current password is incorrect or update failed"}');
        Exit;
      end;

      Render(200, '{"message": "Password changed successfully"}');

    finally
      passwordRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('ChangePassword Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TUsersController.DeleteAccount;
var
  userId: Integer;
  deleteRequest: TDeleteAccountRequest;
  success: Boolean;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Request-Daten parsen
    deleteRequest := Context.Request.BodyAs<TDeleteAccountRequest>;
    try
      // Eingabe validieren
      if not deleteRequest.IsDataValid then
      begin
        Render(400, '{"error": "Invalid deletion request. Password and confirmation text \"DELETE\" required."}');
        Exit;
      end;

      // Account in Datenbank löschen (Soft Delete)
      success := TdmDataAccess.DBDeleteUserAccount(userId, deleteRequest.Password);

      if not success then
      begin
        Render(400, '{"error": "Password incorrect or deletion failed"}');
        Exit;
      end;

      // Session/Token ungültig machen (User ist jetzt gelöscht)
      Context.LoggedUser.Clear;
      Context.SessionStop();

      Render(200, '{"message": "Account deleted successfully"}');

    finally
      deleteRequest.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('DeleteAccount Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TUsersController.DeactivateAccount;
var
  userId: Integer;
  success: Boolean;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Account deaktivieren
    success := TdmDataAccess.DBDeactivateUserAccount(userId);

    if not success then
    begin
      Render(500, '{"error": "Failed to deactivate account"}');
      Exit;
    end;

    // Session/Token ungültig machen
    Context.LoggedUser.Clear;
    Context.SessionStop();

    Render(200, '{"message": "Account deactivated successfully"}');

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('DeactivateAccount Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

procedure TUsersController.GetUserStatistics;
var
  userId: Integer;
  userData: TLoginUser;
  projects: TProjectArray;
  currentMonthEntries: TTimeEntryArray;
  stats: TJSONObject;
  totalProjects, currentMonthMinutes, totalEntries: Integer;
  i: Integer;
  accountAge: Integer;
begin
  try
    userId := GetCurrentUserId;
    if userId = 0 then
    begin
      Render(401, '{"error": "User not authenticated"}');
      Exit;
    end;

    // Basis-Daten laden
    userData := TdmDataAccess.DBGetUserData(userId);
    projects := TdmDataAccess.DBGetUserProjects(userId);

    // Aktueller Monat Zeiteinträge
    currentMonthEntries := TdmDataAccess.DBGetTimeEntriesForPeriod(
      userId,
      EncodeDate(YearOf(Now), MonthOf(Now), 1),
      Now,
      0
    );

    // Statistiken berechnen
    totalProjects := Length(projects);
    totalEntries := Length(currentMonthEntries);

    currentMonthMinutes := 0;
    for i := Low(currentMonthEntries) to High(currentMonthEntries) do
      currentMonthMinutes := currentMonthMinutes + currentMonthEntries[i].GetNetDurationMinutes;

    accountAge := DaysBetween(userData.Created_At, Now);

    // JSON Response erstellen
    stats := TJSONObject.Create;
    try
      stats.AddPair('user_id', userId);
      stats.AddPair('username', userData.Username);
      stats.AddPair('email', userData.Email);
      stats.AddPair('account_age_days', accountAge);
      stats.AddPair('member_since', FormatDateTime('yyyy-mm-dd', userData.Created_At));
      stats.AddPair('total_projects', totalProjects);
      stats.AddPair('current_month_entries', totalEntries);
      stats.AddPair('current_month_minutes', currentMonthMinutes);
      stats.AddPair('current_month_hours', Format('%.1f', [currentMonthMinutes / 60.0]));

      if userData.Last_Login > 0 then
        stats.AddPair('last_login', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', userData.Last_Login))
      else
        stats.AddPair('last_login', '');

      stats.AddPair('is_active', userData.Is_Active);
      stats.AddPair('is_confirmed', userData.Is_Confirmed);

      // Aktivitäts-Level basierend auf diesem Monat
      if currentMonthMinutes > 4800 then // > 80 Stunden
        stats.AddPair('activity_level', 'high')
      else if currentMonthMinutes > 2400 then // > 40 Stunden
        stats.AddPair('activity_level', 'medium')
      else
        stats.AddPair('activity_level', 'low');

      Render(stats.ToJSON);
    finally
      stats.Free;
    end;

  except
    on E: Exception do
    begin
      {$IFDEF DEBUG}
        LogE('GetUserStatistics Error: ' + E.Message);
        raise;
      {$ELSE}
        Render(500, '{"error": "Internal server error"}');
      {$ENDIF}
    end;
  end;
end;

end.
