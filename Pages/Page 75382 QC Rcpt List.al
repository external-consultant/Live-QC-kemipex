Page 75382 "QC Rcpt. List"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-04     27/08/12    Dipak Patel/Nilesh Gajjar
    //                        QC Module - Redesign Released.
    // I-C0009-1400405-01     05/08/14    Chintan Panchal
    //                        Upgrade to NAV 2013 R2
    // ------------------------------------------------------------------------------------------------------------------------------

    CardPageID = "QC Rcpt.";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "QC Rcpt. Header";
    UsageCategory = Lists;
    //T12971-NS
    Caption = 'QC Receipt';
    AdditionalSearchTerms = 'QC Receipt';
    //T12971-NE
    ApplicationArea = all;
    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = Basic;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic;
                }
                //T12706-NS
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.', Comment = '%';
                }
                //T12706-NE
                field("Item Name"; Rec."Item Name")
                {
                    ApplicationArea = Basic;
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic;
                }
                field("Order Quantity"; Rec."Order Quantity")
                {
                    ApplicationArea = Basic;
                }
                field("Inspection Quantity"; Rec."Inspection Quantity")
                {
                    ApplicationArea = Basic;
                }
                field("Quantity to Accept"; Rec."Quantity to Accept")
                {
                    ApplicationArea = Basic;
                }
                field("Qty to Accept with Deviation"; Rec."Qty to Accept with Deviation")
                {
                    ApplicationArea = Basic;
                }
                field("Quantity to Reject"; Rec."Quantity to Reject")
                {
                    ApplicationArea = Basic;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Basic;
                }
                field("QC Date"; Rec."QC Date")
                {
                    ApplicationArea = Basic;
                }
                field("Vendor Lot No."; Rec."Vendor Lot No.")
                {
                    ApplicationArea = Basic;
                }
                field("COA QC"; rec."COA QC")
                {
                    ApplicationArea = basic;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                    ApplicationArea = Basic;
                }

            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")//T12530-N
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(75382),
                              "No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&QC Rcpt")
            {
                Caption = '&QC Rcpt';
                action(Card)
                {
                    ApplicationArea = Basic;
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "QC Rcpt.";
                    RunPageLink = "No." = field("No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
    }
}

