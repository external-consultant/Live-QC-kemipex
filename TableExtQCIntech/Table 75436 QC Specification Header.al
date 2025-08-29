
tableextension 75436 ExtQCSpecificationHeader extends "QC Specification Header"
{



    LookupPageID = "QC Specification List"; //P_ISPL-SPLIT_Q2025

    fields
    {
        modify("No.")
        {

            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-02 NS
                if "No." <> xRec."No." then begin
                    QCSetup_gRec.Get;
                    NoSeriesMgt_gCdu.TestManual(QCSetup_gRec."QC Specification Nos.");
                    "No Series" := '';
                end;
                //I-C0009-1001310-02 NE
            end;
        }

        modify(Status)
        {


            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                if Status = Status::New then begin
                    "Prepared By" := UserId;
                    "Approved By" := '';
                end;
                if Status = Status::Certified then begin
                    QCSpecificationLine_gRec.Reset;
                    QCSpecificationLine_gRec.SetRange("Item Specifiction Code", "No.");
                    if QCSpecificationLine_gRec.FindFirst then begin
                        repeat
                            if ((QCSpecificationLine_gRec."Min.Value" = 0) and
                                (QCSpecificationLine_gRec."Max.Value" = 0) and
                                (QCSpecificationLine_gRec."COA Min.Value" = 0) and
                                (QCSpecificationLine_gRec."COA Max.Value" = 0) and
                                (QCSpecificationLine_gRec."Text Value" = ''))
                            then
                                Error(Text0001_gCtx, QCSpecificationLine_gRec."Line No.");

                            //T52614-NS
                            if QCSpecificationLine_gRec."Decimal Places" <> 0 then
                                QCSpecificationLine_gRec.Validate("Decimal Places");
                        //T52614-NE
                        until QCSpecificationLine_gRec.Next = 0;
                    end;
                    "Approved By" := UserId;
                    "Revision Date" := WorkDate;
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
        if Status = Status::Certified then
            FieldError(Status);

        QCSpecificationLine_gRec.Reset;
        QCSpecificationLine_gRec.SetRange("Item Specifiction Code", "No.");
        QCSpecificationLine_gRec.DeleteAll(true);
        //I-C0009-1001310-02 NE
    end;

    trigger OnAfterInsert()
    begin
        //I-C0009-1001310-01 NS
        if ("No." = '') then begin
            QCSetup_gRec.Get;
            QCSetup_gRec.TestField("QC Specification Nos.");
            // NoSeriesMgt_gCdu.InitSeries(QCSetup_gRec."QC Specification Nos.", xRec."No Series", 0D, "No.", "No Series");
            "No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."QC Specification Nos.", Today, true);//12092024
        end;

        Status := Status::New;
        "Prepared By" := UserId;
        //I-C0009-1001310-01 NE
    end;

    var
        QCSpecificationLine_gRec: Record "QC Specification Line";
        NoSeriesMgt_gCdu: Codeunit NoSeriesManagement;
        QCSetup_gRec: Record "Quality Control Setup";
        Text0001_gCtx: label 'Line No.%1 must have some specification value.';

    procedure AssistEdit(OldQCSpecHeader_iRec: Record "QC Specification Header") Bool: Boolean
    begin
        //I-C0009-1001310-02 NS
        QCSetup_gRec.Get;
        QCSetup_gRec.TestField("QC Specification Nos.");

        if NoSeriesMgt_gCdu.SelectSeries(QCSetup_gRec."QC Specification Nos.", OldQCSpecHeader_iRec."No Series", "No Series") then begin
            NoSeriesMgt_gCdu.SetSeries("No.");
            exit(true);
        end;
        //I-C0009-1001310-02 NE
    end;
}

