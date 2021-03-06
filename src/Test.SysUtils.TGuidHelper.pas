﻿{**********************************************************************
    Copyright(c) 2016 pda <pda2@yandex.ru>

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit Test.SysUtils.TGuidHelper;

{$DEFINE TEST_UNIT}
{$IFDEF FPC}{$I fpc.inc}{$ELSE}{$I delphi.inc}{$ENDIF}
{$IFDEF DELPHI_XE4_PLUS}{$LEGACYIFEND ON}{$ENDIF}

interface

uses
  {$IFDEF FPC}
  fpcunit, testregistry,
  {$ELSE}
  TestFramework,
  {$ENDIF}
  Classes, SysUtils, Types;

{$IF DEFINED(FPC) OR DEFINED(DELPHI_XE2_PLUS)}
type
  TTestTGuidHelper = class(TTestCase)
  strict private
    FGuid: TGUID;
  private
    {$IFDEF FPC}
    procedure FailCreateStringA;
    {$ENDIF}
    procedure FailCreateStringU;
    procedure FailCreateTBytesOffset;
    procedure FailCreateABCD;
  published
    {$IFDEF FPC}
    procedure TestCreateStringA;
    {$ENDIF}
    procedure TestCreateStringU;
    {$IFNDEF FPC}
    { Just ignore the old API. Unfortunately Free Pascal does not distinguish
      between array of Byte, TBytes and TArray<Byte>.
      See http://bugs.freepascal.org/view.php?id=31169 for more info. }
    procedure TestCreateDataBool;
    procedure TestCreateArrayOfByte;
    {$ENDIF}
    procedure TestCreateData;
    procedure TestCreateTBytes;
    procedure TestCreateTBytesOffset;
    procedure TestCreateABCD;
    procedure TestCreateAKSmallInt;
    procedure TestCreateAKWord;
    procedure TestEmpty;
    procedure TestNewGuid;
    procedure TestToByteArray;
    procedure TestToString;
    procedure TestEqual;
  end;
{$IFEND}

implementation

{$IF DEFINED(FPC) OR DEFINED(DELPHI_XE2_PLUS)}
const
  TEST_GUID: TGUID = '{00010203-0405-0607-0809-0A0B0C0D0E0F}';
  TEST_GUID_GOOD: TGUID = '{EC7E5BD7-3846-41E3-A6AF-12BBE7008E03}';
  TEST_LONG_ARRAY: array [0..17] of Byte = (
    $fe, $ff, $00, $01, $02, $03, $04, $05, $06,
    $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
  );
  TEST_GUID_LONG_DIRECT: TGUID = (
    D1: $feff0001; D2: $0203; D3: $0405; D4:($06, $07, $08, $09, $0a, $0b, $0c, $0d)
  );
  TEST_GUID_LONG_SWAPPED: TGUID = (
    D1: $0100fffe; D2: $0302; D3: $0504; D4:($06, $07, $08, $09, $0a, $0b, $0c, $0d)
  );

{ TTestTGuidHelper }

{$IFDEF FPC}
procedure TTestTGuidHelper.FailCreateStringA;
const
  BAD_GUID: AnsiString = '***';
begin
  TGUID.Create(BAD_GUID);
end;

procedure TTestTGuidHelper.TestCreateStringA;
const
  GOOD_GUID: AnsiString = '{EC7E5BD7-3846-41E3-A6AF-12BBE7008E03}';
begin
  CheckTrue(IsEqualGUID(TEST_GUID_GOOD, TGUID.Create(GOOD_GUID)));
  CheckException(FailCreateStringA, EConvertError);
end;
{$ENDIF FPC}

procedure TTestTGuidHelper.FailCreateStringU;
const
  BAD_GUID: UnicodeString = '***';
begin
  TGUID.Create(BAD_GUID);
end;

procedure TTestTGuidHelper.TestCreateStringU;
const
  GOOD_GUID: UnicodeString = '{EC7E5BD7-3846-41E3-A6AF-12BBE7008E03}';
begin
  CheckTrue(IsEqualGUID(TEST_GUID_GOOD, TGUID.Create(GOOD_GUID)));
  CheckException(FailCreateStringU, EConvertError);
end;

{$IFNDEF FPC}
procedure TTestTGuidHelper.TestCreateDataBool;
begin
  CheckTrue(IsEqualGUID(TEST_GUID_LONG_DIRECT, TGUID.Create(TEST_LONG_ARRAY, True)));
  CheckTrue(IsEqualGUID(TEST_GUID_LONG_SWAPPED, TGUID.Create(TEST_LONG_ARRAY, False)));
end;

procedure TTestTGuidHelper.TestCreateArrayOfByte;
const
  RES_1_D1: Cardinal = $00010203;
  RES_1_D2: Word = $0405;
  RES_1_D3: Word = $0607;
  RES_2_D1: Cardinal = $feff0001;
  RES_2_D2: Word = $0203;
  RES_2_D3: Word = $0405;
var
  ByteArray: array of Byte;
  i: Integer;
begin
  SetLength(ByteArray, Length(TEST_LONG_ARRAY));
  for i := 0 to High(ByteArray) do
    ByteArray[i] := TEST_LONG_ARRAY[i];

  FGuid := TGuid.Create(ByteArray, 2, True);
  CheckEquals(Integer(RES_1_D1), Integer(FGuid.D1));
  CheckEquals(RES_1_D2, FGuid.D2);
  CheckEquals(RES_1_D3, FGuid.D3);
  for i := 0 to 7 do
    CheckEquals(ByteArray[i + 10], FGuid.D4[i]);

  FGuid := TGuid.Create(ByteArray, 0, True);
  CheckEquals(Integer(RES_2_D1), Integer(FGuid.D1));
  CheckEquals(RES_2_D2, FGuid.D2);
  CheckEquals(RES_2_D3, FGuid.D3);
  for i := 0 to 7 do
    CheckEquals(ByteArray[i + 8], FGuid.D4[i]);

  SetLength(ByteArray, 0);
  CheckTrue(IsEqualGUID(GUID_NULL, TGuid.Create(ByteArray, 0)));
end;
{$ENDIF FPC}

procedure TTestTGuidHelper.TestCreateData;
begin
  CheckTrue(IsEqualGUID(TEST_GUID_LONG_DIRECT, TGUID.Create(TEST_LONG_ARRAY, TEndian.Big)));
  CheckTrue(IsEqualGUID(TEST_GUID_LONG_SWAPPED, TGUID.Create(TEST_LONG_ARRAY, TEndian.Little)));
end;

procedure TTestTGuidHelper.TestCreateTBytes;
var
  Bytes: TBytes;
  i: Integer;
begin
  SetLength(Bytes, Length(TEST_LONG_ARRAY));
  for i := 0 to High(Bytes) do
    Bytes[i] := TEST_LONG_ARRAY[i];

  CheckTrue(IsEqualGUID(TEST_GUID_LONG_DIRECT, TGUID.Create(Bytes, TEndian.Big)));
  CheckTrue(IsEqualGUID(TEST_GUID_LONG_SWAPPED, TGUID.Create(Bytes, TEndian.Little)));
end;

procedure TTestTGuidHelper.FailCreateTBytesOffset;
var
  Bytes: TBytes;
begin
  SetLength(Bytes, 0);
  FGuid := TGuid.Create(Bytes, 0);
end;

procedure TTestTGuidHelper.TestCreateTBytesOffset;
const
  RES_1_D1: Cardinal = $00010203;
  RES_1_D2: Word = $0405;
  RES_1_D3: Word = $0607;
  RES_2_D1: Cardinal = $feff0001;
  RES_2_D2: Word = $0203;
  RES_2_D3: Word = $0405;
var
  Bytes: TBytes;
  i: Integer;
begin
  SetLength(Bytes, Length(TEST_LONG_ARRAY));
  for i := 0 to High(Bytes) do
    Bytes[i] := TEST_LONG_ARRAY[i];

  FGuid := TGuid.Create(Bytes, 2, TEndian.Big);
  CheckEquals(Integer(RES_1_D1), Integer(FGuid.D1));
  CheckEquals(RES_1_D2, FGuid.D2);
  CheckEquals(RES_1_D3, FGuid.D3);
  for i := 0 to 7 do
    CheckEquals(Bytes[i + 10], FGuid.D4[i]);

  FGuid := TGuid.Create(Bytes, 0, TEndian.Big);
  CheckEquals(Integer(RES_2_D1), Integer(FGuid.D1));
  CheckEquals(RES_2_D2, FGuid.D2);
  CheckEquals(RES_2_D3, FGuid.D3);
  for i := 0 to 7 do
    CheckEquals(Bytes[i + 8], FGuid.D4[i]);

  CheckException(FailCreateTBytesOffset, EArgumentException);
end;

{$IFDEF FPC}{$PUSH}{$ENDIF}{$WARNINGS OFF}
procedure TTestTGuidHelper.FailCreateABCD;
var
  A: Integer;
  B, C: SmallInt;
  D: TBytes;
begin
  SetLength(D, 7);
  TGUID.Create(A, B, C, D);
end;
{$IFDEF FPC}{$POP}{$ELSE}{$IFDEF _WARNINGS_ENABLED}{$WARNINGS ON}{$ENDIF}{$ENDIF}

procedure TTestTGuidHelper.TestCreateABCD;
var
  A: Integer;
  B, C: SmallInt;
  D: TBytes;
begin
  A := $00010203;
  B := $0405;
  C := $0607;
  SetLength(D, 8);
  D[0] := $08; D[1] := $09; D[2] := $0a; D[3] := $0b;
  D[4] := $0c; D[5] := $0d; D[6] := $0e; D[7] := $0f;

  CheckTrue(IsEqualGUID(
    TEST_GUID,
    TGUID.Create(A, B, C, D)
  ));

  CheckException(FailCreateABCD, EArgumentException);
end;

procedure TTestTGuidHelper.TestCreateAKSmallInt;
var
  A: Integer;
  B, C: SmallInt;
  D, E, F, G, H, I, J, K: Byte;
begin
  A := $00010203;
  B := $0405;
  C := $0607;
  D := $08; E := $09; F := $0a; G := $0b; H := $0c; I := $0d; J := $0e; K := $0f;

  CheckTrue(IsEqualGUID(
    TEST_GUID,
    TGUID.Create(A, B, C, D, E, F, G, H, I, J, K)
  ));
end;

procedure TTestTGuidHelper.TestCreateAKWord;
var
  A: Cardinal;
  B, C: Word;
  D, E, F, G, H, I, J, K: Byte;
begin
  A := $00010203;
  B := $0405;
  C := $0607;
  D := $08; E := $09; F := $0a; G := $0b; H := $0c; I := $0d; J := $0e; K := $0f;

  CheckTrue(IsEqualGUID(
    TEST_GUID,
    TGUID.Create(A, B, C, D, E, F, G, H, I, J, K)
  ));
end;

procedure TTestTGuidHelper.TestNewGuid;
begin
  CheckFalse(IsEqualGUID(
    TGUID.NewGuid,
    TGUID.NewGuid
  ));
end;

procedure TTestTGuidHelper.TestToByteArray;
const
  RES_SWAPPED: array [0..15] of Byte = (
    $03, $02, $01, $00, $05, $04, $07, $06, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
  );
var
  ResBytes: TBytes;
  i: Integer;
begin
  ResBytes := TEST_GUID.ToByteArray;
  for i := 0 to High(ResBytes) do
    {$IFDEF ENDIAN_BIG}
    CheckEquals(i, ResBytes[i]);
    {$ELSE}
    CheckEquals(RES_SWAPPED[i], ResBytes[i]);
    {$ENDIF}

  ResBytes := TEST_GUID.ToByteArray(TEndian.Little);
  for i := 0 to High(ResBytes) do
    CheckEquals(RES_SWAPPED[i], ResBytes[i]);

  ResBytes := TEST_GUID.ToByteArray(TEndian.Big);
  for i := 0 to High(ResBytes) do
    CheckEquals(i, ResBytes[i]);
end;

procedure TTestTGuidHelper.TestToString;
begin
  CheckEquals('{00010203-0405-0607-0809-0A0B0C0D0E0F}', TEST_GUID.ToString);
end;

procedure TTestTGuidHelper.TestEmpty;
begin
  CheckTrue(IsEqualGUID(GUID_NULL, TGUID.Empty));
end;

procedure TTestTGuidHelper.TestEqual;
var
  CopyGuid: TGUID;
begin
  CopyGuid := TEST_GUID;

  CheckTrue(TEST_GUID = CopyGuid);
  CheckFalse(TEST_GUID <> CopyGuid);
  CheckFalse(TEST_GUID = GUID_NULL);
end;

initialization
  RegisterTest('System.SysUtils', TTestTGuidHelper.Suite);
{$IFEND}

end.

