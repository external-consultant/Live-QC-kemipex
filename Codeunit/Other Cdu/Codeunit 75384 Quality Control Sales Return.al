Codeunit 75384 "Quality Control - Sales Return"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-05     22/10/14    Chintan Panchal
    //                        QC Module - Redesign Released(Sales Return Receipt QC).
    // I-C0009-1001310-08     29/11/14    Chintan Panchal
    //                        QC Enhancement.
    // ------------------------------------------------------------------------------------------------------------------------------

    Permissions = TableData "Item Ledger Entry" = rm,
                  TableData "Return Receipt Line" = rm;

    trigger OnRun()
    begin
    end;

    var
        SalesReturnRcptLine_gRec: Record "Return Receipt Line";
        ItemLdgrEntry_gRec: Record "Item Ledger Entry";
        Text0000_gCtx: label 'Do you want to create QC Receipt for \ Sales Return Receipt = ''%1'', Line No. = ''%2'' ?';
        Text0001_gCtx: label 'QC Receipt = ''%1'' is created for \ Sales Return Receipt = ''%2'', Line No. = ''%3'' sucessfully.';
        Text0002_gCtx: label 'Sum of "Under Inspection Quantity","Accepted Quantity","Accepted Quantity with Deviation" and "Rejected Quantity" cannot be greater than Quantity.';
        Text0003_gCtx: label 'QC is not required for Item No.= ''%1'' in \ Sales Return Receipt No = ''%2''.';
        Location_gRec: Record Location;
        CreatedQCNo_gTxt: Text;
        Text0004_gCtx: label 'Items are Received and \Related QC Receipts are created successfully.';
        Text0005_gCtx: label 'Please be informed that due to Quality Control requirements for Item No: %1, the system will halt Reservation entries associated with  Document Type and Document No. %2. \This is an acknowledgment message for your attention.';//T12113-N

    procedure CreateQCRcpt_gFnc(SalesReturnRcptLine_iRec: Record "Return Receipt Line"; ShowConfirmMsg_iBln: Boolean)
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        ItemEntryRel_lRec: Record "Item Entry Relation";
        Item_lRec: Record Item;
        LotNo_lCod: Code[50];
        SampleQty_lDec: Decimal;
        QCSetup_lRec: Record "Quality Control Setup";
        ReturnRcptHeader_lRec: Record "Return Receipt Header";
        Location_lRec: Record Location;
    begin
        //Written Function to create "QC Receipt" for Purchase Item.
        //I-C0009-1001310-05-NS
        //T12113-ABA-OS
        // Clear(QCSetup_lRec);
        // QCSetup_lRec.Get;
        // if (not QCSetup_lRec."Allow QC in Sales Return") then
        //     exit;
        //T12113-ABA-OE


        ReturnRcptHeader_lRec.Get(SalesReturnRcptLine_iRec."Document No.");
        if Item_lRec.Get(ReturnRcptHeader_lRec."No.") then begin
            if (not Item_lRec."Allow QC in Sales Return") then begin
                Item_lRec.TestField("Allow QC in Sales Return");
            end;
        end;

        SalesReturnRcptLine_gRec.Copy(SalesReturnRcptLine_iRec);
        SalesReturnRcptLine_gRec.TestField(Type, SalesReturnRcptLine_gRec.Type::Item);
        SalesReturnRcptLine_gRec.TestField("Location Code");
        //T12113-ABA-OS
        Clear(Item_lRec);
        Item_lRec.Get(SalesReturnRcptLine_gRec."No.");
        if (not Item_lRec."Allow QC in Sales Return") then
            exit;
        //T12113-ABA-OE

        if not SalesReturnRcptLine_gRec."QC Required" then
            Error(Text0003_gCtx, SalesReturnRcptLine_gRec."No.", SalesReturnRcptLine_gRec."Document No.");

        if ShowConfirmMsg_iBln then
            if not Confirm(StrSubstNo(Text0000_gCtx, SalesReturnRcptLine_iRec."Document No.", SalesReturnRcptLine_iRec."Line No.")) then
                exit;

        ItemEntryRel_lRec.Reset;
        ItemEntryRel_lRec.SetCurrentkey("Lot No.");  //NG-FIX 120221
        ItemEntryRel_lRec.SetRange("Source ID", SalesReturnRcptLine_gRec."Document No.");
        ItemEntryRel_lRec.SetRange("Source Ref. No.", SalesReturnRcptLine_gRec."Line No.");
        ItemEntryRel_lRec.SetRange("Source Type", Database::"Return Receipt Line");
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
                        ItemLdgrEntry_gRec.SetRange("Document No.", SalesReturnRcptLine_gRec."Document No.");
                        ItemLdgrEntry_gRec.SetRange("Document Line No.", SalesReturnRcptLine_gRec."Line No.");
                        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Sales Return Receipt");
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
            if (SalesReturnRcptLine_gRec."Quantity (Base)" > 0) then
                CreateQCRcpt_lFnc(SalesReturnRcptLine_gRec."Quantity (Base)", '', ItemLedgerEntry_lRec, 0D);

        if ShowConfirmMsg_iBln then
            Message(Text0001_gCtx, CreatedQCNo_gTxt, SalesReturnRcptLine_gRec."Document No.", SalesReturnRcptLine_gRec."Line No.");
        //I-C0009-1001310-05-NS
    end;

    local procedure CreateQCRcpt_lFnc(Quantity_iDec: Decimal; LotNo_iCod: Code[50]; ItemLedgerEntry_iRec: Record "Item Ledger Entry"; ExpDate_iDat: Date)
    var
        QCRcptHead_lRec: Record "QC Rcpt. Header";
        QCRcptHead2_lRec: Record "QC Rcpt. Header";
        Item_lRec: Record Item;
        Customer_lRec: Record Customer;
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCSpecificationLine_lRec: Record "QC Specification Line";
        SalesReturnRcptHeader_lRec: Record "Return Receipt Header";
        QCSpecificationHeader_lRec: Record "QC Specification Header";
        SalesLine_lRec: Record "Sales Line";
        Bin_lRec: Record Bin;
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineDetail2_lRec: Record "QC Line Detail";
        ProdOrderRoutingLine_lRec: Record "Prod. Order Routing Line";
        QtyUnderQC_lDec: Decimal;
        Cnt_lInt: Decimal;
        SalesReturnRcptLine_lRec: Record "Return Receipt Line";
        Location_lRec: Record Location;
        MainLocation_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        //I-C0009-1001310-05-NS
        SalesReturnRcptLine_gRec.TestField("QC Required", true);
        Clear(SalesReturnRcptLine_lRec);
        SalesReturnRcptLine_lRec.Get(SalesReturnRcptLine_gRec."Document No.", SalesReturnRcptLine_gRec."Line No.");

        Item_lRec.Reset;
        QCSpecificationHeader_lRec.Reset;
        Item_lRec.Get(SalesReturnRcptLine_gRec."No.");
        Item_lRec.TestField("Item Specification Code");
        QCSpecificationHeader_lRec.Get(Item_lRec."Item Specification Code");
        QCSpecificationHeader_lRec.TestField(Status, QCSpecificationHeader_lRec.Status::Certified);

        QCRcptHead_lRec.Init;
        QCRcptHead_lRec."Document Type" := QCRcptHead_lRec."document type"::"Sales Return";
        QCRcptHead_lRec."Document No." := SalesReturnRcptLine_gRec."Document No.";
        QCRcptHead_lRec."Document Line No." := SalesReturnRcptLine_gRec."Line No.";
        Clear(Customer_lRec);
        if Customer_lRec.Get(SalesReturnRcptLine_gRec."Sell-to Customer No.") then begin
            QCRcptHead_lRec."Sell-to Customer No." := SalesReturnRcptLine_gRec."Sell-to Customer No.";
            QCRcptHead_lRec."Sell-to Customer Name" := Customer_lRec.Name;
        end;

        QCRcptHead_lRec."Item No." := SalesReturnRcptLine_gRec."No.";
        QCRcptHead_lRec."Variant Code" := SalesReturnRcptLine_gRec."Variant Code";
        QCRcptHead_lRec."Item Name" := Item_lRec.Description;
        QCRcptHead_lRec."Unit of Measure" := Item_lRec."Base Unit of Measure";
        QCRcptHead_lRec."Item Description" := Item_lRec.Description;
        QCRcptHead_lRec."Item Description 2" := Item_lRec."Description 2";

        Clear(SalesReturnRcptHeader_lRec);
        if SalesReturnRcptHeader_lRec.Get(SalesReturnRcptLine_gRec."Document No.") then begin
            QCRcptHead_lRec."Receipt Date" := SalesReturnRcptHeader_lRec."Posting Date";
            //QCRcptHead_lRec."Vendor Shipment No." := SalesReturnRcptHeader_lRec."Vendor Shipment No.";    //I-C0009-1001310-05-O
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

        Clear(SalesLine_lRec);
        if SalesLine_lRec.Get(SalesLine_lRec."document type"::"Return Order", SalesReturnRcptLine_gRec."Return Order No.", SalesReturnRcptLine_gRec."Return Order Line No.") then
            QCRcptHead_lRec."Order Quantity" := SalesLine_lRec.Quantity;

        QCRcptHead_lRec."Inspection Quantity" := Quantity_iDec;
        QCRcptHead_lRec."Remaining Quantity" := Quantity_iDec;

        QCSetup_lRec.Reset();
        QCSetup_lRec.GET();

        if not QCSetup_lRec."QC Block without Location" then
            SetLocationAndBin_lFnc(QCRcptHead_lRec, SalesReturnRcptLine_lRec)
        else
            SetLocationAndBinNew_lFnc(QCRcptHead_lRec, SalesReturnRcptLine_lRec);

        QCRcptHead_lRec.Insert(true);

        if CreatedQCNo_gTxt <> '' then
            CreatedQCNo_gTxt += ' , ' + QCRcptHead_lRec."No."
        else
            CreatedQCNo_gTxt := QCRcptHead_lRec."No.";

        SalesReturnRcptLine_lRec.Validate("Under Inspection Quantity", SalesReturnRcptLine_lRec."Under Inspection Quantity" + Quantity_iDec);
        SalesReturnRcptLine_lRec.Modify;

        ItemLdgrEntry_gRec.Reset;
        ItemLdgrEntry_gRec.SetRange("Document No.", SalesReturnRcptLine_gRec."Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", SalesReturnRcptLine_gRec."Line No.");
        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Sales Return Receipt");
        if LotNo_iCod <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", LotNo_iCod);

        if ItemLdgrEntry_gRec.FindFirst then begin
            QCRcptHead_lRec."Item Tracking" := ItemLdgrEntry_gRec."Item Tracking".AsInteger();
            QCRcptHead_lRec.Modify;
            repeat
                ItemLdgrEntry_gRec."QC No." := QCRcptHead_lRec."No.";
                //T12750-NS 25112024--CreateQCRcpt_lFnc
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
                QCRcptLine_lRec.Print := QCSpecificationLine_lRec.Print; //T13242-N 03-01-2025
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
        //I-C0009-1001310-05-NS
    end;

    local procedure SetLocationAndBinNew_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; SalesReturnRcptLine_lRec: Record "Return Receipt Line")
    var
        ReturnReceiptHeader_lRec: Record "Return Receipt Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
    begin
        /* ReturnReceiptHeader_lRec.Get(SalesReturnRcptLine_lRec."Document No."); //T12968-O
        QCRcptHead_vRec.Validate("Location Code", ReturnReceiptHeader_lRec."Location Code");
        QCRcptHead_vRec.Validate("QC Location", ReturnReceiptHeader_lRec."Location Code");
        if SalesReturnRcptLine_lRec."Bin Code" <> '' then
            QCRcptHead_vRec.Validate("QC Bin Code", SalesReturnRcptLine_lRec."Bin Code");

        MainLocation_lRec.Get(ReturnReceiptHeader_lRec."Location Code");

        QCRcptHead_vRec.Validate("Store Location Code", MainLocation_lRec.Code); */
        //T12968-NS
        ReturnReceiptHeader_lRec.Get(SalesReturnRcptLine_lRec."Document No.");
        QCRcptHead_vRec.Validate("Location Code", SalesReturnRcptLine_lRec."Location Code");
        QCRcptHead_vRec.Validate("QC Location", SalesReturnRcptLine_lRec."Location Code");
        // if PurchRcptLine_gRec."Bin Code" <> '' then
        //     QCRcptHead_vRec.Validate("QC Bin Code", PurchRcptLine_gRec."Bin Code");
        QCRcptHead_vRec.TestField("QC Location");

        //QC Location & Bin Assign Start
        MainLocation_lRec.get(SalesReturnRcptLine_lRec."Location Code");
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
        MainLocation_lRec.Get(SalesReturnRcptLine_lRec."Location Code");

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

    local procedure SetLocationAndBin_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; SalesReturnRcptLine_iRec: Record "Return Receipt Line")
    var
        SalesReturnRcptHeader_lRec: Record "Return Receipt Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
        QCBin_lRec: Record Bin;//T12113-N
    begin
        //I-C0009-1001310-05-NS

        SalesReturnRcptHeader_lRec.Get(SalesReturnRcptLine_iRec."Document No.");
        QCRcptHead_vRec.Validate("Location Code", SalesReturnRcptHeader_lRec."Location Code");
        //QC Location & Bin Assign Start
        // QCRcptHead_vRec.Validate("QC Location", SalesReturnRcptLine_gRec."Location Code");//T12113-ABA-O
        MainLocation_lRec.Get(SalesReturnRcptHeader_lRec."Location Code");//T12113-ABA-N
        QCRcptHead_vRec.Validate("QC Location", MainLocation_lRec."QC Location");//T12113-ABA-N
        //T12113-OS WhseRcpt Post-Issue
        // if SalesReturnRcptLine_gRec."Bin Code" <> '' then
        //     QCRcptHead_vRec.Validate("QC Bin Code", SalesReturnRcptLine_gRec."Bin Code"); 
        //T12113-OE       
        //Find QCBin T12113-NS
        QCBin_lRec.Reset;
        QCBin_lRec.SetRange("Location Code", MainLocation_lRec."QC Location");
        QCBin_lRec.SetRange("Bin Category", QCBin_lRec."Bin Category"::TESTING);
        //QCBin_lRec.SetRange(Default, false);
        if QCBin_lRec.FindFirst then
            QCRcptHead_vRec.Validate("QC Bin Code", QCBin_lRec.Code);
        //Find QCBin T12113-NE

        QCRcptHead_vRec.TestField("QC Location");
        Location_gRec.Get(QCRcptHead_vRec."QC Location");

        if Location_gRec."Bin Mandatory" then
            QCRcptHead_vRec.TestField("QC Bin Code");
        //QC Location & Bin Assign End
        //Store Location & Bin Assign Start
        MainLocation_lRec.Get(SalesReturnRcptHeader_lRec."Location Code");

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
        //I-C0009-1001310-05-NE
    end;

    procedure ShowQCRcpt_gFnc(SalesReturnRcptLine_iRec: Record "Return Receipt Line")
    var
        QCRecptHeader_lRec: Record "QC Rcpt. Header";
        QCNO: Code[100];
        PostedQCHead: Record "Posted QC Rcpt. Header";
        QCRcptList_lPge: Page "QC Rcpt. List";
    begin
        //Function wrritten to show Created Qc Receipt
        //I-C0009-1001310-05-NS
        QCRecptHeader_lRec.Reset;
        QCRecptHeader_lRec.SetRange("Document No.", SalesReturnRcptLine_iRec."Document No.");
        QCRecptHeader_lRec.SetRange("Document Line No.", SalesReturnRcptLine_iRec."Line No.");
        QCRcptList_lPge.SetTableview(QCRecptHeader_lRec);
        QCRcptList_lPge.Run;
        //I-C0009-1001310-05-NE
    end;

    procedure ShowPostedQCRcpt_gFnc(SalesReturnRcptLine_iRec: Record "Return Receipt Line")
    var
        PostedQCRcptHeader_lRec: Record "Posted QC Rcpt. Header";
        QCNO: Code[100];
        PostedQCHead: Record "Posted QC Rcpt. Header";
        PostedQCRcptList_lPge: Page "Posted QC Rcpt. List";
    begin
        //Function wrritten to show Posted Qc Receipt
        //I-C0009-1001310-05-NS
        PostedQCRcptHeader_lRec.Reset;
        PostedQCRcptHeader_lRec.SetRange("Document No.", SalesReturnRcptLine_iRec."Document No.");
        PostedQCRcptHeader_lRec.SetRange("Document Line No.", SalesReturnRcptLine_iRec."Line No.");
        PostedQCRcptList_lPge.SetTableview(PostedQCRcptHeader_lRec);
        PostedQCRcptList_lPge.Run;
        //I-C0009-1001310-05-NE
    end;

    procedure CheckPurchRcptRemaininQty_lFnc(SalesReturnRcptLine_iRec: Record "Return Receipt Line")
    var
        ItemLedgEntry_lRec: Record "Item Ledger Entry";
    begin
        //Function Written to Check Quantity in ILE.
        //I-C0009-1001310-05-NS
        ItemLedgEntry_lRec.Reset;
        ItemLedgEntry_lRec.SetCurrentkey("Document No.");
        ItemLedgEntry_lRec.SetRange("Document No.", SalesReturnRcptLine_iRec."Document No.");
        ItemLedgEntry_lRec.SetRange("Document Line No.", SalesReturnRcptLine_iRec."Line No.");
        if ItemLedgEntry_lRec.FindSet() then begin
            repeat

            until ItemLedgEntry_lRec.Next = 0;
        end;
        //I-C0009-1001310-05-NE
    end;

    procedure CheckQCResultQuantity_lFnc(SalesReturnRcptLine_iRec: Record "Return Receipt Line")
    begin
        //Function Written to Check Quantity with Quantity in QC and Its resultant Quantity.
        //I-C0009-1001310-05-NS
        if SalesReturnRcptLine_iRec."Quantity (Base)" < (SalesReturnRcptLine_iRec."Under Inspection Quantity" + SalesReturnRcptLine_iRec."Accepted Quantity"
                                          + SalesReturnRcptLine_iRec."Accepted with Deviation Qty" + SalesReturnRcptLine_iRec."Rejected Quantity" + SalesReturnRcptLine_iRec."Reworked Quantity")
        then
            Error(Text0002_gCtx);
        //I-C0009-1001310-05-NE
    end;

    procedure QCCreatedMsg_gFnc(var SalesHeader_vRec: Record "Sales Header")
    var
        QCSetup_lRec: Record "Quality Control Setup";
        SalesReturnRcptHeader_lRec: Record "Return Receipt Header";
        SalesReturnRcptLine_lRec: Record "Return Receipt Line";
    begin
        //I-C0009-1001310-05-NS
        QCSetup_lRec.Get;
        if (SalesReturnRcptHeader_lRec.Get(SalesHeader_vRec."Last Return Receipt No.")) and (QCSetup_lRec."Auto Create QC on Sales Return") then begin
            SalesReturnRcptLine_lRec.SetFilter("Document No.", SalesReturnRcptHeader_lRec."No.");
            SalesReturnRcptLine_lRec.SetRange("QC Required", true);
            SalesReturnRcptLine_lRec.SetFilter(Quantity, '>%1', 0);
            if SalesReturnRcptLine_lRec.FindFirst then
                Message(Text0004_gCtx);

        end;
        //I-C0009-1001310-05-NE
    end;

    procedure QCReservationMsg_gFnc(var SalesReturnRcptLine_iRec: Record "Sales Line")
    var
        QCSetup_lRec: Record "Quality Control Setup";
        SalesReturnRcptHeader_lRec: Record "Return Receipt Header";
        SalesReturnRcptLine_lRec: Record "Return Receipt Line";
        ReservEntry: Record "Reservation Entry";
        NewReservEntry: Record "Reservation Entry";
        DocNo_lTxt: Text;
    begin
        //T12113-NS
        QCSetup_lRec.Get;
        Clear(DocNo_lTxt);
        ReservEntry.reset;
        ReservEntry.SetRange("Source ID", SalesReturnRcptLine_iRec."Document No.");//filter
        ReservEntry.SETRANGE("Item No.", SalesReturnRcptLine_iRec."No.");//filter
        ReservEntry.Setrange("Source Subtype", ReservEntry."Source Subtype"::"5");
        ReservEntry.SETRANGE("Reservation Status", "Reservation Status"::Reservation);
        if ReservEntry.FindSet() then
            repeat
                NewReservEntry.reset;
                NewReservEntry.SetRange("Entry No.", ReservEntry."Entry No.");//filter
                NewReservEntry.SetFilter("Source ID", '<>%1', ReservEntry."Source ID");
                NewReservEntry.SETRANGE("Item No.", ReservEntry."Item No.");//filter
                NewReservEntry.Setfilter("Source Subtype", '<>%1', ReservEntry."Source Subtype"::"5");
                NewReservEntry.SETRANGE("Reservation Status", "Reservation Status"::Reservation);
                if NewReservEntry.FindSet() then begin
                    IF DocNo_lTxt <> '' THEN
                        DocNo_lTxt := DocNo_lTxt + '|' + TextCaption_lFnc(NewReservEntry) + ',' + NewReservEntry."Source ID"
                    ELSE
                        DocNo_lTxt := TextCaption_lFnc(NewReservEntry) + ',' + NewReservEntry."Source ID";
                end;
            until ReservEntry.Next() = 0;
        if DocNo_lTxt <> '' then
            Message(Text0005_gCtx, SalesReturnRcptLine_iRec."No.", DocNo_lTxt);
        //T12113-NE
    end;

    procedure TextCaption_lFnc(ReservEntry_iRec: Record "Reservation Entry"): Text   //T12113
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ReqLine: Record "Requisition Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        JobJnlLine: Record "Job Journal Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        TransLine: Record "Transfer Line";
        ServLine: Record "Service Line";
        AppDelChallan: Record "Applied Delivery Challan Entry";


    begin
        //TextCaption() : Text[255]
        CASE ReservEntry_iRec."Source Type" OF
            DATABASE::"Item Ledger Entry":
                EXIT(ItemLedgEntry.TABLECAPTION);
            DATABASE::"Sales Line":
                EXIT(SalesLine.TABLECAPTION);
            DATABASE::"Requisition Line":
                EXIT(ReqLine.TABLECAPTION);
            DATABASE::"Purchase Line":
                EXIT(PurchLine.TABLECAPTION);
            DATABASE::"Item Journal Line":
                EXIT(ItemJnlLine.TABLECAPTION);
            DATABASE::"Job Journal Line":
                EXIT(JobJnlLine.TABLECAPTION);
            DATABASE::"Prod. Order Line":
                EXIT(ProdOrderLine.TABLECAPTION);
            DATABASE::"Prod. Order Component":
                EXIT(ProdOrderComp.TABLECAPTION);
            DATABASE::"Assembly Header":
                EXIT(AssemblyHeader.TABLECAPTION);
            DATABASE::"Assembly Line":
                EXIT(AssemblyLine.TABLECAPTION);
            DATABASE::"Transfer Line":
                EXIT(TransLine.TABLECAPTION);
            DATABASE::"Service Line":
                EXIT(ServLine.TABLECAPTION);
            DATABASE::"Applied Delivery Challan Entry":
                EXIT(AppDelChallan.TABLECAPTION);

        END;
    end;

    //Item Reclass posting for the sales return order Case. Tranfering the Quantity to QC location once the Sales return order is posted.
    procedure CreateandPostItemReclas(PostedDocNo_iCode: Code[20])
    var
        ItemJnlLine_lRec: Record "Item Journal Line";
        QCSetup_gRec: Record "Quality Control Setup";
        ReturnReceiptHeader_lRec: Record "Return Receipt Header";
        ReturnReceiptLine_lRec: Record "Return Receipt Line";
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        QCDocNo_lCode: code[20];
        Item_lRec: Record item;
    begin
        //Movement Store To QC
        QCSetup_gRec.Reset();
        QCSetup_gRec.GET();
        //T12968-NS
        if QCSetup_gRec."QC Block without Location" then
            exit;
        //T12968-NE

        ReturnReceiptHeader_lRec.Reset();
        ReturnReceiptHeader_lRec.GET(PostedDocNo_iCode);

        ReturnReceiptLine_lRec.Reset();
        ReturnReceiptLine_lRec.SetRange("Document No.", ReturnReceiptHeader_lRec."No.");
        ReturnReceiptLine_lRec.SetRange(Type, ReturnReceiptLine_lRec.Type::Item);
        ReturnReceiptLine_lRec.SetRange("QC Required", true);
        if ReturnReceiptLine_lRec.FindSet() then begin
            repeat
                //T12166-NS 
                Clear(Item_lRec);
                Item_lRec.get(ReturnReceiptLine_lRec."No.");
                Item_lRec.TestField("Allow QC in Sales Return", true);
                if Item_lRec."Allow QC in Sales Return" then
                    //T12166-NE
                    InsertItemJnlLine(ReturnReceiptLine_lRec);
            until ReturnReceiptLine_lRec.Next() = 0;

            ItemJnlLine_lRec.Reset;
            ItemJnlLine_lRec.SetRange("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
            ItemJnlLine_lRec.SetRange("Journal Batch Name", QCSetup_gRec."QC General Batch Name");
            ItemJnlLine_lRec.SetRange("Document No.", PostedDocNo_iCode);
            ItemJnlLine_lRec.FindFirst;

            Codeunit.Run(Codeunit::"Item Jnl.-Post", ItemJnlLine_lRec);
        end;
    end;

    local procedure InsertItemJnlLine(ReturnReceiptLine_lRec: Record "Return Receipt Line")
    Var
        ItemJnlLine_lRec: Record "Item Journal Line";
        ItemJnlLine2_lRec: Record "Item Journal Line";
        QCSetup_gRec: Record "Quality Control Setup";
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        CurrentLocation_lRec: Record Location;
        QcLocation_lRec: Record Location;
        ItemJnlTemplate_lRec: Record "Item Journal Template";
        QCBin_lRec: Record Bin;
    begin

        //Movement Store To QC
        ItemLedgerEntry_lRec.Reset();
        ItemLedgerEntry_lRec.SetRange("Document No.", ReturnReceiptLine_lRec."Document No.");
        ItemLedgerEntry_lRec.SetRange("Document Line No.", ReturnReceiptLine_lRec."Line No.");
        ItemLedgerEntry_lRec.SetRange("Entry Type", ItemLedgerEntry_lRec."Entry Type"::Sale);
        ItemLedgerEntry_lRec.Findset();
        repeat
            QCSetup_gRec.Reset();
            QCSetup_gRec.GET();

            ItemJnlTemplate_lRec.Reset();
            ItemJnlTemplate_lRec.GET(QCSetup_gRec."QC Journal Template Name");

            CurrentLocation_lRec.Reset();
            CurrentLocation_lRec.GET(ItemLedgerEntry_lRec."Location Code");
            CurrentLocation_lRec.TestField("QC Location");

            ItemJnlLine_lRec.Init;
            ItemJnlLine_lRec.Validate("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
            ItemJnlLine_lRec.Validate("Journal Batch Name", QCSetup_gRec."QC General Batch Name");

            ItemJnlLine2_lRec.Reset;
            ItemJnlLine2_lRec.SetRange("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
            ItemJnlLine2_lRec.SetRange("Journal Batch Name", QCSetup_gRec."QC General Batch Name");
            if ItemJnlLine2_lRec.FindLast then
                ItemJnlLine_lRec."Line No." := ItemJnlLine2_lRec."Line No." + 10000
            else
                ItemJnlLine_lRec."Line No." := 10000;

            ItemJnlLine_lRec."Document No." := ItemLedgerEntry_lRec."Document No.";
            ItemJnlLine_lRec."Posting Date" := ItemLedgerEntry_lRec."Posting Date";
            ItemJnlLine_lRec."Document Date" := ItemLedgerEntry_lRec."Document Date";
            ItemJnlLine_lRec.Validate("Entry Type", ItemJnlLine_lRec."entry type"::Transfer);
            ItemJnlLine_lRec.Validate("Item No.", ItemLedgerEntry_lRec."Item No.");
            ItemJnlLine_lRec.Validate("Variant Code", ItemLedgerEntry_lRec."Variant Code");
            ItemJnlLine_lRec.Validate("Location Code", ItemLedgerEntry_lRec."Location Code");
            ItemJnlLine_lRec.Validate("New Location Code", CurrentLocation_lRec."QC Location");
            if CurrentLocation_lRec."Bin Mandatory" then begin
                if ReturnReceiptLine_lRec."Bin Code" <> '' then
                    ItemJnlLine_lRec.Validate("Bin Code", ReturnReceiptLine_lRec."Bin Code");
                QCBin_lRec.Reset;
                QCBin_lRec.SetRange("Location Code", CurrentLocation_lRec."QC Location");
                QCBin_lRec.SetRange("Bin Category", QCBin_lRec."Bin Category"::TESTING);
                // QCBin_lRec.SetRange(Default, false);//23072024
                if QCBin_lRec.FindFirst then
                    ItemJnlLine_lRec.Validate("New Bin Code", QCBin_lRec.Code);
            end;
            ItemJnlLine_lRec.Validate("Source Code", ItemJnlTemplate_lRec."Source Code");
            ItemJnlLine_lRec.Validate(quantity, ItemLedgerEntry_lRec.Quantity);

            if ItemJnlLine_lRec."Serial No." <> '' then begin
                ItemJnlLine_lRec.validate("Serial No.", ItemLedgerEntry_lRec."Serial No.");
                ItemJnlLine_lRec.validate("New Serial No.", ItemLedgerEntry_lRec."Serial No.");
            end;
            if ItemJnlLine_lRec."Lot No." <> '' then begin
                ItemJnlLine_lRec.Validate("Lot No.", ItemLedgerEntry_lRec."Lot No.");
                ItemJnlLine_lRec.Validate("New Lot No.", ItemLedgerEntry_lRec."Lot No.");
            end;
            ItemJnlLine_lRec."Skip Confirm Msg" := true;
            ItemJnlLine_lRec."QC No." := ItemLedgerEntry_lRec."QC No.";//Created QC No.
            ItemJnlLine_lRec."QC Relation Entry No." := ItemLedgerEntry_lRec."Entry No.";//QC-Sales Return
            ItemJnlLine_lRec."Document Line No." := ItemLedgerEntry_lRec."Document Line No.";//QC-Sales Return

            ItemJnlLine_lRec.Insert;

            if ItemLedgerEntry_lRec."Item Tracking" <> ItemLedgerEntry_lRec."Item Tracking"::None then
                NegReservationEntry_lFnc(ItemJnlLine_lRec, ItemLedgerEntry_lRec);
        until ItemLedgerEntry_lRec.next = 0;
    end;



    local procedure NegReservationEntry_lFnc(ItemJnlLine_iRec: Record "Item Journal Line"; ILE_lRec: Record "Item Ledger Entry")
    var
        ResEntry_lRec: Record "Reservation Entry";
        EntryNo_lInt: Integer;
        NextEntryNo_lInt: Integer;
    begin
        //Movement Store To QC
        //To Insert the Reservation Entry for Negative Item Journal Line.

        if ResEntry_lRec.FindLast then
            EntryNo_lInt := ResEntry_lRec."Entry No." + 1
        else
            EntryNo_lInt := 1;

        ResEntry_lRec.Lock;
        ResEntry_lRec.Init;
        ResEntry_lRec."Entry No." := EntryNo_lInt;

        ResEntry_lRec.Validate("Item No.", ILE_lRec."Item No.");
        ResEntry_lRec.Validate("Variant Code", ILE_lRec."Variant Code");
        ResEntry_lRec.Validate("Location Code", ILE_lRec."Location Code");
        if ItemJnlLine_iRec."Variant Code" <> '' then
            ResEntry_lRec.Validate("Variant Code", ItemJnlLine_iRec."Variant Code");

        ResEntry_lRec."Source Type" := Database::"Item Journal Line";
        ResEntry_lRec."Source Subtype" := ItemJnlLine_iRec."Entry Type".AsInteger();
        ResEntry_lRec."Source ID" := ItemJnlLine_iRec."Journal Template Name";
        ResEntry_lRec."Source Batch Name" := ItemJnlLine_iRec."Journal Batch Name";
        ResEntry_lRec."Source Ref. No." := ItemJnlLine_iRec."Line No.";
        ResEntry_lRec."Creation Date" := ItemJnlLine_iRec."Posting Date";
        ResEntry_lRec."Expiration Date" := ILE_lRec."Expiration Date";
        ResEntry_lRec."New Expiration Date" := ILE_lRec."Expiration Date";
        ResEntry_lRec."Created By" := UserId;
        if ILE_lRec."Lot No." <> '' then begin
            ResEntry_lRec.Validate("Lot No.", ILE_lRec."Lot No.");
            ResEntry_lRec.Validate("New Lot No.", ILE_lRec."Lot No.");
        end;
        if ILE_lRec."Serial No." <> '' then begin
            ResEntry_lRec.Validate("Serial No.", ILE_lRec."Serial No.");
            ResEntry_lRec.Validate("New Serial No.", ILE_lRec."Serial No.");
        end;
        ResEntry_lRec."Shipment Date" := ILE_lRec."Posting Date";
        ResEntry_lRec."Reservation Status" := ResEntry_lRec."reservation status"::Prospect;
        ResEntry_lRec."Item Tracking" := ILE_lRec."Item Tracking";
        ResEntry_lRec.Quantity := -1 * Abs(ItemJnlLine_iRec.Quantity);
        ResEntry_lRec.Validate("Quantity (Base)", -1 * Abs(ItemJnlLine_iRec.Quantity));
        ResEntry_lRec."Qty. per Unit of Measure" := 1;
        ResEntry_lRec.Validate("Appl.-to Item Entry", ILE_lRec."Entry No.");
        ResEntry_lRec.Validate("Warranty Date", ILE_lRec."Warranty Date");
        ResEntry_lRec.Insert;
    end;
}

