Page 75399 "QC Reservation Entry"
{
    // ------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // ------------------------------------------------------------------------------------------------
    //       ID                   DATE           AUTHOR
    // ------------------------------------------------------------------------------------------------
    // I-C0009-ProdQC-01          23/12/15       Nishant Upadhyay
    //                            Production QC
    //                            New List Page.
    // ------------------------------------------------------------------------------------------------

    SourceTable = "QC Reservation Entry";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic;
                }
                //T12706-NS
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.', Comment = '%';
                    ApplicationArea = all;
                }
                //T12706-NE
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = Basic;
                }
                field("Reservation Status"; Rec."Reservation Status")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = Basic;
                }
                field("Transferred from Entry No."; Rec."Transferred from Entry No.")
                {
                    ApplicationArea = Basic;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic;
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = Basic;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = Basic;
                }
                //T12545-NS
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = All;
                    Caption = 'Manufacturing Date';
                    ToolTip = 'Specifies the Manufacturing Date for the item on the line.';
                }
                //T12545-NE
            }
        }
    }

    actions
    {
    }
}

