Page 75385 "Posted QC Rcpt. List"
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
    // I-C0009-1001310-05     24/11/14    RaviShah
    //                        Return Order from QC Rej. Qty Functionality
    //                        Added New Function "SetSelection"
    // ------------------------------------------------------------------------------------------------------------------------------

    CardPageID = "Posted QC Rcpt";
    DeleteAllowed = false;
    Editable = false;
    PageType = List;
    SourceTable = "Posted QC Rcpt. Header";
    UsageCategory = Lists;
    //T12971-NS
    Caption = 'Posted QC Receipt';
    AdditionalSearchTerms = 'Posted QC Receipt';
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
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Document No."; Rec."Document No.")
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
                    Visible = QualityOrderVisible_gBol;//T12479-N
                }
                field("Item Name"; Rec."Item Name")
                {
                    ApplicationArea = Basic;
                    Visible = QualityOrderVisible_gBol;//T12479-N
                }

                field("Checked By"; Rec."Checked By")
                {
                    ApplicationArea = Basic;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic;
                }
                field("Sample QC"; Rec."Sample QC")
                {
                    ApplicationArea = Basic;
                }
                field("Receipt Date"; Rec."Receipt Date")
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
                field("Accepted Quantity"; Rec."Accepted Quantity")
                {
                    ApplicationArea = Basic;
                }
                field("Accepted with Deviation Qty"; Rec."Accepted with Deviation Qty")
                {
                    ApplicationArea = Basic;
                }
                field("Rejected Quantity"; Rec."Rejected Quantity")
                {
                    ApplicationArea = Basic;
                }
                field("Vendor DC No"; Rec."Vendor DC No")
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
                field("Operation Name"; Rec."Operation Name")
                {
                    ApplicationArea = Basic;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                    ApplicationArea = Basic;
                }
                 field("COA QC"; rec."COA QC")
                {
                    ApplicationArea = basic;
                }
                field("COA AutoPost"; Rec."COA AutoPost")
                {
                    ToolTip = 'Specifies the value of the COA AutoPost field.', Comment = '%';
                }
                
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(75384),
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
            group("&Posted QC Rcpt")
            {
                Caption = '&Posted QC Rcpt';
                action(Card)
                {
                    ApplicationArea = Basic;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Posted QC Rcpt";
                    RunPageLink = "No." = field("No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
    }
    var
        QualityOrderVisible_gBol: Boolean;//T12479-N

    trigger OnOpenPage()
    begin
        OnActivateForm;
        QualityOrderVisible_lFnc;//T12479-N
    end;

    local procedure OnActivateForm()
    begin
        Rec.SetRange("No.");
    end;

    local procedure QualityOrderVisible_lFnc()//T12479-N
    Var
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        QCSetup_lRec.get;
        if QCSetup_lRec."Quality Order with QC Item" then
            QualityOrderVisible_gBol := true
        else
            QualityOrderVisible_gBol := false;

    end;

    procedure SetSelection(var PostedQCRcpt: Record "Posted QC Rcpt. Header")
    begin
        CurrPage.SetSelectionFilter(PostedQCRcpt); //I-C0009-1001310-05-N
    end;
}

