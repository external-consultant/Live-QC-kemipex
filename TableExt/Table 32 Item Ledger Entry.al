TableExtension 75422 Item_Ledger_Entry_75422 extends "Item Ledger Entry"
{
    fields
    {


        modify("Accepted Quantity")
        {


            trigger OnBeforeValidate()
            begin
                CheckSum_lFnc;  //C0009-N 241018
            end;
        }
        modify("Accepted with Deviation Qty")
        {
            trigger OnBeforeValidate()
            begin
                CheckSum_lFnc;  //C0009-N 241018
            end;
        }
        modify("Rejected Quantity")
        {
            trigger OnBeforeValidate()
            begin
                CheckSum_lFnc;  //C0009-N 241018
            end;
        }
        modify("Rework Quantity")
        {


            trigger OnBeforeValidate()
            begin
                CheckSum_lFnc;  //C0009-N 241018
            end;
        }
        modify("Rejection Reason")
        {

            trigger OnBeforeValidate()
            var
                Reason_lRec: Record "Reason Code";
            begin
                if Reason_lRec.Get(Rec."Rejection Reason") then
                    Rec."Rejection Reason Description" := Reason_lRec.Description
                else
                    Rec."Rejection Reason Description" := '';
            end;
        }


    }

    local procedure CheckSum_lFnc()
    begin
        //C0009-NS 241018
        if "Accepted Quantity" + "Accepted with Deviation Qty" + "Rejected Quantity" + "Rework Quantity" > Abs("Remaining Quantity") then
            Error('Total result quanity (%1) cannot be morethan available quantity %2',
                  "Accepted Quantity" + "Accepted with Deviation Qty" + "Rejected Quantity" + "Rework Quantity", Abs("Remaining Quantity"));
        //C0009-NE 241018
    end;
}

