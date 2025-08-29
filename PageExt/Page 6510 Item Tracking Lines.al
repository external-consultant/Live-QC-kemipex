pageextension 75395 ItemTracking extends "Item Tracking Lines"
{
    layout
    {
        modify("Warranty Date")
        {
            Editable = true;
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin

            end;
        }
        modify("Lot No.")
        {
            //T49238-NS
            trigger OnAfterValidate()
            var
                ILE_l: Record "Item Ledger Entry";
            begin
                ILE_l.Reset();
                ILE_l.SetRange("Lot No.", Rec."Lot No.");
                IF ILE_l.FindFirst() then begin
                    rec."Material at QC" := ILE_l."Material at QC";
                    rec.Modify();
                end;
            end;

            //T49238-NE
        }

        //T49238
        addafter("Lot No.")
        {
            field("Material at QC"; Rec."Material at QC")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        //T49238
    }

    actions
    {
        // Add changes to page actions here
    }


    var
        myInt: Integer;
}