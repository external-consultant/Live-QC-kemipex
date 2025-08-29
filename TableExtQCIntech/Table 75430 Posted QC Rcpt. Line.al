
tableextension 75430 PostedQCExtrecpLine extends "Posted QC Rcpt. Line"
{




    fields
    {
        modify(Type)
        {


            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                Mandatory := true;
                if (Type = Type::Minimum) then begin
                    "Max.Value" := 0;
                    "Text Value" := ''
                end else
                    if (Type = Type::Maximum) then begin
                        "Min.Value" := 0;
                        "Text Value" := '';
                        //end else
                        //  if (Type = Type::"4") then begin
                        //    "Min.Value" := 0;
                        //  "Max.Value" := 0;
                        // "Text Value" := '';
                        //Mandatory := false;
                    end else
                        if (Type = Type::Range) then begin
                            "Text Value" := '';
                        end else
                            if (Type = Type::Text) then begin
                                "Min.Value" := 0;
                                "Max.Value" := 0;
                            end;
                //I-C0009-1001310-02 NE
            end;
        }
        modify("Quality Parameter Code")
        {


            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                QCParameter_gRec.Reset;
                if QCParameter_gRec.Get("Quality Parameter Code") then begin
                    Description := QCParameter_gRec.Description;
                    "Method Description" := QCParameter_gRec."Method Description";
                    "Unit of Measure Code" := QCParameter_gRec."Unit of Measure Code";
                end;
                //I-C0009-1001310-02 NE
            end;
        }

    }

    keys
    {

    }

    fieldgroups
    {
    }

    trigger OnAfterDelete()
    begin
        //I-C0009-1001310-02 NS
        UID := UserId;
        PostedQCHead_gRec.Reset;
        PostedQCHead_gRec.SetRange("No.", "No.");
        if not (PostedQCHead_gRec.FindFirst and (UID = PostedQCHead_gRec."Approved By")) then
            Error(Text0001_gCtx);
        //I-C0009-1001310-02 NE
    end;

    var
        QCPara: Record "QC Parameters";
        UID: Code[20];
        PostedQCHead_gRec: Record "Posted QC Rcpt. Header";
        QCParameter_gRec: Record "QC Parameters";
        Text0001_gCtx: label 'Name mentioned in ''''Approved By:'''' only can delete this line.';

    procedure ShowQCDetails_gFnc()
    var
        QCLineDetails_lRec: Record "QC Line Detail";
        PostedQCRcpt_lRec: Record "Posted QC Rcpt. Header";
        QCLineDetails_lPge: Page "QC Line Details";
    begin
        //Function written to Show created QC Receipt.
        //I-C0009-1001310-02 NS
        PostedQCRcpt_lRec.Get("No.");
        QCLineDetails_lRec.Reset;
        QCLineDetails_lRec.SetRange("QC Rcpt No.", PostedQCRcpt_lRec."PreAssigned No.");
        QCLineDetails_lRec.SetRange("QC Rcpt Line No.", "Line No.");
        QCLineDetails_lPge.Editable(false);
        QCLineDetails_lPge.SetTableview(QCLineDetails_lRec);
        QCLineDetails_lPge.RunModal;
        //I-C0009-1001310-02 NE
    end;

    //T52614-NS
    procedure CheckDecimalPlace_lFnc(PostedQcRcptLine_iRec: Record "Posted QC Rcpt. Line")
    var
        DecimalPlaces_lInt: Integer;
        String_lTxt: Text;
        Position_lInt: Integer;
        StringLen_lInt: Integer;
    begin
        DecimalPlaces_lInt := 0;
        String_lTxt := '';
        Position_lInt := 0;
        StringLen_lInt := 0;
        PostedQcRcptLine_iRec.TestField("Rounding Precision");
        if StrPos(Format(PostedQcRcptLine_iRec."Rounding Precision"), '.') > 0 then begin
            String_lTxt := Format(PostedQcRcptLine_iRec."Rounding Precision");
            Position_lInt := StrPos(Format(PostedQcRcptLine_iRec."Rounding Precision"), '.');
            StringLen_lInt := StrLen(Format(PostedQcRcptLine_iRec."Rounding Precision"));
            DecimalPlaces_lInt := StrLen(CopyStr(String_lTxt, Position_lInt + 1, StringLen_lInt));
            if PostedQcRcptLine_iRec."Decimal Places" < DecimalPlaces_lInt then
                Error('One must enter decimal places greater than or equal to %1 for %2 which has QC Receipt No. %3 and Line No. %4.', DecimalPlaces_lInt, PostedQcRcptLine_iRec."Quality Parameter Code", PostedQcRcptLine_iRec."No.", PostedQcRcptLine_iRec."Line No.");
        end else begin
            if PostedQcRcptLine_iRec."Decimal Places" > 0 then
                Error('Decimal place must be 0 for %1 which has QC Receipt No. %2 and Line No. %3.', PostedQcRcptLine_iRec."Quality Parameter Code", PostedQcRcptLine_iRec."No.", PostedQcRcptLine_iRec."Line No.");
        end;
    end;
    //T52614-NE
}

