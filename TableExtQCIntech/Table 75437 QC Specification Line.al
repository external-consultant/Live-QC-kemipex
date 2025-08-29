tableextension 75437 QCSpecLineExt extends "QC Specification Line"
{




    fields
    {

        modify(Type)
        {

            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-01 NS
                Mandatory := true;
                if (Type = Type::Minimum) then begin
                    "Max.Value" := 0;
                    "COA Max.Value" := 0;
                    // "Unit of Measure Code" := ''
                end else
                    if (Type = Type::Maximum) then begin
                        "Min.Value" := 0;
                        "COA Min.Value" := 0;//T13827-N
                        // "Unit of Measure Code" := '';
                        //end else
                        //  if (Type = Type::"4") then begin
                        //    "Min.Value" := 0;
                        //  "Max.Value" := 0;
                        //"Unit of Measure Code" := '';
                        //Mandatory := false;
                    end else
                        if (Type = Type::Range) then begin
                            // "Unit of Measure Code" := '';
                        end else
                            if (Type = Type::Text) then begin
                                "Min.Value" := 0;
                                "Max.Value" := 0;
                                //T13827-NS
                                "COA Min.Value" := 0;
                                "COA Max.Value" := 0;
                                //T13827-NE
                            end;
                //I-C0009-1001310-01 NE
            end;
        }
        modify("Min.Value")
        {
            //T51170-NS
            trigger OnAfterValidate()
            var
            begin
                if "Rounding Precision" > 0 then
                    "Min.Value" := QCGeneral_gCdu.RoundQCParameterPrecision("Quality Parameter Code", "Min.Value", "Rounding Precision");
            end;
            //T51170-NE

        }
        modify("Max.Value")
        {

            //T51170-NS
            trigger OnAfterValidate()
            var
            begin
                if "Rounding Precision" > 0 then
                    "Max.Value" := QCGeneral_gCdu.RoundQCParameterPrecision("Quality Parameter Code", "Max.Value", "Rounding Precision");
            end;
            //T51170-NE
        }
        //T13827-NS
        modify("COA Min.Value")
        {

            trigger OnAfterValidate()
            var
            begin
                if "Rounding Precision" > 0 then
                    "COA Min.Value" := QCGeneral_gCdu.RoundQCParameterPrecision("Quality Parameter Code", "COA Min.Value", "Rounding Precision");
            end;
            //T51170-NE
        }
        modify("COA Max.Value")
        {

            trigger OnAfterValidate()
            var
            begin
                if "Rounding Precision" > 0 then
                    "COA Max.Value" := QCGeneral_gCdu.RoundQCParameterPrecision("Quality Parameter Code", "COA Max.Value", "Rounding Precision");
            end;
            //T51170-NE
        }
        //T13827-NE

        modify("Quality Parameter Code")
        {

            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-01 NS
                QCParameter_gRec.Reset;
                if QCParameter_gRec.Get("Quality Parameter Code") then begin
                    "Document Code" := QCParameter_gRec."Doc Code";
                    Description := QCParameter_gRec.Description;
                    "Method Description" := QCParameter_gRec."Method Description";
                    "Unit of Measure Code" := QCParameter_gRec."Unit of Measure Code";
                    "Item Code" := QCParameter_gRec."Item Code";//T12113-ABA
                    "Item Description" := QCParameter_gRec."Item Description";//T12113-ABA
                    "Rounding Precision" := QCParameter_gRec."Rounding Precision";//T51170-N
                    "Decimal Places" := QCParameter_gRec."Decimal Places";//T52614-N

                end;
                //I-C0009-1001310-01 NE
            end;
        }

        modify("Standard Task Code")
        {


            trigger OnAfterValidate()
            var
                StdTask_lRec: Record "Standard Task";
            begin
                //I-C0009-1001310-01 NS
                if StdTask_lRec.Get("Standard Task Code") then
                    "Standard Task Description" := StdTask_lRec.Description;
                //I-C0009-1001310-01 NE
            end;
        }

        modify("Item Code")
        {

            trigger OnAfterValidate()
            var
                myInt: Integer;
                item_lRec: Record Item;
            begin
                if rec."Item Code" <> xRec."Item Code" then
                    CheckStatus1_lFnc();

                if item_lRec.Get("Item Code") then
                    "Item Description" := item_lRec.Description;
            end;

        }

        modify("Rounding Precision")
        {

            trigger OnAfterValidate()
            var
                Text027: Label 'must be greater than 0.', Comment = 'starts with "Rounding Precision"';//T51170
            begin
                if "Rounding Precision" < 0 then
                    FieldError("Rounding Precision", Text027);

                //T52614-NS
                // if Rec."Rounding Precision" <> 0 then
                if Rec."Rounding Precision" <> xRec."Rounding Precision" then
                    Rec."Decimal Places" := 0;
                // Rec.Validate("Decimal Places");
                //T52614-NE
            end;
        }
        //

        modify("Decimal Places")
        {

            //T52614-NS
            trigger OnAfterValidate()
            var
                DecimalPlaces_lInt: Integer;
                String_lTxt: Text;
                Position_lInt: Integer;
                StringLen_lInt: Integer;
            begin
                //if "Decimal Places" <> 0 then begin
                Rec.TestField("Rounding Precision");
                if StrPos(Format(Rec."Rounding Precision"), '.') > 0 then begin
                    String_lTxt := Format(Rec."Rounding Precision");
                    Position_lInt := StrPos(Format(Rec."Rounding Precision"), '.');
                    StringLen_lInt := StrLen(Format(Rec."Rounding Precision"));
                    DecimalPlaces_lInt := StrLen(CopyStr(String_lTxt, Position_lInt + 1, StringLen_lInt));
                    // DecimalPlaces_lInt := StrLen(CopyStr(Format(Rec."Rounding Precision"), StrPos(Format(Rec."Rounding Precision"), '.') + 1, StrLen(Format(Rec."Rounding Precision"))));
                    if Rec."Decimal Places" < DecimalPlaces_lInt then
                        Error('One must enter decimal places greater than or equal to %1 for %2', DecimalPlaces_lInt, Rec."Quality Parameter Code");
                end else begin
                    if Rec."Decimal Places" > 0 then
                        Error('Decimal place must be 0 for %1.', Rec."Quality Parameter Code");
                end;
                //end;
            end;
            //T52614-NE
        }

    }

    keys
    {

    }

    fieldgroups
    {
    }

    trigger OnBeforeDelete()
    begin
        TestStatus_lFnc; //I-C0009-1001310-01 N
    end;

    trigger OnBeforeInsert()
    begin
        //I-C0009-1001310-01 NS
        TestField("Quality Parameter Code");
        TestStatus_lFnc;
        //I-C0009-1001310-01 NE
    end;

    trigger OnBeforeModify()
    begin
        //I-C0009-1001310-01 NS
        QCSpecificationHeader_gRec.Reset;
        QCSpecificationHeader_gRec.SetRange("No.", "Item Specifiction Code");
        if QCSpecificationHeader_gRec.FindFirst then begin
            if (QCSpecificationHeader_gRec.Status = QCSpecificationHeader_gRec.Status::Certified) or
               (QCSpecificationHeader_gRec.Status = QCSpecificationHeader_gRec.Status::Closed)
            then
                QCSpecificationHeader_gRec.FieldError(Status);
        end;
        //I-C0009-1001310-01 NE
    end;

    trigger OnBeforeRename()
    begin
        //I-C0009-1001310-01 NS
        TestField(Method);
        TestStatus_lFnc;
        //I-C0009-1001310-01 NE
    end;

    var
        ItemDesc: Record Item;
        flag: Boolean;
        InteractTmplLanguage: Record "Interaction Tmpl. Language";
        Attach: Record Attachment;
        QCParameter_gRec: Record "QC Parameters";
        QCSpecificationHeader_gRec: Record "QC Specification Header";
        Text0001_gCtx: label '%1 must be blank.';
        tmpline: Record "QC Specification Line";
        QCGeneral_gCdu: Codeunit "Quality Control - General"; //T51170-N       

    procedure TestStatus_lFnc()
    begin
        //I-C0009-1001310-01 NS
        QCSpecificationHeader_gRec.Reset;
        QCSpecificationHeader_gRec.SetRange("No.", "Item Specifiction Code");
        if QCSpecificationHeader_gRec.FindFirst then begin
            if QCSpecificationHeader_gRec.Status = QCSpecificationHeader_gRec.Status::Certified then
                QCSpecificationHeader_gRec.FieldError(Status);
        end;
        //I-C0009-1001310-01 NE
    end;

    procedure CheckStatus1_lFnc()//T12113-ABA-N
    begin

        QCSpecificationHeader_gRec.Reset;
        QCSpecificationHeader_gRec.SetRange("No.", "Item Specifiction Code");
        if QCSpecificationHeader_gRec.FindFirst then begin
            if (QCSpecificationHeader_gRec.Status = QCSpecificationHeader_gRec.Status::Certified) or
            (QCSpecificationHeader_gRec.Status = QCSpecificationHeader_gRec.Status::Closed) then
                QCSpecificationHeader_gRec.FieldError(Status);
        end;

    end;
}

