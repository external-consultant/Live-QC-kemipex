tableextension 75431 QCLineDetailext extends "QC Line Detail"


{


    fields
    {

        modify("Rejected Qty.")
        {

            trigger OnBeforeValidate()
            begin
                if "Rejected Qty." <> 0 then
                    Rejection := true
                else
                    Rejection := false;
            end;
        }
        modify(Rejection)
        {

            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                if Rejection = false then
                    "Rejected Qty." := 0;
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

    trigger OnBeforeInsert()
    var
        QCLineDetail_lRec: Record "QC Line Detail";
    begin
        //I-C0009-1001310-02 NS
        TestField("Quality Parameter Code");
        if "Line No." = 0 then begin
            QCLineDetail_lRec.Reset;
            QCLineDetail_lRec.SetRange("QC Rcpt No.", "QC Rcpt No.");
            QCLineDetail_lRec.SetRange("QC Rcpt Line No.", "QC Rcpt Line No.");
            if QCLineDetail_lRec.FindLast then
                "Line No." := QCLineDetail_lRec."Line No." + 10000
            else
                "Line No." := 10000;
        end;
        //I-C0009-1001310-02 NE
    end;

    var
        QCParameter_gRec: Record "QC Parameters";
        Text0001_gCtx: label 'QC Receipt No and Serial Number and Lot No. must be there to create QC Line Details.';
        Text50000_gCtx: label 'Actual Value must be in range of %1 to %2';
        Text50001_gCtx: label 'Actual Value must be less than %1';
        Text50002_gCtx: label 'Actual Value must be greater than %1';
        Text50003_gCtx: label 'Actual Value is not within the defined parameters. \Do you still want to proceed?';

    procedure CopyQCLine_gFnc(QCRcptNo_iCod: Code[20]; LotNo_iCod: Code[50]; SerialNo_iCod: Code[50])
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineDetail2_lRec: Record "QC Line Detail";
    begin
        if (QCRcptNo_iCod = '') and (SerialNo_iCod = '') and (LotNo_iCod = '') then
            Error(Text0001_gCtx);

        //I-C0009-1400405-02-NS
        QCLineDetail_lRec.Reset;
        QCLineDetail_lRec.SetRange(QCLineDetail_lRec."QC Rcpt No.", QCRcptNo_iCod);
        QCLineDetail_lRec.SetRange(QCLineDetail_lRec."Serial No.", SerialNo_iCod);
        if not QCLineDetail_lRec.FindFirst then begin
            //I-C0009-1400405-02-NE
            QCRcptLine_lRec.Reset;
            QCRcptLine_lRec.SetRange("No.", QCRcptNo_iCod);
            if QCRcptLine_lRec.FindSet then begin
                repeat
                    QCLineDetail_lRec.Init;
                    QCLineDetail_lRec."QC Rcpt No." := QCRcptNo_iCod;
                    QCLineDetail_lRec."QC Rcpt Line No." := QCRcptLine_lRec."Line No.";
                    QCLineDetail2_lRec.Reset;
                    QCLineDetail2_lRec.SetRange("QC Rcpt No.", QCLineDetail_lRec."QC Rcpt No.");
                    QCLineDetail2_lRec.SetRange("QC Rcpt Line No.", QCLineDetail_lRec."QC Rcpt Line No.");
                    if QCLineDetail2_lRec.FindLast then
                        QCLineDetail_lRec."Line No." := QCLineDetail2_lRec."Line No." + 10000
                    else
                        QCLineDetail_lRec."Line No." := 10000; //I-C0009-1400405-02-N
                    QCLineDetail_lRec."Unit of Measure Code" := QCRcptLine_lRec."Unit of Measure Code";
                    QCLineDetail_lRec.Type := QCRcptLine_lRec.Type;
                    QCLineDetail_lRec."Min.Value" := QCRcptLine_lRec."Min.Value";
                    QCLineDetail_lRec."Max.Value" := QCRcptLine_lRec."Max.Value";
                    QCLineDetail_lRec."Method Description" := QCRcptLine_lRec."Method Description";
                    QCLineDetail_lRec."Text Value" := QCRcptLine_lRec."Text Value";
                    QCLineDetail_lRec."Quality Parameter Code" := QCRcptLine_lRec."Quality Parameter Code";
                    QCLineDetail_lRec.Description := QCRcptLine_lRec.Description;
                    QCLineDetail_lRec."Lot No." := LotNo_iCod;
                    QCLineDetail_lRec."Serial No." := SerialNo_iCod;
                    QCRcptLine_lRec.CalcFields(Method);
                    QCLineDetail_lRec.Method := QCRcptLine_lRec.Method;
                    QCLineDetail_lRec.Insert;
                until QCRcptLine_lRec.Next = 0;
            end;
        end; //I-C0009-1400405-02-N
    end;
}

