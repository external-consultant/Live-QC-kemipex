codeunit 75400 "Cu 22 Item Jnl Post"
{//T12113_NS
    Permissions = tabledata "Item Ledger Entry" = rm;


    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyTrackingFromSpec', '', false, false)]
    local procedure "Item Journal Line_OnAfterCopyTrackingFromSpec"(var ItemJournalLine: Record "Item Journal Line"; TrackingSpecification: Record "Tracking Specification")
    begin
        ItemJournalLine."Rejection Reason" := TrackingSpecification."Rejection Reason";
        ItemJournalLine."Rejection Reason Description" := TrackingSpecification."Rejection Reason Description";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertItemLedgEntry', '', false, false)]
    local procedure "Item Jnl.-Post Line_OnBeforeInsertItemLedgEntry"(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; TransferItem: Boolean; OldItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLineOrigin: Record "Item Journal Line")
    begin
        ItemLedgerEntry."Rejection Reason" := ItemJournalLine."Rejection Reason";
        ItemLedgerEntry."Rejection Reason Description" := ItemJournalLine."Rejection Reason Description";
        // ItemLedgerEntry."Material at QC" := ItemJournalLine."Material at QC";//T12750-ABA-N


    end;

    procedure UpdateManuDate()
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        UpdateFromILE_lRec: Record "Item Ledger Entry";
        Companies_all_lRec: Record Company;
        i: Integer;
        e: Integer;
    begin
        if UserId <> 'INTECH.DEVELOPER' then
            Error('You Dont have permission.');
        Companies_all_lRec.Reset();
        if Companies_all_lRec.FindSet() then
            repeat
                Clear(i);
                Clear(e);
                ItemLedgerEntry_lRec.ChangeCompany(Companies_all_lRec.Name);
                UpdateFromILE_lRec.ChangeCompany(Companies_all_lRec.Name);
                ItemLedgerEntry_lRec.Reset();
                ItemLedgerEntry_lRec.SetCurrentKey("Entry No.");
                ItemLedgerEntry_lRec.SetRange("Manufacturing Date 2", 0D);
                //ItemLedgerEntry_lRec.setfilter("Expiry Period 2", '');
                //ItemLedgerEntry_lRec.SetFilter("Supplier Batch No. 2", '');
                if ItemLedgerEntry_lRec.FindSet() then
                    repeat
                        UpdateFromILE_lRec.Reset();
                        UpdateFromILE_lRec.SetRange("Item No.", ItemLedgerEntry_lRec."Item No.");
                        UpdateFromILE_lRec.SetRange("Variant Code", ItemLedgerEntry_lRec."Variant Code");
                        UpdateFromILE_lRec.SetRange(CustomLotNumber, ItemLedgerEntry_lRec.CustomLotNumber);
                        UpdateFromILE_lRec.SetFilter("Manufacturing Date 2", '<>%1', 0D);
                        if UpdateFromILE_lRec.FindFirst() then begin
                            ItemLedgerEntry_lRec."Manufacturing Date 2" := UpdateFromILE_lRec."Manufacturing Date 2";
                            if Format(ItemLedgerEntry_lRec."Expiry Period 2") = '' then
                                ItemLedgerEntry_lRec."Expiry Period 2" := UpdateFromILE_lRec."Expiry Period 2";
                            if ItemLedgerEntry_lRec."Supplier Batch No. 2" = '' then
                                ItemLedgerEntry_lRec."Supplier Batch No. 2" := UpdateFromILE_lRec."Supplier Batch No. 2";
                            if ItemLedgerEntry_lRec."Warranty Date" = 0D then
                                ItemLedgerEntry_lRec."Warranty Date" := UpdateFromILE_lRec."Warranty Date";
                            ItemLedgerEntry_lRec.Modify();
                            e += 1;
                        end;
                        i += 1;
                    until ItemLedgerEntry_lRec.next = 0;
                Message('%1 ot of %2 lines updated in %3', e, i, Companies_all_lRec.Name);
            until Companies_all_lRec.Next = 0;
    end;
    //T12113_NE
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeApplyItemLedgEntry, '', false, false)]
    // local procedure "Item Jnl.-Post Line_OnBeforeApplyItemLedgEntry"(var ItemLedgEntry: Record "Item Ledger Entry"; var OldItemLedgEntry: Record "Item Ledger Entry"; var ValueEntry: Record "Value Entry"; CausedByTransfer: Boolean; var Handled: Boolean; ItemJnlLine: Record "Item Journal Line"; var ItemApplnEntryNo: Integer)
    // begin
    //     Message('check');
    //     Message('OnBeforeApplyItemLedgEntry %1..%2..%3', ItemLedgEntry."Entry No.", OldItemLedgEntry."Entry No.", ItemApplnEntryNo);

    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnAfterApplyItemLedgEntrySetFilters, '', false, false)]
    // local procedure "Item Jnl.-Post Line_OnAfterApplyItemLedgEntrySetFilters"(var ItemLedgerEntry2: Record "Item Ledger Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    // begin
    //     Message('OnAfterApplyItemLedgEntrySetFilters %1..%2', ItemLedgerEntry2."Entry No.", ItemLedgerEntry."Entry No.");

    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnTestFirstApplyItemLedgEntryOnAfterTestFields, '', false, false)]
    // local procedure "Item Jnl.-Post Line_OnTestFirstApplyItemLedgEntryOnAfterTestFields"(ItemLedgerEntry: Record "Item Ledger Entry"; OldItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    // begin
    //     Message('OnTestFirstApplyItemLedgEntryOnAfterTestFields %1..%2', ItemLedgerEntry."Entry No.", OldItemLedgerEntry."Entry No.");
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnApplyItemLedgEntryOnBeforeOldItemLedgEntryModify, '', false, false)]
    local procedure "Item Jnl.-Post Line_OnApplyItemLedgEntryOnBeforeOldItemLedgEntryModify"(var ItemLedgerEntry: Record "Item Ledger Entry"; var OldItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var AverageTransfer: Boolean)
    begin
        //in case if user reserv the Sales line and Post then Trigger will run. otherwise Exit;
        if (OldItemLedgerEntry."Material at QC") and (OldItemLedgerEntry."Lot No." <> '') then
            Error('QC is Pending on Apply Item Ledger Entry %1 against Lot No %2', OldItemLedgerEntry."Entry No.", OldItemLedgerEntry."Lot No.");
        if (OldItemLedgerEntry."Material at QC") and (OldItemLedgerEntry."Serial No." <> '') then
            Error('QC is Pending on Apply Item Ledger Entry %1 against Serial No %2', OldItemLedgerEntry."Entry No.", OldItemLedgerEntry."Serial No.");
        if (OldItemLedgerEntry."Material at QC") and ((OldItemLedgerEntry."Lot No." = '') and (OldItemLedgerEntry."Serial No." = '')) then
            Error('QC is Pending on Apply Item Ledger Entry %1', OldItemLedgerEntry."Entry No.");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnAfterApplyItemLedgEntryOnBeforeCalcAppliedQty, '', false, false)]
    local procedure "Item Jnl.-Post Line_OnAfterApplyItemLedgEntryOnBeforeCalcAppliedQty"(var OldItemLedgerEntry: Record "Item Ledger Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        ErrorInfo: ErrorInfo;
    begin
        if (OldItemLedgerEntry."Material at QC") and (OldItemLedgerEntry."Lot No." <> '') then
            Error('QC is Pending on Apply Item Ledger Entry %1 against Lot No %2', OldItemLedgerEntry."Entry No.", OldItemLedgerEntry."Lot No.");
        if (OldItemLedgerEntry."Material at QC") and (OldItemLedgerEntry."Serial No." <> '') then
            Error('QC is Pending on Apply Item Ledger Entry %1 against Serial No %2', OldItemLedgerEntry."Entry No.", OldItemLedgerEntry."Serial No.");
        if (OldItemLedgerEntry."Material at QC") and ((OldItemLedgerEntry."Lot No." = '') and (OldItemLedgerEntry."Serial No." = '')) then
            Error('QC is Pending on Apply Item Ledger Entry %1', OldItemLedgerEntry."Entry No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeUpdateItemLedgerEntryRemainingQuantity, '', false, false)]
    local procedure "Item Jnl.-Post Line_OnBeforeUpdateItemLedgerEntryRemainingQuantity"(var ItemLedgerEntry: Record "Item Ledger Entry"; var OldItemLedgEntry: Record "Item Ledger Entry"; AppliedQty: Decimal; CausedByTransfer: Boolean; AverageTransfer: Boolean)
    var
        salesShipmentLine_lRec: Record "Sales Shipment Line";
        Item_lRec: Record Item;
    begin
        //For COA Report Change
        if ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::"Sales Shipment" then begin
            if OldItemLedgEntry."Posted QC No." <> '' then
                ItemLedgerEntry."Posted QC No." := OldItemLedgEntry."Posted QC No.";//Applied Entry
            if OldItemLedgEntry."QC No." <> '' then
                ItemLedgerEntry."QC No." := OldItemLedgEntry."QC No.";
        end;//Post Sales

        if ItemLedgerEntry."Document Type" in [ItemLedgerEntry."Document Type"::"Transfer Shipment", ItemLedgerEntry."Document Type"::"Transfer Receipt"] then begin//Post Transfer Order
            if Item_lRec.Get(ItemLedgerEntry."Item No.") then;
            if not Item_lRec."Allow QC in Transfer Receipt" then begin
                if OldItemLedgEntry."Posted QC No." <> '' then
                    ItemLedgerEntry."Posted QC No." := OldItemLedgEntry."Posted QC No.";//Applied Entry
                if OldItemLedgEntry."QC No." <> '' then
                    ItemLedgerEntry."QC No." := OldItemLedgEntry."QC No.";//Applied Entry
            end;
            //T13270-NS
        end else if (ItemLedgerEntry."Document Type" = ItemLedgerEntry."Document Type"::" ") and (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Transfer) then begin//for Item Reclass Post
            if Item_lRec.Get(ItemLedgerEntry."Item No.") then;
            if not Item_lRec."Allow QC in Transfer Receipt" then begin
                if OldItemLedgEntry."Posted QC No." <> '' then
                    ItemLedgerEntry."Posted QC No." := OldItemLedgEntry."Posted QC No.";//Applied Entry
                if OldItemLedgEntry."QC No." <> '' then
                    ItemLedgerEntry."QC No." := OldItemLedgEntry."QC No.";//Applied Entry
            end;
        end;
        //T13270-NE
        //For COA Report Changes
    end;

    local procedure TrackingofPreDispatchUpdateOnItemLedgerEntry_lFnc(Ile_iRec: Record "Item Ledger Entry"): code[30]
    var
        QCReservationEntry_lRec: Record "QC Reservation Entry";
        SalesShipmentLine_lRec: Record "Sales Shipment Line";
        SalesOrderLine_lrec: Record "Sales Line";
    begin
        //For COA Report Changes
        SalesShipmentLine_lRec.Reset;
        SalesShipmentLine_lRec.SetRange("Document No.", Ile_iRec."Document No.");
        SalesShipmentLine_lRec.SetRange("Line No.", Ile_iRec."Document Line No.");
        SalesShipmentLine_lRec.SetRange("No.", Ile_iRec."Item No.");
        SalesShipmentLine_lRec.SetRange("Location Code", Ile_iRec."Location Code");
        if SalesShipmentLine_lRec.FindSet() then begin
            SalesOrderLine_lrec.reset;
            SalesOrderLine_lrec.SetRange("Document No.", SalesShipmentLine_lRec."Order No.");
            SalesOrderLine_lrec.SetRange("No.", SalesShipmentLine_lRec."No.");
            SalesOrderLine_lrec.SetRange("Line No.", SalesShipmentLine_lRec."Order Line No.");
            if SalesOrderLine_lrec.FindFirst() then begin
                SalesOrderLine_lrec.CalcFields("Total No. of Posted QC");
                if SalesOrderLine_lrec."Total No. of Posted QC" <> 0 then begin

                    QCReservationEntry_lRec.Reset;
                    QCReservationEntry_lRec.SetRange("Source ID", SalesOrderLine_lrec."Document No.");
                    QCReservationEntry_lRec.SetRange("Source Ref. No.", SalesOrderLine_lrec."Line No.");
                    QCReservationEntry_lRec.SetRange("Item No.", Ile_iRec."Item No.");
                    if Ile_iRec."Lot No." <> '' then
                        QCReservationEntry_lRec.SetRange("Lot No.", Ile_iRec."Lot No.");
                    if Ile_iRec."Serial No." <> '' then
                        QCReservationEntry_lRec.SetRange("Serial No.", Ile_iRec."Serial No.");
                    QCReservationEntry_lRec.SetRange("Location Code", Ile_iRec."Location Code");
                    QCReservationEntry_lRec.SetFilter("Posted QC No.", '<>%1', '');
                    if QCReservationEntry_lRec.FindLast then
                        exit(QCReservationEntry_lRec."Posted QC No.")
                    else
                        exit;
                end;
            end;
        end;
        //For COA Report Changes

    end;

    local procedure NonTrackingofPreDispatchUpdateOnILE_lFnc(Ile_iRec: Record "Item Ledger Entry"): code[30]
    var
        SalesShipmentLine_lRec: Record "Sales Shipment Line";
        SalesOrderLine_lrec: Record "Sales Line";
        PostedQC_lRec: Record "Posted QC Rcpt. Header";
    begin
        //For COA Report Changes
        if (Ile_iRec."Lot No." <> '') or (Ile_iRec."Serial No." <> '') then
            exit;
        SalesShipmentLine_lRec.Reset;
        SalesShipmentLine_lRec.SetRange("Document No.", Ile_iRec."Document No.");
        SalesShipmentLine_lRec.SetRange("Line No.", Ile_iRec."Document Line No.");
        SalesShipmentLine_lRec.SetRange("No.", Ile_iRec."Item No.");
        SalesShipmentLine_lRec.SetRange("Location Code", Ile_iRec."Location Code");
        if SalesShipmentLine_lRec.FindSet() then begin
            SalesOrderLine_lrec.reset;
            SalesOrderLine_lrec.SetRange("Document No.", SalesShipmentLine_lRec."Order No.");
            SalesOrderLine_lrec.SetRange("No.", SalesShipmentLine_lRec."No.");
            SalesOrderLine_lrec.SetRange("Line No.", SalesShipmentLine_lRec."Order Line No.");
            if SalesOrderLine_lrec.FindFirst() then begin
                SalesOrderLine_lrec.CalcFields("Total No. of Posted QC");
                if SalesOrderLine_lrec."Total No. of Posted QC" <> 0 then begin
                    PostedQC_lRec.Reset();
                    PostedQC_lRec.SetRange("Document Type", PostedQC_lRec."Document Type"::"Sales Order");
                    PostedQC_lRec.SetRange("Document No.", SalesOrderLine_lrec."Document No.");
                    PostedQC_lRec.SetRange("Document Line No.", SalesOrderLine_lrec."Line No.");
                    PostedQC_lRec.SetFilter("Accepted Quantity", '<>%1', 0);
                    PostedQC_lRec.Setrange("Item Tracking", PostedQC_lRec."Item Tracking"::None);
                    if PostedQC_lRec.FindFirst() then
                        exit(PostedQC_lRec."No.");
                end;
            end;
        end;
        //For COA Report Changes

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnInsertTransferEntryOnTransferValues, '', false, false)]
    local procedure "Item Jnl.-Post Line_OnInsertTransferEntryOnTransferValues"(var NewItemLedgerEntry: Record "Item Ledger Entry"; OldItemLedgerEntry: Record "Item Ledger Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var TempItemEntryRelation: Record "Item Entry Relation"; var IsHandled: Boolean)
    var
        Item_lRec: Record item;
    begin
        if Item_lRec.Get(ItemLedgerEntry."Item No.") then;
        if not Item_lRec."Allow QC in Transfer Receipt" then begin
            //T13270-NS Transfer Order Posting-> In-Transit Entry Updated From From Location Entry-Non Tracking Item
            if ItemLedgerEntry."QC No." <> '' then
                NewItemLedgerEntry."QC No." := ItemLedgerEntry."QC No.";
            if ItemLedgerEntry."Posted QC No." <> '' then
                NewItemLedgerEntry."Posted QC No." := ItemLedgerEntry."Posted QC No.";
            //T13270-NE Non Tracking Item

            //HyperCare-Support-Tracking
            if OldItemLedgerEntry."Posted QC No." <> '' then
                NewItemLedgerEntry."Posted QC No." := OldItemLedgerEntry."Posted QC No.";//Applied Entry
            if OldItemLedgerEntry."QC No." <> '' then
                NewItemLedgerEntry."QC No." := OldItemLedgerEntry."QC No.";//Applied Entry
            //HyperCare-Support-Tracking
        end;

    end;
    //T13334-NS-In 
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", OnAfterCreateItemJnlLineFromAssemblyHeader, '', false, false)]
    // local procedure "Assembly-Post_OnAfterCreateItemJnlLineFromAssemblyHeader"(var ItemJournalLine: Record "Item Journal Line"; AssemblyHeader: Record "Assembly Header")
    // begin
    //     //below code using for Kemipex COA Extension-Assembly Order Post
    //     ItemJournalLine."QC No." := AssemblyHeader."QC No.";
    //     ItemJournalLine."Posted QC No." := AssemblyHeader."Posted QC No.";
    // end;
    //T13334-NE




    local Procedure TestErrorAction()
    var
        IN_ErrorInfor: ErrorInfo;
        PostingDateNotification: Notification;
        PostingDateNotificationLbl: Label 'Posting Date is different from the current date.';
        CheckWorkDate: Label 'Check Work Date?';
    begin
        // //Syntax-begin 
        IN_ErrorInfor.DataClassification(DataClassification::SystemMetadata);
        IN_ErrorInfor.ErrorType(ErrorType::Client);
        IN_ErrorInfor.Verbosity(Verbosity::Error);
        IN_ErrorInfor.Title('This is New Error Title');
        IN_ErrorInfor.Message('This is Error Message');
        IN_ErrorInfor.AddAction('Second', Codeunit::"Error Action Test", 'Test02');
        IN_ErrorInfor.PageNo := Page::"Item List";
        IN_ErrorInfor.AddNavigationAction('Open Item List');
        Error(IN_ErrorInfor);
        // //Syntax-end

        // if Today <> rec."Allow Posting To" then begin
        //     PostingDateNotification.Message(PostingDateNotificationLbl);
        //     PostingDateNotification.Scope := NotificationScope::LocalScope;
        //     PostingDateNotification.AddAction(CheckWorkDate, Codeunit::"Error Action Test", 'OpenMySettings', 'This is Notification tooltip');
        //     PostingDateNotification.Send();
        // end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesDoc"(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        ILE_lRec: Record "Item Ledger Entry";
        SalesShipmentLine_lRec: Record "Sales Shipment Line";
    begin
        if SalesShptHdrNo = '' then
            exit;
        ILE_lRec.Reset();
        ILE_lRec.SetRange("Entry Type", ILE_lRec."Entry Type"::Sale);
        ILE_lRec.SetRange("Document Type", ILE_lRec."Document Type"::"Sales Shipment");
        ILE_lRec.SetRange("Document No.", SalesShptHdrNo);
        if ILE_lRec.FindSet() then
            repeat
                SalesShipmentLine_lRec.Reset();
                SalesShipmentLine_lRec.GET(ILE_lRec."Document No.", ILE_lRec."Document Line No.");
                if (SalesShipmentLine_lRec."QC Created") and (ILE_lRec."Item Tracking" in [ILE_lRec."Item Tracking"::"Lot No.", ILE_lRec."Item Tracking"::"Lot and Serial No.", ILE_lRec."Item Tracking"::"Serial No."]) then
                    ILE_lRec."Posted QC No." := TrackingofPreDispatchUpdateOnItemLedgerEntry_lFnc(ILE_lRec)
                else
                    if (SalesShipmentLine_lRec."QC Created") and (ILE_lRec."Item Tracking" = ILE_lRec."Item Tracking"::None) then
                        ILE_lRec."Posted QC No." := NonTrackingofPreDispatchUpdateOnILE_lFnc(ILE_lRec);
                ILE_lRec.Modify();
            until ILE_lRec.Next() = 0;
    end;

    // [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterModifyEvent', '', true, true)]
    // local procedure OnAfterSalesHeaderModify(var Rec: Record "Sales Header")
    // Var
    //     Int_l: Integer;
    // begin
    //     Int_l += 1;
    //     // Custom logic to execute after a Sales Header is modified
    //     Message('Sales Header %1 has been modified.', Rec."No.");
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeModifyEvent', '', true, true)]
    // local procedure OnBeforeSalesHeaderModify(var Rec: Record "Sales Header")
    // Var
    //     Int_l: Integer;
    // begin
    //     Int_l += 1;
    //     if Rec."Document Type" = Rec."Document Type"::Invoice then
    //         Error('Modifications are not allowed on Sales Orders at this stage.');
    // end;



    // [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterModifyEvent', '', false, false)]
    // local procedure "Sales Header_OnInitInsertOnBeforeInitRecord"(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    // var
    //     Int_l: Integer;
    // begin
    //     Int_l += 1;

    // end;


    // [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterOnInsert, '', false, false)]
    // local procedure "Sales Header_OnAfterOnInsert"(var SalesHeader: Record "Sales Header")
    // var
    //     Int_l: Integer;
    // begin
    //     Int_l += 1;

    // end;
    // [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnInitRecordOnBeforeAssignOrderDate, '', false, false)]
    // local procedure "Sales Header_OnInitRecordOnBeforeAssignOrderDate"(var SalesHeader: Record "Sales Header"; var NewOrderDate: Date)
    // var
    //     Int_l: Integer;
    // begin
    //     Int_l += 1;

    // end;
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Engine Mgt.", OnBeforeCancelReservation, '', false, false)]
    // local procedure "Reservation Engine Mgt._OnBeforeCancelReservation"(var ReservEntry: Record "Reservation Entry"; var IsHandled: Boolean)
    // var
    //     Int_l: Integer;
    // begin
    //     Int_l += 1;
    // end;
    // [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeInsertEvent', '', true, true)]
    // local procedure TrackingSpec336_OnBeforeInsertEvent(var Rec: Record "Tracking Specification")
    // var
    //     Debug_Int: Integer;
    // begin
    //     Debug_Int += 1;
    // end;
    //T51170-NS
    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterInsertItemLedgEntry', '', true, true)]
    local procedure OnAfterInsertILE(VAR ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; VAR ItemLedgEntryNo: Integer; VAR ValueEntryNo: Integer; VAR ItemApplnEntryNo: Integer)
    var
        ItemApplicationEntry: Record "Item Application Entry";
        ILE1: Record "Item Ledger Entry";
        ILE2: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntry2: Record "Value Entry";
    Begin
        if (ItemLedgerEntry.Positive = false) and (ItemLedgerEntry."Overall Changes") and (ItemLedgerEntry."Warranty Date" <> 0D) then begin
            ItemApplicationEntry.Reset();
            ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
            if ItemApplicationEntry.FindFirst() then begin
                if ILE1.Get(ItemApplicationEntry."Inbound Item Entry No.") and (ItemApplicationEntry."Inbound Item Entry No." <> 0) then begin
                    ItemLedgerEntry."Warranty Date" := ILE1."Warranty Date";
                    ItemLedgerEntry."Expiry Period 2" := ILE1."Expiry Period 2";
                    ItemLedgerEntry."Manufacturing Date 2" := ILE1."Manufacturing Date 2";

                    ItemLedgerEntry.Modify();
                end;
            end;
        end
    End;
    //T51170-



}




