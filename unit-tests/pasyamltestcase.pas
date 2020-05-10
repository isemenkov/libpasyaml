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
    procedure TestMultipleMapParse;
    procedure TestMultipleSequenceParse;
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
  Seq : TYamlFile.TOptionReader;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue(YamlFile.Value['title'].AsString = 'Finex 2011');
  AssertTrue(YamlFile.Value['img_url'].AsString = '/finex/html/img');

  AssertTrue(YamlFile.Value['pages'].IsSequence);
  for Seq in YamlFile.Value['pages'].AsSequence do
  begin
    AssertTrue(Seq.Value['act'].AsString = 'idx');
    AssertTrue(Seq.Value['title'].AsString = 'welcome');
  end;

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
  Seq : TYamlFile.TOptionReader;
  Index : Integer = 0;
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
  for Seq in YamlFile.Value['pages'].AsSequence do
  begin
    case Index of
      0 : begin
        AssertTrue(Seq.Value['act'].AsString = 'idx');
        AssertTrue(Seq.Value['title'].AsString = 'Welcome');
        AssertTrue(Seq.Value['html'].AsString = 'public/welcome.phtml');
      end;
      1 : begin
        AssertTrue(Seq.Value['act'].AsString = 'reg');
        AssertTrue(Seq.Value['title'].AsString = 'Register');
        AssertTrue(Seq.Value['html'].AsString = 'public/register.phtml');
      end;
      2 : begin
        AssertTrue(Seq.Value['act'].AsString = 'log');
        AssertTrue(Seq.Value['title'].AsString = 'Log in');
        AssertTrue(Seq.Value['html'].AsString = 'public/login.phtml');
      end;
      3 : begin
        AssertTrue(Seq.Value['act'].AsString = 'out');
        AssertTrue(Seq.Value['title'].AsString = 'Log out');
        AssertTrue(Seq.Value['html'].AsString = 'public/logout.phtml');
      end;
    end;
    Inc(Index);
  end;
  AssertTrue(Index = 4);

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.TestMultipleMapParse;
const
  config : string = ''                                            + sLineBreak +
    'nodes:'                                                      + sLineBreak +
    '  - name: controller'                                        + sLineBreak +
    '    description: Cloud controller node'                      + sLineBreak +
    '    nics:'                                                   + sLineBreak +
    '      management_network: eth0'                              + sLineBreak +
    '      data_network: eth1'                                    + sLineBreak +
    '  - name: kvm_compute'                                       + sLineBreak +
    '    description: Cloud KVM compute node'                     + sLineBreak +
    '    nics:'                                                   + sLineBreak +
    '      management_network: eth0'                              + sLineBreak +
    '      data_network: eth1'                                    + sLineBreak +
    'environment:'                                                + sLineBreak +
    '  base: example-os'                                          + sLineBreak +
    '  override_attributes:'                                      + sLineBreak +
    '    ntp.servers: 0.pool.ntp.org';
var
  YamlFile : TYamlFile;
  Seq : TYamlFile.TOptionReader;
  Index : Integer = 0;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue(YamlFile.Value['nodes'].IsSequence);
  for Seq in YamlFile.Value['nodes'].AsSequence do
  begin
    case Index of
      0 : begin
        AssertTrue(Seq.Value['name'].AsString = 'controller');
        AssertTrue(Seq.Value['description'].AsString = 'Cloud controller node');
        AssertTrue(Seq.Value['nics'].IsMap);
        AssertTrue(Seq.Value['nics'].Value['management_network'].AsString
          = 'eth0');
        AssertTrue(Seq.Value['nics'].Value['data_network'].AsString = 'eth1');
      end;
      1 : begin
        AssertTrue(Seq.Value['name'].AsString = 'kvm_compute');
        AssertTrue(Seq.Value['description'].AsString =
          'Cloud KVM compute node');
        AssertTrue(Seq.Value['nics'].IsMap);
        AssertTrue(Seq.Value['nics'].Value['management_network'].AsString
          = 'eth0');
        AssertTrue(Seq.Value['nics'].Value['data_network'].AsString = 'eth1');
      end;
    end;
    Inc(Index);
  end;
  AssertTrue(Index = 2);

  AssertTrue(YamlFile.Value['environment'].IsMap);
  AssertTrue(YamlFile.Value['environment'].Value['base'].AsString
    = 'example-os');
  AssertTrue(YamlFile.Value['environment'].Value['override_attributes'].IsMap);
  AssertTrue(YamlFile.Value['environment'].Value['override_attributes']
    .Value['ntp.servers'].AsString = '0.pool.ntp.org');

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.TestMultipleSequenceParse;
const
  config : string = ''                                            + sLineBreak +
    '# =========================================================' + sLineBreak +
    '# Node Information'                                          + sLineBreak +
    '# =========================================================' + sLineBreak +
    'nodes:'                                                      + sLineBreak +
    '  - name: ha_controller'                                     + sLineBreak +
    '    fqdn:'                                                   + sLineBreak +
    '      - YOUR_HA_CONTROLLER_NODE_1_FQDN'                      + sLineBreak +
    '      - YOUR_HA_CONTROLLER_NODE_2_FQDN'                      + sLineBreak +
    '      - YOUR_HA_CONTROLLER_NODE_3_FQDN'                      + sLineBreak +
    '      # Add more HA controller nodes as needed.'             + sLineBreak +
    '  - name: kvm_compute'                                       + sLineBreak +
    '    fqdn:'                                                   + sLineBreak +
    '      - YOUR_KVM_COMPUTE_NODE_1_FQDN'                        + sLineBreak +
    '      # Add more compute nodes as needed.';
var
  YamlFile : TYamlFile;
  Seq : TYamlFile.TOptionReader;
  InnerSeq : TYamlFile.TOptionReader;
  Index : Integer = 0;
  InnerIndex : Integer = 0;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue(YamlFile.Value['nodes'].IsSequence);
  for Seq in YamlFile.Value['nodes'].AsSequence do
  begin
    case Index of
      0 : begin
        AssertTrue(Seq.Value['name'].AsString = 'ha_controller');
        AssertTrue(Seq.Value['fqdn'].IsSequence);

        for InnerSeq in Seq.Value['fqdn'].AsSequence do
        begin
          case InnerIndex of
            0 : begin
              AssertTrue(InnerSeq.IsScalar);
              AssertTrue(InnerSeq.AsString = 'YOUR_HA_CONTROLLER_NODE_1_FQDN');
            end;
            1 : begin
              AssertTrue(InnerSeq.IsScalar);
              AssertTrue(InnerSeq.AsString = 'YOUR_HA_CONTROLLER_NODE_2_FQDN');
            end;
            2 : begin
              AssertTrue(InnerSeq.IsScalar);
              AssertTrue(InnerSeq.AsString = 'YOUR_HA_CONTROLLER_NODE_3_FQDN');
            end;
          end;
          Inc(InnerIndex);
        end;
        AssertTrue(InnerIndex = 3);
      end;
      1 : begin
        AssertTrue(Seq.Value['name'].AsString = 'kvm_compute');
        AssertTrue(Seq.Value['fqdn'].IsSequence);

        for InnerSeq in Seq.Value['fqdn'].AsSequence do
        begin
          case InnerIndex of
            0 : begin
              AssertTrue(InnerSeq.IsScalar);
              AssertTrue(InnerSeq.AsString = 'YOUR_KVM_COMPUTE_NODE_1_FQDN');
            end;
          end;
          Inc(InnerIndex);
        end;
        AssertTrue(InnerIndex = 1);
      end;
    end;
    Inc(Index);
    InnerIndex := 0;
  end;
  AssertTrue(Index = 2);

  FreeAndNil(YamlFile);
end;

initialization
  RegisterTest(TYamlTestCase);
end.

