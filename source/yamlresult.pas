(******************************************************************************)
(*                                 libPasYAML                                 *)
(*                object pascal wrapper around libyaml library                *)
(*                       https://github.com/yaml/libyaml                      *)
(*                                                                            *)
(* Copyright (c) 2020                                       Ivan Semenkov     *)
(* https://github.com/isemenkov/libpasyaml                  ivan@semenkov.pro *)
(*                                                          Ukraine           *)
(******************************************************************************)
(*                                                                            *)
(* Module:          Unit 'yamlresult'                                         *)
(* Functionality:   Provide TYamlResult  class which contains result value or *)
(*                  error type like in GO lang                                *)
(*                                                                            *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the GNU General Public License as published by the Free *)
(* Software Foundation; either version 3 of the License.                      *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for *)
(* more details.                                                              *)
(*                                                                            *)
(* A copy  of the  GNU General Public License is available  on the World Wide *)
(* Web at <http://www.gnu.org/copyleft/gpl.html>. You  can also obtain  it by *)
(* writing to the Free Software Foundation, Inc., 51  Franklin Street - Fifth *)
(* Floor, Boston, MA 02110-1335, USA.                                         *)
(*                                                                            *)
(******************************************************************************)

unit yamlresult;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  Classes, SysUtils;

type
  { Result error exception }
  EYamlResultException = class (Exception);

  { Contains result value or error type like in GO lang }
  generic TYamlResult<VALUE_TYPE, ERROR_TYPE> = class
  protected
    type
      TErrorType = (
        IMPOSSIBLE_VALUE,
        IMPOSSIBLE_ERROR
      );

      { OnError event callback }
      TOnErrorEvent = procedure (AErrorType : TErrorType) of object;

      PVALUE_TYPE = ^VALUE_TYPE;
      PERROR_TYPE = ^ERROR_TYPE;

      TValue = record
        Ok : Boolean;
        case Boolean of
          True  : (Value : PVALUE_TYPE);
          False : (Error : PERROR_TYPE);
      end;
  protected
    FValue : TValue;
    FOnError : TOnErrorEvent;

    function _Ok : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    function _Value : VALUE_TYPE;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    function _Error : ERROR_TYPE;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    { Create new result }
    constructor Create (AValue : VALUE_TYPE; AError : ERROR_TYPE; AOk :
      Boolean);
    destructor Destroy; override;

    { Check if result is Ok }
    property Ok : Boolean read _Ok;

    { Get value if exists or EYamlResultException }
    property Value : VALUE_TYPE read _Value;

    { Get error if exists or EYamlResultException }
    property Error : ERROR_TYPE read _Error;

    { OnError event callback }
    property OnError : TOnErrorEvent read FOnError write FOnError;
  end;

  { Void result, only error code is available }
  generic TYamlVoidResult<ERROR_TYPE> = class
    (specialize TYamlResult<Pointer, ERROR_TYPE>)
  public
    constructor Create (AError : ERROR_TYPE; AOk : Boolean);
  private
    property Value;
  end;

implementation

{ TYamlResult generic }

constructor TYamlResult.Create (AValue : VALUE_TYPE; AError : ERROR_TYPE;
  AOk : Boolean);
begin
  FValue.Ok := AOk;

  if AOk then
  begin
    New(FValue.Value);
    FValue.Value^ := AValue;
  end else begin
    New(FValue.Error);
    FValue.Error^ := AError;
  end;
end;

destructor TYamlResult.Destroy;
begin
  if FValue.Ok then
  begin
    FreeAndNil(FValue.Value);
  end else
  begin
    FreeAndNil(FValue.Error);
  end;
end;

function TYamlResult._Ok : Boolean;
begin
  Result := FValue.Ok;
end;

function TYamlResult._Value : VALUE_TYPE;
begin
  if FValue.Ok then
  begin
    Result := FValue.Value^;
  end else
  begin
    if Assigned(FOnError) then
      FOnError(IMPOSSIBLE_VALUE)
    else
      raise EYamlResultException.Create('Impossible value');
  end;
end;

function TYamlResult._Error : ERROR_TYPE;
begin
  if not FValue.Ok then
  begin
    Result := FValue.Error^;
  end else
  begin
    if Assigned(FOnError) then
      FOnError(IMPOSSIBLE_ERROR)
    else
      raise EYamlResultException.Create('Impossible error');
  end;
end;

{ TYamlVoidResult generic }

constructor TYamlVoidResult.Create (AError : ERROR_TYPE; AOk : Boolean);
begin
  inherited Create(nil, AError, AOk);
end;

end.

