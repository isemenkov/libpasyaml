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
{$modeswitch typehelpers}
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
  protected
    function GetValue (AKey : String) : TOptionReader;
  public
    constructor Create (Encoding : TEncoding = ENCODING_UTF8);
    destructor Destroy; override;

    { Parse configuration from string }
    function Parse (ConfigString : String) : TVoidResult; {$IFNDEF DEBUG}inline;
      {$ENDIF}

    property Value [AKey : String] : TOptionReader read GetValue;
  private
    const
      ERROR_OK                                                      =  1;

    type
      TItemValueType = (
        TYPE_NONE,
        TYPE_MAP,
        TYPE_MAP_KEY,
        TYPE_MAP_VALUE,
        TYPE_SEQUENCE,
        TYPE_SEQUENCE_ENTRY,
        TYPE_SCALAR,
        TYPE_END_BLOCK
      );

      PItemValue = ^TItemValue;
      TItemsMap = class(specialize TFPGMap<String, TOptionReader>);
      TItemsList = class(specialize TFPGList<TOptionReader>);

      TItemValue = record
        ValueType : TYamlFile.TItemValueType;
        case Byte of
          TYPE_MAP :            (Map : TItemsMap);
          TYPE_MAP_KEY :        (Key : PChar);
          TYPE_MAP_VALUE :      (Value : PChar);
          TYPE_SEQUENCE :       (Sequence : TItemsList);
          TYPE_SCALAR :         (Scalar : PChar);
      end;

      TItemsSequence = class
      public
        constructor Create;
        constructor Create (AItem : TYamlFile.TOptionReader);
        destructor Destroy; override;

        procedure PushBack (AItemType : TYamlFile.TItemValueType);
        procedure PushBack (AItem : TYamlFile.TOptionReader);
        function First : PItemValue;
        function FirstPop : PItemValue;
        function Last : PItemValue;
        function LastPop : PItemValue;

        function Top : PItemValue;
        function Pop : PItemValue;
      private
        type
          TItemsList = specialize TFPGList<PItemValue>;

        var
          FList : TItemsList;
      end;

    var
      FParser : yaml_parser_t;
      FRoot : TOptionReader;
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
        constructor Create (AType : TYamlFile.TItemValueType);
        destructor Destroy; override;

        function IsMap : Boolean;
        function IsSequence : Boolean;

        function AsString : String;
      private
        FValue : TItemValue;
      end;
  end;

implementation

{ TYamlFile.TItemsSequence }

constructor TYamlFile.TItemsSequence.Create;
begin
  FList := TItemsList.Create;
end;

constructor TYamlFile.TItemsSequence.Create (AItem : TYamlFile.TOptionReader);
begin
  FList := TItemsList.Create;
  FList.Add(@AItem.FValue);
end;

destructor TYamlFile.TItemsSequence.Destroy;
begin
  FreeAndNil(FList);

  inherited Destroy;
end;

procedure TYamlFile.TItemsSequence.PushBack (AItemType :
  TYamlFile.TItemValueType);
begin
  FList.Add(New(PItemValue));
  FList.Last^.ValueType := AItemType;
end;

procedure TYamlFile.TItemsSequence.PushBack (AItem : TYamlFile.TOptionReader);
begin
  FList.Add(@AItem.FValue);
end;

function TYamlFile.TItemsSequence.First : PItemValue;
begin
  Result := FList.First;
end;

function TYamlFile.TItemsSequence.Last : PItemValue;
begin
  Result := FList.Last;
end;

function TYamlFile.TItemsSequence.Top : PItemValue;
begin
  Result := FList.Last;
end;

function TYamlFile.TItemsSequence.FirstPop : PItemValue;
begin
  if FList.Count > 0 then
  begin
    Result := FList.First;
    FList.Delete(0);
  end else
  begin
    Result := nil;
  end;
end;

function TYamlFile.TItemsSequence.LastPop : PItemValue;
begin
  if FList.Count > 0 then
  begin
    Result := FList.Last;
    FList.Delete(FList.Count - 1);
  end else
  begin
    Result := nil;
  end;
end;

function TYamlFile.TItemsSequence.Pop : PItemValue;
  begin
    if FList.Count > 0 then
    begin
      Result := FList.Last;
      FList.Delete(FList.Count - 1);
    end else
    begin
      Result := nil;
    end;
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

constructor TYamlFile.TOptionReader.Create (AType : TYamlFile.TItemValueType);
begin
  FValue.ValueType := AType;

  case AType of
    TYPE_MAP :
      begin
        FValue.Map := TItemsMap.Create;
      end;
    TYPE_SEQUENCE :
      begin
        FValue.Sequence := TItemsList.Create;
      end;
  end;
end;

destructor TYamlFile.TOptionReader.Destroy;
begin
  case FValue.ValueType of
    TYPE_MAP :
      begin
        FreeAndNil(FValue.Map);
      end;
    TYPE_SEQUENCE :
      begin
        FreeAndNil(FValue.Sequence);
      end;
  end;

  inherited Destroy;
end;

function TYamlFile.TOptionReader.IsMap : Boolean;
begin
  Result := (FValue.ValueType = TYPE_MAP);
end;

function TYamlFile.TOptionReader.IsSequence : Boolean;
begin
  Result := (FValue.ValueType = TYPE_SEQUENCE);
end;

function TYamlFile.TOptionReader.AsString : String;
begin
  Result := FValue.Scalar;
end;

{ TYamlFile }

constructor TYamlFile.Create (Encoding : TEncoding);
begin
  FRoot := TOptionReader.Create(TYPE_NONE);

  if yaml_parser_initialize(@FParser) <> ERROR_OK then
    ;
end;

destructor TYamlFile.Destroy;
begin
  yaml_parser_delete(@FParser);
  FreeAndNil(FRoot);
  inherited Destroy;
end;

function TYamlFile.Parse(ConfigString : String) : TVoidResult;
var
  Tokens : TItemsSequence;
  Token : yaml_token_t;

  procedure ProcessTokens;{$IFNDEF DEBUG}inline;{$ENDIF}
  var
    CurrentToken : PItemValue;
    ForwardToken : PItemValue;
    ConfigTree : TItemsSequence;

    function Next(out AToken : PItemValue) : PItemValue;{$IFNDEF DEBUG}inline;
      {$ENDIF}
    begin
      AToken := Tokens.FirstPop;
      Result := AToken;
    end;

    procedure InitializeMapElement (AElement : PItemValue);{$IFNDEF DEBUG}
      inline;{$ENDIF}
    begin
      AElement^.ValueType := TYPE_MAP;
      AElement^.Map := TItemsMap.Create;
    end;

    procedure InitializeSequenceElement (AElement : PItemValue);{$IFNDEF DEBUG}
      inline;{$ENDIF}
    begin
      AElement^.ValueType := TYPE_SEQUENCE;
      AElement^.Sequence := TItemsList.Create;
    end;

    procedure CreateMapElement (ASequence : TItemsSequence);{$IFNDEF DEBUG}
      inline;{$ENDIF}
    begin
      ASequence.PushBack(TYPE_MAP);
      ASequence.Top^.Map := TItemsMap.Create;
    end;

    procedure CreateSequenceElement (ASequence : TItemsSequence);{$IFNDEF DEBUG}
      inline;{$ENDIF}
    begin
      ASequence.PushBack(TYPE_SEQUENCE);
      ASequence.Top^.Sequence := TItemsList.Create;
    end;

    function IsNone (AElement : PItemValue) : Boolean;{$IFNDEF DEBUG}inline;
      {$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_NONE);
    end;

    function IsMapValue (AElement : PItemValue) : Boolean;{$IFNDEF DEBUG}inline;
      {$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_MAP_VALUE);
    end;

    function IsSequence (AElement : PItemValue) : Boolean;{$IFNDEF DEBUG}inline;
      {$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_SEQUENCE);
    end;

    procedure CreateMapValue (AElement : PItemValue; AKey : PChar; AValue :
      PChar);{$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Map[AKey] := TOptionReader.Create(TYPE_SCALAR);
      AElement^.Map[AKey].FValue.Scalar := AValue;
    end;

    procedure CreateSequenceValue (AElement : PItemValue; AKey : PChar);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Map[AKey] := TOptionReader.Create(TYPE_NONE);
    end;

  begin
    ConfigTree := TItemsSequence.Create(FRoot);

    Next(CurrentToken);
    while CurrentToken <> nil do
    begin
      case CurrentToken^.ValueType of
        TYPE_MAP :
          begin
            if IsNone(ConfigTree.Top) then
            begin
              InitializeMapElement(ConfigTree.Top);
            end else
            begin
              CreateMapElement(ConfigTree);
            end;
          end;
        TYPE_MAP_KEY :
          begin
            if IsMapValue(Next(ForwardToken)) and IsSequence(Tokens.First) then
            begin
              CreateSequenceValue(ConfigTree.Top, CurrentToken^.Key);
              ConfigTree.PushBack(ConfigTree.Top^.Map[CurrentToken^.Key]);
            end else
            begin
              CreateMapValue(ConfigTree.Top, CurrentToken^.Key,
                ForwardToken^.Value);
            end;
          end;
        TYPE_SEQUENCE :
          begin
            if IsNone(ConfigTree.Top) then
            begin
              InitializeSequenceElement(ConfigTree.Top);
            end else
            begin
              CreateSequenceElement(ConfigTree);
            end;
          end;
        TYPE_SEQUENCE_ENTRY :
          begin
            ConfigTree.PushBack(TYPE_NONE);
          end;
        TYPE_END_BLOCK :
          begin
            ConfigTree.Pop;
          end;
      end;
      Next(CurrentToken);
    end;
  end;

begin
  yaml_parser_set_input_string(@FParser, PByte(PChar(ConfigString)),
    Length(ConfigString));

  repeat

    if yaml_parser_scan(@FParser, @Token) <> ERROR_OK then
      ;

    case Token.token_type of
      YAML_STREAM_START_TOKEN :
        begin
          Tokens := TItemsSequence.Create;
        end;
      YAML_STREAM_END_TOKEN :
        begin
          ProcessTokens;
        end;
      YAML_KEY_TOKEN :
        begin
          Tokens.PushBack(TYPE_MAP_KEY);
        end;
      YAML_VALUE_TOKEN :
        begin
          Tokens.PushBack(TYPE_MAP_VALUE);
        end;
      YAML_BLOCK_SEQUENCE_START_TOKEN :
        begin
          Tokens.PushBack(TYPE_SEQUENCE);
        end;
      YAML_BLOCK_ENTRY_TOKEN :
        begin
          Tokens.PushBack(TYPE_SEQUENCE_ENTRY);
        end;
      YAML_BLOCK_END_TOKEN :
        begin
          Tokens.PushBack(TYPE_END_BLOCK);
        end;
      YAML_BLOCK_MAPPING_START_TOKEN :
        begin
          Tokens.PushBack(TYPE_MAP);
        end;
      YAML_SCALAR_TOKEN :
        begin
          if Tokens.Last^.ValueType = TYPE_MAP_KEY then
          begin
            Tokens.Last^.Key :=
              StrCopy(StrAlloc(StrLen(PChar(Token.token.scalar.value)) + 1),
                PChar(Token.token.scalar.value));
          end else
          if Tokens.Last^.ValueType = TYPE_MAP_VALUE then
          begin
            Tokens.Last^.Value :=
              StrCopy(StrAlloc(StrLen(PChar(Token.token.scalar.value)) + 1),
                PChar(Token.token.scalar.value));
          end;
        end;
    end;

    if Token.token_type <> YAML_STREAM_END_TOKEN then
      yaml_token_delete(@Token);

  until Token.token_type = YAML_STREAM_END_TOKEN;


  FreeAndNil(Tokens);
  yaml_token_delete(@Token);
  Result := TVoidResult.Create(Longint(ERROR_NONE), True);
end;

function TYamlFile.GetValue (AKey : String) : TOptionReader;
begin
  Result := FRoot.FValue.Map[AKey];
end;

end.

