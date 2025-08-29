Codeunit 75381 "Quality Control - General"
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


    trigger OnRun()
    begin
    end;

    var
        Text0001_gCtx: label '%1 on %2 %3 must not be %4.';
        Text0002_gCtx: label 'The %1 cannot be copied to itself.';

    procedure CopyQCSpecification_gRec(QCSpecification_gCod: Code[20]; CurrentQCSpecification_gRec: Record "QC Specification Header")
    var
        FromProdBOMComponent: Record "Production BOM Line";
        ToProdBOMComponent: Record "Production BOM Line";
        FromProdBOMCompComment: Record "Production BOM Comment Line";
        ToProdBOMCompComment: Record "Production BOM Comment Line";
        ProdBomVersion: Record "Production BOM Version";
        ToQCSpecificationLine_gRec: Record "QC Specification Line";
        FromQCSpecificationLine_gRec: Record "QC Specification Line";
    begin
        if CurrentQCSpecification_gRec."No." = QCSpecification_gCod then
            Error(Text0002_gCtx, CurrentQCSpecification_gRec.TableCaption);

        if CurrentQCSpecification_gRec.Status = CurrentQCSpecification_gRec.Status::Certified then
            Error(
              Text0001_gCtx,
              CurrentQCSpecification_gRec.FieldCaption(Status),
              CurrentQCSpecification_gRec.TableCaption,
              CurrentQCSpecification_gRec."No.",
              CurrentQCSpecification_gRec.Status);

        ToQCSpecificationLine_gRec.SetRange("Item Specifiction Code", CurrentQCSpecification_gRec."No.");
        ToQCSpecificationLine_gRec.DeleteAll;

        FromQCSpecificationLine_gRec.SetRange("Item Specifiction Code", QCSpecification_gCod);


        if FromQCSpecificationLine_gRec.FindFirst then
            repeat
                ToQCSpecificationLine_gRec := FromQCSpecificationLine_gRec;
                ToQCSpecificationLine_gRec."Item Specifiction Code" := CurrentQCSpecification_gRec."No.";
                ToQCSpecificationLine_gRec.Insert;
            until FromQCSpecificationLine_gRec.Next = 0;
    end;

    procedure GetLocationFilter_lFnc(ItemNo_iCod: Code[20]; LocationFilter_iTxt: Text[1000]): Text[1000]
    var
        FinalLocationFilter_lTxt: Text[1000];
        Location_lRec: Record Location;
        Item_lRec: Record Item;
        ReqLine_lRec: Record "Requisition Line";
        IncludeLoc_lBln: Boolean;
    begin
        //I-C0009-1001310-04-NS
        Item_lRec.Get(ItemNo_iCod);
        Location_lRec.SetFilter("Main Location", LocationFilter_iTxt);
        if Location_lRec.FindSet() then begin
            repeat
                IncludeLoc_lBln := false;
                Item_lRec.SetRange("Location Filter", Location_lRec.Code);
                Item_lRec.CalcFields(Inventory, "Qty. on Purch. Order", "Planning Receipt (Qty.)");
                if (Item_lRec.Inventory <> 0) or (Item_lRec."Qty. on Purch. Order" <> 0) or (Item_lRec."Planning Receipt (Qty.)" <> 0) then
                    IncludeLoc_lBln := true;

                if IncludeLoc_lBln then
                    FinalLocationFilter_lTxt += Location_lRec.Code + '|';
            until Location_lRec.Next = 0;
        end;

        if FinalLocationFilter_lTxt <> '' then
            FinalLocationFilter_lTxt := CopyStr(FinalLocationFilter_lTxt, 1, StrLen(FinalLocationFilter_lTxt) - 1);

        exit(FinalLocationFilter_lTxt);
        //I-C0009-1001310-04-NE
    end;

    procedure CheckLocQCReject_gFnc(LocationCode_iCod: Code[20]): Boolean
    var
        Location_lRec: Record Location;
    begin
        //QCV2-NS
        if LocationCode_iCod = '' then
            exit(false);

        Location_lRec.Reset;
        Location_lRec.SetRange("QC Location", LocationCode_iCod);
        if not Location_lRec.IsEmpty then
            exit(true);

        Location_lRec.Reset;
        Location_lRec.SetRange("Rejection Location", LocationCode_iCod);
        if not Location_lRec.IsEmpty then
            exit(true);

        Location_lRec.Reset;
        Location_lRec.SetRange("Rework Location", LocationCode_iCod);
        if not Location_lRec.IsEmpty then
            exit(true);

        Location_lRec.Get(LocationCode_iCod);
        //if Location_lRec."Subcontracting Location" then
        //exit(true);

        Location_lRec.Get(LocationCode_iCod);
        if Location_lRec."Use As In-Transit" then
            exit(true);

        exit(false);
        //QCV2-NE
    end;

    procedure CheckQCRejectLocation_gFnc(LocationCode_iCod: Code[20]): Boolean
    var
        Location_lRec: Record Location;
    begin
        //NG-NS T3367
        if LocationCode_iCod = '' then
            exit(false);

        Location_lRec.Reset;
        Location_lRec.SetRange("QC Location", LocationCode_iCod);
        if not Location_lRec.IsEmpty then
            exit(true);

        Location_lRec.Reset;
        Location_lRec.SetRange("Rejection Location", LocationCode_iCod);
        if not Location_lRec.IsEmpty then
            exit(true);

        Location_lRec.Reset;
        Location_lRec.SetRange("Rework Location", LocationCode_iCod);
        if not Location_lRec.IsEmpty then
            exit(true);

        exit(false);
        //NG-NE T3367
    end;

    procedure CheckOnlyQCLocation_gFnc(LocationCode_iCod: Code[20]): Boolean
    var
        Location_lRec: Record Location;
    begin
        //NG-NS T3367
        if LocationCode_iCod = '' then
            exit(false);

        Location_lRec.Reset;
        Location_lRec.SetRange("QC Location", LocationCode_iCod);
        if not Location_lRec.IsEmpty then
            exit(true);
        //NG-NE T3367
    end;

    procedure CalculateAverge_gFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header")
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineCnt_lInt: Integer;
        ActualValue_gDec: Decimal;
        RejectedQty_gDec: Decimal;
        Rejected_lBln: Boolean;
        Item_lRec: Record Item;
    begin
        //QCV3-NS 24-01-18

        if QCRcptHeader_iRec."Document Type" = QCRcptHeader_iRec."document type"::Production then
            exit;

        Clear(Item_lRec);
        Item_lRec.Get(QCRcptHeader_iRec."Item No.");
        //Item_lRec.TESTFIELD("Entry for each Sample",TRUE);

        QCRcptLine_lRec.Reset;
        QCRcptLine_lRec.SetRange("No.", QCRcptHeader_iRec."No.");
        if QCRcptLine_lRec.FindSet then begin
            repeat
                RejectedQty_gDec := 0;
                ActualValue_gDec := 0;
                QCLineCnt_lInt := 0;
                Rejected_lBln := false;
                if QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Text then begin
                    QCLineDetail_lRec.Reset;
                    QCLineDetail_lRec.SetRange("QC Rcpt No.", QCRcptHeader_iRec."No.");
                    QCLineDetail_lRec.SetRange("QC Rcpt Line No.", QCRcptLine_lRec."Line No.");
                    //QCLineDetail_lRec.SETRANGE("Quality Parameter Code",QCRcptLine_lRec."Quality Parameter Code");
                    if QCLineDetail_lRec.FindSet then begin
                        repeat
                            QCLineDetail_lRec.TestField("Actual Text");
                            QCLineCnt_lInt := QCLineCnt_lInt + 1;
                            RejectedQty_gDec := RejectedQty_gDec + QCLineDetail_lRec."Rejected Qty.";
                            if QCLineDetail_lRec."Rejected Qty." <> 0 then
                                Rejected_lBln := true;
                        until QCLineDetail_lRec.Next = 0;
                        if QCLineCnt_lInt <> 0 then begin
                            QCRcptLine_lRec.Validate(Rejection, Rejected_lBln);
                            QCRcptLine_lRec."Rejected Qty." := (RejectedQty_gDec);
                            if QCRcptLine_lRec.Rejection then
                                QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Fail
                            else
                                QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Pass;
                            QCRcptLine_lRec.Modify(true);
                        end;
                    end;
                    /*
                    END ELSE IF QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Maximum THEN BEGIN
                      QCLineDetail_lRec.RESET;
                      QCLineDetail_lRec.SETRANGE("QC Rcpt No.","No.");
                      QCLineDetail_lRec.SETRANGE("QC Rcpt Line No.",QCRcptLine_lRec."Line No.");
                      //QCLineDetail_lRec.SETRANGE("Quality Parameter Code",QCRcptLine_lRec."Quality Parameter Code");
                      IF QCLineDetail_lRec.FINDFIRST THEN BEGIN
                        QCRcptLine_lRec."Actual Text" := QCLineDetail_lRec."Actual Text";
                        QCRcptLine_lRec.VALIDATE(Rejection,QCLineDetail_lRec.Rejection);
                        QCRcptLine_lRec."Rejected Qty." := QCLineDetail_lRec."Rejected Qty.";
                        IF QCLineDetail_lRec.Rejection THEN
                          QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Fail
                        ELSE
                          QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Pass;
                      END;
                    END ELSE IF QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Minimum THEN BEGIN
                      QCLineDetail_lRec.RESET;
                      QCLineDetail_lRec.SETRANGE("QC Rcpt No.","No.");
                      QCLineDetail_lRec.SETRANGE("QC Rcpt Line No.",QCRcptLine_lRec."Line No.");
                      //QCLineDetail_lRec.SETRANGE("Quality Parameter Code",QCRcptLine_lRec."Quality Parameter Code");
                      IF QCLineDetail_lRec.FINDSET THEN BEGIN
                        REPEAT
                          QCRcptLine_lRec."Actual Text" := QCLineDetail_lRec."Actual Text";
                          QCRcptLine_lRec.VALIDATE(Rejection,QCLineDetail_lRec.Rejection);
                          QCRcptLine_lRec."Rejected Qty." := QCLineDetail_lRec."Rejected Qty.";
                          IF QCLineDetail_lRec.Rejection THEN
                            QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Fail
                          ELSE
                            QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Pass;
                        UNTIL QCRcptLine_lRec.NEXT = 0;
                      END;
                    */
                end else
                    if (QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Range) or (QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Minimum) or (QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Maximum) then begin
                        ActualValue_gDec := 0;
                        QCLineCnt_lInt := 0;
                        RejectedQty_gDec := 0;
                        Rejected_lBln := false;
                        QCLineDetail_lRec.Reset;
                        QCLineDetail_lRec.SetRange("QC Rcpt No.", QCRcptHeader_iRec."No.");
                        QCLineDetail_lRec.SetRange("QC Rcpt Line No.", QCRcptLine_lRec."Line No.");
                        //QCLineDetail_lRec.SETRANGE("Quality Parameter Code",QCRcptLine_lRec."Quality Parameter Code");
                        if QCLineDetail_lRec.FindSet then begin
                            repeat
                                QCLineDetail_lRec.TestField("Actual Value");
                                ActualValue_gDec := ActualValue_gDec + QCLineDetail_lRec."Actual Value";
                                QCLineCnt_lInt := QCLineCnt_lInt + 1;
                                RejectedQty_gDec := RejectedQty_gDec + QCLineDetail_lRec."Rejected Qty.";
                                if QCLineDetail_lRec."Rejected Qty." <> 0 then
                                    Rejected_lBln := true;
                            until QCLineDetail_lRec.Next = 0;
                        end;
                        if QCLineCnt_lInt <> 0 then begin
                            QCRcptLine_lRec."Actual Value" := (ActualValue_gDec / QCLineCnt_lInt);
                            QCRcptLine_lRec.Validate(Rejection, Rejected_lBln);
                            QCRcptLine_lRec."Rejected Qty." := (RejectedQty_gDec);
                            if QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Range then begin
                                if (QCRcptLine_lRec."Actual Value" < QCRcptLine_lRec."Min.Value") or (QCRcptLine_lRec."Actual Value" > QCRcptLine_lRec."Max.Value") then
                                    QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Fail
                                else
                                    QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Pass;
                            end else
                                if QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Minimum then begin
                                    if (QCRcptLine_lRec."Actual Value" < QCRcptLine_lRec."Min.Value") then
                                        QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Fail
                                    else
                                        QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Pass;
                                end else
                                    if QCRcptLine_lRec.Type = QCRcptLine_lRec.Type::Maximum then begin
                                        if (QCRcptLine_lRec."Actual Value" > QCRcptLine_lRec."Max.Value") then
                                            QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Fail
                                        else
                                            QCRcptLine_lRec.Result := QCRcptLine_lRec.Result::Pass;
                                    end;
                            QCRcptLine_lRec.Modify(true);
                        end;
                    end;

            until QCRcptLine_lRec.Next = 0;
        end;
        //QCV3-NE 24-01-18
    end;

    procedure CalculateAvergeNew_gFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header")
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineCnt_lInt: Integer;
        ActualValue_gDec: Decimal;
        RejectedQty_gDec: Decimal;
        Rejected_lBln: Boolean;
        Item_lRec: Record Item;
        AvgCalculatedMsg: Label 'Average value has been calculated for QC Rcpt Line Parameters';
    begin

        //QCRcptHeader_iRec.TestField(Approve, true);

        QCRcptLine_lRec.Reset();
        QCRcptLine_lRec.SetRange("No.", QCRcptHeader_iRec."No.");
        QCRcptLine_lRec.SetFilter(Type, '<>%1', QCRcptLine_lRec.Type::Text);
        IF QCRcptLine_lRec.FindSet() then begin
            repeat
                QCLineDetail_lRec.Reset();
                QCLineDetail_lRec.SetRange("QC Rcpt No.", QCRcptHeader_iRec."No.");
                QCLineDetail_lRec.SetRange("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");
                QCLineDetail_lRec.CalcSums("Actual Value");
                QCRcptLine_lRec."Actual Value" := QCLineDetail_lRec."Actual Value" / QCLineDetail_lRec.Count;
                QCRcptLine_lRec.Modify();

            until QCRcptLine_lRec.Next() = 0;
        end;
        Message(AvgCalculatedMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean);
    begin
        IF ItemJournalLine."Skip Confirm Msg" then begin
            HideDialog := true;
            SuppressCommit := true;
        end;
    end;

    //T51170-NS
    procedure RoundQCParameterPrecision(QCParameterCode_iCde: code[20]; RoundedValue_iDec: Decimal; RoundingPrecision_iDec: Decimal): Decimal
    var
        QCParameter_lRec: Record "QC Parameters";
        RoundingDirection: Text;
        RoundingPrecision: Decimal;
    begin
        if not QCParameter_lRec.GET(QCParameterCode_iCde) then
            exit;
        CASE QCParameter_lRec."Rounding Type" OF
            QCParameter_lRec."Rounding Type"::Nearest:
                RoundingDirection := '=';
            QCParameter_lRec."Rounding Type"::Up:
                RoundingDirection := '>';
            QCParameter_lRec."Rounding Type"::Down:
                RoundingDirection := '<';
        END;

        // IF QCParameter_lRec."Rounding Precision" <> 0 THEN
        //     RoundingPrecision := QCParameter_lRec."Rounding Precision"
        // ELSE
        //     RoundingPrecision := 0.01;
        // if RoundingPrecision_iDec <> RoundingPrecision then
        EXIT(ROUND(RoundedValue_iDec, RoundingPrecision_iDec, RoundingDirection));
    end;
    //T51170-NE

}

