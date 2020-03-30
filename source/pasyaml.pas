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
  Classes, SysUtils, libpasyaml;

const
  ERROR_OK                                                            =  1;

type
  { TYamlFile }
  { Configuration YAML file }
  TYamlFile = class
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

      { Errors list }
      TErrors = (
        ERROR_NONE                                                  = 0,
        ERROR_EMITTER_INIT                                          = 1 shl 0,
        ERROR_EMITTER_FINAL                                         = 1 shl 1,
        ERROR_STREAM_INIT                                           = 1 shl 2,
        ERROR_STREAM_FINAL                                          = 1 shl 3,
        ERROR_DOCUMENT_INIT                                         = 1 shl 4,
        ERROR_DOCUMENT_FINAL                                        = 1 shl 5,
        ERROR_MAP_INIT                                              = 1 shl 6,
        ERROR_MAP_FINAL                                             = 1 shl 7,
        ERROR_SEQUENCE_INIT                                         = 1 shl 8,
        ERROR_SEQUENCE_FINAL                                        = 1 shl 9
      );

      TVoidResult = class(specialize TResult<Pointer, Integer>)
      private
        property Value;
      public
        constructor Create(AError : Integer; AOk : Boolean);
      end;

      { Document encoding }
      TEncoding = (
        { Let the parser choose the encoding. }
        ENCODING_DEFAULT = Longint(YAML_ANY_ENCODING),
        { The default UTF-8 encoding. }
        ENCODING_UTF8    = Longint(YAML_UTF8_ENCODING),
        { The UTF-16-LE encoding with BOM. }
        ENCODING_UTF16LE = Longint(YAML_UTF16LE_ENCODING),
        { The UTF-16-BE encoding with BOM. }
        ENCODING_UTF16BE = Longint(YAML_UTF16BE_ENCODING)
      );

      { Yaml mapping style }
      TMapStyle = (
        { Let the emitter choose the style. }
        MAP_STYLE_ANY   = Longint(YAML_ANY_MAPPING_STYLE),
        { The block mapping style. }
        MAP_STYLE_BLOCK = Longint(YAML_BLOCK_MAPPING_STYLE),
        { The flow mapping style. }
        MAP_STYLE_FLOW  = Longint(YAML_FLOW_MAPPING_STYLE)
      );

      { Yaml sequence style }
      TSequenceStyle = (
        { Let the emitter choose the style. }
        SEQUENCE_STYLE_ANY = Longint(YAML_ANY_SEQUENCE_STYLE),
        { The block sequence style. }
        SEQUENCE_STYLE_BLOCK = Longint(YAML_BLOCK_SEQUENCE_STYLE),
        { The flow sequence style. }
        SEQUENCE_STYLE_FLOW = Longint(YAML_FLOW_SEQUENCE_STYLE)
      );

      { TOptionWriter }
      { Writer for configuration option }
      TOptionWriter = class
      protected
        FEvent : yaml_event_t;
      public
        constructor Create (Event : yaml_event_t);
        destructor Destroy; override;
      end;

      { TMapWriter }
      { Map option writer }
      TMapWriter = class (TOptionWriter)
      public
        constructor Create (Event : yaml_event_t; Style : TMapStyle);
        destructor Destroy; override;
      end;

      { TSequenceWriter }
      { Sequence option writer }
      TSequenceWriter = class (TOptionWriter)
      public
        constructor Create (Event : yaml_event_t; Style : TSequenceStyle);
        destructor Destroy; override;
      end;

      { TOptionReader }
      { Reader for configuration option }
      TOptionReader = class

      end;
  private
    FEmitter : yaml_emitter_t;
    FEvent : yaml_event_t;
    FLastElement : TOptionWriter;
    FLastError : Integer;
  private
    function _CreateMap (Style : TMapStyle) : TOptionWriter;{$IFNDEF DEBUG}
      inline;{$ENDIF}
    function _CreateSequence (Style : TSequenceStyle) : TOptionWriter;
      {$IFNDEF DEBUG}inline;{$ENDIF}
  public
    constructor Create (Encoding : TEncoding = ENCODING_UTF8);
    destructor Destroy; override;

    { Create new map section }
    property CreateMap [Style : TMapStyle] : TOptionWriter read
      _CreateMap;

    { Create new sequence section }
    property CreateSequence [Style : TSequenceStyle] : TOptionWriter read
      _CreateSequence;
  end;

implementation

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

{ TYamlFile.TSequenceWriter }

constructor TYamlFile.TSequenceWriter.Create(Event: yaml_event_t;
  Style: TSequenceStyle);
begin
  inherited Create(Event);
  if yaml_sequence_start_event_initialize(@FEvent, nil,
       pyaml_char_t(PChar(YAML_SEQ_TAG)), 1,
       yaml_sequence_style_e(Longint(Style))) <> ERROR_OK then
  begin

  end;
end;

destructor TYamlFile.TSequenceWriter.Destroy;
begin
  if yaml_mapping_end_event_initialize(@FEvent) <> ERROR_OK then
  begin

  end;

  inherited Destroy;
end;

{ TYamlFile.TMapWriter }

constructor TYamlFile.TMapWriter.Create(Event: yaml_event_t; Style: TMapStyle);
begin
  inherited Create(Event);
  if yaml_mapping_start_event_initialize(@FEvent, nil,
       pyaml_char_t(PChar(YAML_MAP_TAG)), 1,
       yaml_mapping_style_e(Longint(Style))) <> ERROR_OK then
  begin

  end;
end;

destructor TYamlFile.TMapWriter.Destroy;
begin
  if yaml_mapping_end_event_initialize(@FEvent) <> ERROR_OK then
  begin

  end;

  inherited Destroy;
end;

{ TYamlFile.TOptionWriter }

constructor TYamlFile.TOptionWriter.Create(Event: yaml_event_t);
begin
  FEvent := Event;
end;

destructor TYamlFile.TOptionWriter.Destroy;
begin
  inherited Destroy;
end;

{ TYamlConfig }

function TYamlFile._CreateMap(Style: TMapStyle): TOptionWriter;
begin
  FreeAndNil(FLastElement);
  FLastElement := TMapWriter.Create(FEvent, Style);
  Result := FLastElement;
end;

function TYamlFile._CreateSequence(Style: TSequenceStyle): TOptionWriter;
begin
  FreeAndNil(FLastElement);
  FLastElement := TSequenceWriter.Create(FEvent, Style);
  Result := FLastElement;
end;

constructor TYamlFile.Create (Encoding : TEncoding);
begin
  FLastError := Longint(ERROR_NONE);

  if yaml_emitter_initialize(@FEmitter) <> ERROR_OK then
  begin
    FLastError := Longint(ERROR_EMITTER_INIT);
  end;

  if yaml_stream_start_event_initialize(@FEvent,
    yaml_encoding_t(Encoding)) <> ERROR_OK then
  begin
    FLastError := FLastError or Longint(ERROR_STREAM_INIT);
  end;

  if yaml_document_start_event_initialize(@FEvent, nil, nil, nil, 0) <>
    ERROR_OK then
  begin
    FLastError := FLastError or Longint(ERROR_DOCUMENT_INIT);
  end;

  FLastElement := nil;
end;

destructor TYamlFile.Destroy;
begin
  FreeAndNil(FLastElement);
  yaml_stream_end_event_initialize(@FEvent);
  yaml_emitter_delete(@FEmitter);
  inherited Destroy;
end;

end.

