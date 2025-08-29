pageextension 75392 "Posted Return Receipt Card ext" extends "Posted Return Receipt"
{
    actions
    {
        addfirst(processing)
        {
            action(CreateReclassJnl)
            {
                ApplicationArea = All;
                Caption = 'Create Item Reclass Jnl';
                Image = CreateCreditMemo;

                trigger OnAction()
                var
                    QCMgmt: Codeunit "Quality Control - Sales Return";
                begin
                    if Confirm('Do you want to create the Item Reclass Jnl?', true) then begin
                        QCMgmt.CreateandPostItemReclas(Rec."No.");
                    end;
                end;
            }
        }
    }
}
