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
  protected
    function GetValue (AKey : String) : TOptionReader;
  public
    constructor Create (Encoding : TEncoding = ENCODING_UTF8);
    destructor Destroy; override;

    { Parse YAML configuration from string }
    function Parse (ConfigString : String) : TVoidResult; {$IFNDEF DEBUG}inline;
      {$ENDIF}

    { Return option value by path }
    property Value [AKey : String] : TOptionReader read GetValue;
  private
    const
      ERROR_OK                                                      =  1;

    type
      { Config document elements types }
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

      { Config document element }
      TItemValue = record
        ValueType : TYamlFile.TItemValueType;
        case Byte of
          TYPE_MAP :            (Map : TItemsMap);
          TYPE_MAP_KEY :        (Key : PChar);
          TYPE_MAP_VALUE :      (Value : PChar);
          TYPE_SEQUENCE :       (Sequence : TItemsList);
          TYPE_SCALAR :         (Scalar : PChar);
      end;

      { Bidirectional list and stack class }
      TItemsSequence = class
      public
        constructor Create;
        destructor Destroy; override;

        { Get front element value }
        function  Front : PItemValue;

        { Add new element to front }
        procedure FrontPush (AItem : PItemValue);
        procedure FrontPush (AItem : TYamlFile.TOptionReader);

        { Take element from front side }
        function  FrontPop : PItemValue;

        { Get back element value }
        function  Back : PItemValue;

        { Add new element to back }
        procedure BackPush (AItem : PItemValue);
        procedure BackPush (AItem : TYamlFile.TOptionReader);

        { Take element from back side }
        function  BackPop : PItemValue;

        { Add element to stack }
        procedure Push (AItem : PItemValue);
        procedure Push (AItem : TYamlFile.TOptionReader);

        { Get stack's top element value }
        function  Top : PItemValue;

        { Take element from stack }
        function  Pop : PItemValue;
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
      { Result structure which stored value and error type if exists like in GO
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

      { Reader for configuration option }
      TOptionReader = class
      public
        type
          { Sequence type enumerator }
          TSequenceEnumerator = class
          protected
            FOption : PItemValue;
            FCount : Integer;
            FPosition : Cardinal;

            function GetCurrent : TOptionReader;
              {$IFNDEF DEBUG}inline;{$ENDIF}
          public
            constructor Create (AOption : PItemValue);
            function MoveNext : Boolean;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            function GetEnumerator : TSequenceEnumerator;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            property Current : TOptionReader read GetCurrent;
          end;
      protected
        function GetValue (AKey : String) : TOptionReader;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      public
        constructor Create;
        constructor Create (AValue : PItemValue);
        destructor Destroy; override;

        { Return TRUE if element is Map type }
        function IsMap : Boolean;

        { Return TRUE if element is Sequence type }
        function IsSequence : Boolean;

        { Return element's value as String type }
        function AsString : String;

        { Return element's value as Sequence enumerator }
        function AsSequence : TSequenceEnumerator;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return option value by path }
        property Value [AKey : String] : TOptionReader read GetValue;
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

destructor TYamlFile.TItemsSequence.Destroy;
begin
  FreeAndNil(FList);

  inherited Destroy;
end;

function TYamlFile.TItemsSequence.Front : PItemValue;
begin
  Result := FList.First;
end;

procedure TYamlFile.TItemsSequence.FrontPush (AItem : PItemValue);
begin
  FList.Insert(0, AItem);
end;

procedure TYamlFile.TItemsSequence.FrontPush (AItem : TYamlFile.TOptionReader);
begin
  FrontPush(@AItem.FValue);
end;

function TYamlFile.TItemsSequence.FrontPop : PItemValue;
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

function TYamlFile.TItemsSequence.Back : PItemValue;
begin
  Result := FList.Last;
end;

procedure TYamlFile.TItemsSequence.BackPush (AItem : PItemValue);
begin
  FList.Add(AItem);
end;

procedure TYamlFile.TItemsSequence.BackPush (AItem : TYamlFile.TOptionReader);
begin
  BackPush(@AItem.FValue);
end;

function TYamlFile.TItemsSequence.BackPop : PItemValue;
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

procedure TYamlFile.TItemsSequence.Push (AItem : PItemValue);
begin
  BackPush(AItem);
end;

procedure TYamlFile.TItemsSequence.Push (AItem : TYamlFile.TOptionReader);
begin
  BackPush(AItem);
end;

function TYamlFile.TItemsSequence.Top : PItemValue;
begin
  Result := Back;
end;

function TYamlFile.TItemsSequence.Pop : PItemValue;
begin
  Result := BackPop;
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

{ TYamlFile.TOptionReader.TSequenceEnumerator }

constructor TYamlFile.TOptionReader.TSequenceEnumerator.Create (AOption :
  PItemValue);
begin
  FOption := AOption;
  FPosition := 0;
  if (FOption = nil) or (AOption^.ValueType <> TYPE_SEQUENCE) then
    FCount := 0
  else
    FCount := FOption^.Sequence.Count;
end;

function TYamlFile.TOptionReader.TSequenceEnumerator.GetCurrent : TOptionReader;
begin
  if FOption = nil then
  begin
    Result := TOptionReader.Create(FOption);
    Exit;
  end;

  Result := TOptionReader.Create(@FOption^.Sequence.Items[FPosition].FValue);
  Inc(FPosition);
end;

function TYamlFile.TOptionReader.TSequenceEnumerator.MoveNext : Boolean;
begin
  Result := FPosition < FCount;
end;

function TYamlFile.TOptionReader.TSequenceEnumerator.GetEnumerator :
  TYamlFile.TOptionReader.TSequenceEnumerator;
begin
  Result := Self;
end;

{ TYamlFile.TOptionReader }

constructor TYamlFile.TOptionReader.Create;
begin
  FValue.ValueType := TYPE_NONE;
end;

constructor TYamlFile.TOptionReader.Create (AValue : PItemValue);
begin
  FValue := AValue^;
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

function TYamlFile.TOptionReader.GetValue (AKey : String) : TOptionReader;
begin
  Result := FValue.Map[AKey];
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

function TYamlFile.TOptionReader.AsSequence : TSequenceEnumerator;
begin
  Result := TSequenceEnumerator.Create(@FValue);
end;

{ TYamlFile }

constructor TYamlFile.Create (Encoding : TEncoding);
begin
  FRoot := TOptionReader.Create;

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

  { Create new ASequence item and add it to the back side }
  procedure CreateValueAndBackPush (var ASequence : TItemsSequence; AValueType :
    TItemValueType);
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    ASequence.BackPush(New(PItemValue));
    ASequence.Back^.ValueType := AValueType;
  end;

  { Create new ASequence item and add it to the top }
  procedure CreateValueAndTopPush (var ASequence : TItemsSequence; AValueType :
    TItemValueType);
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    ASequence.Push(New(PItemValue));
    ASequence.Top^.ValueType := AValueType;
  end;

  { Process YAML tokens and create document structure }
  procedure ProcessTokens;
    {$IFNDEF DEBUG}inline;{$ENDIF}
  var
    CurrentToken : PItemValue;
    ForwardToken : PItemValue;
    ConfigTree : TItemsSequence;

    { Set next token from Tokens variable sequence to AToken item and also r
      eturn it. Remove token from sequence at end }
    function Next(out AToken : PItemValue) : PItemValue;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AToken := Tokens.FrontPop;
      Result := AToken;
    end;

    { Return next token from Token variable sequence only }
    function ForwardNext : PItemValue;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := Tokens.Front;
    end;

    { Initialize AElement.Map field }
    procedure InitializeMapElement (AElement : PItemValue);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.ValueType := TYPE_MAP;
      AElement^.Map := TItemsMap.Create;
    end;

    { Initialize AElement.Sequence field }
    procedure InitializeSequenceElement (AElement : PItemValue);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.ValueType := TYPE_SEQUENCE;
      AElement^.Sequence := TItemsList.Create;
    end;

    { Create new ASequence element, push it and initialize }
    procedure CreateMapElement (ASequence : TItemsSequence);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      ASequence.Push(New(PItemValue));
      ASequence.Top^.ValueType := TYPE_MAP;
      ASequence.Top^.Map := TItemsMap.Create;
    end;

    { Create new ASequence element, push it and initialize }
    procedure CreateSequenceElement (ASequence : TItemsSequence);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      ASequence.Push(New(PItemValue));
      ASequence.Top^.ValueType := TYPE_SEQUENCE;
      ASequence.Top^.Sequence := TItemsList.Create;
    end;

    { Create new TOptionReader element }
    function CreateOptionReader (AValueType : TItemValueType) : TOptionReader;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := TOptionReader.Create;
      Result.FValue.ValueType := AValueType;

      case AValueType of
        TYPE_MAP      : InitializeMapElement(@Result.FValue);
        TYPE_SEQUENCE : InitializeSequenceElement(@Result.FValue);
      end;
    end;

    { Return TRUE if AElement type is TYPE_NONE }
    function IsNone (AElement : PItemValue) : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_NONE);
    end;

    { Return TRUE if AElement type is TYPE_MAP_VALUE }
    function IsMapValue (AElement : PItemValue) : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_MAP_VALUE);
    end;

    { Return TRUE if AElement type is TYPE_SEQUENCE }
    function IsSequence (AElement : PItemValue) : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_SEQUENCE);
    end;

    { Set AElement.Map[AKey] := AValue }
    procedure CreateMapValue (AElement : PItemValue; AKey : PChar; AValue :
      PChar);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Map[AKey] := CreateOptionReader(TYPE_SCALAR);
      AElement^.Map[AKey].FValue.Scalar := AValue;
    end;

    { Set AElement.Map[AKey] := New(Sequence) }
    procedure CreateSequenceValue (AElement : PItemValue; AKey : PChar);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Map[AKey] := CreateOptionReader(TYPE_NONE);
    end;

    { Create new element and add it to AElement.Sequence }
    function AddSequenceValue (AElement : PItemValue) : PItemValue;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Sequence.Add(TOptionReader.Create);
      Result := @AElement^.Sequence.Items[AElement^.Sequence.Count - 1].FValue;
    end;

  begin
    ConfigTree := TItemsSequence.Create;
    ConfigTree.Push(FRoot);

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
            if IsMapValue(Next(ForwardToken)) and IsSequence(ForwardNext) then
            begin
              CreateSequenceValue(ConfigTree.Top, CurrentToken^.Key);
              ConfigTree.Push(ConfigTree.Top^.Map[CurrentToken^.Key]);
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
            ConfigTree.Push(AddSequenceValue(ConfigTree.Top));
          end;
        TYPE_END_BLOCK :
          begin
            ConfigTree.Pop;
          end;
      end;
      Next(CurrentToken);
    end;
  end;

  { Return Token variable scalar value }
  function TokenScalarValue : PChar;
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    Result := StrCopy(StrAlloc(StrLen(PChar(Token.token.scalar.value)) + 1),
      PChar(Token.token.scalar.value));
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
          CreateValueAndBackPush(Tokens, TYPE_MAP_KEY);
        end;
      YAML_VALUE_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_MAP_VALUE);
        end;
      YAML_BLOCK_SEQUENCE_START_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_SEQUENCE);
        end;
      YAML_BLOCK_ENTRY_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_SEQUENCE_ENTRY);
        end;
      YAML_BLOCK_END_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_END_BLOCK);
        end;
      YAML_BLOCK_MAPPING_START_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_MAP);
        end;
      YAML_SCALAR_TOKEN :
        begin
          if Tokens.Back^.ValueType = TYPE_MAP_KEY then
          begin
            Tokens.Back^.Key := TokenScalarValue;
          end else
          if Tokens.Back^.ValueType = TYPE_MAP_VALUE then
          begin
            Tokens.Back^.Value := TokenScalarValue;
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

