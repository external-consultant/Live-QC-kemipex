codeunit 75402 Subscribe_Page_6510
{

    //Pre-Receipt Inspection/PreDispatch Inspection Req
    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterValidateEvent', 'Warranty Date', true, false)]
    local procedure "ItemTracking_WarrantyDate"(var Rec: Record "Tracking Specification"; xRec: Record "Tracking Specification")
    var
    begin
        //T12545-NS for Manufacturing Date Mandatory
        if rec.IsEmpty then
            exit;
        if xRec."Warranty Date" = 0D then
            exit;

        if Rec."Source Type" in [37, 5405, 5741, 5407] then//[37, 5405, 5741]
            if Rec."Warranty Date" <> 0D then begin
                if Rec."Warranty Date" <> xRec."Warranty Date" then
                    Error('You can not Modified');
            end;
        //T12545-NE

    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", OnBeforeOnModifyRecord, '', false, false)]
    local procedure "Item Tracking Lines_OnBeforeOnModifyRecord"(var TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification"; InsertIsBlocked: Boolean; var Result: Boolean; var IsHandled: Boolean)
    var
        PL_lRec: Record "Purchase Line";
        ReservationEntry_lRec: Record "Reservation Entry";
        SL_lRec: Record "Sales Line";
    begin
        //T12547-NS
        if TrackingSpecification."Source Type" = 39 then begin
            PL_lRec.reset;
            PL_lRec.SetRange("Document Type", PL_lRec."Document Type"::Order);
            PL_lRec.SetRange(type, PL_lRec.Type::Item);
            PL_lRec.SetRange("Document No.", TrackingSpecification."Source ID");
            PL_lRec.SetRange("Line No.", TrackingSpecification."Source Ref. No.");
            PL_lRec.Setrange("Pre-Receipt Inspection", true);
            if PL_lRec.FindSet() then begin
                ReservationEntry_lRec.Reset();
                ReservationEntry_lRec.SetRange("Source Type", 39);
                ReservationEntry_lRec.SetRange("Source Subtype", ReservationEntry_lRec."Source Subtype"::"1");
                ReservationEntry_lRec.SetRange("Source ID", PL_lRec."Document No.");
                ReservationEntry_lRec.SetRange("Source Ref. No.", PL_lRec."Line No.");
                ReservationEntry_lRec.SetRange("Item No.", PL_lRec."No.");
                if ReservationEntry_lRec.FindFirst() then
                    Error('The selected line has relation with QC Receipt, you can not delete or modify it.');
            end;
            //T12547-NE
        end else if TrackingSpecification."Source Type" = 37 then begin
            SL_lRec.reset;
            SL_lRec.SetRange("Document Type", SL_lRec."Document Type"::Order);
            SL_lRec.SetRange(type, SL_lRec.Type::Item);
            SL_lRec.SetRange("Document No.", TrackingSpecification."Source ID");
            SL_lRec.SetRange("Line No.", TrackingSpecification."Source Ref. No.");
            SL_lRec.Setrange("PreDispatch Inspection Req", true);
            if SL_lRec.FindSet() then
                Error('The selected line has relation with QC Receipt, you can not delete or modify it.');
        end;
    end;



    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", OnBeforeDeleteRecord, '', false, false)]
    local procedure "Item Tracking Lines_OnBeforeDeleteRecord"(var TrackingSpecification: Record "Tracking Specification")
    var
        PL_lRec: Record "Purchase Line";
        SL_lRec: Record "Sales Line";
    begin
        //T12547-NS
        if TrackingSpecification."Source Type" = 39 then begin
            PL_lRec.reset;
            PL_lRec.SetRange("Document Type", PL_lRec."Document Type"::Order);
            PL_lRec.SetRange(type, PL_lRec.Type::Item);
            PL_lRec.SetRange("Document No.", TrackingSpecification."Source ID");
            PL_lRec.SetRange("Line No.", TrackingSpecification."Source Ref. No.");
            PL_lRec.Setrange("Pre-Receipt Inspection", true);
            if PL_lRec.FindSet() then
                Error('The selected line has relation with QC Receipt, you can not delete or modify it.');
            //T12547-NE
        end else if TrackingSpecification."Source Type" = 37 then begin
            SL_lRec.reset;
            SL_lRec.SetRange("Document Type", SL_lRec."Document Type"::Order);
            SL_lRec.SetRange(type, SL_lRec.Type::Item);
            SL_lRec.SetRange("Document No.", TrackingSpecification."Source ID");
            SL_lRec.SetRange("Line No.", TrackingSpecification."Source Ref. No.");
            SL_lRec.Setrange("PreDispatch Inspection Req", true);
            if SL_lRec.FindSet() then
                Error('The selected line has relation with QC Receipt, you can not delete or modify it.');
        end;
    end;





    //T12750-NE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateReservEntryExtraFields', '', false, false)]
    local procedure OnCreateReservEntryExtraFields(var InsertReservEntry: Record "Reservation Entry"; OldTrackingSpecification: Record "Tracking Specification"; NewTrackingSpecification: Record "Tracking Specification")
    begin
        InsertReservEntry."Material at QC" := NewTrackingSpecification."Material at QC";
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterMoveFields', '', false, false)]
    local procedure OnAfterMoveFields(var TrkgSpec: Record "Tracking Specification"; var ReservEntry: Record "Reservation Entry");
    begin
        ReservEntry."Material at QC" := TrkgSpec."Material at QC";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Data Collection", OnBeforeTempTrackingSpecificationInsert, '', false, false)]
    local procedure "Item Tracking Data Collection_OnBeforeTempTrackingSpecificationInsert"(var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempEntrySummary: Record "Entry Summary" temporary)
    var
        ILE_l: Record "Item Ledger Entry";
    begin
        ILE_l.Reset();
        ILE_l.SetRange("Lot No.", TempEntrySummary."Lot No.");
        IF ILE_l.FindFirst() then
            TempTrackingSpecification."Material at QC" := ILE_l."Material at QC";
    end;
    //T12750-NE


    var
        myInt: Integer;
}