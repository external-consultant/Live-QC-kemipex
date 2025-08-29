TableExtension 75426 Reservation_Entry_75426 extends "Tracking Specification"
{
    fields
    {
        modify("Rejection Reason")
        {
            Caption = 'Rejection Reason';
            Description = 'T12113';
            TableRelation = "Reason Code";
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
}