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

type

  { TYamlConfig }

  TYamlConfig = class
  private
    FEmitter : yaml_emitter_t;
    FEvent : yaml_event_t;
  public
    constructor Create;
    destructor Destroy; override;
  end;


implementation

{ TYamlConfig }

constructor TYamlConfig.Create;
begin
  yaml_emitter_initialize(@FEmitter);
  FEmitter := yaml_stream_start_event_initialize(@FEvent, YAML_UTF8_ENCODING);
  yaml_document_start_event_initialize(@FEvent, nil, nil, nil, 0);
end;

destructor TYamlConfig.Destroy;
begin
  yaml_stream_end_event_initialize(@FEvent);
  yaml_emitter_delete(@FEmitter);
  inherited Destroy;
end;

end.

