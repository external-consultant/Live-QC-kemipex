Page 75401 "Posted Item QC Tracking Line2"
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

    Caption = 'Posted Item Tracking Lines';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Item Ledger Entry";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Shipped Qty. Not Returned"; Rec."Shipped Qty. Not Returned")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'Manufacturing Date';
                    Editable = false;
                }
                field("QC No."; Rec."QC No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Posted QC No."; Rec."Posted QC No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
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
                field("Rework Quantity"; Rec."Rework Quantity")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        //I-C0009-1001310-02 NS
        if Rec."Posted QC No." <> '' then
            ResultEditable := false
        else
            ResultEditable := true;
        //I-C0009-1001310-02 NE
    end;

    trigger OnInit()
    begin
        ResultEditable := true; //I-C0009-1001310-02 N
    end;

    trigger OnOpenPage()
    var
        CaptionText1: Text[100];
        CaptionText2: Text[100];
    begin
        //I-C0009-1001310-02 NS
        CaptionText1 := Rec."Item No.";
        if CaptionText1 <> '' then begin
            CaptionText2 := CurrPage.Caption;
            CurrPage.Caption := StrSubstNo(Text0001_gCtx, CaptionText1, CaptionText2);
        end;
        //I-C0009-1001310-02 NE
    end;

    var
        Text0001_gCtx: label '%1 - %2';
        //[InDataSet]
        ResultEditable: Boolean;
}

