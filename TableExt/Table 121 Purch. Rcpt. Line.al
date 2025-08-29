TableExtension 75424 QCPurch_Rcpt_Line_75400 extends "Purch. Rcpt. Line"
{
    fields
    {
        Modify("Accepted Quantity")
        {
            trigger OnAfterValidate()
            begin
                QCPurchase_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-04-N
            end;
        }
        modify("Accepted with Deviation Qty")
        {
            trigger OnAfterValidate()
            begin
                QCPurchase_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-04-N
            end;
        }
        modify("Rejected Quantity")
        {
            trigger OnAfterValidate()
            begin
                QCPurchase_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-04-N
            end;
        }
        modify("Under Inspection Quantity")
        {
            trigger OnAfterValidate()
            begin
                QCPurchase_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-04-N
            end;
        }
        modify("Reworked Quantity")
        {
            trigger OnAfterValidate()
            begin
                QCPurchase_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-04-N
            end;
        }
    }
    var
        QCPurchase_gCdu: Codeunit "Quality Control - Purchase";
        Text60860_gCtx: label 'Sum of "Under Inspection Quantity","Accepted Quantity","Accepted Quantity with Deviation", "Rejected Quantity" and "Reworked Quantity" cannot be greater than "Quantity (Base)".';
}