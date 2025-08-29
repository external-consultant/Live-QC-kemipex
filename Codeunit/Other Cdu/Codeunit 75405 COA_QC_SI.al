codeunit 75405 "COA_QC_SI" //T51170
{
    SingleInstance = true;

    procedure SetProcess_gFnc(View_iBln: Boolean)
    begin
        View_gBln := View_iBln;

    end;


    procedure getProcess_gFnc(): Boolean
    begin
        exit(View_gBln);
    end;

    procedure ClearProcess_gFnc()
    begin
        Clear(View_gBln);
    end;










    var


        View_gBln: Boolean;


}
