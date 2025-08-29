Page 75388 "QC Parameters List"
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

    Editable = false;
    PageType = Card;
    SourceTable = "QC Parameters";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(RepeaterControl)
            {
                field("Code"; Rec.Code)
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
                }
                field("Rounding Precision"; Rec."Rounding Precision")//T51170
                {
                    ApplicationArea = Basic;

                }
                field("""Word Doc""<>0"; Rec."Word Doc" <> 0)
                {
                    ApplicationArea = Basic;
                    AssistEdit = true;
                    Caption = 'Attachment';

                    trigger OnAssistEdit()
                    begin
                        //I-C0009-1001310-01 NS
                        if Rec."Doc Code" = '' then begin
                            Message('Record is not Proper. So Delete this and Enter again');
                            exit;
                        end;
                        InteractTmplLanguage."Attachment No." := Rec."Word Doc";
                        if InteractTmplLanguage.Get(Rec."Doc Code", 'Eng') then begin
                            if InteractTmplLanguage."Attachment No." <> 0 then
                                InteractTmplLanguage.OpenAttachment
                            else
                                InteractTmplLanguage.CreateAttachment;
                        end else begin
                            InteractTmplLanguage.Init;
                            InteractTmplLanguage."Interaction Template Code" := Rec."Doc Code";
                            InteractTmplLanguage."Language Code" := 'Eng';
                            InteractTmplLanguage.Description := '';
                            InteractTmplLanguage.CreateAttachment;
                        end;
                        CurrPage.Update;
                        //I-C0009-1001310-01 NE
                    end;
                }
                //T52614-NS
                field("Decimal Places"; Rec."Decimal Places")
                {
                    ToolTip = 'Specifies the value of the Decimal Places field.', Comment = '%';
                }
                //T52614-NE

            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        //I-C0009-1001310-01 NS
        Rec.CalcFields("Word Doc");
        AfterGetCurrRecord;
        //I-C0009-1001310-01 NE
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        AfterGetCurrRecord;  //I-C0009-1001310-01 N
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
}

