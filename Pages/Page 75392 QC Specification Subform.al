Page 75392 "QC Specification Subform"
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

    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "QC Specification Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                field("Item Specifiction Code"; Rec."Item Specifiction Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                //T12113-ABA-NS
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = All;
                    Visible = QualityOrderVisible_gBol;//T12479
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = QualityOrderVisible_gBol;//T12479
                }
                //T12113-ABA-NE
                field("Standard Task Code"; Rec."Standard Task Code")
                {
                    ApplicationArea = Basic;
                }
                field("Program"; Rec."Program")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Quality Parameter Code"; Rec."Quality Parameter Code")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("Method Description"; Rec."Method Description")
                {
                    ApplicationArea = Basic;
                    Caption = 'Method Description';
                }
                field("Rounding Precision"; Rec."Rounding Precision")//T51170
                {
                    ApplicationArea = Basic;

                }
                //T52614-NS
                field("Decimal Places"; Rec."Decimal Places")
                {
                    ToolTip = 'Specifies the value of the Decimal Places field.', Comment = '%';
                }
                //T52614-NE
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        //I-C0009-1001310-01 NS
                        if Rec.Type = Rec.Type::Text then begin
                            "Min.ValueEditable" := false;
                            "Max.ValueEditable" := false;
                            "Text ValueEditable" := true;
                        end else
                            if Rec.Type = Rec.Type::Range then begin
                                "Min.ValueEditable" := true;
                                "Max.ValueEditable" := true;
                                "Text ValueEditable" := false;
                            end else
                                if Rec.Type = Rec.Type::Maximum then begin
                                    "Min.ValueEditable" := false;
                                    "Max.ValueEditable" := true;
                                    "Text ValueEditable" := false;
                                end else
                                    if Rec.Type = Rec.Type::Minimum then begin
                                        "Min.ValueEditable" := true;
                                        "Max.ValueEditable" := false;
                                        "Text ValueEditable" := false;
                                    end;
                        //I-C0009-1001310-01 NE
                    end;
                }
                field("Min.Value"; Rec."Min.Value")
                {
                    ApplicationArea = Basic;
                    Editable = "Min.ValueEditable";
                }
                field("Max.Value"; Rec."Max.Value")
                {
                    ApplicationArea = Basic;
                    Editable = "Max.ValueEditable";

                    trigger OnValidate()
                    begin
                        //I-C0009-1001310-01 NS
                        if Rec."Min.Value" > Rec."Max.Value" then begin
                            Message('Max. Value is always >= Min. Value');
                            Rec."Max.Value" := 0;
                            Rec."Min.Value" := 0;
                        end;
                        //I-C0009-1001310-01 NE
                    end;
                }
                //T13827-NS
                field("COA Min.Value"; Rec."COA Min.Value")
                {
                    ToolTip = 'Specifies the value of the COA Min.Value field.', Comment = '%';
                    Editable = "Min.ValueEditable";
                }
                field("COA Max.Value"; Rec."COA Max.Value")
                {
                    ToolTip = 'Specifies the value of the COA Max.Value field.', Comment = '%';
                    Editable = "Max.ValueEditable";
                    trigger OnValidate()
                    begin
                        //I-C0009-1001310-01 NS
                        if Rec."COA Min.Value" > Rec."COA Max.Value" then begin
                            Message('COA Max. Value is always >= COA Min. Value');
                            Rec."COA Max.Value" := 0;
                            Rec."COA Min.Value" := 0;
                        end;
                        //I-C0009-1001310-01 NE
                    end;
                }
                //T13827-NE

                field("Text Value"; Rec."Text Value")
                {
                    ApplicationArea = Basic;
                    Editable = "Text ValueEditable";
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = Basic;
                }
                field(Print; Rec.Print)
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
        }
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        QualityOrderVisible_lFnc //T12479
    end;

    trigger OnAfterGetRecord()
    begin
        //I-C0009-1001310-01 NS
        Rec.CalcFields(Method);
        AfterGetCurrRecord;
        //I-C0009-1001310-01 NE
    end;

    trigger OnInit()
    begin
        //I-C0009-1001310-01 NS
        "Text ValueEditable" := true;
        "Max.ValueEditable" := true;
        "Min.ValueEditable" := true;
        //I-C0009-1001310-01 NE
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AfterGetCurrRecord;  //I-C0009-1001310-01 N
    end;

    var
        InteractTmplLanguage_gRec: Record "Interaction Tmpl. Language";
        //[InDataSet]
        "Min.ValueEditable": Boolean;
        //[InDataSet]
        "Max.ValueEditable": Boolean;
        //[InDataSet]
        "Text ValueEditable": Boolean;

    local procedure AfterGetCurrRecord()
    begin
        //I-C0009-1001310-01 NS
        xRec := Rec;
        Rec.CalcFields(Method);
        if Rec.Type = Rec.Type::Text then begin
            "Min.ValueEditable" := false;
            "Max.ValueEditable" := false;
            "Text ValueEditable" := true;
        end else
            if Rec.Type = Rec.Type::Range then begin
                "Min.ValueEditable" := true;
                "Max.ValueEditable" := true;
                "Text ValueEditable" := false;
            end else
                if Rec.Type = Rec.Type::Maximum then begin
                    "Min.ValueEditable" := false;
                    "Max.ValueEditable" := true;
                    "Text ValueEditable" := false;
                end else
                    if Rec.Type = Rec.Type::Minimum then begin
                        "Min.ValueEditable" := true;
                        "Max.ValueEditable" := false;
                        "Text ValueEditable" := false;
                    end;
        //I-C0009-1001310-01 NE
    end;
    //T12479-NS
    local procedure QualityOrderVisible_lFnc()
    Var
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        QCSetup_lRec.get;
        if QCSetup_lRec."Quality Order with QC Item" then
            QualityOrderVisible_gBol := true
        else
            QualityOrderVisible_gBol := false;

    end;
    //T12479-NE
    var
        QualityOrderVisible_gBol: Boolean;
}

