PageExtension 75410 Capacity_Ledger_Entries_75410 extends "Capacity Ledger Entries"
{
    layout
    {
        addafter("Dimension Set ID")
        {
            field("QC No."; Rec."QC No.")
            {
                ApplicationArea = Basic;
            }
            field("Posted QC No."; Rec."Posted QC No.")
            {
                ApplicationArea = Basic;
            }
            field("Accepted Quantity"; Rec."Accepted Quantity")
            {
                ApplicationArea = Basic;
            }
            field("Qty Accepted With Deviation"; Rec."Qty Accepted With Deviation")
            {
                ApplicationArea = Basic;
            }
            field("Rework Quantity"; Rec."Rework Quantity")
            {
                ApplicationArea = Basic;
            }
            field("Reject Quantity"; Rec."Reject Quantity")
            {
                ApplicationArea = Basic;
            }
        }
    }
}

