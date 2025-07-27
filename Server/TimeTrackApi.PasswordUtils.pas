unit TimeTrackApi.PasswordUtils;

interface

uses
  System.SysUtils, System.Hash, System.NetEncoding, System.Classes;

type
  TPasswordUtils = class
  private
    class function GenerateSalt(Length: Integer = 32): string;
    class function PBKDF2Hash(const Password, Salt: string; Iterations: Integer = 10000): string;
  public
    // Passwort-Hash erstellen (für Speicherung in DB)
    class function CreatePasswordHash(const Password: string): string;
    // Passwort gegen Hash prüfen
    class function VerifyPassword(const Password, StoredHash: string): Boolean;
  end;

implementation

uses
  System.Math;

{ TPasswordUtils }

class function TPasswordUtils.GenerateSalt(Length: Integer): string;
var
  I: Integer;
  Bytes: TBytes;
begin
  SetLength(Bytes, Length);

  // Zufällige Bytes generieren
  for I := 0 to Length - 1 do
    Bytes[I] := Random(256);

  // Base64 kodieren für String-Darstellung
  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
end;

class function TPasswordUtils.PBKDF2Hash(const Password, Salt: string; Iterations: Integer): string;
var
  SaltBytes, PasswordBytes, HashBytes: TBytes;
  I, J: Integer;
  U, T: TBytes;
  HMAC: THashSHA2;
begin
  // Strings zu Bytes konvertieren
  PasswordBytes := TEncoding.UTF8.GetBytes(Password);
  SaltBytes := TEncoding.UTF8.GetBytes(Salt);

  // 32 Bytes Hash (SHA256)
  SetLength(HashBytes, 32);
  SetLength(T, 32);
  SetLength(U, 32);

  // PBKDF2 Implementation (vereinfacht für eine Iteration)
  // Für Produktionsumgebung sollte eine vollständige PBKDF2-Library verwendet werden

  // Salt + Iteration Counter
  SetLength(SaltBytes, Length(SaltBytes) + 4);
  SaltBytes[High(SaltBytes)-3] := 0;
  SaltBytes[High(SaltBytes)-2] := 0;
  SaltBytes[High(SaltBytes)-1] := 0;
  SaltBytes[High(SaltBytes)] := 1;

  // Erste HMAC-SHA256
  HMAC := THashSHA2.Create(SHA256);
  U := HMAC.GetHMACAsBytes(SaltBytes, PasswordBytes);
  Move(U[0], T[0], 32);

  // Iterationen
  for I := 2 to Iterations do
  begin
    U := HMAC.GetHMACAsBytes(U, PasswordBytes);
    for J := 0 to 31 do
      T[J] := T[J] xor U[J];
  end;

  HashBytes := T;
  Result := TNetEncoding.Base64.EncodeBytesToString(HashBytes);
end;

class function TPasswordUtils.CreatePasswordHash(const Password: string): string;
var
  Salt, Hash: string;
const
  ITERATIONS = 10000; // Anzahl Iterationen (je höher, desto sicherer aber langsamer)
begin
  if Trim(Password) = '' then
    raise Exception.Create('Passwort darf nicht leer sein');

  // Salt generieren
  Salt := GenerateSalt(32);

  // Hash erstellen
  Hash := PBKDF2Hash(Password, Salt, ITERATIONS);

  // Format: Iterations$Salt$Hash (für spätere Verifikation)
  Result := Format('%d$%s$%s', [ITERATIONS, Salt, Hash]);
end;

class function TPasswordUtils.VerifyPassword(const Password, StoredHash: string): Boolean;
var
  Parts: TArray<string>;
  Iterations: Integer;
  Salt, Hash, ComputedHash: string;
begin
  Result := False;

  if (Trim(Password) = '') or (Trim(StoredHash) = '') then
    Exit;

  try
    // Hash-String aufteilen
    Parts := StoredHash.Split(['$']);
    if Length(Parts) <> 3 then
      Exit;

    Iterations := StrToInt(Parts[0]);
    Salt := Parts[1];
    Hash := Parts[2];

    // Hash mit gegebenem Passwort und Salt neu berechnen
    ComputedHash := PBKDF2Hash(Password, Salt, Iterations);

    // Vergleich (zeitkonstant wäre besser für Sicherheit)
    Result := ComputedHash = Hash;

  except
    // Bei Fehlern false zurückgeben
    Result := False;
  end;
end;

end.

//// ===== VERWENDUNGSBEISPIEL =====
//
//unit TestPasswordUtils;
//
//interface
//
//uses
//  PasswordUtils;
//
//procedure TestPasswordHashing;
//
//implementation
//
//procedure TestPasswordHashing;
//var
//  Password, Hash: string;
//  IsValid: Boolean;
//begin
//  Password := 'MeinSicheresPasswort123!';
//
//  // Hash für DB erstellen
//  Hash := TPasswordUtils.CreatePasswordHash(Password);
//  WriteLn('Generierter Hash: ' + Hash);
//
//  // Passwort prüfen
//  IsValid := TPasswordUtils.VerifyPassword(Password, Hash);
//  WriteLn('Passwort korrekt: ' + BoolToStr(IsValid, True));
//
//  // Falsches Passwort testen
//  IsValid := TPasswordUtils.VerifyPassword('FalschesPasswort', Hash);
//  WriteLn('Falsches Passwort: ' + BoolToStr(IsValid, True));
//end;
//
//end.

{
unit PasswordUtilsBcrypt;

interface

uses
  SysUtils, DCPsha256, DCPbcrypt; // Benötigt DCPcrypt Library

type
  TPasswordUtilsBcrypt = class
  public
    class function CreatePasswordHash(const Password: string): string;
    class function VerifyPassword(const Password, Hash: string): Boolean;
  end;

implementation

class function TPasswordUtilsBcrypt.CreatePasswordHash(const Password: string): string;
begin
  // BCrypt mit Cost-Faktor 12 (sehr sicher)
  Result := TBCrypt.HashPassword(Password, TBCrypt.GenerateSalt(12));
end;

class function TPasswordUtilsBcrypt.VerifyPassword(const Password, Hash: string): Boolean;
begin
  Result := TBCrypt.CheckPassword(Password, Hash);
end;

end.
}


