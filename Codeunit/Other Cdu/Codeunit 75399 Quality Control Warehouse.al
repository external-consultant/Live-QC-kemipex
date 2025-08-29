codeunit 75399 "Quality Control Warehouse"
{
    SingleInstance = true;
    //T12113-NB-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Warehouse Mgt.", 'OnBeforeCreateShptLineFromSalesLine', '', false, false)]
    local procedure OnBeforeCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        WarehouseShipmentLine."PreDispatch Inspection Req" := SalesLine."PreDispatch Inspection Req";
        // WarehouseShipmentLine."QC No." := SalesLine."QC No.";
        // WarehouseShipmentLine."Posted QC No." := SalesLine."Posted QC No.";
        WarehouseShipmentLine."QC Created" := SalesLine."QC Created";
    end;


    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", OnSelectEntriesOnAfterTransferFields, '', false, false)]
    local procedure "Item Tracking Lines_OnSelectEntriesOnAfterTransferFields"(var TempTrackingSpec: Record "Tracking Specification" temporary; var TrackingSpecification: Record "Tracking Specification")
    begin
        TempTrackingSpec."Material at QC" := TrackingSpecification."Material at QC";
    end;



    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnAfterCopyTrackingFromTrackingSpec', '', false, false)]
    local procedure OnAfterCopyTrackingFromTrackingSpec(var ReservationEntry: Record "Reservation Entry"; TrackingSpecification: Record "Tracking Specification")
    var
        QCSalesTracking_lRec: Record "QC Sales Tracking";
        QCReceiptHeader_lRec: Record "QC Rcpt. Header";
        EntryNo_lInt: Integer;
    begin

        ReservationEntry."Material at QC" := TrackingSpecification."Material at QC";

        QCSalesTracking_lRec.Reset();
        QCSalesTracking_lRec.SetCurrentKey("Entry No.");
        If QCSalesTracking_lRec.FindLast() then
            EntryNo_lInt := QCSalesTracking_lRec."Entry No.";

        QCSalesTracking_lRec.Reset();
        QCSalesTracking_lRec.Init();
        QCSalesTracking_lRec."Entry No." := EntryNo_lInt + 1;
        QCSalesTracking_lRec.Validate("Document No.", TrackingSpecification."Source Id");
        QCSalesTracking_lRec.Validate("Document Line No.", TrackingSpecification."Source Ref. No.");
        QCSalesTracking_lRec.Validate("Item No.", TrackingSpecification."Item No.");
        QCSalesTracking_lRec.Validate("Lot No.", TrackingSpecification."Lot No.");
        QCSalesTracking_lRec.Validate(Quantity, TrackingSpecification."Quantity (Base)");
        QCReceiptHeader_lRec.Reset();
        QCReceiptHeader_lRec.SetRange("Document Type", QCReceiptHeader_lRec."Document Type"::"Sales Order");
        QCReceiptHeader_lRec.SetRange("Document No.", TrackingSpecification."Source ID");
        If QCReceiptHeader_lRec.FindFirst() then
            QCSalesTracking_lRec.Validate("QC No.", QCReceiptHeader_lRec."No.");
        QCSalesTracking_lRec.Validate("Qty to Accept", TrackingSpecification."Quantity (Base)");
        QCSalesTracking_lRec.Insert();
        //QCSalesTracking_lRec.Validate();
    end;
    //T12113-NB-NE

    //T12547-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchases Warehouse Mgt.", OnPurchLine2ReceiptLineOnAfterUpdateReceiptLine, '', false, false)]
    local procedure "Purchases Warehouse Mgt._OnPurchLine2ReceiptLineOnAfterUpdateReceiptLine"(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var WhseReceiptHeader: Record "Warehouse Receipt Header"; PurchaseLine: Record "Purchase Line")
    begin
        WarehouseReceiptLine."Pre-Receipt Inspection" := PurchaseLine."Pre-Receipt Inspection";
        WarehouseReceiptLine."QC Created" := PurchaseLine."QC Created";
    end;





    //49238
    var
        ModifyRun: Boolean;
        "Material at QC": Boolean;
}