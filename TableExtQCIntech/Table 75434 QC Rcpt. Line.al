
tableextension 75434 QCExtrecptLine extends "QC Rcpt. Line"
{



    fields
    {

        modify(Rejection)
        {

            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-01 NS
                if Rejection = false then
                    "Rejected Qty." := 0;
                //I-C0009-1001310-01 NE
            end;
        }

        modify("Min.Value")
        {

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

        modify("Actual Value")
        {
            trigger OnAfterValidate()
            begin
                // QCV2-NS
                // Hypercare-18-03-25-N-OS
                if Type = Type::Range then begin
                    if ("Actual Value" <> 0) then begin
                        if ("Actual Value" < "Min.Value") or ("Actual Value" > "Max.Value") then begin
                            if not Confirm(Text50013_gCtx, false) then begin
                                Error(Text50010_gCtx, "Min.Value", "Max.Value")
                            end else begin
                                //VALIDATE(Rejection,TRUE);
                                //Validate(Result, Result::Fail); //T52538-OS
                                Validate("QC Status", "QC Status"::Fail); //T52538-NS
                            end;
                        end else begin
                            //VALIDATE(Rejection,FALSE);
                            //Validate(Result, Result::Pass); //T52538-OS
                            Validate("QC Status", "QC Status"::Pass); //T52538-NS
                        end;
                    end;
                end else
                    if (Type = Type::Maximum) then begin
                        if ("Actual Value" <> 0) then begin
                            if ("Actual Value" > "Max.Value") then begin
                                if not Confirm(Text50013_gCtx, false) then begin
                                    Error(Text50011_gCtx, "Max.Value")
                                end else begin
                                    //VALIDATE(Rejection,TRUE);
                                    //Validate(Result, Result::Fail); //T52538-OS
                                    Validate("QC Status", "QC Status"::Fail); //T52538-NS
                                end;
                            end else begin
                                //VALIDATE(Rejection,FALSE);
                                //Validate(Result, Result::Pass); //T52538-OS
                                Validate("QC Status", "QC Status"::Pass); //T52538-NS
                            end;
                        end;
                    end else
                        if (Type = Type::Minimum) then begin
                            if ("Actual Value" <> 0) then begin
                                if ("Actual Value" < "Min.Value") then begin
                                    if not Confirm(Text50013_gCtx, false) then begin
                                        Error(Text50012_gCtx, "Min.Value")
                                    end else begin
                                        //VALIDATE(Rejection,TRUE);
                                        //Validate(Result, Result::Fail);//T52538-OS
                                        Validate("QC Status", "QC Status"::Fail); //T52538-NS
                                    end;
                                end else begin
                                    //VALIDATE(Rejection,FALSE);
                                    //Validate(Result, Result::Pass);//T52538-OS
                                    Validate("QC Status", "QC Status"::Pass); //T52538-NS
                                end;
                            end;
                        end;
                // Hypercare - 18 - 03 - 25 - OE
                // QCV2 - NE
                // T51170 - NS

                if "Rounding Precision" > 0 then
                    "Actual Value" := QCGeneral_gCdu.RoundQCParameterPrecision("Quality Parameter Code", "Actual Value", "Rounding Precision");
                //T51170-NS

            end;
        }

        modify("Quality Parameter Code")
        {
            trigger OnAfterValidate()
            var
                QCSpecificationline_lRec: Record "QC Specification Line";
                myInt: Integer;
                Item_lRec: Record Item;
                QCRecptHdr_lRec: Record "QC Rcpt. Header";
            begin
                if CurrFieldNo = FieldNo(rec."Quality Parameter Code") then begin
                    QCRecptHdr_lRec.get(rec."No.");
                    If Item_lRec.get(QCRecptHdr_lRec."Item No.") then begin
                        if Item_lRec."Item Specification Code" <> '' then begin
                            QCSpecificationline_lRec.Reset();
                            QCSpecificationline_lRec.SetRange("Item Specifiction Code", Item_lRec."Item Specification Code");
                            QCSpecificationline_lRec.SetRange("Quality Parameter Code", "Quality Parameter Code");
                            QCSpecificationline_lRec.FindFirst();
                            Required := true;//T12544-N
                            Print := QCSpecificationLine_lRec.Print;  //T13242-N 03-01-2025
                            "Line No." := QCSpecificationLine_lRec."Line No.";
                            //"Quality Parameter Code" := QCSpecificationLine_lRec."Quality Parameter Code";
                            Description := QCSpecificationline_lRec.Description;
                            "Method Description" := QCSpecificationline_lRec."Method Description";
                            "Unit of Measure Code" := QCSpecificationLine_lRec."Unit of Measure Code";
                            Type := QCSpecificationLine_lRec.Type;
                            QCSpecificationLine_lRec.CalcFields(Method);
                            Method := QCSpecificationLine_lRec.Method;
                            "Min.Value" := QCSpecificationLine_lRec."Min.Value";
                            "COA Min.Value" := QCSpecificationLine_lRec."COA Min.Value";
                            "COA Max.Value" := QCSpecificationLine_lRec."COA Max.Value";
                            "Rounding Precision" := QCSpecificationLine_lRec."Rounding Precision";
                            "Decimal Places" := QCSpecificationLine_lRec."Decimal Places"; //T52614-N
                            "Show in COA" := QCSpecificationLine_lRec."Show in COA";
                            "Default Value" := QCSpecificationLine_lRec."Default Value";
                            "Max.Value" := QCSpecificationLine_lRec."Max.Value";
                            Code := QCSpecificationLine_lRec."Document Code";
                            Mandatory := QCSpecificationLine_lRec.Mandatory;
                            "Text Value" := QCSpecificationLine_lRec."Text Value";
                            "Item Code" := QCSpecificationLine_lRec."Item Code";
                            "Item Description" := QCSpecificationLine_lRec."Item Description";
                        end;
                    end;
                end;

            end;
        }
        modify("Rounding Precision")
        {

            trigger OnBeforeValidate()
            var
                Text027: Label 'must be greater than 0.', Comment = 'starts with "Rounding Precision"';//T51170
            begin
                if "Rounding Precision" <= 0 then
                    FieldError("Rounding Precision", Text027);
            end;
        }

        modify("Selected QC Parameter")
        {

            trigger OnBeforeValidate()
            var
                myInt: Integer;
            begin
                TestField("Item Code");
            end;
        }

        modify("Quantity to Rework")
        {


            trigger OnBeforeValidate()
            begin
                if QCReceipt_gRec.Get(rec."No.") then
                    QCReceipt_gRec.TestField("Document Type", QCReceipt_gRec."document type"::Production);


            end;
        }

        //T12543-NS
        modify("Vendor COA Value Result")
        {
            trigger OnBeforeValidate()
            begin
                //Hypercare-18-03-25-NS
                if Type = Type::Range then begin
                    if ("Vendor COA Value Result" <> 0) then begin
                        if ("Vendor COA Value Result" < "Min.Value") or ("Vendor COA Value Result" > "Max.Value") then begin
                            if not Confirm(Text50003_gCtx, false) then begin
                                Error(Text50000_gCtx, "Min.Value", "Max.Value")
                            end else begin
                                //VALIDATE(Rejection,TRUE);
                                Validate(Result, Result::Fail);
                            end;
                        end else begin
                            //VALIDATE(Rejection,FALSE);
                            Validate(Result, Result::Pass);
                        end;
                    end;
                end else
                    if (Type = Type::Maximum) then begin
                        if ("Vendor COA Value Result" <> 0) then begin
                            if ("Vendor COA Value Result" > "Max.Value") then begin
                                if not Confirm(Text50003_gCtx, false) then begin
                                    Error(Text50001_gCtx, "Max.Value")
                                end else begin
                                    //VALIDATE(Rejection,TRUE);
                                    Validate(Result, Result::Fail);
                                end;
                            end else begin
                                //VALIDATE(Rejection,FALSE);
                                Validate(Result, Result::Pass);
                            end;
                        end;
                    end else
                        if (Type = Type::Minimum) then begin
                            if ("Vendor COA Value Result" <> 0) then begin
                                if ("Vendor COA Value Result" < "Min.Value") then begin
                                    if not Confirm(Text50003_gCtx, false) then begin
                                        Error(Text50002_gCtx, "Min.Value")
                                    end else begin
                                        //VALIDATE(Rejection,TRUE);
                                        Validate(Result, Result::Fail);
                                    end;
                                end else begin
                                    //VALIDATE(Rejection,FALSE);
                                    Validate(Result, Result::Pass);
                                end;
                            end;
                        end;
                //Hypercare-18-03-25-NE
                //T51170-NS               
                if "Rounding Precision" > 0 then
                    "Vendor COA Value Result" := QCGeneral_gCdu.RoundQCParameterPrecision("Quality Parameter Code", "Vendor COA Value Result", "Rounding Precision");
                //T51170-NE
            end;
        }

        //T12543-NE

        //T13242-NS 03-01-2025


    }

    keys
    {

    }

    fieldgroups
    {
    }

    trigger OnAfterModify()
    begin
        //I-C0009-1001310-01 NS
        TestStatus;
        QCReceipt1_gRec.SetRange("No.", "No.");
        if QCReceipt1_gRec.Find('-') then
            QCReceipt1_gRec."Checked By" := UserId;
        QCReceipt1_gRec.Modify;
        //I-C0009-1001310-01 NE
    end;

    var
        QCReceipt_gRec: Record "QC Rcpt. Header";
        QCReceipt1_gRec: Record "QC Rcpt. Header";
        QCParameter_gRec: Record "QC Parameters";
        Text50000_gCtx: label 'Vendor COA Value must be in range of %1 to %2';
        Text50010_gCtx: label 'QC Value must be in range of %1 to %2';
        Text50001_gCtx: label 'Vendor COA Value must be less than %1';
        Text50011_gCtx: label 'QC Value must be less than %1';
        Text50002_gCtx: label 'Vendor COA Value Result must be greater than %1';
        Text50012_gCtx: label 'QC Value Result must be greater than %1';
        Text50003_gCtx: label 'Vendor COA Value is not within the defined parameters. \Do you still want to proceed?';
        Text50013_gCtx: label 'QC Value is not within the defined parameters. \Do you still want to proceed?';
        QCGeneral_gCdu: Codeunit "Quality Control - General";//T51170-N

    procedure TestStatus()
    begin
        //I-C0009-1001310-01 NS
        QCReceipt_gRec.SetRange("No.", "No.");
        if QCReceipt_gRec.FindFirst then begin
            if QCReceipt_gRec.Approve then
                QCReceipt_gRec.FieldError(Approve);
            QCReceipt_gRec.TestField("Approval Status", QCReceipt_gRec."approval status"::Open);  //QCApproval-N
        end;
        //I-C0009-1001310-01 NE
    end;

    procedure ShowQCDetails_gFnc()
    var
        QCLineDetails_lRec: Record "QC Line Detail";
        QCLineDetails_lPge: Page "QC Line Detail List";
        Cnt_lDec: Decimal;
        TotalValue_lDec: Decimal;
    begin
        //Written Function to show Created QC Receipts.
        //I-C0009-1001310-01 NS
        QCLineDetails_lRec.Reset;
        QCLineDetails_lRec.SetRange("QC Rcpt No.", "No.");
        QCLineDetails_lRec.SetRange("QC Rcpt Line No.", "Line No.");
        QCLineDetails_lPge.SetTableview(QCLineDetails_lRec);
        QCLineDetails_lPge.RunModal;


        if Type = Type::Text then begin
            if "Actual Text" = '' then begin
                QCLineDetails_lRec.Reset;
                QCLineDetails_lRec.SetRange("QC Rcpt No.", "No.");
                QCLineDetails_lRec.SetRange("QC Rcpt Line No.", "Line No.");
                QCLineDetails_lRec.SetFilter("Actual Text", '<>%1', '');
                if QCLineDetails_lRec.FindFirst then begin
                    "Actual Text" := QCLineDetails_lRec."Actual Text";
                    Modify;
                end;
            end;
        end else begin
            if "Actual Value" = 0 then begin
                QCLineDetails_lRec.Reset;
                QCLineDetails_lRec.SetRange("QC Rcpt No.", "No.");
                QCLineDetails_lRec.SetRange("QC Rcpt Line No.", "Line No.");
                if QCLineDetails_lRec.FindSet then begin
                    repeat
                        Cnt_lDec += 1;
                        TotalValue_lDec += QCLineDetails_lRec."Actual Value";
                    until QCLineDetails_lRec.Next = 0;

                    if Cnt_lDec <> 0 then begin
                        "Actual Value" := TotalValue_lDec / Cnt_lDec;
                        Modify;
                    end;

                end;
            end;
        end;

        //I-C0009-1001310-01 NE
    end;
}

