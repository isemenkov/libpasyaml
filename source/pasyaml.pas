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
(* Module:          Unit 'pasyaml'                                            *)
(* Functionality:                                                             *)
(*                                                                            *)
(*                                                                            *)
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

unit pasyaml;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  Classes, SysUtils, libpasyaml, fgl;

type
  { TYamlFile }
  { Configuration YAML file }
  TYamlFile = class
  public
    type
      { Forward declarations }
      TOptionReader   = class;
      TVoidResult     = class;

      { Errors codes }
      TErrors = (
        { All OK, no errors }
        ERROR_NONE                                                  = 0

      );

      { Document encoding }
      TEncoding = (
        { Let the parser choose the encoding. }
        ENCODING_DEFAULT     = Longint(YAML_ANY_ENCODING),
        { The default UTF-8 encoding. }
        ENCODING_UTF8        = Longint(YAML_UTF8_ENCODING),
        { The UTF-16-LE encoding with BOM. }
        ENCODING_UTF16LE     = Longint(YAML_UTF16LE_ENCODING),
        { The UTF-16-BE encoding with BOM. }
        ENCODING_UTF16BE     = Longint(YAML_UTF16BE_ENCODING)
      );
  public
    constructor Create (Encoding : TEncoding = ENCODING_UTF8);
    destructor Destroy; override;

    { Parse configuration from string }
    function Parse (ConfigString : String) : TVoidResult; {$IFNDEF DEBUG}inline;
      {$ENDIF}

  private
    const
      ERROR_OK                                                      =  1;

    type
      TItemValueType = (
        TYPE_SEQUENCE,
        TYPE_SEQUENCE_ENTRY,
        TYPE_SCALAR
      );

      TItemsMap = class(specialize TFPGMap<String, TOptionReader>);

      TItemValue = record
        ValueType : TYamlFile.TItemValueType;
        case Byte of
          1 : (Sequence : TItemsMap);
          2 : (Scalar : PChar);
      end;

      //TItemsStack = class(specialize TFPGList<TItemValue>);

    var
      FParser : yaml_parser_t;
      FToken : yaml_token_t;
      FItems : TItemsMap;
  public
    type
      { Result structure which stored value and error type if exists like GO
      lang }
      generic TResult<VALUE_TYPE, ERROR_TYPE> = class
      protected
        FValue : VALUE_TYPE;
        FError : ERROR_TYPE;
        FOk : Boolean;

        function _Ok : Boolean;{$IFNDEF DEBUG}inline;{$ENDIF}
      public
        constructor Create (AValue : VALUE_TYPE; AError : ERROR_TYPE;
          AOk : Boolean);
        destructor Destroy; override;

        property Ok : Boolean read _Ok;
        property Value : VALUE_TYPE read FValue;
        property Error : ERROR_TYPE read FError;
      end;

      { Void result, only error code is available }
      TVoidResult = class(specialize TResult<Pointer, Integer>)
      public
        constructor Create(AError : Integer; AOk : Boolean);
      private
        property Value;
      end;

      TOptionReader = class
      public


      private
        FValue : TItemValue;
      end;
  end;

  operator=(ALeft, ARight : TYamlFile.TItemValue) : Boolean;

implementation

operator=(ALeft, ARight : TYamlFile.TItemValue) : Boolean;
begin
  Result := ALeft.ValueType = ARight.ValueType;
end;

{ TYamlFile.TResult }

constructor TYamlFile.TResult.Create (AValue : VALUE_TYPE; AError : ERROR_TYPE;
  AOk : Boolean);
begin
  FValue := AValue;
  FError := AError;
  FOk := AOk;
end;

destructor TYamlFile.TResult.Destroy;
begin
  inherited Destroy;
end;

function TYamlFile.TResult._Ok : Boolean;
begin
  Result := FOk;
end;

{ TYamlFile.TVoidResult }

constructor TYamlFile.TVoidResult.Create (AError : Integer; AOk : Boolean);
begin
  inherited Create (nil, AError, AOk);
end;

{ TYamlConfig }

constructor TYamlFile.Create (Encoding : TEncoding);
begin
  FItems := TItemsMap.Create;

  if yaml_parser_initialize(@FParser) <> ERROR_OK then
    ;
end;

destructor TYamlFile.Destroy;
begin
  yaml_parser_delete(@FParser);
  FreeAndNil(FItems);
  inherited Destroy;
end;

function TYamlFile.Parse(ConfigString : String) : TVoidResult;
begin
  yaml_parser_set_input_string(@FParser, PByte(PChar(ConfigString)),
    Length(ConfigString));

  repeat

    if yaml_parser_scan(@FParser, @FToken) <> ERROR_OK then
      ;

    case FToken.token_type of
      YAML_STREAM_START_TOKEN : ;
      YAML_STREAM_END_TOKEN : ;
      YAML_KEY_TOKEN : ;
      YAML_VALUE_TOKEN : ;
      YAML_BLOCK_SEQUENCE_START_TOKEN : ;
      YAML_BLOCK_ENTRY_TOKEN : ;
      YAML_BLOCK_END_TOKEN : ;
      YAML_BLOCK_MAPPING_START_TOKEN : ;
      YAML_SCALAR_TOKEN : ;
    end;

    if FToken.token_type <> YAML_STREAM_END_TOKEN then
      yaml_token_delete(@FToken);

  until FToken.token_type = YAML_STREAM_END_TOKEN;

  yaml_token_delete(@FToken);
  Result := TVoidResult.Create(Longint(ERROR_NONE), True);
end;

end.

