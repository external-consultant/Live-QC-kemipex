TableExtension 75428 Return_Receipt_Line_75428 extends "Return Receipt Line"
{
    fields
    {

        Modify("Accepted Quantity")
        {


            trigger OnBeforeValidate()
            var
                QCSalesReturn_gCdu: Codeunit "Quality Control - Sales Return";
            begin
                QCSalesReturn_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-05-N
            end;
        }
        modify("Accepted with Deviation Qty")
        {

            trigger OnBeforeValidate()
            var
                QCSalesReturn_gCdu: Codeunit "Quality Control - Sales Return";
            begin
                QCSalesReturn_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-05-N
            end;
        }
        Modify("Rejected Quantity")
        {


            trigger OnBeforeValidate()
            var
                QCSalesReturn_gCdu: Codeunit "Quality Control - Sales Return";
            begin
                QCSalesReturn_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-05-N
            end;
        }

        modify("Under Inspection Quantity")
        {


            trigger OnBeforeValidate()
            var
                QCSalesReturn_gCdu: Codeunit "Quality Control - Sales Return";
            begin
                QCSalesReturn_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-05-N
            end;
        }

        modify("Reworked Quantity")
        {


            trigger OnBeforeValidate()
            var
                QCSalesReturn_gCdu: Codeunit "Quality Control - Sales Return";
            begin
                QCSalesReturn_gCdu.CheckQCResultQuantity_lFnc(Rec); //I-C0009-1001310-05-N
            end;
        }
    }

    //Unsupported feature: Property Deletion (AsVar) on "OnBeforeInsertInvLineFromRetRcptLineBeforeInsertTextLine(PROCEDURE 12).SalesLine(Parameter 1001)".

}

