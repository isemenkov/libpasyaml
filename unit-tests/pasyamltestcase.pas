unit pasyamltestcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, pasyaml;

type

  { TYamlTestCase }

  TYamlTestCase = class(TTestCase)
  published
    procedure TestMapParse;
    procedure TestSequenceItemMapParse;
    procedure TestSequenceAndMapParse;
  end;

implementation

{ TYamlTestCase }

procedure TYamlTestCase.TestMapParse;
const
  config : string = 'title   : Finex 2011'                        + sLineBreak +
                    'img_url : /finex/html/img'                   + sLineBreak +
                    'css_url : /finex/html/style'                 + sLineBreak +
                    'js_url  : /finex/html/js';
var
  YamlFile : TYamlFile;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue(YamlFile.Value['title'].AsString = 'Finex 2011');
  AssertTrue(YamlFile.Value['img_url'].AsString = '/finex/html/img');
  AssertTrue(YamlFile.Value['css_url'].AsString = '/finex/html/style');
  AssertTrue(YamlFile.Value['js_url'].AsString = '/finex/html/js');

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.TestSequenceItemMapParse;
const
  config : string = 'title     : Finex 2011'                      + sLineBreak +
                    'pages:'                                      + sLineBreak +
                    '  - act   : idx'                             + sLineBreak +
                    '    title : welcome'                         + sLineBreak +
                    'img_url   : /finex/html/img';
var
  YamlFile : TYamlFile;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);
  AssertTrue(YamlFile.Value['title'].AsString = 'Finex 2011');
  AssertTrue(YamlFile.Value['img_url'].AsString = '/finex/html/img');
  AssertTrue(YamlFile.Value['pages'].IsSequence);

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.TestSequenceAndMapParse;
const
  config : string = ''                                            +
    '# config/public.yaml'                                        + sLineBreak +
    ''                                                            + sLineBreak +
    'title   : Finex 2011'                                        + sLineBreak +
    'img_url : /finex/html/img/'                                  + sLineBreak +
    'css_url : /finex/html/style/'                                + sLineBreak +
    'js_url  : /finex/html/js/'                                   + sLineBreak +
    ''                                                            + sLineBreak +
    'template_dir: html/templ/'                                   + sLineBreak +
    ''                                                            + sLineBreak +
    'default_act : idx # used for invalid/missing act='           + sLineBreak +
    ''                                                            + sLineBreak +
    'pages:'                                                      + sLineBreak +
    '  - act   : idx'                                             + sLineBreak +
    '    title : Welcome'                                         + sLineBreak +
    '    html  : public/welcome.phtml'                            + sLineBreak +
    '  - act   : reg'                                             + sLineBreak +
    '    title : Register'                                        + sLineBreak +
    '    html  : public/register.phtml'                           + sLineBreak +
    '  - act   : log'                                             + sLineBreak +
    '    title : Log in'                                          + sLineBreak +
    '    html  : public/login.phtml'                              + sLineBreak +
    '  - act   : out'                                             + sLineBreak +
    '    title : Log out'                                         + sLineBreak +
    '    html  : public/logout.phtml';

var
  YamlFile : TYamlFile;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);
  AssertTrue(YamlFile.Value['title'].AsString = 'Finex 2011');
  AssertTrue(YamlFile.Value['img_url'].AsString = '/finex/html/img/');
  AssertTrue(YamlFile.Value['css_url'].AsString = '/finex/html/style/');
  AssertTrue(YamlFile.Value['js_url'].AsString = '/finex/html/js/');
  AssertTrue(YamlFile.Value['template_dir'].AsString = 'html/templ/');
  AssertTrue(YamlFile.Value['default_act'].AsString = 'idx');
  AssertTrue(YamlFile.Value['pages'].IsSequence);

  FreeAndNil(YamlFile);
end;

initialization
  RegisterTest(TYamlTestCase);
end.

