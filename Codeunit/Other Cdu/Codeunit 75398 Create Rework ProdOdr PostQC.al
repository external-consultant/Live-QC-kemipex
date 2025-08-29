Codeunit 75398 "Create Rework ProdOdr PostQC"
{
    //T07638-Create new codeunit

    trigger OnRun()
    begin
    end;

    var
        ProdQCMgmt_lCdu: Codeunit "Quality Control - Production";
        Text0005_gCtx: label 'Do you want to Create Rework Production Order ?';
        QCSetup_gRec: Record "Quality Control Setup";
        Text0001_gCtx: label 'Production Order = ''%1'' is created for Document No = ''%2'', Item No. = ''%3'' sucessfully.';
        CreatedProdNo_gCde: code[20];
        ProductioOrder_gRec: Record "Production Order";

    procedure ReworkProductionOrder_gFnc(PostQCRcptHeader_iRec: Record "Posted QC Rcpt. Header"): Code[20]
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        CreateReworkProdOrderQC_lCdu: Codeunit "Create Rework Prod. Order QC";
    begin
        if not Confirm(Text0005_gCtx) then
            exit;

        if PostQCRcptHeader_iRec."Quantity to Rework" > 0 then
            PostQCRcptHeader_iRec.TestField("Rework Location");

        Clear(CreateReworkProdOrderQC_lCdu);
        CreatedProdNo_gCde := CreateReworkProdOrderQC_lCdu.ReworkCreateProdOrder_gFnc(PostQCRcptHeader_iRec);//Create Production Oredr
        ProductioOrder_gRec.get(ProductioOrder_gRec.Status::Released, CreatedProdNo_gCde);

        //ProdOrderComponent_gFnc(ProductioOrder_gRec, PostQCRcptHeader_iRec);//Production Order Component

        if CreatedProdNo_gCde <> '' then
            Message(Text0001_gCtx, CreatedProdNo_gCde, PostQCRcptHeader_iRec."No.", PostQCRcptHeader_iRec."Item No.");
    end;

    local procedure InsertReservationEntry_lFnc(ItemLedgerEntry_lRec: Record "Item Ledger Entry"; PostedQCRcpt_iRec: Record "Posted QC Rcpt. Header"; ProdOrderComp_iRec: Record "Prod. Order Component")
    var
        ResEntry_lRec: Record "Reservation Entry";
        EntryNo_lInt: Integer;
        NextEntryNo_lInt: Integer;
    begin
        //To Insert the Reservation Entry for Production Order.

        if ResEntry_lRec.FindLast then
            EntryNo_lInt := ResEntry_lRec."Entry No." + 1
        else
            EntryNo_lInt := 1;

        ResEntry_lRec.Lock;
        ResEntry_lRec.Init;
        ResEntry_lRec."Entry No." := EntryNo_lInt;

        ResEntry_lRec.Validate("Item No.", PostedQCRcpt_iRec."Item No.");
        ResEntry_lRec.Validate("Variant Code", PostedQCRcpt_iRec."Variant Code");
        ResEntry_lRec.Validate("Location Code", PostedQCRcpt_iRec."Location Code");
        if ItemLedgerEntry_lRec."Variant Code" <> '' then
            ResEntry_lRec.Validate("Variant Code", ItemLedgerEntry_lRec."Variant Code");

        ResEntry_lRec."Source Type" := Database::"Prod. Order Component";
        ResEntry_lRec."Source Subtype" := ResEntry_lRec."Source Subtype"::"3";
        ResEntry_lRec."Source ID" := ProdOrderComp_iRec."Prod. Order No.";
        //ResEntry_lRec."Source Batch Name" := ItemLedgerEntry_lRec."Journal Batch Name";
        ResEntry_lRec."Source Prod. Order Line" := ProdOrderComp_iRec."Prod. Order Line No.";
        ResEntry_lRec."Source Ref. No." := ProdOrderComp_iRec."Line No.";
        ResEntry_lRec."Creation Date" := ItemLedgerEntry_lRec."Posting Date";
        ResEntry_lRec."Expiration Date" := ItemLedgerEntry_lRec."Expiration Date";
        ResEntry_lRec."New Expiration Date" := ItemLedgerEntry_lRec."Expiration Date";
        ResEntry_lRec."Created By" := UserId;
        ResEntry_lRec."Creation Date" := today;
        if ItemLedgerEntry_lRec."Lot No." <> '' then begin
            ResEntry_lRec.Validate("Lot No.", ItemLedgerEntry_lRec."Lot No.");
        end;

        ResEntry_lRec."Shipment Date" := PostedQCRcpt_iRec."QC Date";
        ResEntry_lRec."Reservation Status" := ResEntry_lRec."reservation status"::Surplus;
        // ResEntry_lRec."Item Tracking" := ResEntry_lRec."Item Tracking"::"Lot No.";
        ResEntry_lRec."Item Tracking" := ItemLedgerEntry_lRec."Item Tracking";
        ResEntry_lRec.Quantity := -1 * Abs(PostedQCRcpt_iRec."Quantity to Rework");
        ResEntry_lRec.Validate("Quantity (Base)", -1 * Abs(PostedQCRcpt_iRec."Quantity to Rework"));
        ResEntry_lRec."Qty. per Unit of Measure" := 1;
        ResEntry_lRec.Positive := false;
        ResEntry_lRec."Warranty Date" := ItemLedgerEntry_lRec."Warranty Date";
        //ResEntry_lRec.Validate("Appl.-to Item Entry", PostedQCRcpt_iRec."ILE No.");
        ResEntry_lRec.Insert;
    end;

    procedure FGProdOrderComponent_gFnc(ProductionOrder_iRec: Record "Production Order"; PostQCRcptHeader_iRec: Record "Posted QC Rcpt. Header")
    var
        ProdOrderComponent_lRec: Record "Prod. Order Component";
        Item_lRec: Record Item;
        ItemTrackingCode_lRec: Record "Item Tracking Code";
        ProdOrderLine_iRec: Record "Prod. Order Line";
        OldProdComLineFind_lRec: Record "Prod. Order Component";
        LineNo_lInt: Integer;
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        ProdOrderComQtyPerModify_lFnc(ProductionOrder_iRec);//T12756-N// Rework prduction Order Component Update

        ProdOrderLine_iRec.reset;
        ProdOrderLine_iRec.SetRange("Prod. Order No.", ProductionOrder_iRec."No.");
        ProdOrderLine_iRec.SetRange(Status, ProductionOrder_iRec.Status);
        if ProdOrderLine_iRec.FindSet() then
            repeat
                Item_lRec.GET(ProdOrderLine_iRec."Item No.");
                /*  IF Item_lRec."Item Tracking Code" = '' THEN     //31-12-2024-Dharti
                     EXIT;

                 ItemTrackingCode_lRec.GET(Item_lRec."Item Tracking Code");
                 IF (NOT ItemTrackingCode_lRec."SN Specific Tracking") and (NOT ItemTrackingCode_lRec."Lot Specific Tracking") THEN
                     EXIT; */ //31-12-2024-Dharti
                Clear(LineNo_lInt);
                OldProdComLineFind_lRec.reset;
                OldProdComLineFind_lRec.SetRange(Status, ProdOrderLine_iRec.Status::Released);
                OldProdComLineFind_lRec.SetRange("Prod. Order No.", ProductionOrder_iRec."No.");
                OldProdComLineFind_lRec.SetRange("Prod. Order Line No.", ProdOrderLine_iRec."Line No.");
                if OldProdComLineFind_lRec.FindLast() then
                    LineNo_lInt := OldProdComLineFind_lRec."Line No." + 10000
                else
                    LineNo_lInt := 10000;
                Clear(ProdOrderComponent_lRec);
                ProdOrderComponent_lRec.init;
                ProdOrderComponent_lRec.Status := ProdOrderComponent_lRec.Status::Released;
                ProdOrderComponent_lRec."Prod. Order No." := ProductionOrder_iRec."No.";
                ProdOrderComponent_lRec."Prod. Order Line No." := ProdOrderLine_iRec."Line No.";
                ProdOrderComponent_lRec."Line No." := LineNo_lInt;
                ProdOrderComponent_lRec.Validate("Item No.", ProdOrderLine_iRec."Item No.");
                ProdOrderComponent_lRec.Validate("Variant Code", PostQCRcptHeader_iRec."Variant Code");
                ProdOrderComponent_lRec.insert(True);
                // ProdOrderComponent_lRec.Validate("Item No.", ProdOrderLine_iRec."Item No.");
                ProdOrderComponent_lRec.Validate("Quantity per", 1);
                ProdOrderComponent_lRec.Validate(quantity, ProdOrderLine_iRec.Quantity);
                ProdOrderComponent_lRec.Validate("Location Code", PostQCRcptHeader_iRec."Location Code");
                ProdOrderComponent_lRec.Validate("Due Date", ProdOrderLine_iRec."Due Date");//
                ProdOrderComponent_lRec.Modify();
                //Find the Lot No
                ItemLedgerEntry_lRec.Reset;
                ItemLedgerEntry_lRec.SetRange("Posted QC No.", PostQCRcptHeader_iRec."No.");
                // ItemLedgerEntry_lRec.SetRange("Document Line No.", PostQCRcptHeader_iRec."Document Line No.");
                if PostQCRcptHeader_iRec."Vendor Lot No." <> '' then
                    ItemLedgerEntry_lRec.SetRange("Lot No.", PostQCRcptHeader_iRec."Vendor Lot No.");
                ItemLedgerEntry_lRec.SetFilter("Remaining Quantity", '>%1', 0);
                ItemLedgerEntry_lRec.SetFilter("Rework Quantity", '>%1', 0);//31-12-2024 Dharti
                ItemLedgerEntry_lRec.SetRange(Open, true);
                if ItemLedgerEntry_lRec.FindFirst then
                    InsertReservationEntry_lFnc(ItemLedgerEntry_lRec, PostQCRcptHeader_iRec, ProdOrderComponent_lRec);//Reservation Entry//
                ProdOrderLine_iRec.Validate("Due Date", ProductionOrder_iRec."Due Date");
                ProdOrderLine_iRec.Modify();
            until ProdOrderLine_iRec.Next() = 0;
    end;





    //T12756-NS
    Local procedure ProdOrderComQtyPerModify_lFnc(ProductionOrder_iRec: Record "Production Order")
    var
        OldProdComLineFind_lRec: Record "Prod. Order Component";
        QualityControlSetup_lRec: Record "Quality Control Setup";
    begin
        if not ProductionOrder_iRec."Rework Order" then
            exit;
        QualityControlSetup_lRec.get;
        if not QualityControlSetup_lRec."Book Out for RewQty Production" then
            exit;
        OldProdComLineFind_lRec.reset;
        OldProdComLineFind_lRec.SetRange(Status, ProductionOrder_iRec.Status::Released);
        OldProdComLineFind_lRec.SetRange("Prod. Order No.", ProductionOrder_iRec."No.");
        if OldProdComLineFind_lRec.FindSet() then
            repeat
                OldProdComLineFind_lRec.Validate("Quantity per", 0);
                OldProdComLineFind_lRec.Validate("Due Date", ProductionOrder_iRec."Due Date");
                OldProdComLineFind_lRec.Modify(true);
            until OldProdComLineFind_lRec.next = 0;
    end;
    //T12756-NE



}

