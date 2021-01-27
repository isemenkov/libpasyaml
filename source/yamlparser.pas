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
  SysUtils, libpasyaml, yamltypes, container.queue, utils.variant;

type
  TYamlParser = class
  protected
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

      TYamlMapKeyToken = type String;
      TYamlMapValueToken = type String;
      TYamlSequenceEntryToken = type String;
      TYamlAnchorToken = type String;
      TYamlAliasToken = type String;
      TYamlScalarToken = type String;

      TYamlParserToken = class
        ({$IFDEF FPC}specialize{$ENDIF} TVariant8<TYamlMap, TYamlMapKeyToken,
        TYamlMapValueToken, TYamlSequence, TYamlSequenceEntryToken,
        TYamlAnchorToken, TYamlAliasToken, TYamlScalarToken>);
      
      TYamlMapTokenType = TYamlParserToken.TVariantValue1;
      TYamlMapKeyTokenType = TYamlParserToken.TVariantValue2;
      TYamlMapValueTokenType = TYamlParserToken.TVariantValue3;
      TYamlSequenceTokenType = TYamlParserToken.TVariantValue4;
      TYamlSequenceEntryTokenType = TYamlParserToken.TVariantValue5;
      TYamlAnchorTokenType = TYamlParserToken.TVariantValue6;
      TYamlAliasTokenType = TYamlParserToken.TVariantValue7;
      TYamlScalarTokenType = TYamlParserToken.TVariantValue8;

      TYamlTokensStack = class
        ({$IFDEF FPC}specialize{$ENDIF} TQueue<TYamlParserToken>);
  public 
    type
      TParseErrors = (

      );
  public
    constructor Create;
    destructor Destroy; override;
  protected
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

end.