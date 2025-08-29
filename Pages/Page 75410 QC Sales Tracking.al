page 75410 "QC Sales Tracking"//T12113-NB
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "QC Sales Tracking";
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(List)
            {
                ShowCaption = false;
                field("Document No."; rec."Document No.")
                {
                    ApplicationArea = all;
                    Caption = 'Document No.';
                    Editable = false;
                }
                field("Document Line No."; rec."Document Line No.")
                {
                    ApplicationArea = all;
                    Caption = 'Document Line No.';
                    Editable = false;
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = all;
                    Caption = 'Item No.';
                    Editable = false;
                }
                field("Lot No."; rec."Lot No.")
                {
                    ApplicationArea = all;
                    Caption = 'Lot No.';
                    Editable = false;
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = all;
                    Caption = 'Quanity';
                    Editable = false;
                }
                field("QC No."; rec."QC No.")
                {
                    ApplicationArea = all;
                    Caption = 'QC No.';
                }
                field("Qty to Accept"; rec."Qty to Accept")
                {
                    ApplicationArea = all;
                    Caption = 'Qty to Accept';
                }
                field("Qty to Accept with Deviation"; rec."Qty to Accept with Deviation")
                {
                    ApplicationArea = all;
                    Caption = 'Qty to Accept with Deviation';
                }
                field("Qty to Reject"; rec."Qty to Reject")
                {
                    ApplicationArea = all;
                    Caption = 'Qty to Reject';
                }
                field("Qty to Rework"; rec."Qty to Rework")
                {
                    ApplicationArea = all;
                    caption = 'Qty to Rework';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
}