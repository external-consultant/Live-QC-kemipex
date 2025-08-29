pageextension 75384 PostedReturnRcptSubExt extends "Posted Return Receipt Subform"
{
    actions
    {   //T07841 NS
        addafter(ItemTrackingEntries)
        {
            action("&Create QC Receipt")
            {
                ApplicationArea = Basic;
                Image = CalculateLines;

                trigger OnAction()
                var
                    QCSalesReturn_lCdu: Codeunit "Quality Control - Sales Return";
                begin
                    Clear(QCSalesReturn_lCdu);
                    QCSalesReturn_lCdu.CreateQCRcpt_gFnc(Rec, true); //I-C0009-1001310-04-N
                end;
            }
            action("QC &Receipt")
            {
                ApplicationArea = Basic;
                Image = Questionaire;

                trigger OnAction()
                var
                    QCSalesReturn_lCdu: Codeunit "Quality Control - Sales Return";
                begin
                    Clear(QCSalesReturn_lCdu);
                    QCSalesReturn_lCdu.ShowQCRcpt_gFnc(Rec); //I-C0009-1001310-04-N
                end;
            }
            action("&Post QC Receipt")
            {
                ApplicationArea = Basic;
                Caption = 'Posted QC Receipt';
                Image = PersonInCharge;

                trigger OnAction()
                var
                    QCSalesReturn_lCdu: Codeunit "Quality Control - Sales Return";
                begin
                    Clear(QCSalesReturn_lCdu);
                    QCSalesReturn_lCdu.ShowPostedQCRcpt_gFnc(Rec); //I-C0009-1001310-04-N
                end;
            }
        }//T07841 NE
    }
}
