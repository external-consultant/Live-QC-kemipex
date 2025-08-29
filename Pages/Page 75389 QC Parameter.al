Page 75389 "QC Parameter"
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

    UsageCategory = Lists;
    ApplicationArea = all;
    AutoSplitKey = false;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "QC Parameters";
    SourceTableView = sorting(Code)
                      order(ascending);

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic;
                    Caption = 'Code';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = All; //T12113-ABA
                    Visible = QualityOrderVisible_gBol;//T12479
                }
                field("Item Description"; rec."Item Description")
                {
                    ApplicationArea = All;//T12113-ABA
                    Editable = false;
                    Visible = QualityOrderVisible_gBol;//T12479
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic;
                }
                field("Method Description"; Rec."Method Description")
                {
                    ApplicationArea = Basic;
                }

                //T51170-NS 
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ToolTip = 'Specifies the value of the Rounding Type field.', Comment = '%';
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    ToolTip = 'Specifies the value of the Rounding Precision field.', Comment = '%';
                }
                //T51170-NE

                //T52614-NS
                field("Decimal Places"; Rec."Decimal Places")
                {
                    ToolTip = 'Specifies the value of the Decimal Places field.', Comment = '%';
                }
                //T52614-NE
                field("Test Cost (USD)"; Rec."Test Cost (USD)")
                {
                    ToolTip = 'Specifies the value of the Test Cost (USD) field.', Comment = '%';
                    Description = 'T53755';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

            //T12113-ABA-N
            action("Update Item in QC Specifications")
            {
                ApplicationArea = Basic;
                Caption = '&Update Item in QC Specifications';
                Image = UpdateDescription;
                trigger OnAction()
                begin
                    UpdateItemonItemSpectification_lFnc(rec);
                end;
            }
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
        Rec.CalcFields("Word Doc");
        AfterGetCurrRecord;
        //I-C0009-1001310-01 NE
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AfterGetCurrRecord; //I-C0009-1001310-01 N
    end;

    var
        InteractTmplLanguage: Record "Interaction Tmpl. Language";
        Attach: Record Attachment;

    local procedure AfterGetCurrRecord()
    begin
        //I-C0009-1001310-01 NS
        xRec := Rec;
        Rec.CalcFields("Word Doc");
        //I-C0009-1001310-01 NE
    end;

    //T12113-ABA-NS
    local procedure UpdateItemonItemSpectification_lFnc(QCParameter_iRec: Record "QC Parameters")
    var
        QCSpeciFic_lRec: Record "QC Specification Line";
        RecordCount_Int: Integer;
    begin
        Clear(RecordCount_Int);

        Clear(QCSpeciFic_lRec);
        QCSpeciFic_lRec.SetRange("Quality Parameter Code", QCParameter_iRec.Code);
        if QCSpeciFic_lRec.FindSet() then
            repeat
                QCSpeciFic_lRec."Item Code" := QCParameter_iRec."Item Code";
                QCSpeciFic_lRec."Item Description" := QCParameter_iRec."Item Description";
                QCSpeciFic_lRec.Modify();
                RecordCount_Int += 1;
            until QCSpeciFic_lRec.next = 0;
        if RecordCount_Int <> 0 then
            Message(' %1 - Records is updated in QCSpecification', RecordCount_Int);
    end;
    //T12113-ABA-NE

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

