(******************************************************************************)
(*                                 libPasYAML                                 *)
(*                object pascal wrapper around libyaml library                *)
(*                       https://github.com/yaml/libyaml                      *)
(*                                                                            *)
(* Copyright (c) 2021                                       Ivan Semenkov     *)
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

unit yamlparser;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, libpasyaml, yamltypes, container.queue, utils.variant, 
  utils.api.cstring, utils.result;

type
  TYamlParser = class
  protected
    type
      { Config document elements types }
      TYamlTokenType = (
        TYPE_MAP,
        TYPE_MAP_KEY,
        TYPE_MAP_VALUE,
        TYPE_SEQUENCE,
        TYPE_SEQUENCE_ENTRY,
        TYPE_ANCHOR,
        TYPE_ALIAS,
        TYPE_END_BLOCK,
        TYPE_SCALAR
      );

      TYamlMapToken = type Pointer;
      TYamlMapKeyToken = type String;
      TYamlMapValueToken = type String;
      TYamlSequenceToken = type Pointer;
      TYamlSequenceEntryToken = type String;
      TYamlAnchorToken = type String;
      TYamlAliasToken = type String;
      TYamlEndBlock = type Pointer;

      TYamlParserToken = class
        ({$IFDEF FPC}specialize{$ENDIF} TVariant8<TYamlMapToken, 
        TYamlMapKeyToken, TYamlMapValueToken, TYamlSequenceToken, 
        TYamlSequenceEntryToken, TYamlAnchorToken, TYamlAliasToken,
        TYamlEndBlock>);

      TYamlTokensStack = class
        ({$IFDEF FPC}specialize{$ENDIF} TQueue<TYamlParserToken>);
  public 
    type
      TParseErrors = (
        ERROR_OK                                                         = 1,
        ERROR_STRING_PARSE
      );
      TParseResult = {$IFDEF FPC}specialize{$ENDIF} TVoidResult<TParseErrors>;
  public
    constructor Create;
    destructor Destroy; override;

    { Parse YAML configuration from string }
    function Parse (AConfigString : String) : TParseResult;
  protected
    procedure CreateToken (ATokenType : TYamlTokenType; AValue : String);
      {$IFNDEF DEBUG}inline;{$ENDIF}
  protected
    FParser : yaml_parser_t;
    FTokens : TYamlTokensStack;
    FAliases : TYamlMap;
  end;

implementation

{ TYamlParser }

constructor TYamlParser.Create;
begin
  FTokens := TYamlTokensStack.Create;
  FAliases := TYamlMap.Create;
end;

destructor TYamlParser.Destroy;
begin
  FreeAndNil(FAliases);
  FreeAndNil(FTokens);

  inherited Destroy;
end;

procedure TYamlParser.CreateToken (ATokenType : TYamlTokenType; AValue : 
  String);
var
  Token : TYamlParserToken;
begin
  Token := TYamlParserToken.Create;

  case ATokenType of
    TYPE_MAP : begin
      Token.SetValue(TYamlMapToken(nil));
    end;
    TYPE_MAP_KEY : begin
      Token.SetValue(TYamlMapKeyToken(''));
    end;
    TYPE_MAP_VALUE : begin
      Token.SetValue(TYamlMapValueToken(''));
    end;
    TYPE_SEQUENCE : begin
      Token.SetValue(TYamlSequenceToken(nil));
    end;
    TYPE_SEQUENCE_ENTRY : begin
      Token.SetValue(TYamlSequenceEntryToken(''));
    end;
    TYPE_ANCHOR : begin
      Token.SetValue(TYamlAnchorToken(''));
    end;
    TYPE_ALIAS : begin
      Token.SetValue(TYamlAliasToken(''));
    end;
    TYPE_END_BLOCK : begin
      Token.SetValue(TYamlEndBlock(nil));
    end;
    TYPE_SCALAR : begin
      case FTokens.PeekTail.GetType of
        TYPE_MAP_KEY : begin
          FTokens.PeekTail.SetValue(TYamlMapKeyToken(AValue));
        end;
        TYPE_MAP_VALUE : begin
          FTokens.PeekTail.SetValue(TYamlMapValueToken(AValue));
        end;
        TYPE_SEQUENCE_ENTRY : begin
          FTokens.PeekTail.SetValue(TYamlSequenceEntryToken(AValue));
        end;
        TYPE_ANCHOR : begin
          FTokens.PeekTail.SetValue(TYamlAnchorToken(AValue));
        end;
        TYPE_ALIAS : begin
          FTokens.PeekTail.SetValue(TYamlAliasToken(AValue));
        end;
      end;
    end;
  end;

  if ATokenType <> TYPE_SCALAR then
    FTokens.PushTail(Token);
end;

function TYamlParser.Parse (AConfigString : String) : TParseResult;
var
  Token : yaml_token_t;
begin
  yaml_parser_set_input_string(@FParser, 
    PByte(API.CString.Create(AConfigString).ToPAnsiChar), Length(ConfigString));

  repeat
    if yaml_parser_scan(@FParser, @Token) <> ERROR_OK then
    begin
      Exit(TParseResult.CreateError(ERROR_STRING_PARSE));
    end;

    case Token.token_type of
      YAML_STREAM_START_TOKEN : ;
      YAML_STREAM_END_TOKEN : ;
      YAML_KEY_TOKEN : begin
        CreateToken(TYPE_MAP_KEY, API.CString.Create(PAnsiChar(
          CharToken.token.scalar.value)).ToString);
        end;
      YAML_VALUE_TOKEN : begin
        CreateToken(TYPE_MAP_VALUE, API.CString.Create(PAnsiChar(
          CharToken.token.scalar.value)).ToString);
        end;
      YAML_ANCHOR_TOKEN : begin
        CreateToken(TYPE_ANCHOR, API.CString.Create(
          PAnsiChar(CharToken.token.anchor.value)).ToString);
        end;
      YAML_ALIAS_TOKEN : begin
        CreateToken(TYPE_ALIAS, API.CString.Create(
          PAnsiChar(CharToken.token.alias_param.value)).ToString);
        end;
      YAML_BLOCK_SEQUENCE_START_TOKEN : begin
        CreateToken(TYPE_SEQUENCE, '');
        end;
      YAML_BLOCK_ENTRY_TOKEN : begin
        CreateToken(TYPE_SEQUENCE_ENTRY, '');
        end;
      YAML_BLOCK_MAPPING_START_TOKEN : begin
        CreateToken(TYPE_MAP, '');
        end;
    end;

    if Token.token_type <> YAML_STREAM_END_TOKEN then
    begin
      yaml_token_delete(@Token);
    end;

  until Token.token_type <> YAML_STREAM_END_TOKEN;

  yaml_token_delete(@Token);
end;


end.