unit pasyamltestcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, pasyaml, dateutils;

type

  { TYamlTestCase }

  TYamlTestCase = class(TTestCase)
  published
    procedure Test_YamlFile_CreateNewEmpty;
    procedure Test_YamlFile_ParseMap;
    procedure Test_YamlFile_ParseMapPath;
    procedure Test_YamlFile_ParseSequence;
    procedure Test_YamlFile_ParseSequenceItemMap;
    procedure Test_YamlFile_ParseSequenceAndMap;
    procedure Test_YamlFile_ParseMultipleMap;
    procedure Test_YamlFile_ParseMultipleSequence;
    procedure Test_YamlFile_ParseTypes;
  end;

implementation

{ TYamlTestCase }

procedure TYamlTestCase.Test_YamlFile_CreateNewEmpty;
var
  YamlFile : TYamlFile;
begin
  YamlFile := TYamlFile.Create;

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.Test_YamlFile_ParseMap;
const
  config : string = ''                                            +
    'title   : Finex 2011'                                        + sLineBreak +
    'img_url : /finex/html/img'                                   + sLineBreak +
    'css_url : /finex/html/style'                                 + sLineBreak +
    'js_url  : /finex/html/js';
var
  YamlFile : TYamlFile;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue('#Test_YamlFile_ParseMap -> ' +
     'title value is not correct',
     YamlFile.Value['title'].AsString = 'Finex 2011');
  AssertTrue('#Test_YamlFile_ParseMap -> ' +
     'img_url value is not correct',
     YamlFile.Value['img_url'].AsString = '/finex/html/img');
  AssertTrue('#Test_YamlFile_ParseMap -> ' +
     'css_url value is not correct',
     YamlFile.Value['css_url'].AsString = '/finex/html/style');
  AssertTrue('#Test_YamlFile_ParseMap -> ' +
     'js_url value is not correct',
     YamlFile.Value['js_url'].AsString = '/finex/html/js');

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.Test_YamlFile_ParseMapPath;
const
  config : string = ''                                            +
    'nodes:'                                                      + sLineBreak +
    '  name: controller'                                          + sLineBreak +
    '  description: Cloud controller node'                        + sLineBreak +
    '  nics:'                                                     + sLineBreak +
    '    management_network: eth0'                                + sLineBreak +
    '    data_network: eth1'                                      + sLineBreak +
    'environment:'                                                + sLineBreak +
    '  base: example-os'                                          + sLineBreak +
    '  override_attributes:'                                      + sLineBreak +
    '    ntp.servers: 0.pool.ntp.org';
var
  YamlFile : TYamlFile;
begin
  YamlFile := TYamlFile.Create('/');
  YamlFile.Parse(config);

  AssertTrue('#Test_YamlFile_ParseMapPath -> ' +
     'nodes.name value is not correct',
     YamlFile.Value['nodes/name'].AsString = 'controller');
  AssertTrue('#Test_YamlFile_ParseMapPath -> ' +
     'nodes.description value is not correct',
     YamlFile.Value['nodes/description'].AsString = 'Cloud controller node');
  AssertTrue('#Test_YamlFile_ParseMapPath -> ' +
     'nodes.nics.management_network value is not correct',
     YamlFile.Value['nodes/nics/management_network'].AsString = 'eth0');
  AssertTrue('#Test_YamlFile_ParseMapPath -> ' +
     'nodes.nics.data_network value is not correct',
     YamlFile.Value['nodes/nics/data_network'].AsString = 'eth1');
  AssertTrue('#Test_YamlFile_ParseMapPath -> ' +
     'environment.base value is not correct',
     YamlFile.Value['environment/base'].AsString = 'example-os');
  AssertTrue('#Test_YamlFile_ParseMapPath -> ' +
     'environment.override_attributes.ntp.servers value is not correct',
     YamlFile.Value['environment/override_attributes/ntp.servers'].AsString =
     '0.pool.ntp.org');

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.Test_YamlFile_ParseSequence;
const
  config : string = ''                                            +
    '- value1'                                                    + sLineBreak +
    '- value2'                                                    + sLineBreak +
    '- value3';
var
  YamlFile : TYamlFile;
  Seq : TYamlFile.TOptionReader;
  Index : Integer;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue('#Test_YamlFile_ParseSequence -> ' +
     'root element is not correct type', not YamlFile.IsMap);
  AssertTrue('#Test_YamlFile_ParseSequence -> ' +
     'root element is not correct type', YamlFile.IsSequence);

  Index := 0;
  for Seq in YamlFile.AsSequence do
  begin
    case Index of
      0 : begin
        AssertTrue('#Test_YamlFile_ParseSequence -> ' +
          'sequence value index 0 is not correct', Seq.AsString = 'value1');
      end;
      1 : begin
        AssertTrue('#Test_YamlFile_ParseSequence -> ' +
          'sequence value index 1 is not correct', Seq.AsString = 'value2');
      end;
      2 : begin
        AssertTrue('#Test_YamlFile_ParseSequence -> ' +
          'sequence value index 2 is not correct', Seq.AsString = 'value3');
      end;
      3 : begin
        AssertTrue('#Test_YamlFile_ParseSequence -> ' +
          'incorrect sequence value index', False);
      end;
    end;
    Inc(Index);
  end;
  AssertTrue('#Test_YamlFile_ParseSequence -> ' +
    'sequence counter is not correct', Index = 3);

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.Test_YamlFile_ParseSequenceItemMap;
const
  config : string = ''                                            +
    'title     : Finex 2011'                                      + sLineBreak +
    'pages:'                                                      + sLineBreak +
    '  - act   : idx'                                             + sLineBreak +
    '    title : welcome'                                         + sLineBreak +
    'img_url   : /finex/html/img';
var
  YamlFile : TYamlFile;
  Seq : TYamlFile.TOptionReader;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue('#Test_YamlFile_ParseSequenceItemMap -> ' +
     'title value is not correct',
     YamlFile.Value['title'].AsString = 'Finex 2011');
  AssertTrue('#Test_YamlFile_ParseSequenceItemMap -> ' +
     'img_url value is not correct',
     YamlFile.Value['img_url'].AsString = '/finex/html/img');

  AssertTrue('#Test_YamlFile_ParseSequenceItemMap -> ' +
     'pages value is not sequence',
     YamlFile.Value['pages'].IsSequence);
  for Seq in YamlFile.Value['pages'].AsSequence do
  begin
    AssertTrue('#Test_YamlFile_ParseSequenceItemMap -> ' +
     'pages.act value is not correct',
     Seq.Value['act'].AsString = 'idx');
    AssertTrue('#Test_YamlFile_ParseSequenceItemMap -> ' +
     'pages.title value is not correct',
     Seq.Value['title'].AsString = 'welcome');
  end;

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.Test_YamlFile_ParseSequenceAndMap;
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

  AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
     'title value is not correct',
     YamlFile.Value['title'].AsString = 'Finex 2011');
  AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
     'img_url value is not correct',
     YamlFile.Value['img_url'].AsString = '/finex/html/img/');
  AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
     'css_url value is not correct',
     YamlFile.Value['css_url'].AsString = '/finex/html/style/');
  AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
     'js_url value is not correct',
     YamlFile.Value['js_url'].AsString = '/finex/html/js/');
  AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
     'template_dir value is not correct',
     YamlFile.Value['template_dir'].AsString = 'html/templ/');
  AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
     'default_act value is not correct',
     YamlFile.Value['default_act'].AsString = 'idx');

  AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
     'pages value is not sequence',
     YamlFile.Value['pages'].IsSequence);
  for Seq in YamlFile.Value['pages'].AsSequence do
  begin
    case Index of
      0 : begin
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.act value is not correct',
          Seq.Value['act'].AsString = 'idx');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.title value is not correct',
          Seq.Value['title'].AsString = 'Welcome');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.html value is not correct',
          Seq.Value['html'].AsString = 'public/welcome.phtml');
      end;
      1 : begin
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.act value is not correct',
          Seq.Value['act'].AsString = 'reg');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.title value is not correct',
          Seq.Value['title'].AsString = 'Register');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.html value is not correct',
          Seq.Value['html'].AsString = 'public/register.phtml');
      end;
      2 : begin
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.act value is not correct',
          Seq.Value['act'].AsString = 'log');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.title value is not correct',
          Seq.Value['title'].AsString = 'Log in');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.html value is not correct',
          Seq.Value['html'].AsString = 'public/login.phtml');
      end;
      3 : begin
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.act value is not correct',
          Seq.Value['act'].AsString = 'out');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.title value is not correct',
          Seq.Value['title'].AsString = 'Log out');
        AssertTrue('#Test_YamlFile_ParseSequenceAndMap -> ' +
          'pages.html value is not correct',
          Seq.Value['html'].AsString = 'public/logout.phtml');
      end;
    end;
    Inc(Index);
  end;
  AssertTrue(Index = 4);

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.Test_YamlFile_ParseMultipleMap;
const
  config : string = ''                                            +
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
  YamlFile := TYamlFile.Create('/');
  YamlFile.Parse(config);

  AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
     'nodes value is not sequence',
     YamlFile.Value['nodes'].IsSequence);
  for Seq in YamlFile.Value['nodes'].AsSequence do
  begin
    case Index of
      0 : begin
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.name value is not correct',
          Seq.Value['name'].AsString = 'controller');
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.description value is not correct',
          Seq.Value['description'].AsString = 'Cloud controller node');
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.nics value is not map',
          Seq.Value['nics'].IsMap);
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.nics.management_network value is not correct',
          Seq.Value['nics'].Value['management_network'].AsString = 'eth0');
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.nics.data_network value is not correct',
          Seq.Value['nics'].Value['data_network'].AsString = 'eth1');
      end;
      1 : begin
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.name value is not correct',
          Seq.Value['name'].AsString = 'kvm_compute');
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.description value is not correct',
          Seq.Value['description'].AsString = 'Cloud KVM compute node');
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.nics value is not map',
          Seq.Value['nics'].IsMap);
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.nics.management_network value is not correct',
          Seq.Value['nics'].Value['management_network'].AsString = 'eth0');
        AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
          'nodes.nics.data_network value is not correct',
          Seq.Value['nics'].Value['data_network'].AsString = 'eth1');
      end;
    end;
    Inc(Index);
  end;
  AssertTrue(Index = 2);

  AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
    'enviroment value is not map',
    YamlFile.Value['environment'].IsMap);
  AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
    'enviroment.base value is not correct',
    YamlFile.Value['environment'].Value['base'].AsString = 'example-os');
  AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
    'enviroment.override_attributes value is not map',
    YamlFile.Value['environment'].Value['override_attributes'].IsMap);
  AssertTrue('#Test_YamlFile_ParseMultipleMap -> ' +
    'enviroment.override_attributes value is not correct',
    YamlFile.Value['environment'].Value['override_attributes']
    .Value['ntp.servers'].AsString = '0.pool.ntp.org');

  FreeAndNil(YamlFile);
end;

procedure TYamlTestCase.Test_YamlFile_ParseMultipleSequence;
const
  config : string = ''                                            +
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

  AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
    'nodes value is not sequence',
    YamlFile.Value['nodes'].IsSequence);
  for Seq in YamlFile.Value['nodes'].AsSequence do
  begin
    case Index of
      0 : begin
        AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
          'nodes.name value is not correct',
          Seq.Value['name'].AsString = 'ha_controller');
        AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
          'nodes.fqdn value is not sequence',
          Seq.Value['fqdn'].IsSequence);

        for InnerSeq in Seq.Value['fqdn'].AsSequence do
        begin
          case InnerIndex of
            0 : begin
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not scalar',
                InnerSeq.IsScalar);
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not correct',
                InnerSeq.AsString = 'YOUR_HA_CONTROLLER_NODE_1_FQDN');
            end;
            1 : begin
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not scalar',
                InnerSeq.IsScalar);
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not correct',
                InnerSeq.AsString = 'YOUR_HA_CONTROLLER_NODE_2_FQDN');
            end;
            2 : begin
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not scalar',
                InnerSeq.IsScalar);
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not correct',
                InnerSeq.AsString = 'YOUR_HA_CONTROLLER_NODE_3_FQDN');
            end;
          end;
          Inc(InnerIndex);
        end;
        AssertTrue(InnerIndex = 3);
      end;
      1 : begin
        AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
          'nodes.name value is not correct',
          Seq.Value['name'].AsString = 'kvm_compute');
        AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
          'nodes.fqdn value is not sequence',
          Seq.Value['fqdn'].IsSequence);

        for InnerSeq in Seq.Value['fqdn'].AsSequence do
        begin
          case InnerIndex of
            0 : begin
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not scalar',
                InnerSeq.IsScalar);
              AssertTrue('#Test_YamlFile_ParseMultipleSequence -> ' +
                'nodes.fqdn value is not correct',
                InnerSeq.AsString = 'YOUR_KVM_COMPUTE_NODE_1_FQDN');
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

procedure TYamlTestCase.Test_YamlFile_ParseTypes;
const
  config : string = ''                                            +
    'person:'                                                     + sLineBreak +
    '  name: &val "mike"'                                         + sLineBreak +
    '  occupation: ''programmer'' '                               + sLineBreak +
    '  age: 23'                                                   + sLineBreak +
    '  gpa: 3.5'                                                  + sLineBreak +
    '  fav_num: 1e+10'                                            + sLineBreak +
    '  male: true'                                                + sLineBreak +
    '  birthday: 1994-02-06 14:33:22'                             + sLineBreak +
    '  flaws: null'                                               + sLineBreak +
    '  hobbies:'                                                  + sLineBreak +
    '    - hiking'                                                + sLineBreak +
    '    - movies'                                                + sLineBreak +
    '    - riding bike'                                           + sLineBreak +
    '  movies: ["Dark Knight", "Good Will Hunting"]'              + sLineBreak +
    '  friends:'                                                  + sLineBreak +
    '    - name: "Steph"'                                         + sLineBreak +
    '      age: 22'                                               + sLineBreak +
    '    - {name: "Adam", age: 22}'                               + sLineBreak +
    '    - '                                                      + sLineBreak +
    '      name: "Joe"'                                           + sLineBreak +
    '      age: 23'                                               + sLineBreak +
    '  description: >'                                            + sLineBreak +
    '    Nulla consequat massa quis enim.'                        + sLineBreak +
    '    Donec pede justo, fringilla vel,'                        + sLineBreak +
    '    aliquet nec, vulputate eget, arcu.'                      + sLineBreak +
    '    In enim justo, rhoncus ut, imperdiet'                    + sLineBreak +
    '    a, venenatis vitae, justo'                               + sLineBreak +
    '  signature: |'                                              + sLineBreak +
    '    Mike'                                                    + sLineBreak +
    '    Girafee Academy'                                         + sLineBreak +
    '    email - mike@gmail.com'                                  + sLineBreak +
    '  id: *val';

var
  YamlFile : TYamlFile;
  Seq : TYamlFile.TOptionReader;
  Index : Integer = 0;
begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  AssertTrue('#Test_YamlFile_ParseTypes -> ' +
    'person value is not map',
    YamlFile.Value['person'].IsMap);
  with YamlFile.Value['person'] do
  begin
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.name value is not correct',
      Value['name'].AsString = 'mike');
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.occupation value is not correct',
      Value['occupation'].AsString = 'programmer');
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.age value is not correct',
      Value['age'].AsInteger = 23);
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.gpa value is not correct',
      Value['gpa'].AsFloat = 3.5);
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.fav_num value is not correct',
      Value['fav_num'].AsFloat = 1e+10);
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.birthday value is not correct',
      CompareDateTime(Value['birthday'].AsDateTime,
      EncodeDateTime(1994, 2, 6, 14, 33, 22, 0)) = 0);
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.birthday value is not correct',
      CompareTime(Value['birthday'].AsTime, EncodeTime(14, 33, 22, 0)) = 0);
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.birthday value is not correct',
      CompareDate(Value['birthday'].AsDate, EncodeDate(1994, 2, 6)) = 0);

    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'person.hobbies value is not sequence',
      Value['hobbies'].IsSequence);
    for Seq in Value['hobbies'].AsSequence do
    begin
      case Index of
        0 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'person.hobbies value is not correct',
            Seq.AsString = 'hiking');
        end;
        1 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'person.hobbies value is not correct',
            Seq.AsString = 'movies');
        end;
        2 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'person.hobbies value is not correct',
            Seq.AsString = 'riding bike');
        end;
      end;
      Inc(Index);
    end;
    AssertTrue(Index = 3);

    Index := 0;
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'movies value is not sequence', Value['movies'].IsSequence);
    for Seq in Value['movies'].AsSequence do
    begin
      case Index of
        0 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'movies value is not correct',
            Seq.AsString = 'Dark Knight');
        end;
        1 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'movies value is not correct',
            Seq.AsString = 'Good Will Hunting');
        end;
      end;
      Inc(Index);
    end;
    AssertTrue(Index = 2);

    Index := 0;
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'friends value is not sequence', Value['friends'].IsSequence);
    for Seq in Value['friends'].AsSequence do
    begin
      case Index of
        0 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'friends.name value is not correct',
            Seq.Value['name'].AsString = 'Steph');
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'friends.age value is not correct',
            Seq.Value['age'].AsInteger = 22);
        end;
        1 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'friends.name value is not correct',
            Seq.Value['name'].AsString = 'Adam');
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'friends.age value is not correct',
            Seq.Value['age'].AsInteger = 22);
        end;
        2 : begin
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'friends.name value is not correct',
            Seq.Value['name'].AsString = 'Joe');
          AssertTrue('#Test_YamlFile_ParseTypes -> ' +
            'friends.age value is not correct',
            Seq.Value['age'].AsInteger = 23);
        end;
      end;
      Inc(Index);
    end;
    AssertTrue(Index = 3);

    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'description value is not correct',
      Value['description'].AsString = 'Nulla consequat massa quis ' +
      'enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, ' +
      'arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo' +
      sLineBreak);
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'signature value is not correct',
      Value['signature'].AsString = 'Mike' + sLineBreak +
      'Girafee Academy' + sLineBreak + 'email - mike@gmail.com' + sLineBreak);
    AssertTrue('#Test_YamlFile_ParseTypes -> ' +
      'id value is not correct',
      Value['id'].AsString = 'mike');
  end;

  FreeAndNil(YamlFile);
end;

initialization
  RegisterTest(TYamlTestCase);
end.

