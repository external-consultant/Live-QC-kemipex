Codeunit 75385 "Quality Control -Transfer Rcpt"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-06     31/10/14    Chintan Panchal
    //                        QC Module - Redesign Released(Transfer Receipt QC).
    // I-C0009-1001310-08     29/11/14    Chintan Panchal
    //                        QC Enhancement.
    // ------------------------------------------------------------------------------------------------------------------------------

    Permissions = TableData "Item Ledger Entry" = rm,
                  TableData "Transfer Receipt Line" = rm;

    trigger OnRun()
    begin
    end;

    var
        TransferRcptLine_gRec: Record "Transfer Receipt Line";
        ItemLdgrEntry_gRec: Record "Item Ledger Entry";
        Text0000_gCtx: label 'Do you want to create QC Receipt for \ Transfer Receipt = ''%1'', Line No. = ''%2'' ?';
        Text0001_gCtx: label 'QC Receipt = ''%1'' is created for \ Transfer Receipt = ''%2'', Line No. = ''%3'' sucessfully.';
        Text0002_gCtx: label 'Sum of "Under Inspection Quantity","Accepted Quantity","Accepted Quantity with Deviation",""Rejected Quantity"" and "Reworked Quantity" cannot be greater than Quantity.';
        Text0003_gCtx: label 'QC is not required for Item No.= ''%1'' in \ Transfer Receipt No = ''%2''.';
        Location_gRec: Record Location;
        CreatedQCNo_gTxt: Text;
        Text0004_gCtx: label 'Items are Received and \Related QC Receipts are created successfully.';
        Text0005_gCtx: label 'QC is not required for Item %1 in Transfer Receipt No. = %2.';

    procedure CreateQCRcpt_gFnc(TransferRcptLine_iRec: Record "Transfer Receipt Line"; ShowConfirmMsg_iBln: Boolean)
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        ItemEntryRel_lRec: Record "Item Entry Relation";
        Item_lRec: Record Item;
        LotNo_lCod: Code[50];
        SampleQty_lDec: Decimal;
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        //Written Function to create "QC Receipt" for Purchase Item.
        //I-C0009-1001310-06-NS

        //I-C0009-1001310-08-NS
        //T12113-ABA-OS
        // Clear(QCSetup_lRec);
        // QCSetup_lRec.Get;
        // if (not QCSetup_lRec."Allow QC in Transfer Receipt") then
        //     exit;
        //T12113-ABA-OE
        //I-C0009-1001310-08-NE


        TransferRcptLine_gRec.Copy(TransferRcptLine_iRec);
        TransferRcptLine_gRec.TestField("Transfer-from Code");
        TransferRcptLine_gRec.TestField("Transfer-to Code");


        if not TransferRcptLine_gRec."QC Required" then
            Error(Text0003_gCtx, TransferRcptLine_gRec."Item No.", TransferRcptLine_gRec."Document No.");

        //I-C0009-1001310-06-NS
        Clear(Item_lRec);
        Item_lRec.Get(TransferRcptLine_gRec."Item No.");
        if not Item_lRec."Allow QC in Transfer Receipt" then
            Error(Text0005_gCtx, TransferRcptLine_gRec."Item No.", TransferRcptLine_gRec."Document No.");
        //I-C0009-1001310-06-NE
        //T12113-ABA-NS

        Item_lRec.Get(TransferRcptLine_gRec."Item No.");
        if (not Item_lRec."Allow QC in Transfer Receipt") then
            exit;
        //T12113-ABA-NE

        if ShowConfirmMsg_iBln then
            if not Confirm(StrSubstNo(Text0000_gCtx, TransferRcptLine_gRec."Document No.", TransferRcptLine_gRec."Line No.")) then
                exit;

        ItemEntryRel_lRec.Reset;
        ItemEntryRel_lRec.SetCurrentkey("Lot No.");  //NG-N FIX 120221
        ItemEntryRel_lRec.SetRange("Source ID", TransferRcptLine_gRec."Document No.");
        ItemEntryRel_lRec.SetRange("Source Ref. No.", TransferRcptLine_gRec."Line No.");
        ItemEntryRel_lRec.SetRange("Source Type", Database::"Transfer Receipt Line");
        ItemEntryRel_lRec.SetFilter("Lot No.", '<>%1', '');
        if ItemEntryRel_lRec.FindSet then begin
            repeat
                if LotNo_lCod <> ItemEntryRel_lRec."Lot No." then
                    ItemEntryRel_lRec.Mark(true);
                LotNo_lCod := ItemEntryRel_lRec."Lot No.";
            until ItemEntryRel_lRec.Next = 0;
            ItemEntryRel_lRec.MarkedOnly(true);
            ItemEntryRel_lRec.FindFirst;
            repeat
                ItemLedgerEntry_lRec.Reset;
                ItemLedgerEntry_lRec.SetRange("Entry No.", ItemEntryRel_lRec."Item Entry No.");
                ItemLedgerEntry_lRec.SetFilter("Posted QC No.", '%1', '');//28032025
                if ItemLedgerEntry_lRec.FindFirst then begin
                    if (ItemLedgerEntry_lRec."Item Tracking" = ItemLedgerEntry_lRec."item tracking"::"Lot and Serial No.") then begin
                        ItemLdgrEntry_gRec.Reset;
                        ItemLdgrEntry_gRec.SetRange("Document No.", TransferRcptLine_gRec."Document No.");
                        ItemLdgrEntry_gRec.SetRange("Document Line No.", TransferRcptLine_gRec."Line No.");
                        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Transfer Receipt");
                        ItemLdgrEntry_gRec.SetRange("Lot No.", ItemEntryRel_lRec."Lot No.");
                        if ItemLdgrEntry_gRec.FindSet then
                            SampleQty_lDec := ItemLdgrEntry_gRec.Count;
                    end else
                        SampleQty_lDec := ItemLedgerEntry_lRec.Quantity;

                    if ItemLedgerEntry_lRec.Quantity > 0 then
                        CreateQCRcpt_lFnc(SampleQty_lDec, ItemLedgerEntry_lRec."Lot No.",
                                          ItemLedgerEntry_lRec, ItemLedgerEntry_lRec."Expiration Date");
                end;
            until ItemEntryRel_lRec.Next = 0;
        end else
            if (TransferRcptLine_gRec."Quantity (Base)" > 0) then
                CreateQCRcpt_lFnc(TransferRcptLine_gRec."Quantity (Base)", '', ItemLedgerEntry_lRec, 0D);

        if ShowConfirmMsg_iBln then
            Message(Text0001_gCtx, CreatedQCNo_gTxt, TransferRcptLine_gRec."Document No.", TransferRcptLine_gRec."Line No.");
        //I-C0009-1001310-06-NS
    end;

    local procedure CreateQCRcpt_lFnc(Quantity_iDec: Decimal; LotNo_iCod: Code[50]; ItemLedgerEntry_iRec: Record "Item Ledger Entry"; ExpDate_iDat: Date)
    var
        QCRcptHead_lRec: Record "QC Rcpt. Header";
        QCRcptHead2_lRec: Record "QC Rcpt. Header";
        Item_lRec: Record Item;
        Customer_lRec: Record Customer;
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCSpecificationLine_lRec: Record "QC Specification Line";
        TransferRcptHeader_lRec: Record "Transfer Receipt Header";
        QCSpecificationHeader_lRec: Record "QC Specification Header";
        Bin_lRec: Record Bin;
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineDetail2_lRec: Record "QC Line Detail";
        QtyUnderQC_lDec: Decimal;
        Cnt_lInt: Decimal;
        TransferRcptLine_lRec: Record "Transfer Receipt Line";
        Location_lRec: Record Location;
        MainLocation_lRec: Record Location;
        TransferLine_lRec: Record "Transfer Line";
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        //I-C0009-1001310-06-NS
        TransferRcptLine_gRec.TestField("QC Required", true);
        Clear(TransferRcptLine_lRec);
        TransferRcptLine_lRec.Get(TransferRcptLine_gRec."Document No.", TransferRcptLine_gRec."Line No.");

        Item_lRec.Reset;
        QCSpecificationHeader_lRec.Reset;
        Item_lRec.Get(TransferRcptLine_gRec."Item No.");
        Item_lRec.TestField("Item Specification Code");
        QCSpecificationHeader_lRec.Get(Item_lRec."Item Specification Code");
        QCSpecificationHeader_lRec.TestField(Status, QCSpecificationHeader_lRec.Status::Certified);

        QCRcptHead_lRec.Init;
        QCRcptHead_lRec."Document Type" := QCRcptHead_lRec."document type"::"Transfer Receipt";
        QCRcptHead_lRec."Document No." := TransferRcptLine_gRec."Document No.";
        QCRcptHead_lRec."Document Line No." := TransferRcptLine_gRec."Line No.";

        QCRcptHead_lRec."Item No." := TransferRcptLine_gRec."Item No.";
        QCRcptHead_lRec."Variant Code" := TransferRcptLine_gRec."Variant Code";
        QCRcptHead_lRec."Item Name" := Item_lRec.Description;
        QCRcptHead_lRec."Unit of Measure" := Item_lRec."Base Unit of Measure";
        QCRcptHead_lRec."Item Description" := Item_lRec.Description;
        QCRcptHead_lRec."Item Description 2" := Item_lRec."Description 2";
        QCRcptHead_lRec."Order Quantity" := TransferRcptLine_lRec.Quantity;//T12115-ABA

        Clear(TransferRcptHeader_lRec);
        if TransferRcptHeader_lRec.Get(TransferRcptLine_gRec."Document No.") then begin
            QCRcptHead_lRec."Receipt Date" := TransferRcptHeader_lRec."Posting Date";
        end;
        //QCV3-OS 24-01-18
        //IF Item_lRec.Sample <> 0 THEN
        //  QCRcptHead_lRec."Sample Quantity" := ROUND((Quantity_iDec * Item_lRec.Sample)/100,Item_lRec."Rounding Precision")
        //ELSE
        //  QCRcptHead_lRec."Sample Quantity" := Quantity_iDec;
        //QCV3-OE 24-01-18
        //QCV3-NS 24-01-18
        if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::Percentage then begin
            Item_lRec.TestField(Sample);
            QCRcptHead_lRec."Sample Quantity" := ROUND((Quantity_iDec * Item_lRec.Sample) / 100, Item_lRec."Rounding Precision")
        end else
            if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::Quantity then begin
                Item_lRec.TestField(Sample);
                if Quantity_iDec < Item_lRec.Sample then
                    QCRcptHead_lRec."Sample Quantity" := Quantity_iDec
                else
                    QCRcptHead_lRec."Sample Quantity" := Item_lRec.Sample;
            end else
                if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::" " then begin
                    QCRcptHead_lRec."Sample Quantity" := Quantity_iDec;
                end;
        //QCV3-NE 24-01-18
        QCRcptHead_lRec."Vendor Lot No." := LotNo_iCod;
        QCRcptHead_lRec."Exp. Date" := ExpDate_iDat;
        QCRcptHead_lRec."Mfg. Date" := ItemLedgerEntry_iRec."Warranty Date"; //T12204-N

        QCRcptHead_lRec."Inspection Quantity" := Quantity_iDec;
        QCRcptHead_lRec."Remaining Quantity" := Quantity_iDec;

        QCSetup_lRec.Reset();
        QCSetup_lRec.GET();

        if not QCSetup_lRec."QC Block without Location" then
            SetLocationAndBin_lFnc(QCRcptHead_lRec, TransferRcptLine_lRec)
        else
            SetLocationAndBinNew_lFnc(QCRcptHead_lRec, TransferRcptLine_lRec);

        QCRcptHead_lRec.Insert(true);

        if CreatedQCNo_gTxt <> '' then
            CreatedQCNo_gTxt += ' , ' + QCRcptHead_lRec."No."
        else
            CreatedQCNo_gTxt := QCRcptHead_lRec."No.";

        TransferRcptLine_lRec.Validate("Under Inspection Quantity", TransferRcptLine_lRec."Under Inspection Quantity" + Quantity_iDec);
        TransferRcptLine_lRec.Modify;

        ItemLdgrEntry_gRec.Reset;
        ItemLdgrEntry_gRec.SetRange("Document No.", TransferRcptLine_gRec."Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", TransferRcptLine_gRec."Line No.");
        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Transfer Receipt");
        if LotNo_iCod <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", LotNo_iCod);

        if ItemLdgrEntry_gRec.FindFirst then begin
            QCRcptHead_lRec."Item Tracking" := ItemLdgrEntry_gRec."Item Tracking".AsInteger();
            QCRcptHead_lRec.Modify;
            repeat
                ItemLdgrEntry_gRec."QC No." := QCRcptHead_lRec."No.";
                //T12750-NS 25112024-
                if (QCSetup_lRec."QC Block without Location") and (Not ItemLdgrEntry_gRec."Material at QC") and (ItemLdgrEntry_gRec."Posted QC No." = '') then//28032025
                    ItemLdgrEntry_gRec."Material at QC" := true;
                //T12750-NE 25112024  
                ItemLdgrEntry_gRec.Modify;
            until ItemLdgrEntry_gRec.Next = 0;
        end;

        QCSpecificationLine_lRec.Reset;
        QCSpecificationLine_lRec.SetRange("Item Specifiction Code", Item_lRec."Item Specification Code");
        if QCSpecificationLine_lRec.FindFirst then begin
            repeat
                QCRcptLine_lRec.Required := true;//T12544-N
                QCRcptLine_lRec.Print := QCSpecificationLine_lRec.Print;//T13242-N 03-01-2025
                QCRcptLine_lRec."No." := QCRcptHead_lRec."No.";
                QCRcptLine_lRec."Line No." := QCSpecificationLine_lRec."Line No.";
                QCRcptLine_lRec.Validate("Quality Parameter Code", QCSpecificationLine_lRec."Quality Parameter Code");
                //T51170-NS
                QCRcptLine_lRec.Description := QCSpecificationLine_lRec.Description;
                QCRcptLine_lRec."Method Description" := QCSpecificationLine_lRec."Method Description";
                //T51170-NE
                QCRcptLine_lRec.Validate("Unit of Measure Code", QCSpecificationLine_lRec."Unit of Measure Code");
                QCRcptLine_lRec.Type := QCSpecificationLine_lRec.Type;
                QCSpecificationLine_lRec.CalcFields(Method);
                QCRcptLine_lRec.Method := QCSpecificationLine_lRec.Method;
                QCRcptLine_lRec.Type := QCSpecificationLine_lRec.Type;
                QCRcptLine_lRec."Min.Value" := QCSpecificationLine_lRec."Min.Value";
                QCRcptLine_lRec."Max.Value" := QCSpecificationLine_lRec."Max.Value";
                //T13827-NS
                QCRcptLine_lRec."COA Min.Value" := QCSpecificationLine_lRec."COA Min.Value";
                QCRcptLine_lRec."COA Max.Value" := QCSpecificationLine_lRec."COA Max.Value";
                //T13827-NE
                //T51170-NS            
                QCRcptLine_lRec."Rounding Precision" := QCSpecificationLine_lRec."Rounding Precision";//T51170-N
                QCRcptLine_lRec."Show in COA" := QCSpecificationLine_lRec."Show in COA";
                QCRcptLine_lRec."Default Value" := QCSpecificationLine_lRec."Default Value";
                //T51170-NE
                QCRcptLine_lRec."Decimal Places" := QCSpecificationLine_lRec."Decimal Places"; //T52614-N
                QCRcptLine_lRec.Code := QCSpecificationLine_lRec."Document Code";
                QCRcptLine_lRec.Mandatory := QCSpecificationLine_lRec.Mandatory;
                QCRcptLine_lRec."Text Value" := QCSpecificationLine_lRec."Text Value";
                //T12113-ABA-NS
                QCRcptLine_lRec."Item Code" := QCSpecificationLine_lRec."Item Code";
                QCRcptLine_lRec."Item Description" := QCSpecificationLine_lRec."Item Description";
                //T12113-ABA-NE
                QCRcptLine_lRec.Insert;

                if (Item_lRec."Entry for each Sample") and
                   (QCRcptHead_lRec."Item Tracking" <> QCRcptHead_lRec."item tracking"::"Lot and Serial No.") and
                   (QCRcptHead_lRec."Item Tracking" <> QCRcptHead_lRec."item tracking"::"Serial No.")
                then begin
                    for Cnt_lInt := 1 to QCRcptHead_lRec."Sample Quantity" do begin
                        QCLineDetail_lRec.Init;
                        QCLineDetail_lRec."QC Rcpt No." := QCRcptHead_lRec."No.";
                        QCLineDetail_lRec."QC Rcpt Line No." := QCRcptLine_lRec."Line No.";
                        QCLineDetail2_lRec.Reset;
                        QCLineDetail2_lRec.SetRange("QC Rcpt No.", QCLineDetail_lRec."QC Rcpt No.");
                        QCLineDetail2_lRec.SetRange("QC Rcpt Line No.", QCLineDetail_lRec."QC Rcpt Line No.");

                        if QCLineDetail2_lRec.FindLast then
                            QCLineDetail_lRec."Line No." := QCLineDetail2_lRec."Line No." + 10000
                        else
                            QCLineDetail_lRec."Line No." := 10000;

                        QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");
                        QCLineDetail_lRec.Type := QCRcptLine_lRec.Type;
                        QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");

                        QCLineDetail_lRec."Min.Value" := QCRcptLine_lRec."Min.Value";
                        QCLineDetail_lRec."Max.Value" := QCRcptLine_lRec."Max.Value";
                        QCLineDetail_lRec."Text Value" := QCRcptLine_lRec."Text Value";
                        QCLineDetail_lRec."Lot No." := QCRcptHead_lRec."Vendor Lot No.";
                        QCLineDetail_lRec."Unit of Measure Code" := QCRcptLine_lRec."Unit of Measure Code";

                        QCLineDetail_lRec.Insert;
                    end;
                end;

            until QCSpecificationLine_lRec.Next = 0;
        end;
        //I-C0009-1001310-06-NS
    end;

    local procedure SetLocationAndBinNew_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; TransferRcptLine_iRec: Record "Transfer Receipt Line")
    var
        TransferRcptHeader_lRec: Record "Transfer Receipt Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
    begin
        /* TransferRcptHeader_lRec.Get(TransferRcptLine_iRec."Document No.");  //T12968-O
        MainLocation_lRec.Get(TransferRcptHeader_lRec."Transfer-to Code");
        QCRcptHead_vRec.Validate("Location Code", TransferRcptHeader_lRec."Transfer-to Code");
        QCRcptHead_vRec.Validate("QC Location", TransferRcptHeader_lRec."Transfer-to Code"); */
        //T12968-NS
        TransferRcptHeader_lRec.Get(TransferRcptLine_iRec."Document No.");
        QCRcptHead_vRec.Validate("Location Code", TransferRcptLine_iRec."Transfer-to Code");
        QCRcptHead_vRec.Validate("QC Location", TransferRcptLine_iRec."Transfer-to Code");
        // if PurchRcptLine_gRec."Bin Code" <> '' then
        //     QCRcptHead_vRec.Validate("QC Bin Code", PurchRcptLine_gRec."Bin Code");
        QCRcptHead_vRec.TestField("QC Location");

        //QC Location & Bin Assign Start
        MainLocation_lRec.get(TransferRcptLine_iRec."Transfer-to Code");
        if MainLocation_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", QCRcptHead_vRec."QC Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::QC);
            Bin_lRec.FindLast;
            QCRcptHead_vRec.Validate("QC Bin Code", Bin_lRec.Code);
            QCRcptHead_vRec.TestField("QC Bin Code");
        End;
        //QC Location & Bin Assign End

        //Store Location & Bin Assign Start
        MainLocation_lRec.Get(TransferRcptLine_iRec."Transfer-to Code");

        QCRcptHead_vRec.Validate("Store Location Code", MainLocation_lRec.Code);
        if MainLocation_lRec."Accept Bin Code" <> '' then
            QCRcptHead_vRec.Validate("Store Bin Code", MainLocation_lRec."Accept Bin Code")
        else begin
            if MainLocation_lRec."Bin Mandatory" then begin
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", QCRcptHead_vRec."Store Location Code");
                Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::STORE);
                Bin_lRec.FindLast;
                QCRcptHead_vRec.Validate("Store Bin Code", Bin_lRec.Code);
            end;
        end;
        //Store Location & Bin Assign End

        //Rejection Location & Bin Assign Start
        MainLocation_lRec.TestField("Rejection Location");
        QCRcptHead_vRec.Validate("Rejection Location", MainLocation_lRec."Rejection Location");
        Location_lRec.Get(QCRcptHead_vRec."Rejection Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rejection Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REJECT);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Reject Bin Code", Bin_lRec.Code);
        end;
        //Rejection Location & Bin Assign End

        //Rework Location & Bin Assign Start
        MainLocation_lRec.TestField("Rework Location");
        QCRcptHead_vRec.Validate("Rework Location", MainLocation_lRec."Rework Location");
        Location_lRec.Get(QCRcptHead_vRec."Rework Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rework Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REWORK);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Rework Bin Code", Bin_lRec.Code);
        end;
        //Rework Location & Bin Assign End
        //I-C0009-1001310-04-NE
        //T12968-NE
    end;

    local procedure SetLocationAndBin_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; TransferRcptLine_iRec: Record "Transfer Receipt Line")
    var
        TransferRcptHeader_lRec: Record "Transfer Receipt Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
        QCBin_lRec: Record Bin;
    begin
        //I-C0009-1001310-06-NS
        TransferRcptHeader_lRec.Get(TransferRcptLine_iRec."Document No.");
        MainLocation_lRec.Get(TransferRcptHeader_lRec."Transfer-to Code");
        QCRcptHead_vRec.Validate("Location Code", MainLocation_lRec."QC Location");

        //QC Location & Bin Assign Start
        QCRcptHead_vRec.Validate("QC Location", MainLocation_lRec."QC Location");
        QCBin_lRec.Reset;
        QCBin_lRec.SetRange("Location Code", MainLocation_lRec."QC Location");
        QCBin_lRec.SetRange("Bin Category", QCBin_lRec."bin category"::TESTING);//add a filter DD
        //QCBin_lRec.SetRange(Default, false);
        if QCBin_lRec.FindFirst then
            QCRcptHead_vRec.Validate("QC Bin Code", QCBin_lRec.Code);

        QCRcptHead_vRec.TestField("QC Location");
        Location_gRec.Get(QCRcptHead_vRec."QC Location");

        if Location_gRec."Bin Mandatory" then
            QCRcptHead_vRec.TestField("QC Bin Code");
        //QC Location & Bin Assign End

        //Store Location & Bin Assign Start
        QCRcptHead_vRec.Validate("Store Location Code", MainLocation_lRec.Code);
        if MainLocation_lRec."Accept Bin Code" <> '' then
            QCRcptHead_vRec.Validate("Store Bin Code", MainLocation_lRec."Accept Bin Code")
        else begin
            if MainLocation_lRec."Bin Mandatory" then begin
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", QCRcptHead_vRec."Store Location Code");
                Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::STORE);
                Bin_lRec.FindLast;
                QCRcptHead_vRec.Validate("Store Bin Code", Bin_lRec.Code);
            end;
        end;
        //Store Location & Bin Assign End

        //Rejection Location & Bin Assign Start
        MainLocation_lRec.TestField("Rejection Location");
        QCRcptHead_vRec.Validate("Rejection Location", MainLocation_lRec."Rejection Location");
        Clear(Location_lRec);
        Location_lRec.Get(QCRcptHead_vRec."Rejection Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rejection Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REJECT);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Reject Bin Code", Bin_lRec.Code);
        end;
        //Rejection Location & Bin Assign End

        //Rework Location & Bin Assign Start
        MainLocation_lRec.TestField("Rework Location");
        QCRcptHead_vRec.Validate("Rework Location", MainLocation_lRec."Rework Location");
        Clear(Location_lRec);
        Location_lRec.Get(QCRcptHead_vRec."Rework Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rework Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REWORK);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Rework Bin Code", Bin_lRec.Code);
        end;
        //Rework Location & Bin Assign End
        //I-C0009-1001310-06-NE
    end;

    procedure ShowQCRcpt_gFnc(TransferRcptLine_iRec: Record "Transfer Receipt Line")
    var
        QCRecptHeader_lRec: Record "QC Rcpt. Header";
        QCNO: Code[100];
        PostedQCHead: Record "Posted QC Rcpt. Header";
        QCRcptList_lPge: Page "QC Rcpt. List";
    begin
        //Function wrritten to show Created Qc Receipt
        //I-C0009-1001310-06-NS
        QCRecptHeader_lRec.Reset;
        QCRecptHeader_lRec.SetRange("Document No.", TransferRcptLine_iRec."Document No.");
        QCRecptHeader_lRec.SetRange("Document Line No.", TransferRcptLine_iRec."Line No.");
        QCRcptList_lPge.SetTableview(QCRecptHeader_lRec);
        QCRcptList_lPge.Run;
        //I-C0009-1001310-06-NE
    end;

    procedure ShowPostedQCRcpt_gFnc(TransferRcptLine_iRec: Record "Transfer Receipt Line")
    var
        PostedQCRcptHeader_lRec: Record "Posted QC Rcpt. Header";
        QCNO: Code[100];
        PostedQCHead: Record "Posted QC Rcpt. Header";
        PostedQCRcptList_lPge: Page "Posted QC Rcpt. List";
    begin
        //Function wrritten to show Posted Qc Receipt
        //I-C0009-1001310-06-NS
        PostedQCRcptHeader_lRec.Reset;
        PostedQCRcptHeader_lRec.SetRange("Document No.", TransferRcptLine_iRec."Document No.");
        PostedQCRcptHeader_lRec.SetRange("Document Line No.", TransferRcptLine_iRec."Line No.");
        PostedQCRcptList_lPge.SetTableview(PostedQCRcptHeader_lRec);
        PostedQCRcptList_lPge.Run;
        //I-C0009-1001310-06-NE
    end;

    procedure CheckPurchRcptRemaininQty_lFnc(TransferRcptLine_iRec: Record "Transfer Receipt Line")
    var
        ItemLedgEntry_lRec: Record "Item Ledger Entry";
    begin
        //Function Written to Check Quantity in ILE.
        //I-C0009-1001310-06-NS
        ItemLedgEntry_lRec.Reset;
        ItemLedgEntry_lRec.SetCurrentkey("Document No.");
        ItemLedgEntry_lRec.SetRange("Document No.", TransferRcptLine_iRec."Document No.");
        ItemLedgEntry_lRec.SetRange("Document Line No.", TransferRcptLine_iRec."Line No.");
        if ItemLedgEntry_lRec.FindSet() then begin
            repeat

            until ItemLedgEntry_lRec.Next = 0;
        end;
        //I-C0009-1001310-06-NE
    end;

    procedure CheckQCResultQuantity_lFnc(TransferRcptLine_iRec: Record "Transfer Receipt Line")
    begin
        //Function Written to Check Quantity with Quantity in QC and Its resultant Quantity.
        //I-C0009-1001310-06-NS
        if TransferRcptLine_iRec."Quantity (Base)" < (TransferRcptLine_iRec."Under Inspection Quantity" + TransferRcptLine_iRec."Accepted Quantity"
                                          + TransferRcptLine_iRec."Accepted with Deviation Qty" + TransferRcptLine_iRec."Rejected Quantity" + TransferRcptLine_iRec."Reworked Quantity")
        then
            Error(Text0002_gCtx);
        //I-C0009-1001310-06-NE
    end;

    procedure QCCreatedMsg_gFnc(var TransferHeader_vRec: Record "Transfer Header")
    var
        QCSetup_lRec: Record "Quality Control Setup";
        TransferRcptHeader_lRec: Record "Transfer Receipt Header";
        TransferRcptLine_lRec: Record "Transfer Receipt Line";
    begin
        //I-C0009-1001310-06-NS
        QCSetup_lRec.Get;
        if (QCSetup_lRec."Auto CreateQC on Transfer Rcpt") then begin
            TransferRcptHeader_lRec.Reset;
            TransferRcptHeader_lRec.SetRange("Transfer Order No.", TransferHeader_vRec."No.");
            if TransferRcptHeader_lRec.FindFirst then begin
                TransferRcptLine_lRec.SetFilter("Document No.", TransferRcptHeader_lRec."No.");
                TransferRcptLine_lRec.SetRange("QC Required", true);
                TransferRcptLine_lRec.SetFilter(Quantity, '>%1', 0);
                if TransferRcptLine_lRec.FindFirst then
                    Message(Text0004_gCtx);
            end;
        end;
        //I-C0009-1001310-06-NE
    end;
}

