pageextension 75382 PgeExtManufactSetup extends "Manufacturing Setup"
{
    layout
    {
        addlast(General)
        {
            field("Quality Production Order Nos"; Rec."Quality Production Order Nos")
            {
                ApplicationArea = All;
            }
            field("Quality Location Code"; Rec."Quality Location Code")
            {
                ApplicationArea = All;
            }
            field("Rework Production No. Series"; rec."Rework Production No. Series")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}