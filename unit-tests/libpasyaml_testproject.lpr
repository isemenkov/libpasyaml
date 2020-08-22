program libpasyaml_testproject;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, pasyamltestcase, pasyaml;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

