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

unit libpasyaml;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

{$IFDEF FPC}
  {$PACKRECORDS C}
{$ENDIF}

const

type
  { The character type (UTF-8 octet). }
  pyaml_char_t = ^yaml_char_t;
  yaml_char_t = type Byte;

  { The version directive data. }
  yaml_version_directive_s = record
    major : Integer; { The major version number. }
    minor : Integer; { The minor version number. }
  end;
  yaml_version_directive_t = yaml_version_directive_s;

  { The tag directive data. }
  yaml_tag_directive_s = record
    handle : pyaml_char_t; { The tag handle. }
    prefix : pyaml_char_t; { The tag prefix. }
  end;
  yaml_tag_directive_t = yaml_tag_directive_s;

  { The stream encoding. }
  yaml_encoding_e = (
    YAML_ANY_ENCODING,     { Let the parser choose the encoding. }
    YAML_UTF8_ENCODING,    { The default UTF-8 encoding. }
    YAML_UTF16LE_ENCODING, { The UTF-16-LE encoding with BOM. }
    YAML_UTF16BE_ENCODING  { The UTF-16-BE encoding with BOM. }
  );
  yaml_encoding_t = yaml_encoding_e;

  { Line break types. }
  yaml_break_e = (
    YAML_ANY_BREAK,        { Let the parser choose the break type. }
    YAML_CR_BREAK,         { Use CR for line breaks (Mac style). }
    YAML_LN_BREAK,         { Use LN for line breaks (Unix style). }
    YAML_CRLN_BREAK        { Use CR LN for line breaks (DOS style). }
  );
  yaml_break_t = yaml_break_e;

  { Many bad things could happen with the parser and emitter. }
  yaml_error_type_e = (
    YAML_NO_ERROR,         { No error is produced. }
    YAML_MEMORY_ERROR,     { Cannot allocate or reallocate a block of memory. }
    YAML_READER_ERROR,     { Cannot read or decode the input stream. }
    YAML_SCANNER_ERROR,    { Cannot scan the input stream. }
    YAML_PARSER_ERROR,     { Cannot parse the input stream. }
    YAML_COMPOSER_ERROR,   { Cannot compose a YAML document. }
    YAML_WRITER_ERROR,     { Cannot write to the output stream. }
    YAML_EMITTER_ERROR     { Cannot emit a YAML stream. }
  );
  yaml_error_type_t = yaml_error_type_e;

  { The pointer position. }
  yaml_mark_s = record
    index : QWord;         { The position index. }
    line : QWord;          { The position line. }
    column : QWord;        { The position column. }
  end;
  yaml_mark_t = yaml_mark_s;

  { Scalar styles. }
  yaml_scalar_style_e = (
    YAML_ANY_SCALAR_STYLE,           { Let the emitter choose the style. }
    YAML_PLAIN_SCALAR_STYLE,         { The plain scalar style. }
    YAML_SINGLE_QUOTED_SCALAR_STYLE, { The single-quoted scalar style. }
    YAML_DOUBLE_QUOTED_SCALAR_STYLE, { The double-quoted scalar style. }
    YAML_LITERAL_SCALAR_STYLE,       { The literal scalar style. }
    YAML_FOLDED_SCALAR_STYLE         { The folded scalar style. }
  );
  yaml_scalar_style_t = yaml_scalar_style_e;

  { Sequence styles. }
  yaml_sequence_style_e = (
    YAML_ANY_SEQUENCE_STYLE,         { Let the emitter choose the style. }
    YAML_BLOCK_SEQUENCE_STYLE,       { The block sequence style. }
    YAML_FLOW_SEQUENCE_STYLE         { The flow sequence style. }
  );
  yaml_sequence_style_t = yaml_sequence_style_e;

  { Mapping styles. }
  yaml_mapping_style_e = (
    YAML_ANY_MAPPING_STYLE,          { Let the emitter choose the style. }
    YAML_BLOCK_MAPPING_STYLE,        { The block mapping style. }
    YAML_FLOW_MAPPING_STYLE          { The flow mapping style. }
  );
  yaml_mapping_style_t = yaml_mapping_style_e;

  { Token types. }
  yaml_token_type_e = (
    YAML_NO_TOKEN,                   { An empty token. }
    YAML_STREAM_START_TOKEN,         { A STREAM-START token. }
    YAML_STREAM_END_TOKEN,           { A STREAM-END token. }
    YAML_VERSION_DIRECTIVE_TOKEN,    { A VERSION-DIRECTIVE token. }
    YAML_TAG_DIRECTIVE_TOKEN,        { A TAG-DIRECTIVE token. }
    YAML_DOCUMENT_START_TOKEN,       { A DOCUMENT-START token. }
    YAML_DOCUMENT_END_TOKEN,         { A DOCUMENT-END token. }
    YAML_BLOCK_SEQUENCE_START_TOKEN, { A BLOCK-SEQUENCE-START token. }
    YAML_BLOCK_MAPPING_START_TOKEN,  { ??? }
    YAML_BLOCK_END_TOKEN,            { A BLOCK-END token. }
    YAML_FLOW_SEQUENCE_START_TOKEN,  { A FLOW-SEQUENCE-START token. }
    YAML_FLOW_SEQUENCE_END_TOKEN,    { A FLOW-SEQUENCE-END token. }
    YAML_FLOW_MAPPING_START_TOKEN,   { A FLOW-MAPPING-START token. }
    YAML_FLOW_MAPPING_END_TOKEN,     { A FLOW-MAPPING-END token. }
    YAML_BLOCK_ENTRY_TOKEN,          { A BLOCK-ENTRY token. }
    YAML_FLOW_ENTRY_TOKEN,           { A FLOW-ENTRY token. }
    YAML_KEY_TOKEN,                  { A KEY token. }
    YAML_VALUE_TOKEN,                { A VALUE token. }
    YAML_ALIAS_TOKEN,                { An ALIAS token. }
    YAML_ANCHOR_TOKEN,               { An ANCHOR token. }
    YAML_TAG_TOKEN,                  { A TAG token. }
    YAML_SCALAR_TOKEN                { A SCALAR token. }
  );
  yaml_token_type_t = yaml_token_type_e;

  { The token structure. }
  yaml_token_s = record
    token_type : yaml_token_type_t;  { The token type. }
    { The token data. }
    case token : Integer of
      { The stream start (for @c YAML_STREAM_START_TOKEN). }
      1 : (stream_start : record
             { The stream encoding. }
             encoding : yaml_encoding_t;
           end;
          );
      { The alias (for @c YAML_ALIAS_TOKEN). }
      2 : (alias_param : record
             { The alias value. }
             value : pyaml_char_t;
           end;
          );
      { The anchor (for @c YAML_ANCHOR_TOKEN). }
      3 : (anchor : record
             { The anchor value. }
             value : pyaml_char_t;
           end;
          );
      { The tag (for @c YAML_TAG_TOKEN). }
      4 : (tag : record
             { The tag handle. }
             handle : pyaml_char_t;
             { The tag suffix. }
             suffix : pyaml_char_t;
           end;
          );
      { The scalar value (for @c YAML_SCALAR_TOKEN). }
      5 : (scalar : record
             { The scalar value. }
             value : pyaml_char_t;
             { The length of the scalar value. }
             length : QWord;
             { The scalar style. }
             style : yaml_scalar_style_t;
           end;
          );
      { The version directive (for @c YAML_VERSION_DIRECTIVE_TOKEN). }
      6 : (version_directive : record
             { The major version number. }
             major : Integer;
             { The minor version number. }
             minor : Integer;
           end;
          );
      { The tag directive (for @c YAML_TAG_DIRECTIVE_TOKEN). }
      7 : (tag_directive : record
             { The tag handle. }
             handle : pyaml_char_t;
             { The tag prefix. }
             prefix : pyaml_char_t;
           end;
          );
    start_mark : yaml_mark_t;        { The beginning of the token. }
    end_mark : yaml_mark_t;          { The end of the token. }
  end;
  yaml_token_t = yaml_token_s;

  { Event types. }
  yaml_event_type_e = (
    YAML_NO_EVENT,                   { An empty event. }
    YAML_STREAM_START_EVENT,         { A STREAM-START event. }
    YAML_STREAM_END_EVENT,           { A STREAM-END event. }
    YAML_DOCUMENT_START_EVENT,       { A DOCUMENT-START event. }
    YAML_DOCUMENT_END_EVENT,         { A DOCUMENT-END event. }
    YAML_ALIAS_EVENT,                { An ALIAS event. }
    YAML_SCALAR_EVENT,               { A SCALAR event. }
    YAML_SEQUENCE_START_EVENT,       { A SEQUENCE-START event. }
    YAML_SEQUENCE_END_EVENT,         { A SEQUENCE-END event. }
    YAML_MAPPING_START_EVENT,        { A MAPPING-START event. }
    YAML_MAPPING_END_EVENT           { A MAPPING-END event. }
  );
  yaml_event_type_t = yaml_event_type_e;

  { The event structure. }
  yaml_event_s = record
    event_type : yaml_event_type_t;  { The event type. }
    case data : Integer of
    { The stream parameters (for @c YAML_STREAM_START_EVENT). }
    1 : (stream_start : record
           { The document encoding. }
           encoding : yaml_encoding_t;
         end;
        );
    { The document parameters (for @c YAML_DOCUMENT_START_EVENT). }
    2 : (document_start : record
           { The version directive. }
           version_directive : pyaml_version_directive_t;
           { The list of tag directives }
           tag_directives : record
             { The beginning of the tag directives list. }
             start : pyaml_tag_directive_t;
             { The end of the tag directives list. }
             end_tag : pyaml_tag_directive_t;
           end;
           { Is the document indicator implicit? }
           implicit : Integer;
         end;
        );
    { The document end parameters (for @c YAML_DOCUMENT_END_EVENT). }
    3 : (document_end : record
           { Is the document end indicator implicit? }
           implicit : Integer;
         end;
        );
    { The alias parameters (for @c YAML_ALIAS_EVENT). }
    4: (alias_param : record
          { The anchor. }
          anchor : pyaml_char_t;
        end;
       );
    { The scalar parameters (for @c YAML_SCALAR_EVENT). }
    5 : (scalar : record
         { The anchor. }
         anchor : pyaml_char_t;
         { The tag. }
         tag : pyaml_char_t;
         { The scalar value. }
         value : pyaml_char_t;
         { The length of the scalar value. }
         length : QWord;
         { Is the tag optional for the plain style? }
         plain_implicit : Integer;
         { Is the tag optional for any non-plain style? }
         quoted_implicit : Integer;
         { The scalar style. }
         style : yaml_scalar_style_t;
         end;
        );
    { The sequence parameters (for @c YAML_SEQUENCE_START_EVENT). }
    6 : (sequence_start : record
         { The anchor. }
         anchor : pyaml_char_t;
         { The tag. }
         tag : pyaml_char_t;
         { Is the tag optional? }
         implicit : Integer;
         { The sequence style. }
         style : yaml_sequence_style_t;
         end;
        );
    { The mapping parameters (for @c YAML_MAPPING_START_EVENT). }
    7 : (mapping_start : record
         { The anchor. }
         anchor : pyaml_char_t;
         { The tag. }
         tag : pyaml_char_t;
         { Is the tag optional? }
         implicit : Integer;
         { The mapping style. }
         style : yaml_mapping_style_t;
         end;
        );
    start_mark : yaml_mark_t;        { The beginning of the event. }
    end_mark : yaml_mark_t;          { The end of the event. }
  end;
  pyaml_event_t = ^yaml_event_t;
  yaml_event_t = yaml_event_s;

{$IFDEF WINDOWS}
  const libYaml = 'libyaml.dll';
{$ENDIF}
{$IFDEF LINUX}
  const libYaml = 'libyaml.so';
{$ENDIF}

{ Get the library version as a string.

  @returns The function returns the pointer to a static string of the form
  @c "X.Y.Z", where @c X is the major version number, @c Y is a minor version
  number, and @c Z is the patch version number. }
function yaml_get_version_string : PChar; cdecl; external libYaml;

{ Get the library version numbers.

  @param[out]      major   Major version number.
  @param[out]      minor   Minor version number.
  @param[out]      patch   Patch version number. }
procedure yaml_get_version (major : PInteger; minor : PInteger; patch :
  PInteger); cdecl; external libYaml;

{ Free any memory allocated for a token object.

  @param[in,out]   token   A token object. }
procedure yaml_token_delete (token : pyaml_token_t); cdecl; external libYaml;

{ Create the STREAM-START event.

  @param[out]      event       An empty event object.
  @param[in]       encoding    The stream encoding.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_stream_start_event_initialize (event : pyaml_event_t; encoding :
  yaml_encoding_t) : Integer; cdecl; external libYaml;

{ Create the STREAM-END event.

  @param[out]      event       An empty event object.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_stream_end_event_initialize (event : pyaml_event_t) : Integer;
  cdecl; external libYaml;

{ Create the DOCUMENT-START event.

  The @a implicit argument is considered as a stylistic parameter and may be
  ignored by the emitter.

  @param[out]      event                   An empty event object.
  @param[in]       version_directive       The %YAML directive value or
                                           @c NULL.
  @param[in]       tag_directives_start    The beginning of the %TAG
                                           directives list.
  @param[in]       tag_directives_end      The end of the %TAG directives
                                           list.
  @param[in]       implicit                If the document start indicator is
                                           implicit.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_document_start_event_initialize (event : pyaml_event_t;
  version_directive : pyaml_version_directive_t; tag_directives_start :
  pyaml_tag_directive_t; tag_directives_end : pyaml_tag_directive_t;
  implicit : Integer) : Integer; cdecl; external libYaml;

{ Create the DOCUMENT-END event.

  The @a implicit argument is considered as a stylistic parameter and may be
  ignored by the emitter.

  @param[out]      event       An empty event object.
  @param[in]       implicit    If the document end indicator is implicit.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_document_end_event_initialize (event : pyaml_event_t; implicit :
  Integer) : Integer; cdecl; external libYaml;

{ Create an ALIAS event.

  @param[out]      event       An empty event object.
  @param[in]       anchor      The anchor value.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_alias_event_initialize (event : pyaml_event_t; anchor :
  pyaml_char_t) : Integer; cdecl; external libYaml;

{ Create a SCALAR event.

  The @a style argument may be ignored by the emitter.

  Either the @a tag attribute or one of the @a plain_implicit and
  @a quoted_implicit flags must be set.

  @param[out]      event           An empty event object.
  @param[in]       anchor          The scalar anchor or @c NULL.
  @param[in]       tag             The scalar tag or @c NULL.
  @param[in]       value           The scalar value.
  @param[in]       length          The length of the scalar value.
  @param[in]       plain_implicit  If the tag may be omitted for the plain
                                   style.
  @param[in]       quoted_implicit If the tag may be omitted for any
                                   non-plain style.
  @param[in]       style           The scalar style.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_scalar_event_initialize (event : pyaml_event_t; anchor :
  pyaml_char_t; tag : pyaml_char_t; value : pyaml_char_t; length : Integer;
  plain_implicit : Integer; quoted_implicit : Integer; style :
  yaml_scalar_style_t) : Integer; cdecl; external libYaml;

{ Create a SEQUENCE-START event.

  The @a style argument may be ignored by the emitter.

  Either the @a tag attribute or the @a implicit flag must be set.

  @param[out]      event       An empty event object.
  @param[in]       anchor      The sequence anchor or @c NULL.
  @param[in]       tag         The sequence tag or @c NULL.
  @param[in]       implicit    If the tag may be omitted.
  @param[in]       style       The sequence style.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_sequence_start_event_initialize (event : pyaml_event_t;
  anchor : pyaml_char_t; tag : pyaml_char_t; implicit : Integer; style :
  yaml_sequence_style_t) : Integer; cdecl; external libYaml;

{ Create a SEQUENCE-END event.

  @param[out]      event       An empty event object.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_sequence_end_event_initialize (event : pyaml_event_t) : Integer;
  cdecl; external libYaml;

{ Create a MAPPING-START event.

  The @a style argument may be ignored by the emitter.

  Either the @a tag attribute or the @a implicit flag must be set.

  @param[out]      event       An empty event object.
  @param[in]       anchor      The mapping anchor or @c NULL.
  @param[in]       tag         The mapping tag or @c NULL.
  @param[in]       implicit    If the tag may be omitted.
  @param[in]       style       The mapping style.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_mapping_start_event_initialize (event : pyaml_event_t; anchor :
  pyaml_char_t; tag : pyaml_char_t; implicit : Integer; style :
  yaml_mapping_style_t) : Integer; cdecl; external libYaml;

{ Create a MAPPING-END event.

  @param[out]      event       An empty event object.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_mapping_end_event_initialize (event : pyaml_event_t) : Integer;
  cdecl; external libYaml;

{ Free any memory allocated for an event object.

  @param[in,out]   event   An event object. }
procedure yaml_event_delete (event : pyaml_event_t); cdecl; external libYaml;


implementation

end.

