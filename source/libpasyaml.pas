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
  { The tag @c !!null with the only possible value: @c null. }
  YAML_NULL_TAG = 'tag:yaml.org,2002:null';

  { The tag @c !!bool with the values: @c true and @c falce. }
  YAML_BOOL_TAG = 'tag:yaml.org,2002:bool';

  { The tag @c !!str for string values. }
  YAML_STR_TAG = 'tag:yaml.org,2002:str';

  { The tag @c !!int for integer values. }
  YAML_INT_TAG = 'tag:yaml.org,2002:int';

  { The tag @c !!float for float values. }
  YAML_FLOAT_TAG = 'tag:yaml.org,2002:float';

  { The tag @c !!timestamp for date and time values. }
  YAML_TIMESTAMP_TAG = 'tag:yaml.org,2002:timestamp';

  { The tag @c !!seq is used to denote sequences. }
  YAML_SEQ_TAG = 'tag:yaml.org,2002:seq';

  { The tag @c !!map is used to denote mapping. }
  YAML_MAP_TAG = 'tag:yaml.org,2002:map';

  { The default scalar tag is @c !!str. }
  YAML_DEFAULT_SCALAR_TAG = YAML_STR_TAG;

  { The default sequence tag is @c !!seq. }
  YAML_DEFAULT_SEQUENCE_TAG = YAML_SEQ_TAG;

  { The default mapping tag is @c !!map. }
  YAML_DEFAULT_MAPPING_TAG = YAML_MAP_TAG;

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

  { Node types. }
  yaml_node_type_e = (
    YAML_NO_NODE,                    { An empty node. }
    YAML_SCALAR_NODE,                { A scalar node. }
    YAML_SEQUENCE_NODE,              { A sequence node. }
    YAML_MAPPING_NODE                { A mapping node. }
  );
  yaml_node_type_t = yaml_node_type_e;

  { An element of a sequence node. }
  yaml_node_item_t = Integer;

  { An element of a mapping node. }
  yaml_node_pair_s = record
    key : Integer;                   { The key of the element. }
    value : Integer;                 { The value of the element. }
  end;
  yaml_node_pair_t = yaml_node_pair_s;

  { The node structure. }
  pyaml_node_item_t = ^yaml_node_item_t;
  yaml_node_s = record
    node_type : yaml_node_type_t;    { The node type. }
    tag : pyaml_char_t;              { The node tag. }
    { The node data. }
    case data : Integer of
    { The scalar parameters (for @c YAML_SCALAR_NODE). }
    1 : (scalar = record
           { The scalar value. }
           value : pyaml_char_t;
           { The length of the scalar value. }
           length : QWord;
           { The scalar style. }
           style : yaml_scalar_style_t;
         end;
        );
    { The sequence parameters (for @c YAML_SEQUENCE_NODE). }
    2 : (sequence = record
           { The stack of sequence items. }
           items = record
             { The beginning of the stack. }
             start_item : pyaml_node_item_t;
             { The end of the stack. }
             end_item : pyaml_node_item_t;
             { The top of the stack. }
             top_item : pyaml_node_item_t;
           end;
           { The sequence style. }
           style : yaml_sequence_style_t;
         end;
        );
    { The mapping parameters (for @c YAML_MAPPING_NODE). }
    3 : (mapping : record
           { The stack of mapping pairs (key, value). }
           pairs = record
             { The beginning of the stack. }
             start_stack : pyaml_node_pair_t;
             { The end of the stack. }
             end_stack : pyaml_node_pair_t;
             { The top of the stack. }
             top_stack : pyaml_node_pair_t;
           end;
           { The mapping style. }
           style : yaml_mapping_style_t;
         end;
        );
    start_mark : yaml_mark_t;        { The beginning of the node. }
    end_mark : yaml_mark_t;          { The end of the node. }
  end;
  yaml_node_item_t = yaml_node_s;

  { The document structure. }
  yaml_document_s = record
    { The document nodes. }
    nodes = record
      { The beginning of the stack. }
      start_stack : pyaml_node_t;
      { The end of the stack. }
      end_stack : pyaml_node_t;
      { The top of the stack. }
      top_stack : pyaml_node_t;
    end;
    version_directive : pyaml_version_directive_t; { The version directive. }
    { The list of tag directives. }
    tag_directives = record
      { The beginning of the tag directives list. }
      start_list : pyaml_tag_directive_t;
      { The end of the tag directives list. }
      end_list : pyaml_tag_directive_t;
    end;
    start_implicit : Integer;      { Is the document start indicator implicit? }
    end_implicit : Integer;          { Is the document end indicator implicit? }
    start_mark : yaml_mark_t;        { The beginning of the document. }
    end_mark : yaml_mark_t;          { The end of the document. }
  end;
  yaml_document_t = yaml_document_s;

  { The prototype of a read handler.

    The read handler is called when the parser needs to read more bytes from the
    source.  The handler should write not more than @a size bytes to the @a
    buffer.  The number of written bytes should be set to the @a length variable.

    @param[in,out]   data        A pointer to an application data specified by
                                 yaml_parser_set_input().
    @param[out]      buffer      The buffer to write the data from the source.
    @param[in]       size        The size of the buffer.
    @param[out]      size_read   The actual number of bytes read from the source.

    @returns On success, the handler should return 1.  If the handler failed,
    the returned value should be 0. On EOF, the handler should set the
    @a size_read to 0 and return 1. }
  yaml_read_handler_t = function (data : Pointer; buffer : PByte; size : QWord;
    size_read : PQWord) : Integer;

  { This structure holds information about a potential simple key. }
  yaml_simple_key_s = record
    possible : Integer;              { Is a simple key possible? }
    required : Integer;              { Is a simple key required? }
    token_number : QWord;            { The number of the token. }
    mark : yaml_mark_t;              { The position mark. }
  end;
  yaml_simple_key_t = yaml_simple_key_s;

  { The states of the parser. }
  yaml_parser_state_e = (
    { Expect STREAM-START. }
    YAML_PARSE_STREAM_START_STATE.
    { Expect the beginning of an implicit document. }
    YAML_PARSE_IMPLICIT_DOCUMENT_START_STATE,
    { Expect DOCUMENT-START. }
    YAML_PARSE_DOCUMENT_START_STATE,
    { Expect the content of a document. }
    YAML_PARSE_DOCUMENT_CONTENT_STATE,
    { Expect DOCUMENT-END. }
    YAML_PARSE_DOCUMENT_END_STATE,
    { Expect a block node. }
    YAML_PARSE_BLOCK_NODE_STATE,
    { Expect a block node or indentless sequence. }
    YAML_PARSE_BLOCK_NODE_OR_INDENTLESS_SEQUENCE_STATE,
    { Expect a flow node. }
    YAML_PARSE_FLOW_NODE_STATE,
    { Expect the first entry of a block sequence. }
    YAML_PARSE_BLOCK_SEQUENCE_FIRST_ENTRY_STATE,
    { Expect an entry of a block sequence. }
    YAML_PARSE_BLOCK_SEQUENCE_ENTRY_STATE,
    { Expect an entry of an indentless sequence. }
    YAML_PARSE_INDENTLESS_SEQUENCE_ENTRY_STATE,
    { Expect the first key of a block mapping. }
    YAML_PARSE_BLOCK_MAPPING_FIRST_KEY_STATE,
    { Expect a block mapping key. }
    YAML_PARSE_BLOCK_MAPPING_KEY_STATE,
    { Expect a block mapping value. }
    YAML_PARSE_BLOCK_MAPPING_VALUE_STATE,
    { Expect the first entry of a flow sequence. }
    YAML_PARSE_FLOW_SEQUENCE_FIRST_ENTRY_STATE,
    { Expect an entry of a flow sequence. }
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_STATE,
    { Expect a key of an ordered mapping. }
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_KEY_STATE,
    { Expect a value of an ordered mapping. }
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_VALUE_STATE,
    { Expect the and of an ordered mapping entry. }
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_END_STATE,
    { Expect the first key of a flow mapping. }
    YAML_PARSE_FLOW_MAPPING_FIRST_KEY_STATE,
    { Expect a key of a flow mapping. }
    YAML_PARSE_FLOW_MAPPING_KEY_STATE,
    { Expect a value of a flow mapping. }
    YAML_PARSE_FLOW_MAPPING_VALUE_STATE,
    { Expect an empty value of a flow mapping. }
    YAML_PARSE_FLOW_MAPPING_EMPTY_VALUE_STATE,
    { Expect nothing. }
    YAML_PARSE_END_STATE
  );
  yaml_parser_state_t = yaml_parser_state_e;



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

{ Create a YAML document.

  @param[out]      document                An empty document object.
  @param[in]       version_directive       The %YAML directive value or
                                           @c NULL.
  @param[in]       tag_directives_start    The beginning of the %TAG
                                           directives list.
  @param[in]       tag_directives_end      The end of the %TAG directives
                                           list.
  @param[in]       start_implicit          If the document start indicator is
                                           implicit.
  @param[in]       end_implicit            If the document end indicator is
                                           implicit.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_document_initialize (document : pyaml_document_t;
  version_directive : pyaml_version_directive_t; tag_directives_start :
  pyaml_tag_directive_t; tag_directives_end : pyaml_tag_directive_t;
  start_implicit : Integer; end_implicit : Integer) : Integer; cdecl;
  external libYaml;

{ Delete a YAML document and all its nodes.

  @param[in,out]   document        A document object. }
procedure yaml_document_delete (document : pyaml_document_t); cdecl;
  external libYaml;

{ Get a node of a YAML document.

  The pointer returned by this function is valid until any of the functions
  modifying the documents are called.

  @param[in]       document        A document object.
  @param[in]       index           The node id.

  @returns the node objct or @c NULL if @c node_id is out of range. }
function yaml_document_get_node (document : pyaml_document_t; index : Integer) :
  pyaml_node_t; cdecl; external libYaml;

{ Get the root of a YAML document node.

  The root object is the first object added to the document.

  The pointer returned by this function is valid until any of the functions
  modifying the documents are called.

  An empty document produced by the parser signifies the end of a YAML
  stream.

  @param[in]       document        A document object.

  @returns the node object or NULL if the document is empty. }
function yaml_document_get_root_node (document : pyaml_document_t) :
  pyaml_node_t; cdecl; external libYaml;

{ Create a SCALAR node and attach it to the document.

  The @a style argument may be ignored by the emitter.

  @param[in,out]   document        A document object.
  @param[in]       tag             The scalar tag.
  @param[in]       value           The scalar value.
  @param[in]       length          The length of the scalar value.
  @param[in]       style           The scalar style.

  @returns the node id or 0 on error. }
function yaml_document_add_scalar (document : pyaml_document_t; tag :
  pyaml_char_t; value : pyaml_char_t; length : Integer; style :
  yaml_scalar_style_t) : Integer; cdecl; external libYaml;

{ Create a SEQUENCE node and attach it to the document.

  The @a style argument may be ignored by the emitter.

  @param[in,out]   document    A document object.
  @param[in]       tag         The sequence tag.
  @param[in]       style       The sequence style.

  @returns the node id or 0 on error. }
function yaml_document_add_sequence (document : pyaml_document_t; tag :
  pyaml_char_t; style : yaml_sequence_style_t) : Integer; cdecl;
  external libYaml;

{ Create a MAPPING node and attach it to the document.

  The @a style argument may be ignored by the emitter.

  @param[in,out]   document    A document object.
  @param[in]       tag         The sequence tag.
  @param[in]       style       The sequence style.

  @returns the node id or 0 on error. }
function yaml_document_add_mapping (document : pyaml_document_t; tag :
  pyaml_char_t; style : yaml_mapping_style_t) : Integer; cdecl;
  external libYaml;

{ Add an item to a SEQUENCE node.

  @param[in,out]   document    A document object.
  @param[in]       sequence    The sequence node id.
  @param[in]       item        The item node id.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_document_append_sequence_item (document : pyaml_document_t;
  sequence : Integer; item : Integer) : Integer; cdecl; external libYaml;

{ Add a pair of a key and a value to a MAPPING node.

  @param[in,out]   document    A document object.
  @param[in]       mapping     The mapping node id.
  @param[in]       key         The key node id.
  @param[in]       value       The value node id.

  @returns 1 if the function succeeded, 0 on error. }
function yaml_document_append_mapping_pair (document : pyaml_document_t;
  mapping : Integer; key : Integer; value : Integer) : Integer; cdecl;
  external libYaml;






implementation

end.

