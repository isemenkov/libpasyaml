(******************************************************************************)
(*                                 libPasYAML                                 *)
(*                object pascal wrapper around libyaml library                *)
(*                       https://github.com/yaml/libyaml                      *)
(*                                                                            *)
(* Copyright (c) 2020 - 2021                                Ivan Semenkov     *)
(* https://github.com/isemenkov/libpasyaml                  ivan@semenkov.pro *)
(*                                                          Ukraine           *)
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

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  Classes, SysUtils, libpasyaml, dateutils, utils.result, container.list, 
  container.avltree, utils.functor;

type
  { Configuration YAML file }
  TYamlFile = class
  public
    type
      { Forward declarations }
      TOptionReader = class;
  protected
    { Return value by key }
    function GetValue (AKey : String) : TOptionReader;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    constructor Create (APathKeyDelimiter : String = '.');
    destructor Destroy; override;

    { Parse YAML configuration from string }
    procedure Parse (ConfigString : String);

    { Return option value by path }
    property Value [AKey : String] : TOptionReader read GetValue;
  private
    const
      ERROR_OK                                                           = 1;

    type    
      { Config document elements types }
      TItemValueType = (
        TYPE_NONE,
        TYPE_MAP,
        TYPE_MAP_KEY,
        TYPE_MAP_VALUE,
        TYPE_SEQUENCE,
        TYPE_SEQUENCE_ENTRY,
        TYPE_ANCHOR,
        TYPE_ALIAS,
        TYPE_SCALAR,
        TYPE_END_BLOCK
      );

      PItemValue = ^TItemValue;

      { PItemValue compare functor }  
      TItemValueCompareFunctor =
        class(specialize TBinaryFunctor<PItemValue, Integer>)
      public
        function Call(AValue1, AValue2 : PItemValue) : Integer; override;
      end;

      { TOptionReader compare functor }
      TOptionReaderCompareFunctor = 
        class(specialize TBinaryFunctor<TOptionReader, Integer>)
      public
        function Call(AValue1, AValue2 : TOptionReader) : Integer; override;
      end;
      
      TItemsMap = class(specialize TAvlTree<String, TOptionReader,
        TCompareFunctorString>);
      TItemsList = class(specialize TList<TOptionReader, 
        TOptionReaderCompareFunctor>);

      { Config document element }
      TItemValue = record
        ValueType : TYamlFile.TItemValueType;
        case Byte of
          TYPE_MAP :            (Map : TItemsMap);
          TYPE_MAP_KEY :        (Key : PChar);
          TYPE_MAP_VALUE :      (Value : PChar);
          TYPE_SEQUENCE :       (Sequence : TItemsList);
          TYPE_SEQUENCE_ENTRY : (SequenceEntry : PChar);
          TYPE_ANCHOR :         (Anchor : PChar);
          TYPE_ALIAS :          (AliasName : PChar);
          TYPE_SCALAR :         (Scalar : PChar);
      end;

      { Bidirectional list and stack class }
      TItemsSequence = class
      public
        constructor Create;
        destructor Destroy; override;

        { Get front element value }
        function  Front : PItemValue; overload;
          {$IFNDEF DEBUG}inline;{$ENDIF}
        function  Front (ALevel : Cardinal) : PItemValue; overload;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Add new element to front }
        procedure FrontPush (AItem : PItemValue);
          {$IFNDEF DEBUG}inline;{$ENDIF}
        procedure FrontPush (AItem : TYamlFile.TOptionReader);
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Take element from front side }
        function  FrontPop : PItemValue;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get back element value }
        function  Back : PItemValue; overload;
          {$IFNDEF DEBUG}inline;{$ENDIF}
        function  Back (ALevel : Cardinal) : PItemValue; overload;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Add new element to back }
        procedure BackPush (AItem : PItemValue);
          {$IFNDEF DEBUG}inline;{$ENDIF}
        procedure BackPush (AItem : TYamlFile.TOptionReader);
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Take element from back side }
        function  BackPop : PItemValue;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Add element to stack }
        procedure Push (AItem : PItemValue);
          {$IFNDEF DEBUG}inline;{$ENDIF}
        procedure Push (AItem : TYamlFile.TOptionReader);
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get stack's top element value }
        function Top : PItemValue;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Take element from stack }
        function Pop : PItemValue;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      private
        type
          TItemsList = specialize TList<PItemValue, TItemValueCompareFunctor>;
        var
          FList : TItemsList;
      end;

    var
      FParser : yaml_parser_t;
      FRoot : TOptionReader;
      FPathKeyDelimiter : String;
  public
    type
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
            FPathKeyDelimiter : String;

            function GetCurrent : TOptionReader;
              {$IFNDEF DEBUG}inline;{$ENDIF}
          public
            constructor Create (AOption : PItemValue; APathKeyDelimiter : 
              String = '.');
            function MoveNext : Boolean;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            function GetEnumerator : TSequenceEnumerator;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            property Current : TOptionReader read GetCurrent;
          end;
      protected
        { Parse option path }
        function ParsePath (APath : String) : TOptionReader; 
          {$IFNDEF DEBUG}inline;{$ENDIF}

        function GetValue (AKey : String) : TOptionReader;
          {$IFNDEF DEBUG}inline;{$ENDIF}
        function ParseDateTime (AValue : String) : TDateTime;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      public
        constructor Create (APathKeyDelimiter : String = '.');
        constructor Create (AValue : PItemValue; APathKeyDelimiter : String =
          '.');
        destructor Destroy; override;

        { Return TRUE if element is Map type }
        function IsMap : Boolean;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return TRUE if element is Sequence type }
        function IsSequence : Boolean;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return TRUE if element is Scalar type }
        function IsScalar : Boolean;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return element's value as String type }
        function AsString : String;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return element's value as Integer type }
        function AsInteger : Integer;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return element's value as Float type }
        function AsFloat : Double;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return element's value as TDate type }
        function AsDate : TDate;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return element's value as TTime type }
        function AsTime : TTime;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return element's value as TDateTime type }
        function AsDateTime : TDateTime;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return element's value as Sequence enumerator }
        function AsSequence : TSequenceEnumerator;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return option value by path }
        property Value [AKey : String] : TOptionReader read GetValue;
      private
        FValue : TItemValue;
        FPathKeyDelimiter : String;
      end;

      { Writer for configuration option }
      TOptionWriter = class
      protected
        { Create new map value }
        function CreateMapValue (AName : String) : TOptionWriter;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      public
        constructor Create (AValue : PItemValue; APathKeyDelimiter : String =
          '.');

        property CreateMap [AName : String] : TOptionWriter read CreateMapValue;
      private
        FValue : TItemValue;
        FPathKeyDelimiter : String;
      end;
  public
    { Return TRUE if root element is Map type }
    function IsMap : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    { Return TRUE if root element is Sequence type }
    function IsSequence : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}

    { Return root element's value as Sequence enumerator }
    function AsSequence : TOptionReader.TSequenceEnumerator;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  end;

implementation

{ TYamlFile.TItemValueCompareFunctor }

function TYamlFile.TItemValueCompareFunctor.Call(AValue1, AValue2 : PItemValue) 
  : Integer;
begin
  if (AValue1 = nil) or (AValue2 = nil) or (AValue1^.ValueType < 
    AValue2^.ValueType) then
  begin
    Result := -1;
  end else if AValue2^.ValueType < AValue1^.ValueType then
  begin
    Result := 1;
  end else
  begin
    Result := 0;
  end;
end;

{ TYamlFile.TOptionReaderCompareFunctor }

function TYamlFile.TOptionReaderCompareFunctor.Call(AValue1, AValue2 : 
  TOptionReader) : Integer;
begin
  if AValue1.FValue.ValueType < AValue2.FValue.ValueType then
  begin
    Result := -1;
  end else if AValue2.FValue.ValueType < AValue1.FValue.ValueType then
  begin
    Result := 1;
  end else
  begin
    Result := 0;
  end;
end;

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
  Result := FList.FirstEntry.Value;
end;

function TYamlFile.TItemsSequence.Front (ALevel : Cardinal) : PItemValue;
begin
  if FList.Length > ALevel then
  begin
    Result := FList.NthEntry(ALevel).Value;
  end else
    Result := nil;
end;

procedure TYamlFile.TItemsSequence.FrontPush (AItem : PItemValue);
begin
  FList.Prepend(AItem);
end;

procedure TYamlFile.TItemsSequence.FrontPush (AItem : TYamlFile.TOptionReader);
begin
  FrontPush(@AItem.FValue);
end;

function TYamlFile.TItemsSequence.FrontPop : PItemValue;
begin
  if FList.Length > 0 then
  begin
    Result := FList.FirstEntry.Value;
    FList.FirstEntry.Remove;
  end else
  begin
    Result := nil;
  end;
end;

function TYamlFile.TItemsSequence.Back : PItemValue;
begin
  Result := FList.LastEntry.Value;
end;

function TYamlFile.TItemsSequence.Back (ALevel : Cardinal) : PItemValue;
begin
  if (FList.Length - ALevel) > 0 then
  begin
    Result := FList.NthEntry(FList.Length - ALevel - 1).Value;
  end else
    Result := nil;
end;

procedure TYamlFile.TItemsSequence.BackPush (AItem : PItemValue);
begin
  FList.Append(AItem);
end;

procedure TYamlFile.TItemsSequence.BackPush (AItem : TYamlFile.TOptionReader);
begin
  BackPush(@AItem.FValue);
end;

function TYamlFile.TItemsSequence.BackPop : PItemValue;
begin
  if FList.Length > 0 then
  begin
    Result := FList.LastEntry.Value;
    FList.LastEntry.Remove;
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

{ TYamlFile.TOptionReader.TSequenceEnumerator }

constructor TYamlFile.TOptionReader.TSequenceEnumerator.Create (AOption :
  PItemValue; APathKeyDelimiter : String);
begin
  FOption := AOption;
  FPosition := 0;
  FPathKeyDelimiter := APathKeyDelimiter;

  if (FOption = nil) or (AOption^.ValueType <> TYPE_SEQUENCE) then
    FCount := 0
  else
    FCount := FOption^.Sequence.Length;
end;

function TYamlFile.TOptionReader.TSequenceEnumerator.GetCurrent : TOptionReader;
begin
  if FOption = nil then
  begin
    Result := TOptionReader.Create(FOption, FPathKeyDelimiter);
    Exit;
  end;

  Result := 
    TOptionReader.Create(@FOption^.Sequence.NthEntry(FPosition).Value.FValue,
    FPathKeyDelimiter);
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

constructor TYamlFile.TOptionReader.Create (APathKeyDelimiter : String);
begin
  FValue.ValueType := TYPE_NONE;
  FPathKeyDelimiter := APathKeyDelimiter;
end;

constructor TYamlFile.TOptionReader.Create (AValue : PItemValue; 
  APathKeyDelimiter : String);
begin
  FValue := AValue^;
  FPathKeyDelimiter := APathKeyDelimiter;
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

function TYamlFile.TOptionReader.ParsePath (APath : String) : TOptionReader;
var
  Key : String;
  StartPos, DelimiterPos : Integer;
  Item : TOptionReader;
begin
  if FValue.ValueType <> TYPE_MAP then
  begin
    Exit(TOptionReader.Create(FPathKeyDelimiter));
  end;

  StartPos := 1;
  Item := Self;
  DelimiterPos := Pos(FPathKeyDelimiter, APath);

  if DelimiterPos = 0 then
  begin
    Exit(Item.FValue.Map.Search(APath));
  end;

  while DelimiterPos <> 0 do
  begin
    Key := Copy(APath, StartPos, DelimiterPos - StartPos);
    Item := Item.FValue.Map.Search(Key);
    StartPos := DelimiterPos + 1;
    DelimiterPos := Pos(FPathKeyDelimiter, APath, StartPos);
  end;

  Key := Copy(APath, StartPos, Length(APath) - StartPos + 1);
  Result := Item.FValue.Map.Search(Key);
end;

function TYamlFile.TOptionReader.GetValue (AKey : String) : TOptionReader;
begin
  Result := ParsePath(AKey);
end;

function TYamlFile.TOptionReader.ParseDateTime (AValue : String) : TDateTime;
var
  yy : Word;
  mm : Word;
  dd : Word;
  hh : Word;
  mn : Word;
  sc : Word;
begin
  yy := StrToIntDef(Copy(AValue, 1, 4), 0);
  mm := StrToIntDef(Copy(AValue, 6, 2), 0);
  dd := StrToIntDef(Copy(AValue, 9, 2), 0);
  hh := StrToIntDef(Copy(AValue, 12, 2), 0);
  mn := StrToIntDef(Copy(AValue, 15, 2), 0);
  sc := StrToIntDef(Copy(AValue, 18, 2), 0);

  Result := EncodeDateTime(yy, mm, dd, hh, mn, sc, 0);
end;

function TYamlFile.TOptionReader.IsMap : Boolean;
begin
  Result := (FValue.ValueType = TYPE_MAP);
end;

function TYamlFile.TOptionReader.IsSequence : Boolean;
begin
  Result := (FValue.ValueType = TYPE_SEQUENCE);
end;

function TYamlFile.TOptionReader.IsScalar : Boolean;
begin
  Result := (FValue.ValueType = TYPE_SCALAR);
end;

function TYamlFile.TOptionReader.AsString : String;
begin
  Result := FValue.Scalar;
end;

function TYamlFile.TOptionReader.AsInteger : Integer;
begin
  Result := StrToInt(FValue.Scalar);
end;

function TYamlFile.TOptionReader.AsFloat : Double;
begin
  Result := StrToFloat(FValue.Scalar);
end;

function TYamlFile.TOptionReader.AsDateTime : TDateTime;
begin
  Result := ParseDateTime(FValue.Scalar);
end;

function TYamlFile.TOptionReader.AsDate : TDate;
begin
  Result := DateOf(ParseDateTime(FValue.Scalar));
end;

function TYamlFile.TOptionReader.AsTime : TTime;
begin
  Result := TimeOf(ParseDateTime(FValue.Scalar));
end;

function TYamlFile.TOptionReader.AsSequence : TSequenceEnumerator;
begin
  Result := TSequenceEnumerator.Create(@FValue, FPathKeyDelimiter);
end;

{ TYamlFile.TOptionWriter }
constructor TYamlFile.TOptionWriter.Create (AValue : PItemValue; 
  APathKeyDelimiter : String);
begin
  FValue := AValue^;
  FPathKeyDelimiter := APathKeyDelimiter;
end;

{ TYamlFile }

constructor TYamlFile.Create (APathKeyDelimiter : String);
begin
  FPathKeyDelimiter := APathKeyDelimiter;
  FRoot := TOptionReader.Create(FPathKeyDelimiter);

  if yaml_parser_initialize(@FParser) <> ERROR_OK then
    ;
end;

destructor TYamlFile.Destroy;
begin
  yaml_parser_delete(@FParser);
  FreeAndNil(FRoot);
  inherited Destroy;
end;

procedure TYamlFile.Parse(ConfigString : String);
const
  {%H-}PREVIOUS_TOKEN_POSITION                                           = 0;
  THROUGH_TWO_TOKENS_POSITION                                            = 1;
var
  Tokens : TItemsSequence;
  Token : yaml_token_t;
  CurrentFlowEntry : TItemValueType = TYPE_NONE;

  { Create new ASequence item and add it to the back side }
  procedure CreateValueAndBackPush (var ASequence : TItemsSequence; AValueType :
    TItemValueType);
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    ASequence.BackPush(New(PItemValue));
    ASequence.Back^.ValueType := AValueType;

    if AValueType = TYPE_SEQUENCE_ENTRY then
    begin
      ASequence.Back^.SequenceEntry := nil;
    end;
  end;

  { Create new ASequence item and add it to the top }
  procedure CreateValueAndTopPush (var ASequence : TItemsSequence; AValueType :
    TItemValueType);
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    ASequence.Push(New(PItemValue));
    ASequence.Top^.ValueType := AValueType;
  end;

  { Remember current flow entry element type }
  procedure RememberFlowEntry (AEntry : TItemValueType);
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    CurrentFlowEntry := AEntry;
  end;

  { Process YAML tokens and create document structure }
  procedure ProcessTokens;
    {$IFNDEF DEBUG}inline;{$ENDIF}
  var
    CurrentToken : PItemValue;
    ForwardToken : PItemValue;
    ConfigTree : TItemsSequence;
    AliasesMap : TItemsMap;

    { Set next token from Tokens variable sequence to AToken item and also
      return it. Remove token from sequence at end }
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
      Result := TOptionReader.Create(FPathKeyDelimiter);
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

    { Return TRUE if AElement type is TYPE_MAP }
    function IsMap (AElement : PItemValue) : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_MAP);
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

    { Return TRUE if AElement type is TYPE_ANCHOR }
    function IsAnchor (AElement : PItemValue) : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_ANCHOR);
    end;

    { Return TRUE if AElement type is TYPE_ALIAS }
    function IsAlias (AElement : PItemValue) : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := (AElement^.ValueType = TYPE_ALIAS);
    end;

    { Set AElement.Map[AKey] := AValue }
    procedure CreateMapValue (AElement : PItemValue; AKey : PChar; AValue :
      PChar); overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Map.Insert(AKey, CreateOptionReader(TYPE_SCALAR));
      AElement^.Map.Search(AKey).FValue.Scalar := AValue;
    end;

    { Set AElement.Map[AKey] := New(Map) }
    procedure CreateMapValue (AElement : PItemValue; AKey : PChar); overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Map.Insert(AKey, CreateOptionReader(TYPE_NONE));
    end;

    { Set AElement.Map[AKey] := New(Sequence) }
    procedure CreateSequenceValue (AElement : PItemValue; AKey : PChar);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Map.Insert(AKey, CreateOptionReader(TYPE_NONE));
    end;

    { Store anchor key and value }
    procedure CreateAnchorValue (AKey : PChar; AValue : PChar);
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AliasesMap.Insert(AKey, CreateOptionReader(TYPE_SCALAR));
      AliasesMap.Search(AKey).FValue.Scalar := AValue;
    end;

    { Return Alias[Key] value }
    function GetAliasValue (AKey : PChar) : PChar;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := AliasesMap.Search(AKey).FValue.Scalar;
    end;

    { Create new element and add it to AElement.Sequence }
    function AddSequenceValue (AElement : PItemValue) : PItemValue; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Sequence.Append(TOptionReader.Create(FPathKeyDelimiter));
      Result := @AElement^.Sequence.NthEntry(AElement^.Sequence.Length - 1)
        .Value.FValue;
    end;

    { Create new element and add it to AElement.Sequence TYPE_SCALAR type and
      AValue value }
    function AddSequenceValue (AElement : PItemValue; AValue : PChar) :
      PItemValue; overload;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      AElement^.Sequence.Append(TOptionReader.Create(FPathKeyDelimiter));
      AElement^.Sequence.NthEntry(AElement^.Sequence.Length - 1).Value.FValue
        .ValueType := TYPE_SCALAR;
      AElement^.Sequence.NthEntry(AElement^.Sequence.Length - 1).Value.FValue
        .Scalar := AValue;
      Result := @AElement^.Sequence.NthEntry(AElement^.Sequence.Length - 1)
        .Value.FValue;
    end;

    { Return TRUE if AElement sequence entry contains value }
    function IsSequenceEntryHasValue (AElement : PItemValue) : Boolean;
      {$IFNDEF DEBUG}inline;{$ENDIF}
    begin
      Result := (AElement^.SequenceEntry <> nil);
    end;

  begin
    AliasesMap := TItemsMap.Create;
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
            { CurrentToken  ->   NextToken   ->   NextToken
                   ^                ^                 ^
              TYPE_MAP_KEY    TYPE_MAP_VALUE    TYPE_SEQUENCE }
            if IsMapValue(Next(ForwardToken)) and IsSequence(ForwardNext) then
            begin
              CreateSequenceValue(ConfigTree.Top, CurrentToken^.Key);
              ConfigTree.Push(ConfigTree.Top^.Map.Search(CurrentToken^.Key));
            end else
            { CurrentToken  ->   NextToken   ->   NextToken
                   ^                ^                 ^
              TYPE_MAP_KEY    TYPE_MAP_VALUE       TYPE_MAP }
            if IsMapValue(ForwardToken) and IsMap(ForwardNext) then
            begin
              CreateMapValue(ConfigTree.Top, CurrentToken^.Key);
              ConfigTree.Push(ConfigTree.Top^.Map.Search(CurrentToken^.Key));
            end else
            { CurrentToken  ->   NextToken   ->   NextToken
                   ^                ^                 ^
              TYPE_MAP_KEY    TYPE_MAP_VALUE      TYPE_ALIAS }
            if IsMapValue(ForwardToken) and IsAlias(ForwardNext) then
            begin
              CreateMapValue(ConfigTree.Top, CurrentToken^.Key,
                GetAliasValue(Next(ForwardToken)^.AliasName));
            end else
            begin
              { CurrentToken  ->   NextToken   ->   NextToken
                     ^                ^                 ^
                TYPE_MAP_KEY    TYPE_MAP_VALUE    TYPE_MAP_KEY }
              CreateMapValue(ConfigTree.Top, CurrentToken^.Key,
                ForwardToken^.Value);

              { CurrentToken  ->   NextToken   ->   NextToken
                     ^                ^                 ^
                TYPE_MAP_KEY    TYPE_MAP_VALUE    TYPE_ANCHOR }
              if IsAnchor(ForwardNext) then
              begin
                CreateAnchorValue(ForwardNext^.Anchor, ForwardToken^.Value);
                Next(ForwardToken);
              end;
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
            if IsSequenceEntryHasValue(CurrentToken) then
            begin
              AddSequenceValue(ConfigTree.Top, CurrentToken^.SequenceEntry);
            end else
            if IsAlias(ForwardNext) then
            begin
              AddSequenceValue(ConfigTree.Top,
                GetAliasValue(Next(ForwardToken)^.AliasName));
            end else
            begin
              ConfigTree.Push(AddSequenceValue(ConfigTree.Top));
            end;
          end;
        TYPE_END_BLOCK :
          begin
            ConfigTree.Pop;
          end;
      end;
      Next(CurrentToken);
    end;

    FreeAndNil(ConfigTree);
    FreeAndNil(AliasesMap);
  end;

  { Return Token variable scalar value }
  function TokenScalarValue : PChar;
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    Result := StrCopy(StrAlloc(StrLen(PChar(Token.token.scalar.value)) + 1),
      PChar(Token.token.scalar.value));
  end;

  { Return Token variable anchor value }
  function TokenAnchorValue : PChar;
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    Result := StrCopy(StrAlloc(StrLen(PChar(Token.token.anchor.value)) + 1),
      PChar(Token.token.anchor.value));
  end;

  { Return Token variable alias value }
  function TokenAliasValue : PChar;
    {$IFNDEF DEBUG}inline;{$ENDIF}
  begin
    Result := StrCopy(StrAlloc(StrLen(PChar(Token.token.alias_param.value))
      + 1), PChar(Token.token.alias_param.value));
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
      YAML_ANCHOR_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_ANCHOR);
          Tokens.Back^.Anchor := TokenAnchorValue;
        end;
      YAML_ALIAS_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_ALIAS);
          Tokens.Back^.AliasName := TokenAliasValue;
        end;
      YAML_BLOCK_SEQUENCE_START_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_SEQUENCE);
        end;
      YAML_BLOCK_ENTRY_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_SEQUENCE_ENTRY);
        end;
      YAML_FLOW_ENTRY_TOKEN :
        begin
          if CurrentFlowEntry = TYPE_SEQUENCE_ENTRY then
          begin
            CreateValueAndBackPush(Tokens, CurrentFlowEntry);
          end;
        end;
      YAML_FLOW_SEQUENCE_START_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_SEQUENCE);
          CreateValueAndBackPush(Tokens, TYPE_SEQUENCE_ENTRY);
          RememberFlowEntry(TYPE_SEQUENCE_ENTRY);
        end;
      YAML_BLOCK_END_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_END_BLOCK);
        end;
      YAML_FLOW_SEQUENCE_END_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_END_BLOCK);
          RememberFlowEntry(TYPE_NONE);
        end;
      YAML_BLOCK_MAPPING_START_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_MAP);
        end;
      YAML_FLOW_MAPPING_START_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_MAP);
        end;
      YAML_FLOW_MAPPING_END_TOKEN :
        begin
          CreateValueAndBackPush(Tokens, TYPE_END_BLOCK);
        end;
      YAML_SCALAR_TOKEN :
        begin
          case Tokens.Back^.ValueType of
            TYPE_MAP_KEY :
              begin
                Tokens.Back^.Key := TokenScalarValue;
              end;
            TYPE_MAP_VALUE :
              begin
                Tokens.Back^.Value := TokenScalarValue;
              end;
            TYPE_SEQUENCE_ENTRY :
              begin
                Tokens.Back^.SequenceEntry := TokenScalarValue;
              end;
            TYPE_ANCHOR :
              begin
                { We need back for two elements from current token position.
                  Current token now not in the queue so we back for another one
                  element and get the second one from end. }
                case Tokens.Back(THROUGH_TWO_TOKENS_POSITION)^.ValueType of
                  TYPE_MAP_VALUE :
                    begin
                      Tokens.Back(THROUGH_TWO_TOKENS_POSITION)^.Key :=
                        TokenScalarValue;
                    end;
                  TYPE_SEQUENCE_ENTRY :
                    begin
                      Tokens.Back(THROUGH_TWO_TOKENS_POSITION)^.SequenceEntry :=
                        TokenScalarValue;
                    end;
                end;
              end;
            TYPE_ALIAS :
              begin
                { See TYPE_ANCHOR comment }
                Tokens.Back(THROUGH_TWO_TOKENS_POSITION)^.AliasName :=
                  TokenAliasValue;
              end;
          end;
        end;
    end;

    if Token.token_type <> YAML_STREAM_END_TOKEN then
      yaml_token_delete(@Token);

  until Token.token_type = YAML_STREAM_END_TOKEN;

  yaml_token_delete(@Token);
  FreeAndNil(Tokens);
end;

function TYamlFile.GetValue (AKey : String) : TOptionReader;
begin
  Result := FRoot.ParsePath(AKey);
end;

function TYamlFile.IsMap : Boolean;
begin
  Result := (FRoot.FValue.ValueType = TYPE_MAP);
end;

function TYamlFile.IsSequence : Boolean;
begin
  Result := (FRoot.FValue.ValueType = TYPE_SEQUENCE);
end;

function TYamlFile.AsSequence : TOptionReader.TSequenceEnumerator;
begin
  Result := TOptionReader.TSequenceEnumerator.Create(@FRoot.FValue,
    FPathKeyDelimiter);
end;

end.

