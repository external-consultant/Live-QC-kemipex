codeunit 75401 "Error Action Test"
{
    trigger OnRun()
    begin

    end;

    procedure Test01()  //Not Showing button bcoz -not used Error Info object.
    begin
        Message('Test 01');
    end;

    procedure Test01_(ErrorInfo: ErrorInfo)
    begin
        Message('Test 01');
    end;

    procedure Test02(ErrorInfor: ErrorInfo)
    begin
        Message('Test 02');
    end;


    procedure OpenMySettings(PostingDateNofication: Notification);
    begin
        Page.Run(Page::"User Settings");
    end;

    procedure OpenItemTrackingLine(PostingDateNofication: Notification);
    begin
        page.Run(page::"Output Journal");
    end;

    procedure First_gFnc(Var EnterFirst_iDec: Decimal)

    begin

        EnterFirst_iDec := EnterFirst_iDec + 10;
        Message('Var  %1', EnterFirst_iDec);
    end;

    procedure Second_gFnc(EnterFirst_iDec: Decimal)
    begin
        EnterFirst_iDec := EnterFirst_iDec + 10;
        Message(' NotVar %1', EnterFirst_iDec);
    end;


    var
        myInt: Integer;

    var
        Result_gDec: Decimal;
}