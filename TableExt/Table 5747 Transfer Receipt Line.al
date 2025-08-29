TableExtension 75427 Transfer_Receipt_Line_75427 extends "Transfer Receipt Line"
{
    fields
    {

        modify("Accepted Quantity")
        {
            trigger OnAfterValidate()
            var
                QCTransferRcpt_lCdu: Codeunit "Quality Control -Transfer Rcpt";
            begin
                QCTransferRcpt_lCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-06-N
            end;
        }
        modify("Accepted with Deviation Qty")
        {

            trigger OnAfterValidate()
            var
                QCTransferRcpt_lCdu: Codeunit "Quality Control -Transfer Rcpt";
            begin
                QCTransferRcpt_lCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-06-N
            end;
        }
        modify("Rejected Quantity")
        {


            trigger OnAfterValidate()
            var
                QCTransferRcpt_lCdu: Codeunit "Quality Control -Transfer Rcpt";
            begin
                QCTransferRcpt_lCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-06-N
            end;
        }

        modify("Under Inspection Quantity")
        {


            trigger OnBeforeValidate()
            var
                QCTransferRcpt_lCdu: Codeunit "Quality Control -Transfer Rcpt";
            begin
                QCTransferRcpt_lCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-06-N
            end;
        }


    }
}

