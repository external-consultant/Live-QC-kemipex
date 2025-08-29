Codeunit 75390 Subscribe_Codeunit_333
{
    Permissions = tabledata "Item Ledger Entry" = RM;
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterInitPurchOrderLine', '', false, false)]
    local procedure OnAfterInitPurchOrderLine(var PurchaseLine: Record "Purchase Line"; RequisitionLine: Record "Requisition Line");
    var
        Location_lRec: Record Location;
        dd: Record "Item Journal Line";
        QCSetup_lRec: Record "Quality Control Setup";
        Item_lRec: Record Item;
        WMSManagement: Codeunit "WMS Management";
        PurchaseHeader_lRec: Record "Purchase Header";
        sa: page "Assembly Order";
    begin
        // if PurchaseLine."Document Type" <> PurchaseLine."document type"::Order then
        //     exit;

        // IF PurchaseLine.Type <> PurchaseLine.Type::Item then
        //     exit;

        // if (PurchaseLine."No." <> xRec."No.") and (Rec."No." <> '') then begin
        PurchaseHeader_lRec.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        Item_lRec.Get(PurchaseLine."No.");
        if Item_lRec."Allow QC in GRN" then begin//T12113-ABA
            // if Item_lRec.CheckItemVendorCatelogueForQC(PurchaseHeader_lRec."Buy-from Vendor No.") then begin //T12115-N T13134
            PurchaseHeader_lRec.TestField("Location Code");
            QCSetup_lRec.Reset();
            QCSetup_lRec.GET();

            if not QCSetup_lRec."QC Block without Location" then begin
                if Location_lRec.Get(PurchaseHeader_lRec."Location Code") then begin
                    Location_lRec.TestField("QC Location");
                    PurchaseLine.Validate("Location Code", Location_lRec."QC Location");
                    // Message(PurchaseLine."Location Code");---HB
                end;
                // end;//T13134-O
            end;
            // end;
        end;


    end;


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", OnSetItemJnlLineOnBeforeUpdateReservation, '', false, false)]
    // local procedure "Reservation Management_OnSetItemJnlLineOnBeforeUpdateReservation"(var ReservEntry: Record "Reservation Entry"; ItemJnlLine: Record "Item Journal Line")
    // begin
    //     ItemJnlLine
    // end;


    //T13334-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Engine Mgt.", OnBeforeUpdateItemTracking, '', false, false)]
    local procedure "Reservation Engine Mgt._OnBeforeUpdateItemTracking"(var ReservEntry: Record "Reservation Entry"; var TrackingSpecification: Record "Tracking Specification")
    begin
        if ReservEntry."QC No." <> '' then
            TrackingSpecification."QC No." := ReservEntry."QC No.";
        if ReservEntry."Posted QC No." <> '' then
            TrackingSpecification."Posted QC No." := ReservEntry."Posted QC No.";//for Assembly Order Hypercare 01-03-2025       

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeInsertSetupTempSplitItemJnlLine, '', false, false)]
    local procedure "Item Jnl.-Post Line_OnBeforeInsertSetupTempSplitItemJnlLine"(var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempItemJournalLine: Record "Item Journal Line" temporary; var PostItemJnlLine: Boolean; var ItemJournalLine2: Record "Item Journal Line"; SignFactor: Integer; FloatingFactor: Decimal)
    begin
        if TempTrackingSpecification."QC No." <> '' then
            TempItemJournalLine."QC No." := TempTrackingSpecification."QC No.";
        if TempTrackingSpecification."Posted QC No." <> '' then
            TempItemJournalLine."Posted QC No." := TempTrackingSpecification."Posted QC No.";//for Assembly Order Hypercare 01-03-2025      

    end;
    //T13334-NE




}

