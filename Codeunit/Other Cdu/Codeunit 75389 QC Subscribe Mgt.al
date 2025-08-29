Codeunit 75389 "QC Subscribe Mgt."
{

    trigger OnRun()
    begin
    end;

    local procedure "=========T39=========="()
    begin
    end;

    [EventSubscriber(Objecttype::Table, 39, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure OnNoAfterValidate_gFnc(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        Item_lRec: Record Item;
        WMSManagement: Codeunit "WMS Management";
        PurchaseHeader_lRec: Record "Purchase Header";
    begin
        if Rec."Document Type" <> Rec."document type"::Order then
            exit;

        IF Rec.Type <> Rec.Type::Item then
            exit;

        if (Rec."No." <> xRec."No.") and (Rec."No." <> '') then begin
            PurchaseHeader_lRec.Get(Rec."Document Type", Rec."Document No.");
            Item_lRec.Get(Rec."No.");
            if Item_lRec."Allow QC in GRN" then begin//T12113-ABA
                QCSetup_lRec.Reset();
                QCSetup_lRec.GET();
                // if Item_lRec.CheckItemVendorCatelogueForQC(PurchaseHeader_lRec."Buy-from Vendor No.") then begin //T12115-N  //T13134-O
                if Not QCSetup_lRec."QC Block without Location" then//25112024-N
                    PurchaseHeader_lRec.TestField("Location Code");


                if Not QCSetup_lRec."QC Block without Location" then begin
                    if Location_lRec.Get(PurchaseHeader_lRec."Location Code") then begin
                        Location_lRec.TestField("QC Location");
                        Rec.Validate("Location Code", Location_lRec."QC Location");
                    end;
                end;
                // end; //T13134-O
            end;
        end;
    end;

    [EventSubscriber(Objecttype::Table, 39, 'OnAfterValidateEvent', 'Drop Shipment', false, false)]
    local procedure DropShipmentAfterValidate_gFnc(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        Item_lRec: Record Item;
        WMSManagement: Codeunit "WMS Management";
        PurchaseHeader_lRec: Record "Purchase Header";
    begin
        if Rec."Document Type" <> Rec."document type"::Order then
            exit;

        IF Rec.Type <> Rec.Type::Item then
            exit;

        if (Rec."Drop Shipment") and (Rec."No." <> '') then begin
            PurchaseHeader_lRec.Get(Rec."Document Type", Rec."Document No.");
            Item_lRec.Get(Rec."No.");
            if Item_lRec."Allow QC in GRN" then begin
                QCSetup_lRec.Reset();
                QCSetup_lRec.GET();
                // if Item_lRec.CheckItemVendorCatelogueForQC(PurchaseHeader_lRec."Buy-from Vendor No.") then begin //T13134-O
                if Not QCSetup_lRec."QC Block without Location" then//25112024-N
                    PurchaseHeader_lRec.TestField("Location Code");
                if Location_lRec.Get(PurchaseHeader_lRec."Location Code") then begin
                    if rec."Location Code" <> PurchaseHeader_lRec."Location Code" then
                        Rec."Location Code" := PurchaseHeader_lRec."Location Code";
                end;
                // end; //T13134-O
            end;
        end;
    end;

    [EventSubscriber(Objecttype::Table, 39, 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure OnLocationNoAfterValidate_gFnc(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        Item_lRec: Record Item;
        WMSManagement: Codeunit "WMS Management";
    begin
        if Rec."Document Type" <> Rec."document type"::Order then
            exit;

        if Rec.Type <> Rec.Type::Item then
            exit;

        Rec."Bin Code" := '';
        if Rec."Drop Shipment" then
            exit;

        if (Rec."Location Code" <> '') and (Rec."No." <> '') then begin
            Location_lRec.Get(Rec."Location Code");
            if Location_lRec."Bin Mandatory" and not Location_lRec."Directed Put-away and Pick" then begin
                QCSetup_lRec.Get;
                Item_lRec.Get(Rec."No.");
                if (Item_lRec."Allow QC in GRN") and//T12113-ABA
                // (Item_lRec.CheckItemVendorCatelogueForQC(Rec."Buy-from Vendor No.")) and //T12115-N //T13134-O
                 (QCSetup_lRec."Automatic QC Bin Selection") and
                   (Rec."Document Type" = Rec."document type"::Order)
                then
                    GetDefaultQCBin_lFnc(Rec."No.", Rec."Location Code", Rec."Bin Code");

                if Rec."Bin Code" = '' then
                    WMSManagement.GetDefaultBin(Rec."No.", Rec."Variant Code", Rec."Location Code", Rec."Bin Code");
                HandleDedicatedBin_lFnc(Rec, false);
            end;
        end;
    end;

    [EventSubscriber(Objecttype::Table, 39, 'OnAfterValidateEvent', 'Variant Code', false, false)]
    local procedure OnVariantAfterValidate_gFnc(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        Item_lRec: Record Item;
        WMSManagement: Codeunit "WMS Management";
    begin
        if Rec."Document Type" <> Rec."document type"::Order then
            exit;

        if Rec.Type <> Rec.Type::Item then
            exit;

        Rec."Bin Code" := '';
        if Rec."Drop Shipment" then
            exit;

        if (Rec."Location Code" <> '') and (Rec."No." <> '') then begin
            Location_lRec.Get(Rec."Location Code");
            if Location_lRec."Bin Mandatory" and not Location_lRec."Directed Put-away and Pick" then begin
                QCSetup_lRec.Get;
                Item_lRec.Get(Rec."No.");
                if (Item_lRec."Allow QC in GRN") and//T12113-ABA
                // (Item_lRec.CheckItemVendorCatelogueForQC(Rec."Buy-from Vendor No.")) and //T12115-N //T13134-O
                (QCSetup_lRec."Automatic QC Bin Selection") and
                 (Rec."Document Type" = Rec."document type"::Order)
              then
                    GetDefaultQCBin_lFnc(Rec."No.", Rec."Location Code", Rec."Bin Code");

                if Rec."Bin Code" = '' then
                    WMSManagement.GetDefaultBin(Rec."No.", Rec."Variant Code", Rec."Location Code", Rec."Bin Code");
                HandleDedicatedBin_lFnc(Rec, false);
            end;
        end;
    end;

    procedure GetDefaultQCBin_lFnc(ItemNo: Code[20]; LocationCode: Code[10]; var BinCode: Code[20]): Boolean
    var
        Bin_lRec: Record Bin;
        BinContent: Record "Bin Content";
        Location: Record Location;
    begin
        Location.Get(LocationCode);
        Bin_lRec.Reset;
        Bin_lRec.SetRange("Location Code", LocationCode);
        Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::TESTING);
        if Bin_lRec.FindFirst then begin
            BinCode := Bin_lRec.Code;
            exit(true);
        end;
    end;

    local procedure HandleDedicatedBin_lFnc(PurchaseLine_iRec: Record "Purchase Line"; IssueWarning: Boolean)
    var
        WhseIntegrationMgt: Codeunit "Whse. Integration Management";
    begin
        if not PurchaseLine_iRec.IsInbound and (PurchaseLine_iRec."Quantity (Base)" <> 0) then
            WhseIntegrationMgt.CheckIfBinDedicatedOnSrcDoc(PurchaseLine_iRec."Location Code", PurchaseLine_iRec."Bin Code", IssueWarning);
    end;

    local procedure "======== T37 =========="()
    begin
    end;

    // [EventSubscriber(Objecttype::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    // local procedure T37_OnNoAfterValidate_gFnc(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    // var
    //     Location_lRec: Record Location;
    //     QCSetup_lRec: Record "Quality Control Setup";
    //     Item_lRec: Record Item;
    //     WMSManagement: Codeunit "WMS Management";
    //     SH_lRec: Record "Sales Header";
    // begin
    //     // if Rec."Document Type" <> Rec."document type"::"Return Order" then
    //     //     exit;
    //     if Rec.Type <> rec.Type::Item then
    //         exit;

    //     if (Rec."No." <> xRec."No.") and (Rec."No." <> '') then begin
    //         if SH_lRec.Get(Rec."Document Type", Rec."Document No.") then begin
    //             Item_lRec.Get(Rec."No.");
    //             if Item_lRec."Allow QC in Sales Return" then begin//T12113-ABA                    
    //                 SH_lRec.TestField("Location Code");
    //                 if Location_lRec.Get(SH_lRec."Location Code") then begin
    //                     Location_lRec.TestField("QC Location");
    //                     Rec.Validate("Location Code", Location_lRec."QC Location");

    //                 end;
    //             end;
    //         end;
    //     end;
    // end;

    //T12115-ABA-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Sales Validation", OnBeforeCheckHeaderLocation, '', false, false)]
    local procedure "GST Sales Validation_OnBeforeCheckHeaderLocation"(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        Item_lRec: Record Item;
        SH_lRec: Record "Sales Header";
    begin
        /* if SalesLine."Document Type" <> SalesLine."document type"::"Return Order" then
            exit;
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;

        if (SalesLine."No." <> '') then begin
            if SH_lRec.Get(SalesLine."Document Type", SalesLine."Document No.") then begin
                Item_lRec.Get(SalesLine."No.");
                if Item_lRec."Allow QC in Sales Return" then begin
                    IsHandled := true;
                end;
            end;
        end; */
        IsHandled := true; //18-12-2024 As per YT
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnCopySalesInvLinesToDocOnAfterCopySalesDocLine, '', false, false)]
    // local procedure "Copy Document Mgt._OnCopySalesInvLinesToDocOnAfterCopySalesDocLine"(ToSalesLine: Record "Sales Line"; FromSalesInvLine: Record "Sales Invoice Line")
    // var
    //     Item_lRec: Record Item;
    //     Location_lRec: Record Location;
    //     QualityControlSetup_lRec: Record "Quality Control Setup";
    // begin

    //     if ToSalesLine."Document Type" <> ToSalesLine."document type"::"Return Order" then
    //         exit;

    //     IF ToSalesLine.Type <> ToSalesLine.Type::Item then
    //         exit;

    //     Item_lRec.Get(FromSalesInvLine."No.");
    //     if Not Item_lRec."Allow QC in Sales Return" then
    //         exit;

    //     Item_lRec.Get(FromSalesInvLine."No.");
    //     if Item_lRec."Allow QC in Sales Return" then begin
    //         if Location_lRec.Get(FromSalesInvLine."Location Code") then begin
    //             Location_lRec.TestField("QC Location");
    //             ToSalesLine.Validate("Location Code", Location_lRec."QC Location");

    //         ToSalesLine.Modify();
    //         end;
    //     end;

    // end;
    //T12115-ABA-NE







    // [EventSubscriber(Objecttype::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    // local procedure T37_OnLocationNoAfterValidate_gFnc(var xRec: Record "Purchase Line"; var Rec: Record "Purchase Line"; CurrFieldNo: Integer)
    // var
    //     Location_lRec: Record Location;
    //     QCSetup_lRec: Record "Quality Control Setup";
    //     Item_lRec: Record Item;
    //     WMSManagement: Codeunit "WMS Management";
    // begin
    //     if Rec."Document Type" <> Rec."document type"::Order then
    //         exit;

    //     if Rec.Type <> Rec.Type::Item then
    //         exit;

    //     Rec."Bin Code" := '';
    //     if Rec."Drop Shipment" then
    //         exit;

    //     if (Rec."Location Code" <> '') and (Rec."No." <> '') then begin
    //         Location_lRec.Get(Rec."Location Code");
    //         if Location_lRec."Bin Mandatory" and not Location_lRec."Directed Put-away and Pick" then begin
    //             QCSetup_lRec.Get;
    //             Item_lRec.Get(Rec."No.");
    //             if (Item_lRec."QC Required") and
    //                (QCSetup_lRec."Automatic QC Bin Selection") and
    //                (Rec."Document Type" = Rec."document type"::Order)
    //             then
    //                 GetDefaultQCBin_lFnc(Rec."No.", Rec."Location Code", Rec."Bin Code");

    //             if Rec."Bin Code" = '' then
    //                 WMSManagement.GetDefaultBin(Rec."No.", Rec."Variant Code", Rec."Location Code", Rec."Bin Code");
    //             HandleDedicatedBin_lFnc(Rec, false);
    //         end;
    //     end;
    // end;

    // [EventSubscriber(Objecttype::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Variant Code', false, false)]
    // local procedure T37_OnVariantAfterValidate_gFnc(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    // var
    //     Location_lRec: Record Location;
    //     QCSetup_lRec: Record "Quality Control Setup";
    //     Item_lRec: Record Item;
    //     WMSManagement: Codeunit "WMS Management";
    // begin
    //     if Rec."Document Type" <> Rec."document type"::Order then
    //         exit;

    //     if Rec.Type <> Rec.Type::Item then
    //         exit;

    //     Rec."Bin Code" := '';
    //     if Rec."Drop Shipment" then
    //         exit;

    //     if (Rec."Location Code" <> '') and (Rec."No." <> '') then begin
    //         Location_lRec.Get(Rec."Location Code");
    //         if Location_lRec."Bin Mandatory" and not Location_lRec."Directed Put-away and Pick" then begin
    //             QCSetup_lRec.Get;
    //             Item_lRec.Get(Rec."No.");
    //             if (Item_lRec."QC Required") and
    //                (QCSetup_lRec."Automatic QC Bin Selection") and
    //                (Rec."Document Type" = Rec."document type"::Order)
    //             then
    //                 GetDefaultQCBin_lFnc(Rec."No.", Rec."Location Code", Rec."Bin Code");

    //             if Rec."Bin Code" = '' then
    //                 WMSManagement.GetDefaultBin(Rec."No.", Rec."Variant Code", Rec."Location Code", Rec."Bin Code");
    //             HandleDedicatedBin_lFnc(Rec, false);
    //         end;
    //     end;
    // end;

    local procedure "======= T83 ========="()
    begin
    end;

    [EventSubscriber(Objecttype::Page, Page::"Output Journal", 'OnDeleteRecordEvent', '', false, false)]
    local procedure T83_OnBeforeDeleteSub_lFnc(var Rec: Record "Item Journal Line"; var AllowDelete: Boolean)
    var
        QCProduction_gCdu: Codeunit "Quality Control - Production";
    begin
        QCProduction_gCdu.CheckQCRcptExist_gFnc(Rec); //I-C0009-1001310-04-N
    end;

    [EventSubscriber(Objecttype::Table, 83, 'OnAfterValidateEvent', 'Output Quantity', false, false)]
    local procedure T83_OnAfterValidateOutQty_lFnc(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        QCProduction_gCdu: Codeunit "Quality Control - Production";
    begin
        //I-C0009-1001310-04-NS
        if not (Rec."Rejected QC Line") then
            QCProduction_gCdu.CheckQuantity_lFnc(Rec);
        //I-C0009-1001310-04-NE
    end;

    local procedure "====== T5741 ======"()
    begin
    end;

    [EventSubscriber(Objecttype::Table, 5741, 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure T5741_ItemAfterValidate_lFnc(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        Item_lRec: Record Item;
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        TransferHeader_lRec: Record "Transfer Header";

    begin
        if Rec."Item No." = '' then
            exit;

        Item_lRec.Get(Rec."Item No.");
        if Item_lRec."Allow QC in Transfer Receipt" then begin
            Rec."QC Required" := Item_lRec."Allow QC in Transfer Receipt";//T12113-ABA Yaksh
            TransferHeader_lRec.get(rec."Document No.");
            TransferHeader_lRec.TestField("Transfer-to Code");

            QCSetup_lRec.get;//T12968-N
            if Not QCSetup_lRec."QC Block without Location" then begin //T12968-N
                if Location_lRec.Get(TransferHeader_lRec."Transfer-to Code") then begin
                    Location_lRec.TestField("QC Location");
                    Rec.Validate("Transfer-to Code", Location_lRec."QC Location");
                end;
                //T12968-NS
            end else begin
                Rec.Validate("Transfer-to Code", TransferHeader_lRec."Transfer-to Code");
            end;
            //T12968-NE            
        end;
    end;

    local procedure "========C21==========="()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 21, 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure OnAfterItemJnlChkLine_gFnc(var ItemJnlLine: Record "Item Journal Line")
    var
        QualityControlGeneral_lCdu: Codeunit "Quality Control - General";
        SourceCodeSetup_lRec: Record "Source Code Setup";
        Text50000_gCtx: label 'should not be (QC, Rejection, Rework) Location';
        QCProd_lCdu: Codeunit "Quality Control - Production";
    begin
        //C0009-NS 100417  //Check Item Reclass Journal Post Not Allowed for QC,Reject Location
        //CP-NS
        SourceCodeSetup_lRec.Get;
        if SourceCodeSetup_lRec."Item Reclass. Journal" = ItemJnlLine."Source Code" then begin
            if (ItemJnlLine."Entry Type" = ItemJnlLine."entry type"::Transfer) and (not ItemJnlLine."Skip Confirm Msg") and (not ItemJnlLine.Adjustment) then begin
                Clear(QualityControlGeneral_lCdu);
                if QualityControlGeneral_lCdu.CheckLocQCReject_gFnc(ItemJnlLine."Location Code") then
                    ItemJnlLine.FieldError("Location Code", Text50000_gCtx);
            end;
        end;
        //C0009-NE 100417

        Clear(QCProd_lCdu);
        QCProd_lCdu.CheckOPforRntLine_gFnc(ItemJnlLine);  //C0009-N 101019
    end;

    local procedure "=======C22=========="()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 22, 'OnBeforePostLineByEntryType', '', false, false)]
    local procedure OnBeforePostLineByEntryType_gFnc(var ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean)
    var
        QCProduction_lCdu: Codeunit "Quality Control - Production";
    begin
        if ItemJournalLine."Entry Type" <> ItemJournalLine."entry type"::Output then
            exit;

        //I-C0009-1001310-04-NS
        Clear(QCProduction_lCdu);
        QCProduction_lCdu.ChangeIJLforSerialLotNo_gFnc(ItemJournalLine);    //QCV3-N  30-01-18
        QCProduction_lCdu.CheckPrevOperationPosted_gFnc(ItemJournalLine);
        QCProduction_lCdu.PostOutputCheck_gFnc(ItemJournalLine);
        //I-C0009-1001310-04-NE
    end;

    [EventSubscriber(Objecttype::Codeunit, 22, 'OnBeforeInsertCapLedgEntry', '', false, false)]
    local procedure OnBeforeInsertCapLedgEntry_gFnc(var CapLedgEntry: Record "Capacity Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        ProdOrderRtngLine_lRec: Record "Prod. Order Routing Line";
        QCProduction_lCdu: Codeunit "Quality Control - Production";
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        //I-C0009-1001310-04-NS  //QCV4-NS
        if not ItemJournalLine.Subcontracting then begin
            QCSetup_lRec.Get;
            ProdOrderRtngLine_lRec.Reset;
            ProdOrderRtngLine_lRec.SetRange(Status, ProdOrderRtngLine_lRec.Status::Released);
            ProdOrderRtngLine_lRec.SetRange("Prod. Order No.", ItemJournalLine."Order No.");
            ProdOrderRtngLine_lRec.SetRange("Routing No.", ItemJournalLine."Routing No.");
            ProdOrderRtngLine_lRec.SetRange("Routing Reference No.", ItemJournalLine."Routing Reference No.");
            ProdOrderRtngLine_lRec.SetFilter("Routing Status", '<> %1', ProdOrderRtngLine_lRec."routing status"::Finished);
            ProdOrderRtngLine_lRec.SetRange("Operation No.", ItemJournalLine."Operation No.");
            if ProdOrderRtngLine_lRec.FindFirst then begin
                if ProdOrderRtngLine_lRec."QC Required" then begin
                    CapLedgEntry."Input Quantity" := ItemJournalLine."Accepted Quantity" + ItemJournalLine."Qty Accepted with Deviation" + ItemJournalLine."Rework Quantity" + ItemJournalLine."Scrap Quantity";
                    CapLedgEntry."Accepted Quantity" := ItemJournalLine."Accepted Quantity";
                    CapLedgEntry."Qty Accepted With Deviation" := ItemJournalLine."Qty Accepted with Deviation";
                    CapLedgEntry."Rework Quantity" := ItemJournalLine."Rework Quantity";
                    CapLedgEntry."Reject Quantity" := ItemJournalLine."Reject Quantity";
                    CapLedgEntry."QC No." := ItemJournalLine."QC No.";
                    CapLedgEntry."Posted QC No." := ItemJournalLine."Posted QC No.";
                end else
                    CapLedgEntry."Accepted Quantity" := ItemJournalLine."Output Quantity";
            end;
        end;
        //I-C0009-1001310-04-NE  //QCV4-NE
    end;

    [EventSubscriber(Objecttype::Codeunit, 22, 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure OnAfterInitItemLedgEntry_gFnc(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)

    begin
        NewItemLedgEntry."QC No." := ItemJournalLine."QC No.";                //I-C0009-1001310-04-N
        NewItemLedgEntry."Posted QC No." := ItemJournalLine."Posted QC No.";  //I-C0009-1001310-04-N
        NewItemLedgEntry."QC Relation Entry No." := ItemJournalLine."QC Relation Entry No.";//T12113-ABA-N
        NewItemLedgEntry.Retest := ItemJournalLine.Retest;//T12113-ABA-N
        NewItemLedgEntry."Rework Quantity" := ItemJournalLine."Rework Quantity";//31-12-2024
        NewItemLedgEntry."Overall Changes" := ItemJournalLine."Overall Changes";//T51170-N


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeInsertItemLedgEntry, '', false, false)]
    local procedure "Item Jnl.-Post Line_OnBeforeInsertItemLedgEntry"(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; TransferItem: Boolean; OldItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLineOrigin: Record "Item Journal Line")
    var
        Loaction_lRec: Record Location;//T12113-ABA-N
    begin
        Clear(Loaction_lRec);
        if Loaction_lRec.get(ItemLedgerEntry."Location Code") then
            ItemLedgerEntry."Location QC Category" := Loaction_lRec."QC Category";
    end;


    [EventSubscriber(Objecttype::Codeunit, 22, 'OnAfterInsertItemLedgEntry', '', false, false)]
    local procedure OnAfterInsertItemLedgEntry_gFnc(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer; var ValueEntryNo: Integer; var ItemApplnEntryNo: Integer)
    var
        QualityControlProduction_lCdu: Codeunit "Quality Control - Production";
    begin
        //C0009-SubConQCV2-NS
        Clear(QualityControlProduction_lCdu);
        //QualityControlProduction_lCdu.CreateReservationBackForSubConQC_gFnc(ItemLedgerEntry,ItemJournalLine);
        //C0009-SubConQCV2-NE
    end;

    local procedure "========C90==========="()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 90, 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnPurchPostBeforRun_gFnc(var Sender: Codeunit "Purch.-Post"; var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    var
        PurchaseLine_lRec: Record "Purchase Line";
        QualityControlGeneral_lCdu: Codeunit "Quality Control - General";
    begin
        // if PurchaseHeader."Document Type" = PurchaseHeader."document type"::Order then begin
        //     Clear(QualityControlGeneral_lCdu);
        // if QualityControlGeneral_lCdu.CheckLocQCReject_gFnc(PurchaseHeader."Location Code") then
        //     PurchaseHeader.FieldError("Location Code", 'should not be (QC, Rejection, Rework) Location');
        // end;
        // For Kemipex as normal location and QC, Rejection, Rework location are same this validation is not required.

        if PurchaseHeader."Document Type" in [PurchaseHeader."document type"::"Return Order", PurchaseHeader."document type"::"Credit Memo"] then begin
            PurchaseLine_lRec.Reset;
            PurchaseLine_lRec.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine_lRec.SetRange("Document No.", PurchaseHeader."No.");
            PurchaseLine_lRec.SetFilter(Quantity, '<>%1', 0);
            if PurchaseLine_lRec.FindSet then begin
                repeat
                    Clear(QualityControlGeneral_lCdu);
                    if QualityControlGeneral_lCdu.CheckOnlyQCLocation_gFnc(PurchaseLine_lRec."Location Code") then
                        PurchaseLine_lRec.FieldError("Location Code", 'cannot not be QC Location for Purchase Return Order');
                until PurchaseLine_lRec.Next = 0;
            end;
        end;
    end;

    [EventSubscriber(Objecttype::Codeunit, 90, 'OnBeforePurchRcptLineInsert', '', false, false)]
    local procedure OnBeforePurchRcptLineInsert_gFnc(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    var
        Item_lRec: Record Item;
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        if (PurchRcptLine.Type = PurchRcptLine.Type::Item) and (PurchRcptLine.Quantity <> 0) then begin
            Item_lRec.Get(PurchRcptLine."No.");
            QCSetup_lRec.Get;
            //T12113-ABA-NS
            if (Item_lRec."Allow QC in GRN") then begin
                // if Item_lRec.CheckItemVendorCatelogueForQC(PurchRcptLine."Buy-from Vendor No.") then begin //T12115-N T13134
                PurchRcptLine."QC Required" := Item_lRec."Allow QC in GRN";
                PurchRcptLine."QC Pending" := Item_lRec."Allow QC in GRN";

                // end;
                //T12113-ABA-NE
            end;
        end;
    end;

    //NG-NS 011223
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeReturnRcptLineInsert', '', false, false)]
    local procedure OnBeforeReturnRcptLineInsert(var ReturnRcptLine: Record "Return Receipt Line"; ReturnRcptHeader: Record "Return Receipt Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; xSalesLine: Record "Sales Line"; var TempSalesLineGlobal: Record "Sales Line" temporary);
    var
        Item_lRec: Record Item;
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        if (ReturnRcptLine.Type = ReturnRcptLine.Type::Item) and (ReturnRcptLine.Quantity <> 0) then begin
            Item_lRec.Get(ReturnRcptLine."No.");
            QCSetup_lRec.Get;
            //T12113-ABA-NS
            if (Item_lRec."Allow QC in Sales Return") then begin
                ReturnRcptLine."QC Required" := Item_lRec."Allow QC in Sales Return";
                ReturnRcptLine."QC Pending" := Item_lRec."Allow QC in Sales Return";
            end;
            //T12113-ABA-NE
        end;
    end;

    local procedure "========C81==========="()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 81, 'OnAfterPost', '', false, false)]
    local procedure OnAfterSalePost_gFnc(var SalesHeader: Record "Sales Header")
    var
        QCSalesReturn_lCdu: Codeunit "Quality Control - Sales Return";
        SalesLine_lRec: Record "Sales Line";
    begin
        if SalesHeader.Receive then
            QCSalesReturn_lCdu.QCCreatedMsg_gFnc(SalesHeader);


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeUpdateWhseDocuments, '', false, false)]
    local procedure "Sales-Post_OnBeforeUpdateWhseDocuments"(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; WhseReceive: Boolean; WhseShip: Boolean; WhseRcptHeader: Record "Warehouse Receipt Header"; WhseShptHeader: Record "Warehouse Shipment Header"; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary)
    var
        QCSalesReturn_lCdu: Codeunit "Quality Control - Sales Return";
        SalesLine_lRec: Record "Sales Line";
    begin
        //T12166-NS
        if WhseRcptHeader."No." <> '' then begin
            if SalesHeader.Receive then
                QCSalesReturn_lCdu.QCCreatedMsg_gFnc(SalesHeader);
        end;
        //T12166-NE
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterReturnRcptLineInsert', '', false, false)]
    local procedure OnAfterReturnRcptLineInsert(var ReturnRcptLine: Record "Return Receipt Line"; ReturnRcptHeader: Record "Return Receipt Header"; SalesLine: Record "Sales Line"; ItemShptLedEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; var SalesHeader: Record "Sales Header");
    var
        QCSetup_lRec: Record "Quality Control Setup";
        QCRtn_lCdu: Codeunit "Quality Control - Sales Return";
    begin
        if (ReturnRcptLine."QC Required") then begin
            QCSetup_lRec.Get;
            if QCSetup_lRec."Auto Create QC on Sales Return" then
                QCRtn_lCdu.CreateQCRcpt_gFnc(ReturnRcptLine, false);

        end;
    end;

    //T12166-ABA-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", OnBeforeOnRun, '', false, false)]
    local procedure "Sales-Post (Yes/No)_OnBeforeOnRun"(var SalesHeader: Record "Sales Header")
    var
        QCRtn_lCdu: Codeunit "Quality Control - Sales Return";
        SalesLine: Record "Sales Line";
        item_lRec: Record item;
    begin
        SalesLine.reset;
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '>%1', 0);
        if SalesLine.FindSet() then
            repeat
                item_lRec.get(SalesLine."No.");
                if item_lRec."Allow QC in Sales Return" then
                    QCRtn_lCdu.QCReservationMsg_gFnc(SalesLine);
            until SalesLine.next = 0;
    end;
    //T12166-ABA-NE





    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnRunOnBeforeFinalizePosting, '', false, false)]
    local procedure "Sales-Post_OnRunOnBeforeFinalizePosting"(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; GenJnlLineExtDocNo: Code[35]; var EverythingInvoiced: Boolean; GenJnlLineDocNo: Code[20]; SrcCode: Code[10]; PreviewMode: Boolean)
    var
        QCMgmt: Codeunit "Quality Control - Sales Return";
    begin
        if ReturnReceiptHeader."No." = '' then
            exit;
        QCMgmt.CreateandPostItemReclas(ReturnReceiptHeader."No.");//Movement Entry StoreLocation To QC
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", 'OnAfterInsertEvent', '', true, true)]
    // local procedure "IleLine_OnAfterInsertEvent"
    // (
    //     var Rec: Record "Item Ledger Entry";
    //     RunTrigger: Boolean
    // )
    // var

    // begin
    //     if rec.IsTemporary then
    //         exit;

    //     rec.TestField(Description);
    // end;


    //NG-NE 011223


    [EventSubscriber(Objecttype::Codeunit, 90, 'OnAfterPurchRcptLineInsert', '', false, false)]
    local procedure OnAfterPurchRcptLineInsert_gFnc(PurchaseLine: Record "Purchase Line"; PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean)
    var
        QCSetup_lRec: Record "Quality Control Setup";
        QCPurchase_lCdu: Codeunit "Quality Control - Purchase";
    begin
        if (PurchRcptLine."QC Required") and (not PurchRcptLine."Pre-Receipt Inspection") and (not PurchaseLine."Drop Shipment") then begin//T12547-N
            QCSetup_lRec.Get;
            if QCSetup_lRec."Auto Create QC on GRN" then
                QCPurchase_lCdu.CreateQCRcpt_gFnc(PurchRcptLine, false);
        end;
    end;

    [EventSubscriber(Objecttype::Codeunit, 90, 'OnBeforeReturnShptLineInsert', '', false, false)]
    local procedure OnBeforeReturnShptLineInsert_gFnc(var ReturnShptLine: Record "Return Shipment Line"; var ReturnShptHeader: Record "Return Shipment Header"; var PurchLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    begin
        ReturnShptLine."Receipt No." := PurchLine."Receipt No.";
        ReturnShptLine."Receipt Line No." := PurchLine."Receipt Line No.";
    end;

    [EventSubscriber(Objecttype::Codeunit, 90, 'OnAfterReturnShptLineInsert', '', false, false)]
    procedure OnAfterReturnShptLineInsert_gFnc(var ReturnShptLine: Record "Return Shipment Line"; ReturnShptHeader: Record "Return Shipment Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary)
    var
        PostedQCRcpt_lRec: Record "Posted QC Rcpt. Header";
        TotalReturnedQty_lDec: Decimal;
    begin
        if PostedQCRcpt_lRec.Get(ReturnShptLine."QC No.") then begin
            TotalReturnedQty_lDec := PostedQCRcpt_lRec."Returned Quantity" + ReturnShptLine.Quantity;
            PostedQCRcpt_lRec.Validate("Returned Quantity", TotalReturnedQty_lDec);
            PostedQCRcpt_lRec.Modify;
        end;
    end;

    local procedure "========C91==========="()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 91, 'OnAfterPost', '', false, false)]
    local procedure OnAfterPost_gFnc(var PurchaseHeader: Record "Purchase Header")
    var
        QCPurchase_lCdu: Codeunit "Quality Control - Purchase";
    begin
        if PurchaseHeader.Receive then
            QCPurchase_lCdu.QCCreatedMsg_gFnc(PurchaseHeader);
    end;



    local procedure "========C5813=========="()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 5813, 'OnBeforeOnRun', '', false, false)]
    local procedure OnBeforeRun_gFnc(var PurchRcptLine: Record "Purch. Rcpt. Line"; var IsHandled: Boolean)
    begin
        ChkMandatoryQCFields_gFnc(PurchRcptLine);
    end;

    [EventSubscriber(Objecttype::Codeunit, 5813, 'OnAfterInsertNewReceiptLine', '', false, false)]
    local procedure OnAfterInsertPurchRcptLine_gFnc(var PurchRcptLine: Record "Purch. Rcpt. Line"; PostedWhseReceiptLine: Record "Posted Whse. Receipt Line"; var PostedWhseRcptLineFound: Boolean; DocLineNo: Integer)
    begin
        PurchRcptLine."QC Pending" := false;
    end;

    local procedure ChkMandatoryQCFields_gFnc(PurchRcptLine_iRec: Record "Purch. Rcpt. Line")
    var
        QCRcptHdr_lRec: Record "QC Rcpt. Header";
    begin
        if PurchRcptLine_iRec."QC Required" then begin
            QCRcptHdr_lRec.reset;
            QCRcptHdr_lRec.SetRange("Document Type", QCRcptHdr_lRec."Document Type"::Purchase);
            QCRcptHdr_lRec.SetRange("Document No.", PurchRcptLine_iRec."Document No.");
            QCRcptHdr_lRec.SetRange("Document Line No.", PurchRcptLine_iRec."Line No.");
            QCRcptHdr_lRec.SetRange("Item No.", PurchRcptLine_iRec."No.");
            if QCRcptHdr_lRec.FindSet() then begin//20-01-2024-N Hypercare
                PurchRcptLine_iRec.TestField("Accepted Quantity", 0);
                PurchRcptLine_iRec.TestField("Accepted with Deviation Qty", 0);
                PurchRcptLine_iRec.TestField("Rejected Quantity", 0);
                PurchRcptLine_iRec.TestField("Under Inspection Quantity", 0);
                PurchRcptLine_iRec.TestField("Reworked Quantity", 0);
            end;
        end;
    end;

    [EventSubscriber(Objecttype::Codeunit, 5813, 'OnBeforeCheckPurchRcptLine', '', false, false)]
    local procedure OnBeforeCheckPurchRcptLine_gFnc(var PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
        ChkMandatoryQCFields_gFnc(PurchRcptLine);
    end;

    [EventSubscriber(Objecttype::Codeunit, 5813, 'OnBeforeNewPurchRcptLineInsert', '', false, false)]
    local procedure OnBeforeNewPurchRcptLineInsert_gFnc(var NewPurchRcptLine: Record "Purch. Rcpt. Line"; OldPurchRcptLine: Record "Purch. Rcpt. Line")
    begin
        NewPurchRcptLine."QC Pending" := false;
    end;

    local procedure "======C333========"()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 333, 'OnAfterPurchOrderLineInsert', '', false, false)]
    local procedure C333_OnAfterPurchOrderLineInsert(var PurchOrderLine: Record "Purchase Line"; var RequisitionLine: Record "Requisition Line")
    var
        Item_lRec: Record Item;
        Location_lRec: Record Location;
        Bin_lRec: Record Bin;
        PurchaseHeader_lRec: Record "Purchase Header";
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        //I-C0009-1001310-04-NS
        if Item_lRec.Get(PurchOrderLine."No.") then begin
            //if Item_lRec."Allow QC in GRN" then begin//T12113-ABA //T12115-O
            if (Item_lRec."Allow QC in GRN") then begin //T12115-N
                //  if (Item_lRec."Allow QC in GRN") and (Item_lRec.CheckItemVendorCatelogueForQC(PurchOrderLine."Buy-from Vendor No.")) then begin //T12115-N//T13134-O
                PurchaseHeader_lRec.Get(PurchOrderLine."Document Type", PurchOrderLine."Document No.");

                QCSetup_lRec.Reset();
                QCSetup_lRec.GET();

                if Not QCSetup_lRec."QC Block without Location" then begin
                    if Location_lRec.Get(PurchaseHeader_lRec."Location Code") then begin
                        Location_lRec.TestField("QC Location");
                        PurchOrderLine.Validate("Location Code", Location_lRec."QC Location");
                    end;
                end;

                //SubConChngV2-NS
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", PurchOrderLine."Location Code");
                if Bin_lRec.FindFirst then
                    PurchOrderLine."Bin Code" := Bin_lRec.Code;
                //SubConChngV2-NE
            end else
                PurchOrderLine."Bin Code" := RequisitionLine."Bin Code";
        end;
        //I-C0009-1001310-04-NE
    end;

    local procedure "========C 99000773 ======="()
    begin
    end;

    [EventSubscriber(Objecttype::Codeunit, 99000773, 'OnAfterTransferRoutingLine', '', false, false)]
    procedure C99000773_OnAfterTransferRoutingLine_gFnc(var ProdOrderLine: Record "Prod. Order Line"; var RoutingLine: Record "Routing Line"; var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
        ProdOrderRoutingLine."QC Required" := RoutingLine."QC Required";
    end;

    local procedure "===== Attachment ====="()
    begin
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', true, true)]
    local procedure "Document Attachment Factbox_OnBeforeDrillDown"
(
    DocumentAttachment: Record "Document Attachment";
    var RecRef: RecordRef
)
    begin
        IF DocumentAttachment."Table ID" = 75384 Then begin
            RecRef.Open(DATABASE::"Posted QC Rcpt. Header");
            PostedQCRcptHeader_gRec.RESET;
            PostedQCRcptHeader_gRec.Setrange("No.", DocumentAttachment."No.");
            if PostedQCRcptHeader_gRec.FindFirst then
                RecRef.GetTable(PostedQCRcptHeader_gRec);

        end;
        IF DocumentAttachment."Table ID" = 75382 Then begin
            RecRef.Open(DATABASE::"QC Rcpt. Header");
            QCRcptHeader_gRec.RESET;
            QCRcptHeader_gRec.Setrange("No.", DocumentAttachment."No.");
            if QCRcptHeader_gRec.FindFirst then
                RecRef.GetTable(QCRcptHeader_gRec);

        end;
    end;


    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', true, true)]
    local procedure "Document Attachment Details_OnAfterOpenForRecRef"
    (
        var DocumentAttachment: Record "Document Attachment";
        var RecRef: RecordRef
    )
    begin
        IF RecRef.Number = 75384 Then begin
            FieldRef := RecRef.Field(1);
            RecNo := FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
        end;
        IF RecRef.Number = 75382 Then begin
            FieldRef := RecRef.Field(1);
            RecNo := FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeInsertAttachment', '', true, true)]
    local procedure "Document Attachment_OnBeforeInsertAttachment"
    (
        var DocumentAttachment: Record "Document Attachment";
        var RecRef: RecordRef
    )
    begin
        IF RecRef.Number = 75384 Then begin
            FieldRef := RecRef.Field(1);
            RecNo := FieldRef.Value;
            DocumentAttachment.Validate("No.", RecNo);
        end;
        IF RecRef.Number = 75382 Then begin
            FieldRef := RecRef.Field(1);
            RecNo := FieldRef.Value;
            DocumentAttachment.Validate("No.", RecNo);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterTransRcptLineModify', '', false, false)]
    local procedure C5705_OnAfterTransRcptLineModify(CommitIsSuppressed: Boolean; TransferLine: Record "Transfer Line"; var TransferReceiptLine: Record "Transfer Receipt Line")
    var
        Item_lRec: Record Item;//T12115-ABA
        QCSetup_lRec: Record "Quality Control Setup";
        QCTransferRcpt_lCdu: Codeunit "Quality Control -Transfer Rcpt";
    begin
        IF (TransferReceiptLine."QC Required") THEN BEGIN
            CLEAR(Item_lRec);
            Item_lRec.GET(TransferReceiptLine."Item No.");
            QCSetup_lRec.GET;
            IF (Item_lRec."Allow QC in Transfer Receipt") AND (QCSetup_lRec."Auto CreateQC on Transfer Rcpt") THEN
                QCTransferRcpt_lCdu.CreateQCRcpt_gFnc(TransferReceiptLine, FALSE);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeInsertTransRcptLine', '', false, false)]
    local procedure C5705_OnBeforeInsertTransRcptLine(CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; var IsHandled: Boolean; var TransRcptLine: Record "Transfer Receipt Line")
    var
        QCSetup_lRec: Record "Quality Control Setup";
        Item_lRec: Record Item;
        Location_lRec: Record Location;
    begin
        //I-C0009-1001310-06-NS
        IF (TransRcptLine.Quantity <> 0) THEN BEGIN
            Item_lRec.GET(TransRcptLine."Item No.");
            QCSetup_lRec.GET;
            Location_lRec.GET(TransLine."Transfer-to Code");
            //T12113-ABA-NS
            IF (Item_lRec."Allow QC in Transfer Receipt") THEN BEGIN//T12113-ABA
                TransRcptLine."QC Required" := Item_lRec."Allow QC in Transfer Receipt";
                TransRcptLine."QC Pending" := Item_lRec."Allow QC in Transfer Receipt";
            END;
            //T12113-ABA-NE
        END;
        //I-C0009-1001310-06-NE
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterCheckBeforePost', '', false, false)]
    // local procedure T5704_OnAfterCheckBeforePost(var TransferHeader: Record "Transfer Header")
    // var
    //     QualityControlGeneral_lCdu: Codeunit "Quality Control - General";
    // begin
    //     CLEAR(QualityControlGeneral_lCdu);
    //     IF QualityControlGeneral_lCdu.CheckLocQCReject_gFnc(TransferHeader."Transfer-from Code") THEN
    //         TransferHeader.FIELDERROR("Transfer-from Code", 'should not be (QC, Rejection, Rework) Location');
    // end;
    // For Kemipex as normal location and QC, Rejection, Rework location are same this validation is not required.


    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforeTestItemFields', '', false, false)]
    local procedure OnBeforeTestItemFields(var ItemJournalLine: Record "Item Journal Line"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; var IsHandled: Boolean);
    begin
        IF ItemJournalLine."Document Type" = ItemJournalLine."Document Type"::"Purchase Receipt" then
            IsHandled := true;  //NG-N 150223 In Case of QC Receipt in Subcon - SKip Location Check
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl. Line-Reserve", 'OnBeforeTestOldReservEntryLocationCode', '', false, false)]
    local procedure OnBeforeTestOldReservEntryLocationCode(var OldReservEntry: Record "Reservation Entry"; var ItemJnlLine: Record "Item Journal Line"; var IsHandled: Boolean);
    begin
        IF (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Output) AND (ItemJnlLine."Source Code" = 'PURCHASES') then
            IsHandled := true;  //NG-N 150223 In Case of QC Receipt in Subcon - SKip Location Check
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GST Purchase Subscribers", 'OnBeforeCheckHeaderLocation', '', false, false)]
    local procedure OnBeforeCheckHeaderLocation(PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean);
    var
        PH_lRec: Record "Purchase Header";
        Item_lRec: Record Item;
    begin
        if PurchaseLine."Document Type" <> PurchaseLine."document type"::Order then
            exit;
        if PurchaseLine.Type <> PurchaseLine.Type::Item then
            exit;

        IF NOT PH_lRec.GET(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            Exit;

        //IF NOT PH_lRec.Subcontracting then
        //  Exit;
        if (PurchaseLine."No." <> '') then begin
            if PH_lRec.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then begin
                Item_lRec.Get(PurchaseLine."No.");
                if Item_lRec."Allow QC in Sales Return" then begin
                    IsHandled := true;
                end;
            end;
        end;

        // IsHandled := true;  //NG-N Skip Error in Subcon Worksheet Calculation 170223
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Get Source Doc. Inbound", 'OnAfterSetWarehouseRequestFilters', '', false, false)]
    local procedure OnAfterSetWarehouseRequestFilters(var WarehouseRequest: Record "Warehouse Request"; WarehouseReceiptHeader: Record "Warehouse Receipt Header");
    var
        Locaion_lRec: Record Location;
    begin
        IF Locaion_lRec.GET(WarehouseReceiptHeader."Location Code") Then begin
            IF Locaion_lRec."QC Location" <> '' THen begin
                WarehouseRequest.FilterGroup(2);
                WarehouseRequest.SetRange("Location Code");
                WarehouseRequest.SetFilter("Location Code", '%1|%2', Locaion_lRec.Code, Locaion_lRec."QC Location");
                WarehouseRequest.FilterGroup(0);
            end;
        end;
    end;
    //T12115-ABA-NS  
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Transfer Line-Reserve", OnBeforeTransferTransferToItemJnlLine, '', false, false)]
    local procedure "Transfer Line-Reserve_OnBeforeTransferTransferToItemJnlLine"(var TransferLine: Record "Transfer Line"; var ItemJournalLine: Record "Item Journal Line"; Direction: Enum "Transfer Direction"; var IsHandled: Boolean)
    begin
        case Direction of
            Direction::Inbound:
                begin
                    if TransferLine."QC Required" then
                        ItemJournalLine."New Location Code" := TransferLine."Transfer-to Code";
                end;
        end;
    end;
    //T12115-ABA-NE
    //T12115-ABA-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", OnBeforePostItemJournalLine, '', false, false)]
    local procedure "TransferOrder-Post Receipt_OnBeforePostItemJournalLine"(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; TransferReceiptLine: Record "Transfer Receipt Line"; CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; PostedWhseRcptHeader: Record "Posted Whse. Receipt Header")
    begin
        if TransferReceiptLine."QC Required" then
            ItemJournalLine."New Location Code" := TransferReceiptLine."Transfer-to Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", OnAfterCopyFromTransferLine, '', false, false)]
    local procedure "Transfer Receipt Line_OnAfterCopyFromTransferLine"(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
        TransferReceiptLine."QC Required" := TransferLine."QC Required";
    end;
    //T12115-ABA-NE


    [EventSubscriber(ObjectType::Table, Database::"QC Rcpt. Header", OnAfterDeleteEvent, '', false, false)]
    local procedure T_QCRCPT_OnAfterDeleteEvent(var Rec: Record "QC Rcpt. Header"; RunTrigger: Boolean)
    var
        SalesLine_lRec: Record "Sales Line";
        FromDocAttachment_lRec: Record "Document Attachment";
        PurchaseLine_lRec: Record "Purchase Line";//T12547-N
    begin
        if Rec.IsTemporary then
            exit;
        if rec."PreDispatch QC" then begin
            SalesLine_lRec.reset;
            SalesLine_lRec.SetRange("Document Type", SalesLine_lRec."Document Type"::Order);
            SalesLine_lRec.SetRange("Document No.", rec."Document No.");
            SalesLine_lRec.SetRange("Line No.", Rec."Document Line No.");
            if SalesLine_lRec.FindFirst() then begin
                SalesLine_lRec.CalcFields("Total No. of Posted QC");
                SalesLine_lRec.CalcFields("Total No. of QC");
                IF (SalesLine_lRec."Total No. of QC" = 0) AND (SalesLine_lRec."Total No. of Posted QC" = 0) THEN BEGIN  //Predispatch
                    SalesLine_lRec."QC Created" := false;
                    SalesLine_lRec.Modify();
                END;
            end;
        end;
        //T12547-NS
        if rec."Pre-Receipt QC" then begin
            PurchaseLine_lRec.reset;
            PurchaseLine_lRec.SetRange("Document Type", PurchaseLine_lRec."Document Type"::Order);
            PurchaseLine_lRec.SetRange("Document No.", Rec."Document No.");
            PurchaseLine_lRec.SetRange("Line No.", Rec."Document Line No.");
            if PurchaseLine_lRec.FindFirst() then begin
                PurchaseLine_lRec.CalcFields("Total No. of Posted QC");
                PurchaseLine_lRec.CalcFields("Total No. of QC");
                IF (PurchaseLine_lRec."Total No. of QC" = 0) AND (PurchaseLine_lRec."Total No. of Posted QC" = 0) THEN BEGIN  //Pre-Receipt
                    PurchaseLine_lRec."QC Created" := false;
                    PurchaseLine_lRec.Modify();
                END;
            end;
            //T12547-NE
        end;
        //T12530-NS
        FromDocAttachment_lRec.Reset();
        FromDocAttachment_lRec.setrange("Table ID", 75382);
        FromDocAttachment_lRec.setrange("No.", Rec."No.");
        if FromDocAttachment_lRec.FindSet() then
            FromDocAttachment_lRec.DeleteAll();
        //T12530-NE

    end;

    //T12530-NS
    procedure DocumentAttachmentInsert_gFnc(Var Rec: Record "QC Rcpt. Header"; DocNo: code[20]) //ABA T11390-N 
    var
        FromDocAttachment_lRec: Record "Document Attachment";
        ToDocAttachment_lRec: Record "Document Attachment";
        FindLineNoDocAttachment_lRec: Record "Document Attachment";
    begin
        Clear(FromDocAttachment_lRec);
        FromDocAttachment_lRec.Reset();
        FromDocAttachment_lRec.setrange("Table ID", 75382);
        FromDocAttachment_lRec.setrange("No.", Rec."No.");
        if FromDocAttachment_lRec.FindSet() then begin
            repeat
                ToDocAttachment_lRec.reset;
                ToDocAttachment_lRec.Init;
                ToDocAttachment_lRec.Validate("File Extension", FromDocAttachment_lRec."File Extension");
                ToDocAttachment_lRec.Validate("File Name", FromDocAttachment_lRec."File Name");
                //ToDocAttachment_lRec.Validate("Document Type", ToDocAttachment_lRec."Document Type"::Quote);
                ToDocAttachment_lRec.Validate("Table ID", 75384);
                ToDocAttachment_lRec.Validate("No.", DocNo);
                ToDocAttachment_lRec.validate("Document Reference ID", FromDocAttachment_lRec."Document Reference ID");

                FindLineNoDocAttachment_lRec.reset;
                FindLineNoDocAttachment_lRec.SetRange("Table ID", 75384);
                //FindLineNoDocAttachment_lRec.SetRange("Document Type", ToDocAttachment_lRec."Document Type"::Quote);
                FindLineNoDocAttachment_lRec.SetRange("No.", DocNo);
                if FindLineNoDocAttachment_lRec.FindLast() then
                    ToDocAttachment_lRec.Validate("Line No.", FindLineNoDocAttachment_lRec."Line No." + 1000)
                else
                    ToDocAttachment_lRec.Validate("Line No.", 1000);
                ToDocAttachment_lRec.Insert(true);
            until FromDocAttachment_lRec.next = 0;
        end;
    end;
    //T-NE
    var
        PostedQCRcptHeader_gRec: Record "Posted QC Rcpt. Header";
        QCRcptHeader_gRec: Record "QC Rcpt. Header";//T12530-N
        FieldRef: FieldRef;
        RecNo: Code[20];
}

