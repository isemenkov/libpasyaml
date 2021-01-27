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

unit yamltypes;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, container.list, container.avltree, utils.variant, utils.functor;

type
  PYamlItem = ^TYamlItem;
  TYamlItemCompareFunctor = class
    ({$IFDEF FPC}specialize{$ENDIF} TBinaryFunctor<PYamlItem, Integer>)
  public
    function Call(AValue1, AValue2 : PYamlItem) : Integer; override;
  end;

  { YAML sequence item type. }
  TYamlSequence = {$IFDEF FPC}type specialize{$ENDIF} TList<PYamlItem>;
  
  { TAML map item type. }
  TYamlMap = {$IFDEF FPC}type specialize{$ENDIF} TAvlTree<String, PYamlItem, 
    YamlItemCompareFunctor>;

  { YAML item type. }
  TYamlItem = class({$IFDEF FPC}type specialize{$ENDIF} TVariant2<TYamlSequence, 
    TYamlMap>);
  TYamlItemSequence = TYamlItem.TVariantValue1;
  TYamlItemMap = TYamlItem.TVariantValue2;

implementation

{ TYamlItemCompareFunctor } 

function TYamlItemCompareFunctor.Call (AValue1, AValue2 : PYamlItem) : Integer;
begin
  if (AValue1 = nil) or (AValue2 = nil) or (AValue1^.GetType < AValue2^.GetType)
    then
  begin
    Result := -1
  end else if AValue2^.GetType < AValue1^.GetType then
  begin
    Result := 1;
  end else
  begin
    Result := 0;
  end;
end;

end.
  