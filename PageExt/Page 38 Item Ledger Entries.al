PageExtension 75406 Item_Ledger_Entries_75406 extends "Item Ledger Entries"
{
    layout
    {
        addafter("Prod. Order Comp. Line No.")
        {
            field("QC No."; Rec."QC No.")
            {
                ApplicationArea = Basic;
            }
            field("Posted QC No."; Rec."Posted QC No.")
            {
                ApplicationArea = Basic;
            }
            field("QC Relation Entry No."; Rec."QC Relation Entry No.")
            {
                ApplicationArea = All;
            }
        }
    }
    //YH++
    actions
    {
        addlast(processing)
        {
            action("Update Bulk Fields by YH")
            {
                ApplicationArea = all;
                trigger OnAction()
                var
                    UpdateILECOdeunit: Codeunit "Cu 22 Item Jnl Post";
                begin
                    UpdateILECOdeunit.UpdateManuDate();
                end;
            }
        }
    }
    //YH--
}

