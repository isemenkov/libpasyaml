unit pasyamltestcase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, libpasyaml;

type

  TLibYamlTestCase= class(TTestCase)
  published
    procedure TestHookUp;
  end;

implementation

procedure TLibYamlTestCase.TestHookUp;
begin
  Fail('Напишите ваш тест');
end;



initialization

  RegisterTest(TLibYamlTestCase);
end.

