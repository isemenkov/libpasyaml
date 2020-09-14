# libPasYAML
libPasYAML is object pascal wrapper around [libyaml library](https://yaml.org/). Library for parsing and emitting YAML.



### Table of contents

* [Requierements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Testing](#testing)
* [Bindings](#bindings)
  * [Usage example](#usage-example)
    * [Create and load YAML config](#create-and-load-yaml-config)
    * [Get value data](#get-value-data)
    * [Iterate through sequence value data](#iterate-through-sequence-value-data)



### Requirements

* [Free Pascal Compiler](http://freepascal.org)
* [Lazarus IDE](http://www.lazarus.freepascal.org/) (optional)

Library is tested with latest stable FreePascal Compiler (currently 3.2.0) and Lazarus IDE (currently 2.0.10).



### Installation

Get the sources and add the *source* directory to the *fpc.cfg* file.



### Usage

Clone the repository `git clone https://github.com/isemenkov/libpasyaml`.

Add the unit you want to use to the `uses` clause.



### Testing

A testing framework consists of the following ingredients:
1. Test runner project located in `unit-tests` directory.
2. Test cases (FPCUnit based) for main classes. 



### Bindings

[libpasyaml.pas](https://github.com/isemenkov/libpasyaml/blob/master/source/libpasyaml.pas) file contains the libyaml translated headers to use this library is pascal programs. You can find C API documentation at [yaml.org website](https://yaml.org/).



### Object wrapper

[pasyaml.pas](https://github.com/isemenkov/libpasyaml/blob/master/source/pasyaml.pas) file contains the libyaml object wrapper.

#### Usage example

##### Create and load YAML config

```pascal
uses
  pasyaml;
  
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

begin
  YamlFile := TYamlFile.Create;
  YamlFile.Parse(config);

  FreeAndNil(YamlFile);
```

##### Get value data

```pascal
  { You may use key path }
  Writeln(YamlFile.Value['person.name'].AsString);
  Writeln(YamlFile.Value['person.occupation'].AsString);
  Writeln(YamlFile.Value['person.age'].AsString);

  { Or single key }
  with YamlFile.Value['person'] do
  begin
    Writeln(Value['name'].AsString);
    Writeln(Value['occupation'].AsString);
    Writeln(Value['age'].AsInteger);
    Writeln(Value['gpa'].AsFloat);
    Writeln(Value['birthday'].AsDateTime);
    Writeln(Value['id'].AsString);
  end;
```

##### Iterate through sequence value data

```pascal
var
  Seq : TYamlFile.TOptionReader;

begin
  for Seq in Value['hobbies'].AsSequence do
  begin
    Writeln(Seq.AsString);
  end;
end;
```

