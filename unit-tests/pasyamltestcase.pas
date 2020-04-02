unit pasyamltestcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, libpasyaml, pasyaml, fgl;

type

  TLibYamlTokenBasedInputStringTestCase = class(TTestCase)
  private
    type
      TTokenMap = class;
      TToken    = class;
  public
    type
      TBlockType = (
        TYPE_BLOCK_MAP,
        TYPE_BLOCK_SEQUENCE,
        TYPE_BLOCK_SCALAR
      );
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestParseNodes;
    procedure TestCheckParseNodes;
  private
    FParser : yaml_parser_t;
    FToken : yaml_token_t;
    FTokenMap : TTokenMap;
  private
    type
      TToken = class
      public
        constructor Create (AName : string; ABlockType : TBlockType);
      private
        FName : string;
        FBlockType : TBlockType;
      end;

      TTokenMap = class(specialize TFPGMap<String, TToken>)
      public
        constructor Create;
        procedure Push (AToken : TToken);
        function Pop : TToken;
        function Top : TToken;
      private
        FTop : TToken;

      end;
  end;


  { TLibYamlTestCase }

  TLibYamlTestCase = class(TTestCase)
  published
    procedure TestCreate;
    procedure TestVersion;
    procedure TestParser;
  end;

  { TYamlTestCase }

  TYamlTestCase = class(TTestCase)
  published
    procedure TestCreate;
  end;

implementation

{ TLibYamlTokenBasedInputStringTestCase }

procedure TLibYamlTokenBasedInputStringTestCase.SetUp;
const
  Input = 'title   : Finex 2011'                                  + sLineBreak +
          'img_url : /finex/html/img/'                            + sLineBreak +
          'css_url : /finex/html/style/'                          + sLineBreak +
          'js_url  : /finex/html/js/'                             + sLineBreak +
          ''                                                      + sLineBreak +
          'template_dir: html/templ/'                             + sLineBreak +
          ''                                                      + sLineBreak +
          'default_act : idx    # used for invalid/missing act='  + sLineBreak +
          ''                                                      + sLineBreak +
          'pages:'                                                + sLineBreak +
          '  - act   : idx'                                       + sLineBreak +
          '    title : Welcome'                                   + sLineBreak +
          '    html  : public/welcome.phtml'                      + sLineBreak +
          '  - act   : reg'                                       + sLineBreak +
          '    title : Register'                                  + sLineBreak +
          '    html  : public/register.phtml'                     + sLineBreak +
          '  - act   : log'                                       + sLineBreak +
          '    title : Log in'                                    + sLineBreak +
          '    html  : public/login.phtml'                        + sLineBreak +
          '  - act   : out'                                       + sLineBreak +
          '    title : Log out'                                   + sLineBreak +
          '    html  : public/logout.phtml';
var
  Result : Integer;
begin
  FTokenType := TTokenType.Create;

  Result := yaml_parser_initialize(@FParser);
  if Result = 0 then
    Fail('yaml_parser_initialize: initialize failed!');

  yaml_parser_set_input_string(@FParser, PByte(PChar(Input)), Length(Input));
end;

procedure TLibYamlTokenBasedInputStringTestCase.TearDown;
begin
  yaml_parser_delete(@FParser);
  FreeAndNil(FTokenType);
end;

procedure TLibYamlTokenBasedInputStringTestCase.TestParseNodes;
var
  Result : Integer;
begin
  repeat

    Result := yaml_parser_scan(@FParser, @FToken);
    if Result = 0 then
      Fail('yaml_parser_scan: input string parse fail!');

    if FToken.token_type <> YAML_STREAM_END_TOKEN then
      yaml_token_delete(@FToken);

  until FToken.token_type = YAML_STREAM_END_TOKEN;

  yaml_token_delete(@FToken);
end;

procedure TLibYamlTokenBasedInputStringTestCase.TestCheckParseNodes;
var
  Result : Integer;
begin
  repeat

    yaml_parser_scan(@FParser, @FToken);




    if FToken.token_type <> YAML_STREAM_END_TOKEN then
      yaml_token_delete(@FToken);

  until FToken.token_type = YAML_STREAM_END_TOKEN;

  yaml_token_delete(@FToken);
end;

{ TYamlTestCase }

procedure TYamlTestCase.TestCreate;
var
  Config : TYamlFile;
begin
  Config := TYamlFile.Create(ENCODING_UTF8);

  FreeAndNil(Config);
end;

{ TLibYamlTestCase }

procedure TLibYamlTestCase.TestCreate;
var
  emitter : yaml_emitter_t;
  event : yaml_event_t;
  buffer : string[64];
  Result : Integer;
begin
  yaml_emitter_initialize(@emitter);

  Result := yaml_stream_start_event_initialize(@event, YAML_UTF8_ENCODING);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_document_start_event_initialize(@event, nil, nil, nil, 0);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);
  Result := yaml_mapping_start_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_MAP_TAG)), 1, YAML_ANY_MAPPING_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);
  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('fruit')),
    Length('fruit'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_sequence_start_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_SEQ_TAG)), 1, YAML_ANY_SEQUENCE_STYLE);

  {--- first item ---}
  Result := yaml_mapping_start_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_MAP_TAG)), 1, YAML_ANY_MAPPING_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('name')),
    Length('name'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('apple')),
    Length('apple'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('color')),
    Length('color'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('red')),
    Length('red'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('count')),
    Length('count'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  buffer := Format('%d', [12]);
  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_INT_TAG)), pyaml_char_t(@buffer[0]),
    Length(buffer), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_mapping_end_event_initialize(@event);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);
  {--- end first item ---}

  {--- second item ---}
  Result := yaml_mapping_start_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_MAP_TAG)), 1, YAML_ANY_MAPPING_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('name')),
    Length('name'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('orange')),
    Length('apple'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('color')),
    Length('color'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('orange')),
    Length('red'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_STR_TAG)), pyaml_char_t(PChar('count')),
    Length('count'), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  buffer := Format('%d', [3]);
  Result := yaml_scalar_event_initialize(@event, nil,
    pyaml_char_t(PChar(YAML_INT_TAG)), pyaml_char_t(@buffer[0]),
    Length(buffer), 1, 0, YAML_PLAIN_SCALAR_STYLE);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_mapping_end_event_initialize(@event);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);
  {--- end second item ---}

  Result := yaml_sequence_end_event_initialize(@event);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);
  Result := yaml_mapping_end_event_initialize(@event);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);
  Result := yaml_document_end_event_initialize(@event, 0);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  Result := yaml_stream_end_event_initialize(@event);
  AssertTrue(Format('Failed to emit event %d: %s', [event.event_type,
    emitter.problem]), Result <> 0);

  yaml_emitter_delete(@emitter);
end;

procedure TLibYamlTestCase.TestVersion;
var
  major, minor, patch : Integer;
  Version : String;
begin
  major := -1;
  minor := -1;
  patch := -1;

  yaml_get_version(@major, @minor, @patch);
  Version := Format('%d.%d.%d', [major, minor, patch]);
  AssertTrue('YAML version is not correct', Version = yaml_get_version_string);
end;

procedure TLibYamlTestCase.TestParser;
var
  parser : yaml_parser_t;
  input : string;
  token : yaml_token_t;
begin
  input := 'title   : Finex 2011'                                 + sLineBreak +
           'img_url : /finex/html/img/'                           + sLineBreak +
           'css_url : /finex/html/style/'                         + sLineBreak +
           'js_url  : /finex/html/js/'                            + sLineBreak +
           ''                                                     + sLineBreak +
           'template_dir: html/templ/'                            + sLineBreak +
           ''                                                     + sLineBreak +
           'default_act : idx    # used for invalid/missing act=' + sLineBreak +
           ''                                                     + sLineBreak +
           'pages:'                                               + sLineBreak +
           '  - act   : idx'                                      + sLineBreak +
           '    title : Welcome'                                  + sLineBreak +
           '    html  : public/welcome.phtml'                     + sLineBreak +
           '  - act   : reg'                                      + sLineBreak +
           '    title : Register'                                 + sLineBreak +
           '    html  : public/register.phtml'                    + sLineBreak +
           '  - act   : log'                                      + sLineBreak +
           '    title : Log in'                                   + sLineBreak +
           '    html  : public/login.phtml'                       + sLineBreak +
           '  - act   : out'                                      + sLineBreak +
           '    title : Log out'                                  + sLineBreak +
           '    html  : public/logout.phtml';

  if yaml_parser_initialize(@parser) <> 1 then
    Fail('Failed to initialize parser');
  yaml_parser_set_input_string(@parser, PByte(PChar(input)), Length(input));

  repeat
    if yaml_parser_scan(@parser, @token) <> 1 then
      Fail('Failed to parse token');



    if token.token_type <> YAML_STREAM_END_TOKEN then
      yaml_token_delete(@token);
  until (token.token_type = YAML_STREAM_END_TOKEN);
  yaml_token_delete(@token);

  yaml_parser_delete(@parser);
end;

initialization
  RegisterTest(TLibYamlTokenBasedInputStringTestCase);
  RegisterTest(TLibYamlTestCase);
  RegisterTest(TYamlTestCase);
end.

