Page 75387 "Posted QC Rcpt. Subform"
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
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = true;
    PageType = ListPart;
    SourceTable = "Posted QC Rcpt. Line";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                //T12544-NS
                field(Required; Rec.Required)
                {
                    ApplicationArea = Basic;
                }
                //T12544-NE
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic;
                }
                //T12113-ABA-NS
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = ViewOrderwithQCItem_gBln;//T12479-N
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = ViewOrderwithQCItem_gBln;//T12479-N
                }
                //T12113-ABA-NE

                field("Quality Parameter Code"; Rec."Quality Parameter Code")
                {
                    ApplicationArea = Basic;

                }
                field("Method Description"; Rec."Method Description")
                {
                    ApplicationArea = Basic;
                    Caption = 'Method Description';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic;
                }
                field("Rounding Precision"; Rec."Rounding Precision")     //T51170-NS
                {
                    ApplicationArea = basic;
                }
                //T52614-NS
                field("Decimal Places"; Rec."Decimal Places")
                {
                    ToolTip = 'Specifies the value of the Decimal Places field.', Comment = '%';
                }
                //T52614-NE
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        //I-C0009-1001310-01 NS
                        if Rec.Type = Rec.Type::Text then begin
                            "Min.ValueEditable" := false;
                            "Max.ValueEditable" := false;
                            CompulsoryEditable := true
                        end else
                            if Rec.Type = Rec.Type::Range then begin
                                "Min.ValueEditable" := true;
                                "Max.ValueEditable" := true;
                                CompulsoryEditable := true
                            end else
                                if Rec.Type = Rec.Type::Maximum then begin
                                    "Min.ValueEditable" := false;
                                    "Max.ValueEditable" := true;
                                    CompulsoryEditable := true
                                end else
                                    if Rec.Type = Rec.Type::Minimum then begin
                                        "Min.ValueEditable" := true;
                                        "Max.ValueEditable" := false;
                                        CompulsoryEditable := true
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
                }
                //T13827-NS
                field("COA Min.Value"; Rec."COA Min.Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the COA Min.Value field.', Comment = '%';
                }
                field("COA Max.Value"; Rec."COA Max.Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the COA Max.Value field.', Comment = '%';
                }
                //T13827-NE
                field("Text Value"; Rec."Text Value")
                {
                    ApplicationArea = Basic;
                    Editable = "Text ValueEditable";
                }
                //T12543-NS
                field("Vendor COA Text Result"; Rec."Vendor COA Text Result")
                {
                    ApplicationArea = all;
                }
                field("Vendor COA Value Result"; Rec."Vendor COA Value Result")
                {
                    ApplicationArea = Basic;
                    trigger OnValidate()
                    var
                    begin
                        DecimalPlaces_lFnc(Rec."Vendor COA Value Result", Rec."Decimal Places");//T52614-N
                    end;
                }
                //T12543-NE

                //T52614-NS
                field(VendorCOAValueText_gTxt; VendorCOAValueText_gTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor COA Value Text';
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                //T52614-NE
                field("Actual Value"; Rec."Actual Value")
                {
                    ApplicationArea = Basic;

                }
                field("Actual Text"; Rec."Actual Text")
                {
                    ApplicationArea = Basic;
                }
                field(Rejection; Rec.Rejection)
                {
                    ApplicationArea = Basic;
                }
                field("Rejected Qty."; Rec."Rejected Qty.")
                {
                    ApplicationArea = Basic;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = Basic;
                    Editable = CompulsoryEditable;
                    Visible = false;
                }
                field("Quality Order No."; rec."Quality Order No.")
                {
                    ApplicationArea = Basic;
                    Visible = ViewQualityOrderApplicable_gBln;
                }
                field("Selected QC Parameter"; rec."Selected QC Parameter")
                {
                    ApplicationArea = basic;
                    Visible = ViewQualityOrderApplicable_gBln;//T12479-N

                }
                //T13827-NS
                field(Result; rec.Result)
                {
                    ApplicationArea = All;
                }
                //T13827-NE
                field("Quantity to Rework"; rec."Quantity to Rework")
                {
                    ApplicationArea = basic;
                    Editable = QtyReworkEditible_gBol;
                }
                field(Notes; Rec.Notes)
                {
                    ToolTip = 'Specifies the value of the Notes field.', Comment = '%';
                }
                //T52538-NS
                field("QC Status"; Rec."QC Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the QC Status field.', Comment = '%';
                }
                field("Test Cost (USD)"; Rec."Test Cost (USD)")
                {
                    ToolTip = 'Specifies the value of the Test Cost (USD) field.', Comment = '%';
                    Description = 'T53755';
                }
                //T52538-NE
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("<Action1907935204>")
            {
                Caption = '&Line';
                action("<Action1000000002>")
                {
                    ApplicationArea = Basic;
                    Caption = 'QC Line Detail';

                    trigger OnAction()
                    begin
                        Rec.ShowQCDetails_gFnc; //I-C0009-1001310-02 N
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //I-C0009-1001310-01 NS
        Rec.CalcFields(Method);
        AfterGetCurrRecord;
        QtyReworkEditible_lFnc;//T12212-N
        Visible_lFnc;//T12479-N
        DecimalPlaces_lFnc(Rec."Vendor COA Value Result", Rec."Decimal Places");//T52614-N
        //I-C0009-1001310-01 NE
    end;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        QtyReworkEditible_lFnc;//T12212-N
        Visible_lFnc;
    end;

    trigger OnInit()
    begin
        //I-C0009-1001310-01 NS
        "Text ValueEditable" := true;
        "Max.ValueEditable" := true;
        "Min.ValueEditable" := true;
        QtyReworkEditible_gBol := false;//T12212-N
        //I-C0009-1001310-01 NE
    end;

    //T52614-NS
    local procedure DecimalPlaces_lFnc(DecValue_iDec: Decimal; Places_iInt: Integer)
    var
        FormatString: Text;
    begin
        if Places_iInt > 0 then begin
            FormatString := '<Precision,' + Format(Places_iInt + 1) + '>' + '<sign><Integer Thousand>' + '<Decimals,' + Format(Places_iInt + 1) + '>';
            VendorCOAValueText_gTxt := Format(DecValue_iDec, 0, FormatString);
            if StrPos(VendorCOAValueText_gTxt, '*') > 0 then
                VendorCOAValueText_gTxt := 'Please check the Setup or connect with the IT Team.'
        end else
            VendorCOAValueText_gTxt := Format(DecValue_iDec);

        if DecValue_iDec = 0 then
            VendorCOAValueText_gTxt := '';

    end;
    //T52614-NE

    var
        VendorCOAValueText_gTxt: Text;
        InteractTmplLanguage_gRec: Record "Interaction Tmpl. Language";
        "Min.ValueEditable": Boolean;

        "Max.ValueEditable": Boolean;
        //[InDataSet]
        "Text ValueEditable": Boolean;
        //[InDataSet]
        CompulsoryEditable: Boolean;
        QtyReworkEditible_gBol: Boolean;//T12212-N
        ViewOrderwithQCItem_gBln: Boolean;
        ViewQualityOrderApplicable_gBln: Boolean;

    procedure Refresh()
    begin
        CurrPage.Update(false); ////I-C0009-1001310-01 N
    end;

    local procedure AfterGetCurrRecord()
    begin
        //I-C0009-1001310-01 NS
        xRec := Rec;
        Rec.CalcFields(Method);

        if Rec.Type = Rec.Type::Text then begin
            "Min.ValueEditable" := false;
            "Max.ValueEditable" := false;
            "Text ValueEditable" := true;
            CompulsoryEditable := true
        end else
            if Rec.Type = Rec.Type::Range then begin
                "Min.ValueEditable" := true;
                "Max.ValueEditable" := true;
                "Text ValueEditable" := false;
                CompulsoryEditable := true
            end else
                if Rec.Type = Rec.Type::Maximum then begin
                    "Min.ValueEditable" := false;
                    "Max.ValueEditable" := true;
                    "Text ValueEditable" := false;
                    CompulsoryEditable := true
                end else
                    if Rec.Type = Rec.Type::Minimum then begin
                        "Min.ValueEditable" := true;
                        "Max.ValueEditable" := false;
                        "Text ValueEditable" := false;
                        CompulsoryEditable := true
                    end;
        //I-C0009-1001310-01 NE

    end;

    local procedure QtyReworkEditible_lFnc()
    Var
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
    begin
        if QCRcptHeader_lRec.get(Rec."No.") then
            if QCRcptHeader_lRec."Document Type" <> QCRcptHeader_lRec."Document Type"::Production then
                exit;
        QtyReworkEditible_gBol := true;
    end;

    local procedure Visible_lFnc()//T12479-N
    Var
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        QCSetup_lRec.get;
        if QCSetup_lRec."Quality Order with QC Item" then
            ViewOrderwithQCItem_gBln := true
        else
            ViewOrderwithQCItem_gBln := false;

        //T12479-NS        
        if QCSetup_lRec."Quality Order Applicable" then
            ViewQualityOrderApplicable_gBln := true
        else
            ViewQualityOrderApplicable_gBln := false;
        //T12479-NE

    end;


}

