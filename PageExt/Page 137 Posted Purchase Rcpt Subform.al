/* PageExtension 75408 Posted_Purch_Rcpt_Subfrm_75408 extends "Posted Purchase Rcpt. Subform" //T51170-O Moved in to COA Extension.
{
    layout
    {
        addafter(Quantity)
        {
            field("Under Inspection Quantity"; Rec."Under Inspection Quantity")
            {
                ApplicationArea = Basic;
                Editable = false;
            }
            field("Accepted Quantity"; Rec."Accepted Quantity")
            {
                ApplicationArea = Basic;
                Editable = false;
            }
            field("Accepted with Deviation Qty"; Rec."Accepted with Deviation Qty")
            {
                ApplicationArea = Basic;
                Editable = false;
            }
            field("Rejected Quantity"; Rec."Rejected Quantity")
            {
                ApplicationArea = Basic;
                Editable = false;
            }
            field("QC Required"; Rec."QC Required")
            {
                ApplicationArea = Basic;
            }
            field("QC Pending"; Rec."QC Pending")
            {
                ApplicationArea = Basic;
            }
            field("TC Received"; Rec."TC Received")
            {
                ApplicationArea = Basic;
            }
            field("TC Remarks"; Rec."TC Remarks")
            {
                ApplicationArea = Basic;
            }
        }
    }
    actions
    {
        addafter(ItemInvoiceLines)
        {
            action("&Create QC Receipt")
            {
                ApplicationArea = Basic;
                Image = CalculateLines;

                trigger OnAction()
                var
                    QCPurchase_lCdu: Codeunit "Quality Control - Purchase";
                begin
                    Clear(QCPurchase_lCdu);
                    QCPurchase_lCdu.CreateQCRcpt_gFnc(Rec, true); //I-C0009-1001310-04-N
                end;
            }
            action("QC &Receipt")
            {
                ApplicationArea = Basic;
                Image = Questionaire;

                trigger OnAction()
                var
                    QCPurchase_lCdu: Codeunit "Quality Control - Purchase";
                begin
                    Clear(QCPurchase_lCdu);
                    QCPurchase_lCdu.ShowQCRcpt_gFnc(Rec); //I-C0009-1001310-04-N
                end;
            }
            action("&Post QC Receipt")
            {
                ApplicationArea = Basic;
                Caption = 'Posted QC Receipt';
                Image = PersonInCharge;

                trigger OnAction()
                var
                    QCPurchase_lCdu: Codeunit "Quality Control - Purchase";
                begin
                    Clear(QCPurchase_lCdu);
                    QCPurchase_lCdu.ShowPostedQCRcpt_gFnc(Rec); //I-C0009-1001310-04-N
                end;
            }
        }
    }
}

 */