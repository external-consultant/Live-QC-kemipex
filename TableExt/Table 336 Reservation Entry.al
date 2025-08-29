TableExtension 75425 Reservation_Entry_75425 extends "Reservation Entry"
{
    fields
    {

        //Unsupported feature: Property Modification (CalcFormula) on ""Action Message Adjustment"(Field 31)".

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

        modify("Rework Reason")
        {

            trigger OnBeforeValidate()
            var
                Rework_lRec: Record "Rework Code";
            begin
                if Rework_lRec.Get(Rec."Rework Reason") then
                    Rec."Rework Reason Description" := Rework_lRec.Description
                else
                    Rec."Rework Reason Description" := '';
            end;
        }


    }



    local procedure CheckSum_lFnc()
    begin
        //C0009-NS 241018
        if "Accepted Quantity" + "Accepted with Deviation Qty" + "Rejected Quantity" + "Rework Quantity" > Abs(Quantity) then
            Error('Total result quanity (%1) cannot be morethan available quantity %2',
                  "Accepted Quantity" + "Accepted with Deviation Qty" + "Rejected Quantity" + "Rework Quantity", Abs(Quantity));
        //C0009-NE 241018
    end;

    procedure GetNextEntryNo_gFnc(): Integer
    var
        ReservationEntry_lRec: Record "Reservation Entry";
    begin
        //C0009-NS 241018
        ReservationEntry_lRec.Reset;
        if ReservationEntry_lRec.FindLast then
            exit(ReservationEntry_lRec."Entry No." + 1)
        else
            exit(1);
        //C0009-NE 241018
    end;
}

