Page 75384 "QC Rcpt. Subform"
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
    // DeleteAllowed = false;//T51170-N
    // InsertAllowed = false;//T51170-N
    PageType = ListPart;
    SourceTable = "QC Rcpt. Line";
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
                    // Editable = RequiredEditible_gBol;//T51170-N //28-04-2025-O
                }
                //T12544-NE
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
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
                field("Selected QC Parameter"; rec."Selected QC Parameter")
                {
                    ApplicationArea = All;
                    Visible = ViewQualityOrderApplicable_gBln;//T12479-N
                }
                //T12113-ABA-NE
                field("Quality Parameter Code"; Rec."Quality Parameter Code")
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    Editable = RequiredEditible_gBol;//T51170-N
                }
                field("Method Description"; Rec."Method Description")
                {
                    ApplicationArea = Basic;
                    Caption = 'Method Description';
                    Editable = false;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Rounding Precision"; Rec."Rounding Precision")     //T51170-NS
                {
                    ApplicationArea = basic;
                    Editable = false;
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
                    Editable = false;
                }
                field("Min.Value"; Rec."Min.Value")
                {
                    ApplicationArea = Basic;
                    // Editable = false;//T51170-O
                    Editable = RequiredEditible_gBol;//T51170-N
                }
                field("Max.Value"; Rec."Max.Value")
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    Editable = RequiredEditible_gBol;//T51170-N
                }
                //T13827-NS
                field("COA Min.Value"; Rec."COA Min.Value")
                {
                    ApplicationArea = All;
                    // Editable = false;
                    Editable = RequiredEditible_gBol;//T51170-N
                    ToolTip = 'Specifies the value of the COA Min.Value field.', Comment = '%';
                }
                field("COA Max.Value"; Rec."COA Max.Value")
                {
                    ApplicationArea = All;
                    // Editable = false;
                    Editable = RequiredEditible_gBol;//T51170-N
                    ToolTip = 'Specifies the value of the COA Max.Value field.', Comment = '%';
                }
                //T13827-NE
                field("Text Value"; Rec."Text Value")
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                    Editable = RequiredEditible_gBol;//T51170-N
                }
                //T12543-NS
                field("Vendor COA Text Result"; Rec."Vendor COA Text Result")
                {
                    ApplicationArea = all;
                    Editable = "Actual TextEditable";
                }
                field("Vendor COA Value Result"; Rec."Vendor COA Value Result")
                {
                    ApplicationArea = Basic;
                    Editable = "Actual ValueEditable";
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
                    Editable = "Actual ValueEditable";
                    Style = Strong;
                    StyleExpr = true;
                    //T53755-NS
                    trigger OnValidate()
                    var
                        QCParamater_lRec: Record "QC Parameters";
                    begin
                        if rec."Actual Value" <> 0 then begin
                            if QCParamater_lRec.Get(Rec."Quality Parameter Code") then
                                Rec."Test Cost (USD)" := QCParamater_lRec."Test Cost (USD)"
                        end
                        else
                            Rec."Test Cost (USD)" := 0;
                    end;
                    //T53755-NE
                }


                field("Actual Text"; Rec."Actual Text")
                {
                    ApplicationArea = Basic;
                    Editable = "Actual TextEditable";
                    Style = Strong;
                    StyleExpr = true;
                    //T53755-NS
                    trigger OnValidate()
                    var
                        QCParamater_lRec: Record "QC Parameters";
                    begin
                        if rec."Actual Text" <> '' then begin
                            if QCParamater_lRec.Get(Rec."Quality Parameter Code") then
                                Rec."Test Cost (USD)" := QCParamater_lRec."Test Cost (USD)"
                        End
                        else
                            Rec."Test Cost (USD)" := 0;
                    end;
                    //T53755-NE
                }
                field("Test Cost (USD)"; Rec."Test Cost (USD)")
                {
                    ToolTip = 'Specifies the value of the Test Cost (USD) field.', Comment = '%';
                    Description = 'T53755';
                }
                field(Rejection; Rec.Rejection)
                {
                    ApplicationArea = Basic;
                }
                field("Rejected Qty."; Rec."Rejected Qty.")
                {
                    ApplicationArea = Basic;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field(Result; Rec.Result)
                {
                    ApplicationArea = Basic;
                }
                //T12212-NS
                field("Quantity to Rework"; Rec."Quantity to Rework")
                {
                    ApplicationArea = Basic;
                    Editable = QtyReworkEditible_gBol;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                //T12212-NE
                field("Quality Order No."; rec."Quality Order No.")
                {
                    ApplicationArea = All;
                    Visible = ViewQualityOrderApplicable_gBln;//T12479-N

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
                //T52538-NE
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("QC Line Detail")
            {
                ApplicationArea = Basic;
                Caption = 'QC Line Detail';
                Image = LedgerEntries;

                trigger OnAction()
                begin
                    Rec.ShowQCDetails_gFnc; //I-C0009-1001310-02 N
                end;
            }
            //T12113-ABA-NS
            action("Create Quality Order Request")
            {
                ApplicationArea = All;
                Image = Production;
                Visible = ViewQualityOrderApplicable_gBln;//T12479-N

                trigger OnAction()
                var
                    CreateProdOrder_lCdu: Codeunit "Create Rework Prod. Order QC";
                    QCRcptLine_lRec: Record "QC Rcpt. Line";
                    CreateQONo_hTxt: text;
                    Text0001_gCtx: label 'Quality Order created successfully. Quality Order No: ''%1''.';
                begin
                    Clear(QCRcptLine_lRec);
                    QCRcptLine_lRec.SetRange("No.", Rec."No.");
                    QCRcptLine_lRec.SetRange("Selected QC Parameter", true);
                    if QCRcptLine_lRec.FindSet() then begin
                        if not Confirm('Do you want to Create Quality Orders Request?', true) then
                            exit;
                        repeat
                            Clear(CreateProdOrder_lCdu);
                            CreateQONo_hTxt := CreateProdOrder_lCdu.CreateQualityOrderRequest_gFnc(Rec);
                            if CreateQONo_hTxt <> '' then
                                Message(Text0001_gCtx, CreateQONo_hTxt);
                        until QCRcptLine_lRec.next = 0;
                    end else
                        Error('Select the  QC Parameter field in the Line for Create Quality Order Request.');
                end;
            }
            //T12113-ABA-NE
            //T12113-NB-NS
            // action("View Item Tracking")
            // {
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     var
            //         QCSalesTracking_lRec: Record "QC Sales Tracking";
            //         QCSalesItracking_lPag: page "QC Sales Tracking";
            //     begin
            //         QCSalesTracking_lRec.Reset();
            //         QCSalesTracking_lRec.SetRange("QC No.", Rec."No.");
            //         QCSalesItracking_lPag.SetTableView(QCSalesTracking_lRec);
            //         QCSalesItracking_lPag.Run();

            //     end;
            // }
            //T12113-NB-NE
        }
    }

    trigger OnAfterGetRecord()
    begin

        ////I-C0009-1001310-01 NS
        Rec.CalcFields(Method);
        AfterGetCurrRecord;
        //I-C0009-1001310-01 NE
        QtyReworkEditible_lFnc;//T12212-N
        RequiredEditible_lFnc;//T51170-N
        Visible_lFnc;//T12479-N
        DecimalPlaces_lFnc(Rec."Vendor COA Value Result", Rec."Decimal Places");//T52614-N
    end;

    trigger OnInit()
    begin
        //I-C0009-1001310-01 NS

        "Actual TextEditable" := true;
        "Actual ValueEditable" := true;
        //I-C0009-1001310-01 NE
        QtyReworkEditible_gBol := false;//T12212-N
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        AfterGetCurrRecord;
        QtyReworkEditible_lFnc;//T12212-N
        RequiredEditible_lFnc;//T51170-N
        Visible_lFnc;//T12479-N

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
        Attach_gRec: Record Attachment;
        QCRcpt: Record "QC Rcpt. Header";
        //[InDataSet]
        "Actual ValueEditable": Boolean;
        //[InDataSet]
        "Actual TextEditable": Boolean;
        QtyReworkEditible_gBol: Boolean;//T12212-N
        ViewOrderwithQCItem_gBln: Boolean;//T12479-N
        ViewQualityOrderApplicable_gBln: Boolean;//T12479-N
        QCSetup_gRec: Record "Quality Control Setup";
        //T51170-NS
        RequiredEditible_gBol: Boolean;
        UserSetup_gRec: Record "User Setup";
    //T51170-NE

    //T51170-NS
    local procedure QCPermissionAllowed_lFnc()
    begin
        UserSetup_gRec.get(UserId);
        if not UserSetup_gRec."QC Line Modify Allowed" then
            Error('You are not allowed. Kindly contact to admin.');
    end;

    local procedure RequiredEditible_lFnc()
    Var
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
    begin
        UserSetup_gRec.get(UserId);
        if not UserSetup_gRec."QC Line Modify Allowed" then
            exit;
        if QCRcptHeader_lRec.get(Rec."No.") then
            RequiredEditible_gBol := true;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        myInt: Integer;
    begin
        QCPermissionAllowed_lFnc;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        QCPermissionAllowed_lFnc();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        // QCPermissionAllowed_lFnc();
    end;

    //T51170-NE
    procedure Refresh()
    begin
        CurrPage.Update(false); //I-C0009-1001310-02 N
    end;

    local procedure AfterGetCurrRecord()
    begin
        //I-C0009-1001310-01 NS
        xRec := Rec;
        Rec.CalcFields(Method);

        if Rec.Type = Rec.Type::Text then begin
            "Actual ValueEditable" := false;
            "Actual TextEditable" := true;
        end else
            if Rec.Type = Rec.Type::Range then begin
                "Actual ValueEditable" := true;
                "Actual TextEditable" := false; //Hypercare-18-03-25-N
            end else
                if ((Rec.Type = Rec.Type::Maximum) or (Rec.Type = Rec.Type::Minimum)) then begin
                    "Actual ValueEditable" := true;
                    "Actual TextEditable" := false;
                end;
        //I-C0009-1001310-01 NE
        Visible_lFnc();

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
        QCSetup_lRec.get;
        if QCSetup_lRec."Quality Order Applicable" then
            ViewQualityOrderApplicable_gBln := true
        else
            ViewQualityOrderApplicable_gBln := false;
        //T12479-NE

    end;
}

