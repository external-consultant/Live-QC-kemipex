tableextension 75432 QCParametersExt extends "QC Parameters"
{


    LookupPageID = "QC Parameters List";

    fields
    {

        modify(Description)
        {

            trigger OnBeforeValidate()
            var
                QCSetup_lRec: Record "Quality Control Setup";
            begin
                //I-C0009-1001310-01 NS
                QCSetup_lRec.Get;
                if ("Doc Code" = '') then begin
                    QCSetup_lRec.TestField("Word Doc Nos.");
                    // NoSeriesMgt.InitSeries(QCSetup_lRec."Word Doc Nos.", xRec."No Series", 0D, "Doc Code", "No Series");
                    "Doc Code" := NoSeriesMgt.GetNextNo(QCSetup_lRec."Word Doc Nos.", Today, true);//12092024
                end;
                //I-C0009-1001310-01 NE
            end;
        }

        modify("Item Code")
        {

            trigger OnBeforeValidate()
            var
                Item_lRec: Record Item;
            begin
                if Item_lRec.Get("Item Code") then
                    "Item Description" := Item_lRec.Description;
            end;
        }

        modify("Rounding Precision")
        {

            trigger OnBeforeValidate()
            begin
                // if "Rounding Precision" <= 0 then
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
        modify("Decimal Places")
        {

            trigger OnBeforeValidate()
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
                        Error('One must enter decimal places greater than or equal to %1 for %2', DecimalPlaces_lInt, Rec.Code);
                end else begin
                    if Rec."Decimal Places" > 0 then
                        Error('Decimal place must be 0 for %1.', Rec.Code);
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

    trigger OnAfterDelete()
    var
        QCSpecificationLine_lRec: Record "QC Specification Line";
    begin
        QCSpecificationLine_lRec.Reset;
        QCSpecificationLine_lRec.SetRange("Quality Parameter Code", Code);
        if QCSpecificationLine_lRec.FindFirst then
            Error('You cannot delete the QC Parameter %1 as there is one or more QC Specification (%2) created', Code, QCSpecificationLine_lRec."Item Specifiction Code");

        //I-C0009-1001310-01 NS
        InteractTmplLanguage_gRec.SetRange("Interaction Template Code", "Doc Code");
        if InteractTmplLanguage_gRec.FindFirst then
            InteractTmplLanguage_gRec.Delete;

        Attach_gRec.SetRange("No.", "Word Doc");
        if Attach_gRec.FindFirst then
            Attach_gRec.Delete;
        //I-C0009-1001310-01 NE
    end;

    var
        QCPar: Record "QC Parameters";
        NoSeriesMgt: Codeunit "No. Series";//12092024
        InteractTmplLanguage_gRec: Record "Interaction Tmpl. Language";
        Attach_gRec: Record Attachment;
        Text027: Label 'must be greater than 0.', Comment = 'starts with "Rounding Precision"';//T51170
}

