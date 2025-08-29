Page 75393 "QC Line Details"
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
    // I-C0009-1400405-02       16/10/2014  Ganesh Chede
    //                        Adding new colunm 1) "Unit of Measure Code" 2) "Min. Value" 3)"Max. Value"
    // ------------------------------------------------------------------------------------------------------------------------------

    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "QC Line Detail";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                field("QC Rcpt No."; Rec."QC Rcpt No.")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Quality Parameter Code"; Rec."Quality Parameter Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("QC Rcpt Line No."; Rec."QC Rcpt Line No.")
                {
                    ApplicationArea = Basic;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Method Description"; Rec."Method Description")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Min.Value"; Rec."Min.Value")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Max.Value"; Rec."Max.Value")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Actual Value"; Rec."Actual Value")
                {
                    ApplicationArea = Basic;
                    Editable = "Actual ValueEditable";
                }
                field("Actual Text"; Rec."Actual Text")
                {
                    ApplicationArea = Basic;
                    Editable = "Actual TextEditable";
                }
                field("Rejected Qty."; Rec."Rejected Qty.")
                {
                    ApplicationArea = Basic;
                }
                field(Rejection; Rec.Rejection)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("QC Result")
            {
                ApplicationArea = Basic;
                RunObject = Page "QC Result";
                RunPageLink = "QC No." = field("QC Rcpt No."),
                              "Lot No." = field("Lot No."),
                              "Serial No." = field("Serial No.");
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //I-C0009-1001310-02 NS
        if Rec.Type = Rec.Type::Text then begin
            "Actual ValueEditable" := false;
            "Actual TextEditable" := true;
        end else
            if Rec.Type = Rec.Type::Range then begin
                "Actual ValueEditable" := true;
                "Actual TextEditable" := true;
            end else
                if ((Rec.Type = Rec.Type::Maximum) or (Rec.Type = Rec.Type::Minimum)) then begin
                    "Actual ValueEditable" := true;
                    "Actual TextEditable" := false;
                end
        //I-C0009-1001310-02 NE
    end;

    trigger OnAfterGetRecord()
    begin
        //I-C0009-1001310-02 NS
        if Rec.Type = Rec.Type::Text then begin
            "Actual ValueEditable" := false;
            "Actual TextEditable" := true;
        end else
            if Rec.Type = Rec.Type::Range then begin
                "Actual ValueEditable" := true;
                "Actual TextEditable" := true;
            end else
                if ((Rec.Type = Rec.Type::Maximum) or (Rec.Type = Rec.Type::Minimum)) then begin
                    "Actual ValueEditable" := true;
                    "Actual TextEditable" := false;
                end
        //I-C0009-1001310-02 NE
    end;

    trigger OnInit()
    begin
        //I-C0009-1001310-02 NS
        "Actual TextEditable" := true;
        "Actual ValueEditable" := true;
        //I-C0009-1001310-02 NE
    end;

    var
        //[InDataSet]
        "Actual ValueEditable": Boolean;
        //[InDataSet]
        "Actual TextEditable": Boolean;
}

