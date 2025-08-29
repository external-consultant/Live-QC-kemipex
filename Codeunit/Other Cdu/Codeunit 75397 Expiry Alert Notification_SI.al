codeunit 75397 "Expiry Alert Notification"
{//T12113-NS
    SingleInstance = true;
    trigger OnRun()
    begin

    end;

    //For Sales Lines
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeOpenItemTrackingLines', '', false, false)]
    local procedure "Sales Line_OnBeforeOpenItemTrackingLines"(SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        Saleshead_lRec: Record "Sales Header";
    begin
        if SalesLine."Document Type" <> SalesLine."Document Type"::Order then
            exit;

        if Saleshead_lRec.Get(Saleshead_lRec."Document Type"::Order, SalesLine."Document No.") then begin
            SourcePostingDate_gDte := Saleshead_lRec."Posting Date";
            CheckExpiry_gBln := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterOpenItemTrackingLines', '', false, false)]
    local procedure "Sales Line_OnAfterOpenItemTrackingLines"(SalesLine: Record "Sales Line")
    var

    begin
        CheckExpiry_gBln := false;
        SourcePostingDate_gDte := 0D;
    end;

    //For Transfer Lines
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnBeforeOpenItemTrackingLines', '', false, false)]
    local procedure "Transfer Line_OnBeforeOpenItemTrackingLines"(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    var
        TransferHeader_lRec: Record "Transfer Header";
    begin
        if TransferHeader_lRec.Get(TransferLine."Document No.") then begin
            SourcePostingDate_gDte := TransferHeader_lRec."Posting Date";
            CheckExpiry_gBln := true;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Transfer Line-Reserve", 'OnAfterCallItemTracking', '', false, false)]
    local procedure "Transfer Line-Reserve_OnAfterCallItemTracking"(var TransferLine: Record "Transfer Line")
    begin
        CheckExpiry_gBln := false;
        SourcePostingDate_gDte := 0D;
    end;

    //For Item Jnl Lines
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl. Line-Reserve", 'OnBeforeCallItemTracking', '', false, false)]
    local procedure "Item Jnl. Line-Reserve_OnBeforeCallItemTracking"(var ItemJournalLine: Record "Item Journal Line"; IsReclass: Boolean; var IsHandled: Boolean)
    begin
        if ItemJournalLine."Journal Template Name" = 'CONSUMPTIO' then begin
            SourcePostingDate_gDte := ItemJournalLine."Posting Date";
            CheckExpiry_gBln := true;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Consumption Journal", 'OnAfterActionEvent', 'Item &Tracking Lines', false, false)]
    local procedure ConsumptionJournal_OnAfterActionEvent_ItemTrackingLines(var Rec: Record "Item Journal Line")
    begin
        CheckExpiry_gBln := false;
        SourcePostingDate_gDte := 0D;

    end;

    //For Updating the Message after checking the Date formula 

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnBeforeInsertEvent', '', true, true)]
    local procedure ReservationEntry_OnBeforeInsertEvent(var Rec: Record "Reservation Entry")
    var
        QCsetup_lRec: Record "Quality Control Setup";
        ExpiryDateValue_lDte: Date;
        ExpiryDateValueILE_lDte: Date;
        MessagePopup_lBol: Boolean;//18-12-2024
    begin
        /* if Rec.IsTemporary then
            exit;
        ExpiryDateValue_lDte := 0D;
        ExpiryDateValueILE_lDte := 0D;
        Clear(MessagePopup_lBol); //18-12-2024-N
        if CheckExpiry_gBln then begin
            QCsetup_lRec.Get();
            QCsetup_lRec.TestField("Expiry Alert Notification");
            ExpiryDateValue_lDte := CalcDate('<' + Format(QCsetup_lRec."Expiry Alert Notification") + '>', SourcePostingDate_gDte);
            ExpiryDateValueILE_lDte := CalculateExpiryDate(Rec."Item No.", Rec."Variant Code", Rec."Lot No.", Rec."Serial No.");
            if ExpiryDateValueILE_lDte <> 0D then begin
                if rec."Item No." <> '' then
                    //18-12-2024-NS
                    if (ExpiryDateValue_lDte < ExpiryDateValueILE_lDte) then
                        MessagePopup_lBol := True;
                if (SourcePostingDate_gDte < ExpiryDateValueILE_lDte) then
                    MessagePopup_lBol := True;
                if MessagePopup_lBol then
                    Message('Item %1 will Expire on %2', Rec."Item No.", ExpiryDateValueILE_lDte);
                // if (SourcePostingDate_gDte < ExpiryDateValueILE_lDte) or (ExpiryDateValue_lDte > ExpiryDateValueILE_lDte) then
                //     Message('Item %1 will Expire on %2', Rec."Item No.", ExpiryDateValue_lDte);
            end;
        end; */
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reservation Entry", 'OnBeforeModifyEvent', '', true, true)]
    local procedure ReservationEntry_OnBeforeModifyEvent(var Rec: Record "Reservation Entry")
    var
        QCsetup_lRec: Record "Quality Control Setup";
        ExpiryDateValue_lDte: Date;
        ExpiryDateValueILE_lDte: Date;
        MessagePopup_lBol: Boolean;//18-12-2024

    begin
        if Rec.IsTemporary then
            exit;
        ExpiryDateValue_lDte := 0D;
        ExpiryDateValueILE_lDte := 0D;
        Clear(MessagePopup_lBol); //18-12-2024-N

        if CheckExpiry_gBln then begin
            QCsetup_lRec.Get();
            QCsetup_lRec.TestField("Expiry Alert Notification");
            ExpiryDateValue_lDte := CalcDate('<' + Format(QCsetup_lRec."Expiry Alert Notification") + '>', SourcePostingDate_gDte);
            ExpiryDateValueILE_lDte := CalculateExpiryDate(Rec."Item No.", Rec."Variant Code", Rec."Lot No.", Rec."Serial No.");
            if ExpiryDateValueILE_lDte <> 0D then begin
                if Rec."Item No." <> '' then
                    if (ExpiryDateValueILE_lDte >= SourcePostingDate_gDte) and (ExpiryDateValueILE_lDte <= ExpiryDateValue_lDte) then
                        Message('Item %1 will Expire on %2', Rec."Item No.", ExpiryDateValueILE_lDte);
            end;
        end;
    end;



    procedure CalculateExpiryDate(ItemNO: Code[20]; Variant: Code[20]; Lotno: Code[50]; serialno: Code[50]): Date
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.RESET;
        ItemLedgEntry.SETCURRENTKEY("Item No.", Open, "Variant Code", Positive, "Lot No.", "Serial No.");

        ItemLedgEntry.SETRANGE("Item No.", ItemNo);
        ItemLedgEntry.SETRANGE(Open, TRUE);
        ItemLedgEntry.SETRANGE("Variant Code", Variant);
        IF LotNo <> '' THEN
            ItemLedgEntry.SETRANGE("Lot No.", LotNo)
        ELSE
            IF SerialNo <> '' THEN
                ItemLedgEntry.SETRANGE("Serial No.", SerialNo);
        ItemLedgEntry.SETRANGE(Positive, TRUE);

        IF ItemLedgEntry.FINDLAST THEN
            EXIT(ItemLedgEntry."Expiration Date");
    end;

    var
        CheckExpiry_gBln: Boolean;
        SourcePostingDate_gDte: Date;
    //T12113-NE
}