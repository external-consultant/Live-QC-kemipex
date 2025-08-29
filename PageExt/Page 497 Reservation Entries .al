pageextension 75399 ReservationEntries extends "Reservation Entries"
{
    layout
    {
        //T49238
        addafter("Creation Date")
        {
            field("Material at QC"; Rec."Material at QC")
            {
                ApplicationArea = All;
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