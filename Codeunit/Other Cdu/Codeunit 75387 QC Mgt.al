Codeunit 75387 "QC Mgt"
{
    Permissions = tabledata "Item Ledger Entry" = RM;
    trigger OnRun()
    begin
    end;

    var
        LotNo_gCod: Code[50];
        Text0006_gCtx: label 'If Rejection Quantity has a value, Accepted and Accepted with Deviation fields cannot be filled. Conversely, if Accepted or Accepted with Deviation fields are filled, Rejection Quantity must be blank. This condition applies to Lot Item on QC Receipt.';//T12436-N

    procedure SetLotNo_gFnc(LotNo_iCod: Code[50])
    begin
        //I-C0009-1001310-04-NS
        LotNo_gCod := '';
        LotNo_gCod := LotNo_iCod;
        //I-C0009-1001310-04-NE
    end;

    procedure CallPostedItemTrackingFrm_gFnc(Type: Integer; Subtype: Integer; ID: Code[20]; BatchName: Code[10]; ProdOrderLine: Integer; RefNo: Integer; var QCRcptHeader_vRec: Record "QC Rcpt. Header"): Boolean
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ItemLdgrEntry_lRec: Record "Item Ledger Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
        Rejection_lcde: Code[20];//T12113        
    begin
        // Used when calling Item Tracking from Posted Shipments/Receipts:        
        CollectItemEntryRelation_gFnc(TempItemLedgEntry, Type, Subtype, ID, BatchName, ProdOrderLine, RefNo, 0, QCRcptHeader_vRec."No.");
        if LotNo_gCod <> '' then
            TempItemLedgEntry.SetRange("Lot No.", LotNo_gCod);
        if not TempItemLedgEntry.IsEmpty then begin
            Page.RunModal(Page::"Posted Item QC Tracking Lines", TempItemLedgEntry);
            if TempItemLedgEntry.FindSet then begin
                repeat
                    //ItemLdgrEntry_gRec := TempItemLedgEntry;    //CP-O

                    //CP-NS
                    Clear(ItemLdgrEntry_lRec);
                    ItemLdgrEntry_lRec.Get(TempItemLedgEntry."Entry No.");
                    ItemLdgrEntry_lRec."Accepted Quantity" := TempItemLedgEntry."Accepted Quantity";
                    ItemLdgrEntry_lRec."Accepted with Deviation Qty" := TempItemLedgEntry."Accepted with Deviation Qty";
                    ItemLdgrEntry_lRec."Rejected Quantity" := TempItemLedgEntry."Rejected Quantity";
                    ItemLdgrEntry_lRec."Rework Quantity" := TempItemLedgEntry."Rework Quantity";
                    //CP-NE
                    //T12113-NS
                    ItemLdgrEntry_lRec."Rejection Reason" := TempItemLedgEntry."Rejection Reason";
                    ItemLdgrEntry_lRec."Rejection Reason Description" := TempItemLedgEntry."Rejection Reason Description";
                    //T12113_NE

                    ItemLdgrEntry_lRec.Modify;

                    TotalAccQty_lDec += TempItemLedgEntry."Accepted Quantity";
                    TotalAccWithDevi_lDec += TempItemLedgEntry."Accepted with Deviation Qty";
                    TotalRejQty_lDec += TempItemLedgEntry."Rejected Quantity";
                    TotalRewQty_lDec += TempItemLedgEntry."Rework Quantity";
                    if TempItemLedgEntry."Rejection Reason" <> '' then//T12113
                        Rejection_lcde := TempItemLedgEntry."Rejection Reason";
                until TempItemLedgEntry.Next = 0;
            end;

            if (not QCRcptHeader_vRec.Approve) and (QCRcptHeader_vRec."Approval Status" = QCRcptHeader_vRec."approval status"::Open) then begin
                if TotalAccQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Accept" := TotalAccQty_lDec;

                if TotalRejQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Reject" := TotalRejQty_lDec;

                if TotalRewQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Rework" := TotalRewQty_lDec;

                if TotalAccWithDevi_lDec <> 0 then
                    QCRcptHeader_vRec."Qty to Accept with Deviation" := TotalAccWithDevi_lDec;

                //21082024 T12436-NS
                if (QCRcptHeader_vRec."Quantity to Accept" <> 0) or (QCRcptHeader_vRec."Qty to Accept with Deviation" <> 0) then
                    if (QCRcptHeader_vRec."Quantity to Reject" > 0) and (QCRcptHeader_vRec."Item Tracking" in [QCRcptHeader_vRec."Item Tracking"::"Lot No."]) then
                        Error(Text0006_gCtx);
                //21082024 T12436-NE
                QCRcptHeader_vRec.Validate("Rejection Reason", Rejection_lcde);//T12113
                QCRcptHeader_vRec.Modify;
            end;

            exit(true);
        end else
            exit(false);
        //I-C0009-1001310-04-NE
    end;

    procedure CallPostedItemTrackingSalesReturn_gFnc(Type: Integer; Subtype: Integer; ID: Code[20]; BatchName: Code[10]; ProdOrderLine: Integer; RefNo: Integer; var QCRcptHeader_vRec: Record "QC Rcpt. Header"): Boolean
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ItemLdgrEntry_lRec: Record "Item Ledger Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
        Rejection_lcde: Code[20];//T12113        
    begin
        // Used when calling Item Tracking from Posted Shipments/Receipts:        
        CollectItemEntryRelationForSalesReturn_gFnc(TempItemLedgEntry, Type, Subtype, ID, BatchName, ProdOrderLine, RefNo, 0, QCRcptHeader_vRec."No.");
        if LotNo_gCod <> '' then
            TempItemLedgEntry.SetRange("Lot No.", LotNo_gCod);
        if not TempItemLedgEntry.IsEmpty then begin
            Page.RunModal(Page::"Posted Item QC Tracking Lines", TempItemLedgEntry);
            if TempItemLedgEntry.FindSet then begin
                repeat
                    //ItemLdgrEntry_gRec := TempItemLedgEntry;    //CP-O

                    //CP-NS
                    Clear(ItemLdgrEntry_lRec);
                    ItemLdgrEntry_lRec.Get(TempItemLedgEntry."Entry No.");
                    ItemLdgrEntry_lRec."Accepted Quantity" := TempItemLedgEntry."Accepted Quantity";
                    ItemLdgrEntry_lRec."Accepted with Deviation Qty" := TempItemLedgEntry."Accepted with Deviation Qty";
                    ItemLdgrEntry_lRec."Rejected Quantity" := TempItemLedgEntry."Rejected Quantity";
                    ItemLdgrEntry_lRec."Rework Quantity" := TempItemLedgEntry."Rework Quantity";
                    //CP-NE
                    //T12113-NS
                    ItemLdgrEntry_lRec."Rejection Reason" := TempItemLedgEntry."Rejection Reason";
                    ItemLdgrEntry_lRec."Rejection Reason Description" := TempItemLedgEntry."Rejection Reason Description";
                    if TempItemLedgEntry."Rejection Reason" <> '' then
                        Rejection_lcde := TempItemLedgEntry."Rejection Reason";
                    //T12113_NE

                    ItemLdgrEntry_lRec.Modify;

                    TotalAccQty_lDec += TempItemLedgEntry."Accepted Quantity";
                    TotalAccWithDevi_lDec += TempItemLedgEntry."Accepted with Deviation Qty";
                    TotalRejQty_lDec += TempItemLedgEntry."Rejected Quantity";
                    TotalRewQty_lDec += TempItemLedgEntry."Rework Quantity";

                until TempItemLedgEntry.Next = 0;
            end;

            if (not QCRcptHeader_vRec.Approve) and (QCRcptHeader_vRec."Approval Status" = QCRcptHeader_vRec."approval status"::Open) then begin
                if TotalAccQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Accept" := TotalAccQty_lDec;

                if TotalRejQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Reject" := TotalRejQty_lDec;

                if TotalRewQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Rework" := TotalRewQty_lDec;

                if TotalAccWithDevi_lDec <> 0 then
                    QCRcptHeader_vRec."Qty to Accept with Deviation" := TotalAccWithDevi_lDec;
                //21082024 T12436-NS
                if (QCRcptHeader_vRec."Quantity to Accept" <> 0) or (QCRcptHeader_vRec."Qty to Accept with Deviation" <> 0) then
                    if (QCRcptHeader_vRec."Quantity to Reject" > 0) and (QCRcptHeader_vRec."Item Tracking" in [QCRcptHeader_vRec."Item Tracking"::"Lot No."]) then
                        Error(Text0006_gCtx);
                //21082024 T12436-NE
                QCRcptHeader_vRec.Validate("Rejection Reason", Rejection_lcde);//T12113
                QCRcptHeader_vRec.Modify;
            end;

            exit(true);
        end else
            exit(false);
        //I-C0009-1001310-04-NE
    end;

    procedure CallPostedItemTrackingForSubConGRN_gFnc(QCRcptHeader_vRec: Record "QC Rcpt. Header"): Boolean
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        UpdItemLdgrEntry_lRec: Record "Item Ledger Entry";
        FindILE_lRec: Record "Item Ledger Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
        PRL_lRec: Record "Purch. Rcpt. Line";
    begin
        // Used when calling Item Tracking from Posted Receipt of Subcon:
        //I-C0009-1001310-04-NS  //SubConQCV2-NS

        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;

        PRL_lRec.GET(QCRcptHeader_vRec."Document No.", QCRcptHeader_vRec."Document Line No.");
        PRL_lRec.Testfield("Order No.");


        FindILE_lRec.Reset;
        FindILE_lRec.SetRange("Entry Type", FindILE_lRec."entry type"::Output);
        FindILE_lRec.SetRange("Document Type", FindILE_lRec."document type"::" ");

        FindILE_lRec.Setfilter("Document No.", '%1|%2', PRL_lRec."Document No.", PRL_lRec."Prod. Order No.");
        FindILE_lRec.Setfilter("Document Line No.", '%1|%2', QCRcptHeader_vRec."Document Line No.", 0);
        FindILE_lRec.SETRANGE("Order No.", PRL_lRec."Prod. Order No.");
        FindILE_lRec.SETRANGE("Order Line No.", PRL_lRec."Prod. Order Line No.");
        if FindILE_lRec.FindSet then begin
            repeat
                TempItemLedgEntry := FindILE_lRec;
                TempItemLedgEntry."Job No." := QCRcptHeader_vRec."No.";  //Temp Save QC No. in Job No. Field To Require in next stage
                TempItemLedgEntry.Insert;
            until FindILE_lRec.Next = 0;
        end;

        TempItemLedgEntry.Reset;
        if LotNo_gCod <> '' then
            TempItemLedgEntry.SetRange("Lot No.", LotNo_gCod);

        if not TempItemLedgEntry.IsEmpty then begin
            Page.RunModal(Page::"Posted Item QC Tracking Lines", TempItemLedgEntry);
            if TempItemLedgEntry.FindSet then begin
                repeat
                    Clear(UpdItemLdgrEntry_lRec);
                    UpdItemLdgrEntry_lRec.Get(TempItemLedgEntry."Entry No.");
                    UpdItemLdgrEntry_lRec."Accepted Quantity" := TempItemLedgEntry."Accepted Quantity";
                    UpdItemLdgrEntry_lRec."Accepted with Deviation Qty" := TempItemLedgEntry."Accepted with Deviation Qty";
                    UpdItemLdgrEntry_lRec."Rejected Quantity" := TempItemLedgEntry."Rejected Quantity";
                    UpdItemLdgrEntry_lRec."Rework Quantity" := TempItemLedgEntry."Rework Quantity";
                    //T12113-NS
                    UpdItemLdgrEntry_lRec."Rejection Reason" := TempItemLedgEntry."Rejection Reason";
                    UpdItemLdgrEntry_lRec."Rejection Reason Description" := TempItemLedgEntry."Rejection Reason Description";
                    //T12113_NE
                    UpdItemLdgrEntry_lRec.Modify;

                    TotalAccQty_lDec += TempItemLedgEntry."Accepted Quantity";
                    TotalAccWithDevi_lDec += TempItemLedgEntry."Accepted with Deviation Qty";
                    TotalRejQty_lDec += TempItemLedgEntry."Rejected Quantity";
                    TotalRewQty_lDec += TempItemLedgEntry."Rework Quantity";
                until TempItemLedgEntry.Next = 0;
            end;

            if (not QCRcptHeader_vRec.Approve) and (QCRcptHeader_vRec."Approval Status" = QCRcptHeader_vRec."approval status"::Open) then begin
                if TotalAccQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Accept" := TotalAccQty_lDec;

                if TotalRejQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Reject" := TotalRejQty_lDec;

                if TotalRewQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Rework" := TotalRewQty_lDec;

                if TotalAccWithDevi_lDec <> 0 then
                    QCRcptHeader_vRec."Qty to Accept with Deviation" := TotalAccWithDevi_lDec;

                QCRcptHeader_vRec.Modify;
            end;

            exit(true);
        end else
            exit(false);
        //I-C0009-1001310-04-NE  //SubConQCV2-NE
    end;

    procedure CollectItemEntryRelation_gFnc(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SourceType: Integer; SourceSubtype: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer; TotalQty: Decimal; QC_PostedQCNo_iCod: Code[20]): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        Quantity: Decimal;
        Ile_lRec: Record "Item Ledger Entry";
    begin
        //I-C0009-1001310-04-NE  //SubConQCV2-NS
        Quantity := 0;
        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;
        ItemEntryRelation.SetCurrentkey("Source ID", "Source Type");
        ItemEntryRelation.SetRange("Source Type", SourceType);
        ItemEntryRelation.SetRange("Source Subtype", SourceSubtype);
        ItemEntryRelation.SetRange("Source ID", SourceID);
        ItemEntryRelation.SetRange("Source Batch Name", SourceBatchName);
        ItemEntryRelation.SetRange("Source Prod. Order Line", SourceProdOrderLine);
        ItemEntryRelation.SetRange("Source Ref. No.", SourceRefNo);
        if ItemEntryRelation.FindSet then
            repeat
                ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                TempItemLedgEntry := ItemLedgEntry;
                TempItemLedgEntry."Job No." := QC_PostedQCNo_iCod;  //Temp Save QC/Posted QC No. in Job No. Field To Require in next stage
                TempItemLedgEntry.Insert;
                Quantity := Quantity + ItemLedgEntry.Quantity;

            until ItemEntryRelation.Next = 0;
        exit(Quantity = TotalQty);
        //I-C0009-1001310-04-NE  //SubConQCV2-NE
    end;

    procedure CollectItemEntryRelationForSalesReturn_gFnc(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SourceType: Integer; SourceSubtype: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer; TotalQty: Decimal; QC_PostedQCNo_iCod: Code[20]): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        Quantity: Decimal;
        Ile_lRec: Record "Item Ledger Entry";
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        Quantity := 0;
        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;
        ItemEntryRelation.SetCurrentkey("Source ID", "Source Type");
        ItemEntryRelation.SetRange("Source Type", SourceType);
        ItemEntryRelation.SetRange("Source Subtype", SourceSubtype);
        ItemEntryRelation.SetRange("Source ID", SourceID);
        ItemEntryRelation.SetRange("Source Batch Name", SourceBatchName);
        ItemEntryRelation.SetRange("Source Prod. Order Line", SourceProdOrderLine);
        ItemEntryRelation.SetRange("Source Ref. No.", SourceRefNo);
        if ItemEntryRelation.FindSet then
            repeat
                ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                //T12113-ABA-NS
                Ile_lRec.reset;
                QCSetup_lRec.get;
                if not QCSetup_lRec."QC Block without Location" then//T12968-N
                    Ile_lRec.SetRange("QC Relation Entry No.", ItemLedgEntry."Entry No.");
                Ile_lRec.SetRange("Document No.", ItemLedgEntry."Document No.");
                Ile_lRec.SetRange("Item No.", ItemLedgEntry."Item No.");
                //T12968-NS
                Ile_lRec.SetRange("Document Line No.", ItemLedgEntry."Document Line No.");
                if ItemEntryRelation."Lot No." <> '' then
                    Ile_lRec.SetRange("Lot No.", ItemEntryRelation."Lot No.");
                if ItemEntryRelation."Serial No." <> '' then
                    Ile_lRec.SetRange("Serial No.", ItemEntryRelation."Serial No.");
                //T12968-NE
                Ile_lRec.SetFilter("Remaining Quantity", '>%1', 0);
                if Ile_lRec.FindSet() then begin
                    TempItemLedgEntry := Ile_lRec;
                    TempItemLedgEntry."Job No." := QC_PostedQCNo_iCod;  //Temp Save QC/Posted QC No. in Job No. Field To Require in next stage
                    TempItemLedgEntry.Insert;
                    Quantity := Quantity + Ile_lRec.Quantity;
                end;
            //T12113-ABA-NE

            /* T12113-ABA-OS 
            TempItemLedgEntry := ItemLedgEntry;
            TempItemLedgEntry."Job No." := QC_PostedQCNo_iCod;  //Temp Save QC/Posted QC No. in Job No. Field To Require in next stage
            TempItemLedgEntry.Insert;
            Quantity := Quantity + ItemLedgEntry.Quantity;
            T12113-ABA-OS  */
            until ItemEntryRelation.Next = 0;
        exit(Quantity = TotalQty);
        //I-C0009-1001310-04-NE  //SubConQCV2-NE
    end;

    procedure CollectItemEntryRelationForPurchase_gFnc(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SourceType: Integer; SourceSubtype: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer; TotalQty: Decimal; QC_PostedQCNo_iCod: Code[20]): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        Quantity: Decimal;
        Ile_lRec: Record "Item Ledger Entry";
    begin
        Quantity := 0;
        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;
        ItemEntryRelation.SetCurrentkey("Source ID", "Source Type");
        ItemEntryRelation.SetRange("Source Type", SourceType);
        ItemEntryRelation.SetRange("Source Subtype", SourceSubtype);
        ItemEntryRelation.SetRange("Source ID", SourceID);
        ItemEntryRelation.SetRange("Source Batch Name", SourceBatchName);
        ItemEntryRelation.SetRange("Source Prod. Order Line", SourceProdOrderLine);
        ItemEntryRelation.SetRange("Source Ref. No.", SourceRefNo);
        if ItemEntryRelation.FindSet then
            repeat
                ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                TempItemLedgEntry := ItemLedgEntry;
                TempItemLedgEntry."Job No." := QC_PostedQCNo_iCod;  //Temp Save QC/Posted QC No. in Job No. Field To Require in next stage
                TempItemLedgEntry.Insert;
                Quantity := Quantity + ItemLedgEntry.Quantity;
            until ItemEntryRelation.Next = 0;
        exit(Quantity = TotalQty);
        //I-C0009-1001310-04-NE  //SubConQCV2-NE
    end;

    procedure CallPostedItemTrackingFrmPosted_gFnc(Type: Integer; Subtype: Integer; ID: Code[20]; BatchName: Code[10]; ProdOrderLine: Integer; RefNo: Integer; PostedQCRcptHeader_iRec: Record "Posted QC Rcpt. Header"): Boolean
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        // Used when calling Item Tracking from Posted Shipments/Receipts:
        //I-C0009-1001310-04-NS
        CollectItemEntryRelation_gFnc(TempItemLedgEntry, Type, Subtype, ID, BatchName, ProdOrderLine, RefNo, 0, PostedQCRcptHeader_iRec."No.");
        //QCV3-NS  24-01-18
        if LotNo_gCod <> '' then
            TempItemLedgEntry.SetRange("Lot No.", LotNo_gCod);
        //QCV3-NE  24-01-18

        if not TempItemLedgEntry.IsEmpty then begin
            Page.RunModal(Page::"Posted Item QC Tracking Lines", TempItemLedgEntry);
            exit(true);
        end else
            exit(false);
        //I-C0009-1001310-04-NE
    end;

    procedure CallPostedItemTrackingForSubConGRNPosted_gFnc(PostedQCRcptHeader_iRec: Record "Posted QC Rcpt. Header"): Boolean
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        UpdItemLdgrEntry_lRec: Record "Item Ledger Entry";
        FindILE_lRec: Record "Item Ledger Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
    begin
        // Used when calling Item Tracking from Posted Receipt of Subcon:
        //I-C0009-1001310-04-NS  //SubConQCV2-NS

        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;

        FindILE_lRec.Reset;
        FindILE_lRec.SetRange("Entry Type", FindILE_lRec."entry type"::Output);
        FindILE_lRec.SetRange("Document Type", FindILE_lRec."document type"::" ");
        FindILE_lRec.SetRange("Document No.", PostedQCRcptHeader_iRec."Document No.");
        FindILE_lRec.SetRange("Document Line No.", PostedQCRcptHeader_iRec."Document Line No.");
        if FindILE_lRec.FindSet then begin
            repeat
                TempItemLedgEntry := FindILE_lRec;
                TempItemLedgEntry."Job No." := PostedQCRcptHeader_iRec."No.";  //Temp Save QC No. in Job No. Field To Require in next stage
                TempItemLedgEntry.Insert;
            until FindILE_lRec.Next = 0;
        end;

        TempItemLedgEntry.Reset;
        if LotNo_gCod <> '' then
            TempItemLedgEntry.SetRange("Lot No.", LotNo_gCod);

        if not TempItemLedgEntry.IsEmpty then
            Page.RunModal(Page::"Posted Item QC Tracking Line2", TempItemLedgEntry);
        //I-C0009-1001310-04-NE  //SubConQCV2-NE
    end;



    procedure Retest_CallPostedItemTrackingFrm_gFnc(Type: Integer; Subtype: Integer; ID: Code[20]; BatchName: Code[10]; ProdOrderLine: Integer; RefNo: Integer; QCRcptHeader_vRec: Record "QC Rcpt. Header"): Boolean
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ItemLdgrEntry_lRec: Record "Item Ledger Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
        Rejection_lcde: Code[20];//T12113 
    begin
        // Used when calling Item Tracking from Ledger Entry:        
        Retest_QCCollectItemEntryRelation_gFnc(TempItemLedgEntry, Type, Subtype, ID, BatchName, ProdOrderLine, RefNo, 0, QCRcptHeader_vRec."No.");

        if LotNo_gCod <> '' then
            TempItemLedgEntry.SetRange("Lot No.", LotNo_gCod);


        if not TempItemLedgEntry.IsEmpty then begin
            Page.RunModal(Page::"Posted Item QC Tracking Lines", TempItemLedgEntry);
            if TempItemLedgEntry.FindSet then begin
                repeat
                    Clear(ItemLdgrEntry_lRec);
                    ItemLdgrEntry_lRec.Get(TempItemLedgEntry."Entry No.");
                    ItemLdgrEntry_lRec."Accepted Quantity" := TempItemLedgEntry."Accepted Quantity";
                    ItemLdgrEntry_lRec."Accepted with Deviation Qty" := TempItemLedgEntry."Accepted with Deviation Qty";
                    ItemLdgrEntry_lRec."Rejected Quantity" := TempItemLedgEntry."Rejected Quantity";
                    ItemLdgrEntry_lRec."Rework Quantity" := TempItemLedgEntry."Rework Quantity";
                    ItemLdgrEntry_lRec."Rejection Reason" := TempItemLedgEntry."Rejection Reason";
                    ItemLdgrEntry_lRec."Rejection Reason Description" := TempItemLedgEntry."Rejection Reason Description";
                    ItemLdgrEntry_lRec.Modify;

                    TotalAccQty_lDec += TempItemLedgEntry."Accepted Quantity";
                    TotalAccWithDevi_lDec += TempItemLedgEntry."Accepted with Deviation Qty";
                    TotalRejQty_lDec += TempItemLedgEntry."Rejected Quantity";
                    TotalRewQty_lDec += TempItemLedgEntry."Rework Quantity";
                    if TempItemLedgEntry."Rejection Reason" <> '' then
                        Rejection_lcde := TempItemLedgEntry."Rejection Reason";
                until TempItemLedgEntry.Next = 0;
            end;

            if (not QCRcptHeader_vRec.Approve) and (QCRcptHeader_vRec."Approval Status" = QCRcptHeader_vRec."approval status"::Open) then begin
                if TotalAccQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Accept" := TotalAccQty_lDec;

                if TotalRejQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Reject" := TotalRejQty_lDec;

                if TotalRewQty_lDec <> 0 then
                    QCRcptHeader_vRec."Quantity to Rework" := TotalRewQty_lDec;

                if TotalAccWithDevi_lDec <> 0 then
                    QCRcptHeader_vRec."Qty to Accept with Deviation" := TotalAccWithDevi_lDec;

                //21082024 T12436-NS
                if (QCRcptHeader_vRec."Quantity to Accept" <> 0) or (QCRcptHeader_vRec."Qty to Accept with Deviation" <> 0) then
                    if (QCRcptHeader_vRec."Quantity to Reject" > 0) and (QCRcptHeader_vRec."Item Tracking" in [QCRcptHeader_vRec."Item Tracking"::"Lot No."]) then
                        Error(Text0006_gCtx);
                //21082024 T12436-NE
                QCRcptHeader_vRec.Validate("Rejection Reason", Rejection_lcde);//T12113
                QCRcptHeader_vRec.Modify;
            end;
            exit(true);
        end else
            exit(false);

    end;

    procedure Retest_QCCollectItemEntryRelation_gFnc(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SourceType: Integer; SourceSubtype: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer; TotalQty: Decimal; QC_PostedQCNo_iCod: Code[20]): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        Quantity: Decimal;
        QCRcpt_lRec: Record "QC Rcpt. Header";
    begin
        Quantity := 0;
        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;
        // ItemEntryRelation.SetCurrentkey("Source ID", "Source Type");
        // ItemEntryRelation.SetRange("Source Type", SourceType);
        // ItemEntryRelation.SetRange("Source Subtype", SourceSubtype);
        // ItemEntryRelation.SetRange("Source ID", SourceID);
        // ItemEntryRelation.SetRange("Source Batch Name", SourceBatchName);
        // ItemEntryRelation.SetRange("Source Prod. Order Line", SourceProdOrderLine);
        // ItemEntryRelation.SetRange("Source Ref. No.", SourceRefNo);
        // if ItemEntryRelation.FindSet then
        //     repeat
        QCRcpt_lRec.get(QC_PostedQCNo_iCod);
        ItemLedgEntry.Get(QCRcpt_lRec."ILE No.");
        TempItemLedgEntry := ItemLedgEntry;
        TempItemLedgEntry."Job No." := QC_PostedQCNo_iCod;  //Temp Save QC/Posted QC No. in Job No. Field To Require in next stage
        TempItemLedgEntry.Insert;
        Quantity := Quantity + ItemLedgEntry.Quantity;
        //until ItemEntryRelation.Next = 0;
        exit(Quantity = TotalQty);
    end;

    procedure Retest_PostedQCCollectItemEntryRelation_gFnc(var TempItemLedgEntry: Record "Item Ledger Entry" temporary; SourceType: Integer; SourceSubtype: Option "0","1","2","3","4","5","6","7","8","9","10"; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer; TotalQty: Decimal; QC_PostedQCNo_iCod: Code[20]): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
        Quantity: Decimal;
        PostedQCRcpt_lRec: Record "Posted QC Rcpt. Header";
    begin
        Quantity := 0;
        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;
        // ItemEntryRelation.SetCurrentkey("Source ID", "Source Type");
        // ItemEntryRelation.SetRange("Source Type", SourceType);
        // ItemEntryRelation.SetRange("Source Subtype", SourceSubtype);
        // ItemEntryRelation.SetRange("Source ID", SourceID);
        // ItemEntryRelation.SetRange("Source Batch Name", SourceBatchName);
        // ItemEntryRelation.SetRange("Source Prod. Order Line", SourceProdOrderLine);
        // ItemEntryRelation.SetRange("Source Ref. No.", SourceRefNo);
        // if ItemEntryRelation.FindSet then
        //     repeat
        PostedQCRcpt_lRec.get(QC_PostedQCNo_iCod);
        ItemLedgEntry.Get(PostedQCRcpt_lRec."ILE No.");
        TempItemLedgEntry := ItemLedgEntry;
        TempItemLedgEntry."Job No." := QC_PostedQCNo_iCod;  //Temp Save QC/Posted QC No. in Job No. Field To Require in next stage
        TempItemLedgEntry.Insert;
        Quantity := Quantity + ItemLedgEntry.Quantity;
        //until ItemEntryRelation.Next = 0;
        exit(Quantity = TotalQty);
    end;

    procedure Retest_CallPostedItemTrackingFrmPosted_gFnc(Type: Integer; Subtype: Integer; ID: Code[20]; BatchName: Code[10]; ProdOrderLine: Integer; RefNo: Integer; PostQCRcptHeader_vRec: Record "Posted QC Rcpt. Header"): Boolean
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ItemLdgrEntry_lRec: Record "Item Ledger Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
        Rejection_lcde: Code[20];//T12113 
    begin
        // Used when calling Item Tracking from Ledger Entry:        
        Retest_PostedQCCollectItemEntryRelation_gFnc(TempItemLedgEntry, Type, Subtype, ID, BatchName, ProdOrderLine, RefNo, 0, PostQCRcptHeader_vRec."No.");

        if LotNo_gCod <> '' then
            TempItemLedgEntry.SetRange("Lot No.", LotNo_gCod);
        if not TempItemLedgEntry.IsEmpty then begin
            Page.RunModal(Page::"Posted Item QC Tracking Lines", TempItemLedgEntry);
            exit(true);
        end else
            exit(false);

    end;
    //T12113-NE

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", OnBeforeTransferOrderPostReceipt, '', false, false)]
    local procedure "TransferOrder-Post Receipt_OnBeforeTransferOrderPostReceipt"(var Sender: Codeunit "TransferOrder-Post Receipt"; var TransferHeader: Record "Transfer Header"; var CommitIsSuppressed: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    var
        i: Integer;
    begin

        i := i + 1;
    end;



}

