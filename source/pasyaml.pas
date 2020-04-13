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
  private
    function _GetValue (APath : String) : TOptionReader;{$IFNDEF DEBUG}inline;
      {$ENDIF}
  public
    constructor Create (Encoding : TEncoding = ENCODING_UTF8);
    destructor Destroy; override;

    { Parse configuration from string }
    function Parse (ConfigString : String) : TVoidResult; {$IFNDEF DEBUG}inline;
      {$ENDIF}

    property Value[Path : String] : TOptionReader read _GetValue;
  private
    const
      ERROR_OK                                                      =  1;

    type
      TItemValueType = (
        TYPE_MAP,
        TYPE_SEQUENCE,
        TYPE_SEQUENCE_ENTRY,
        TYPE_SCALAR
      );

      TItemMapValueToken = (
        TOKEN_KEY,
        TOKEN_VALUE
      );

      PItemValue = ^TItemValue;
      TItemsMap = class(specialize TFPGMap<String, TOptionReader>);
      TItemsSequence = class(specialize TFPGList<PItemValue>);

      TItemValue = record
        ValueType : TYamlFile.TItemValueType;
        case Byte of
          TYPE_MAP :            (Map : record
                                   Token : TItemMapValueToken;
                                   Value : PChar;
                                 end;);
          TYPE_SEQUENCE :       (Sequence : TItemsSequence);
          TYPE_SEQUENCE_ENTRY : (Entry : PItemValue);
          TYPE_SCALAR :         (Scalar : PChar);
      end;

      TItemsStack = class
      public
        constructor Create;
        destructor Destroy;override;

        procedure Push (AValue : PItemValue);{$IFNDEF DEBUG}inline;{$ENDIF}
        function Pop : PItemValue;{$IFNDEF DEBUG}inline;{$ENDIF}
        function Top : PItemValue;{$IFNDEF DEBUG}inline;{$ENDIF}
        function Count : Cardinal;{$IFNDEF DEBUG}inline;{$ENDIF}
      private
        type
          TItemsList = specialize TFPGList<PItemValue>;

        var
          FList : TItemsList;
      end;

    var
      FParser : yaml_parser_t;
      FToken : yaml_token_t;
      FItems : TItemsMap;
      FStack : TItemsStack;
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
      private
        function _AsString : String; {$IFNDEF DEBUG}inline;{$ENDIF}
      public
        constructor Create (AItem : PItemValue);
        destructor Destroy; override;

        property AsString : String read _AsString;

      private
        FValue : PItemValue;
      end;
  end;

implementation

{ TYamlFile.TItemsStack }

constructor TYamlFile.TItemsStack.Create;
begin
  FList := TItemsList.Create;
end;

destructor TYamlFile.TItemsStack.Destroy;
begin
  FreeAndNil(FList);
end;

procedure TYamlFile.TItemsStack.Push (AValue : PItemValue);
begin
  FList.Add(AValue);
end;

function TYamlFile.TItemsStack.Pop : PItemValue;
begin
  if FList.Count > 0 then
  begin
    Result := FList.First;
    FList.Remove(FList.Items[0]);
  end;
end;

function TYamlFile.TItemsStack.Top : PItemValue;
begin
  if FList.Count > 0 then
  begin
    Result := FList.First;
  end;
end;

function TYamlFile.TItemsStack.Count : Cardinal;
begin
  Result := FList.Count;
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

{ TYamlFile.TOptionReader }

constructor TYamlFile.TOptionReader.Create (AItem : PItemValue);
begin
  FValue := AItem;
end;

destructor TYamlFile.TOptionReader.Destroy;
begin
  FreeAndNil(FValue);
  inherited Destroy;
end;

function TYamlFile.TOptionReader._AsString : String;
begin
  case FValue^.ValueType of
    TYPE_MAP : begin
      Result := FValue^.Map.Value;
    end;
    TYPE_SEQUENCE : begin

    end;
    TYPE_SEQUENCE_ENTRY : begin

    end;
    TYPE_SCALAR : begin
      Result := FValue^.Scalar^;
    end else
    Result := '';
  end;
end;

{ TYamlFile }

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

  procedure ProcessMapSection;{$IFNDEF DEBUG}inline;{$ENDIF}
  var
    Key : PChar;
    Item : PItemValue;
  begin
    case FStack.Top^.Map.Token of
      TOKEN_KEY :
        begin
          FStack.Top^.Map.Value :=
            StrCopy(StrAlloc(Strlen(PChar(FToken.token.scalar.value)) + 1),
            PChar(FToken.token.scalar.value));
        end;
      TOKEN_VALUE :
        begin
          Key := FStack.Top^.Map.Value;
          FStack.Top^.Map.Value :=
            StrCopy(StrAlloc(Strlen(PChar(FToken.token.scalar.value)) + 1),
            PChar(FToken.token.scalar.value));
          FItems.Add(Key, TOptionReader.Create(FStack.Pop));
          New(Item);
          FStack.Push(Item);
          FStack.Top^.ValueType := TYPE_MAP;
        end;
    end;
  end;

var
  Item : PItemValue;
begin
  yaml_parser_set_input_string(@FParser, PByte(PChar(ConfigString)),
    Length(ConfigString));

  FStack := TItemsStack.Create;

  repeat

    if yaml_parser_scan(@FParser, @FToken) <> ERROR_OK then
      ;

    case FToken.token_type of
      YAML_STREAM_START_TOKEN : ;
      YAML_STREAM_END_TOKEN : ;
      YAML_KEY_TOKEN :
        if FStack.Count > 0 then
        begin
          FStack.Top^.Map.Token := TOKEN_KEY;
        end;
      YAML_VALUE_TOKEN :
        if FStack.Count > 0 then
        begin
          FStack.Top^.Map.Token := TOKEN_VALUE;
        end;
      YAML_BLOCK_SEQUENCE_START_TOKEN :
        ;
      YAML_BLOCK_ENTRY_TOKEN :
        ;
      YAML_BLOCK_END_TOKEN :
        ;
      YAML_BLOCK_MAPPING_START_TOKEN :
        begin
          New(Item);
          FStack.Push(Item);
          FStack.Top^.ValueType := TYPE_MAP;
        end;
      YAML_SCALAR_TOKEN :
        if FStack.Count > 0 then
        begin
          case FStack.Top^.ValueType of
            TYPE_MAP :               ProcessMapSection;
            TYPE_SEQUENCE : ;
            TYPE_SEQUENCE_ENTRY : ;
            TYPE_SCALAR : ;
          end;
        end;
    end;

    if FToken.token_type <> YAML_STREAM_END_TOKEN then
      yaml_token_delete(@FToken);

  until FToken.token_type = YAML_STREAM_END_TOKEN;

  if FStack.Count = 0 then
    FreeAndNil(FStack)
  else
    ;

  yaml_token_delete(@FToken);
  Result := TVoidResult.Create(Longint(ERROR_NONE), True);
end;

function TYamlFile._GetValue (APath : String) : TOptionReader;
begin
  Result := FItems[APath];
end;

end.

