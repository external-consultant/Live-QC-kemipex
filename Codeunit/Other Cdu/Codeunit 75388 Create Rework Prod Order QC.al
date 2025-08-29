Codeunit 75388 "Create Rework Prod. Order QC"
{
    //T07638-Create new codeunit

    trigger OnRun()
    begin
    end;

    var
        Direction: Option Forward,Backward;
        Text005: label 'One or more of the lines on this %1 require special warehouse handling. The %2 for these lines has been set to blank.';
        QCSetup_gRec: Record "Quality Control Setup";
        SourceNo_gCde: code[20];
        SourceRefeNo_gCde: Integer;
        SourceType_gInt: Integer;
        SourceSubType_gOpt: Option;
        TemporaryReservationEntry_gRec: Record "Reservation Entry" temporary;

    procedure CreateProdOrder_gFnc(PostedQCRcptHeader_iRec: Record "Posted QC Rcpt. Header"): Code[20]
    var
        NewProductionOrder_lRec: Record "Production Order";
        NoSeriesMgmnt_lCdu: Codeunit "No. Series";//Old NoSeriesManagement
        ReleaseProductionOrder_lRec: Record "Production Order";
        QCSetup_lRec: Record "Quality Control Setup";
        ProductionOrder_lRec: Record "Production Order";
        Direction: Option Forward,Backward;
        CalcMethod: Option "No Levels","One level","All levels";
        FilterProductionOrder_lRec: Record "Production Order";
        MFSetup_lRec: Record "Manufacturing Setup";//T12113-ABA-N
        CreateReworkProdOdrPostQC_lCdu: codeunit "Create Rework ProdOdr PostQC";//T12756-N
        ParentProductionOrder_lRec: Record "Production Order";
    begin
        if PostedQCRcptHeader_iRec."Document Type" <> PostedQCRcptHeader_iRec."document type"::Production then
            exit;

        if PostedQCRcptHeader_iRec."Quantity to Rework" = 0 then
            exit;

        QCSetup_lRec.Get;
        // QCSetup_lRec.Testfield("Rework Location Pro. Order"); //T13091-O
        QCSetup_lRec.Testfield("Rework Order Nos.");

        ProductionOrder_lRec.Init;
        ProductionOrder_lRec.Status := ProductionOrder_lRec.Status::Released;
        ProductionOrder_lRec."No." := NoSeriesMgmnt_lCdu.GetNextNo(QCSetup_lRec."Rework Order Nos.", 0D, true);
        ProductionOrder_lRec."No. Series" := QCSetup_lRec."Rework Order Nos.";
        if ProductionOrder_lRec.Insert(true) then begin
            ProductionOrder_lRec.Validate("Location Code", PostedQCRcptHeader_iRec."Rework Location");
            ProductionOrder_lRec."Source Type" := ProductionOrder_lRec."source type"::Item;
            ProductionOrder_lRec.Validate("Source No.", PostedQCRcptHeader_iRec."Item No.");
            ProductionOrder_lRec.Validate(Quantity, PostedQCRcptHeader_iRec."Quantity to Rework");
            //T12756-OS
            // if ProductionOrder_lRec."Due Date" = 0D then 
            //     ProductionOrder_lRec.Validate("Due Date", Today);
            //T12756-OE

            ProductionOrder_lRec."Dimension Set ID" := PostedQCRcptHeader_iRec."Dimension Set ID";
            ProductionOrder_lRec."Shortcut Dimension 1 Code" := PostedQCRcptHeader_iRec."Shortcut Dimension 1 Code";
            ProductionOrder_lRec."Shortcut Dimension 2 Code" := PostedQCRcptHeader_iRec."Shortcut Dimension 2 Code";
            if ParentProductionOrder_lRec.get(ParentProductionOrder_lRec.Status::Released, PostedQCRcptHeader_iRec."Document No.") then begin
                ProductionOrder_lRec.Validate("Variant Code", ParentProductionOrder_lRec."Variant Code");
                ProductionOrder_lRec."Production BOM Version" := ParentProductionOrder_lRec."Production BOM Version";
                ProductionOrder_lRec.Validate("Due Date", ParentProductionOrder_lRec."Due Date");//T12756-N
            end;

            ProductionOrder_lRec."Rework Order" := true;
            ProductionOrder_lRec."Order Status" := ProductionOrder_lRec."Order Status"::Released;//T12546
            //T12212-NS for Rework Production Order
            ProductionOrder_lRec."Source Order No." := PostedQCRcptHeader_iRec."Document No.";//Parent Production Order
            ProductionOrder_lRec."Source QC No." := PostedQCRcptHeader_iRec."PreAssigned No.";//QC No
            ProductionOrder_lRec."Source Posted QC No." := PostedQCRcptHeader_iRec."No."; //Posted QC No

            //T12212-NE for Rework Production Order
            ProductionOrder_lRec.Modify(true);

            //Referash Production Order...
            FilterProductionOrder_lRec.Reset;
            FilterProductionOrder_lRec.SetRange(Status, ProductionOrder_lRec.Status);
            FilterProductionOrder_lRec.SetRange("No.", ProductionOrder_lRec."No.");
            FilterProductionOrder_lRec.FindFirst;
            RefOrder_gFnc(FilterProductionOrder_lRec);

            UpdateParentOrderNo_lFnc(ProductionOrder_lRec, PostedQCRcptHeader_iRec);//T12212-N //Child Order No.
            ReservationEntryMovementParentOrderToReworkProd_lFnc(ProductionOrder_lRec, PostedQCRcptHeader_iRec);//T12756-N
            CreateReworkProdOdrPostQC_lCdu.FGProdOrderComponent_gFnc(ProductionOrder_lRec, PostedQCRcptHeader_iRec);//Production Order Component- T12756-N
            ProductionOrder_lRec.Validate("Due Date", ParentProductionOrder_lRec."Due Date");//T12756-N
            ProductionOrder_lRec.Modify(true);

            exit(ProductionOrder_lRec."No.");
        end;
    end;

    local procedure RefOrder_gFnc(var ProductionOrder_vRec: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        RoutingNo: Code[20];
        Item: Record Item;
        Family: Record Family;
        CreateProdOrderLines: Codeunit "Create Prod. Order Lines";
        ErrorOccured: Boolean;
    begin
        RoutingNo := ProductionOrder_vRec."Routing No.";
        case ProductionOrder_vRec."Source Type" of
            ProductionOrder_vRec."source type"::Item:
                if Item.Get(ProductionOrder_vRec."Source No.") then begin
                    RoutingNo := Item."Routing No.";
                end;
            ProductionOrder_vRec."source type"::Family:
                if Family.Get(ProductionOrder_vRec."Source No.") then
                    RoutingNo := Family."Routing No.";
        end;
        if RoutingNo <> ProductionOrder_vRec."Routing No." then begin
            ProductionOrder_vRec."Routing No." := RoutingNo;
            ProductionOrder_vRec.Modify;
        end;

        ProdOrderLine.LockTable;

        Direction := Direction::Backward;
        //if not CreateProdOrderLines.Copy(ProductionOrder_vRec, Direction, '', false) then
        if not CreateProdOrderLines.Copy(ProductionOrder_vRec, Direction, ProductionOrder_vRec."Variant Code", false) then
            ErrorOccured := true;

        if ErrorOccured then
            Message(Text005, ProductionOrder_vRec.TableCaption, ProdOrderLine.FieldCaption("Bin Code"));

    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure T5406_OnAfterModify_lFnc(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line"; RunTrigger: Boolean)
    var
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        if Rec.IsTemporary then
            exit;

        if Rec."Finished Quantity" = 0 then
            exit;

        QCSetup_lRec.Get;
        if not QCSetup_lRec."Restrict Excess Qty. Output" then
            exit;

        if Rec."Finished Quantity" > Rec.Quantity then
            Rec.FieldError("Finished Quantity", StrSubstNo('can not be more than %1 line quantity', Rec.Quantity));
    end;

    procedure CreateQualityOrderRequest_gFnc(QCRcptLine_iRec: Record "QC Rcpt. Line"): Code[20]
    var
        NewProductionOrder_lRec: Record "Production Order";
        NoSeriesMgmnt_lCdu: Codeunit "No. Series";//Old NoSeriesManagement
        ReleaseProductionOrder_lRec: Record "Production Order";
        MFSetup_lRec: Record "Manufacturing Setup";
        ProductionOrder_lRec: Record "Production Order";
        Direction: Option Forward,Backward;
        CalcMethod: Option "No Levels","One level","All levels";
        FilterProductionOrder_lRec: Record "Production Order";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
    begin

        QCRcptHeader_lRec.get(QCRcptLine_iRec."No.");
        // if QCRcptHeader_lRec."Document Type" <> QCRcptHeader_lRec."document type"::Purchase then
        //     exit;

        if QCRcptLine_iRec."Quality Order No." <> '' then
            exit;


        MFSetup_lRec.Get;
        MFSetup_lRec.Testfield("Quality Location Code");
        MFSetup_lRec.Testfield("Quality Production Order Nos");
        if not (QCRcptLine_iRec."Item Code" <> '') Then
            Exit;
        ProductionOrder_lRec.Init;
        ProductionOrder_lRec.Status := ProductionOrder_lRec.Status::Released;
        ProductionOrder_lRec."No." := NoSeriesMgmnt_lCdu.GetNextNo(MFSetup_lRec."Quality Production Order Nos", 0D, true);
        ProductionOrder_lRec."No. Series" := MFSetup_lRec."Quality Production Order Nos";
        if ProductionOrder_lRec.Insert(true) then begin
            ProductionOrder_lRec.Validate("Location Code", MFSetup_lRec."Quality Location Code");
            ProductionOrder_lRec."Source Type" := ProductionOrder_lRec."source type"::Item;
            ProductionOrder_lRec.Validate("Source No.", QCRcptLine_iRec."Item Code");
            ProductionOrder_lRec.Validate(Quantity, 1);
            if ProductionOrder_lRec."Due Date" = 0D then
                ProductionOrder_lRec.Validate("Due Date", Today);

            ProductionOrder_lRec."Dimension Set ID" := QCRcptHeader_lRec."Dimension Set ID";
            ProductionOrder_lRec."Shortcut Dimension 1 Code" := QCRcptHeader_lRec."Shortcut Dimension 1 Code";
            ProductionOrder_lRec."Shortcut Dimension 2 Code" := QCRcptHeader_lRec."Shortcut Dimension 2 Code";
            ProductionOrder_lRec."QC Receipt No" := QCRcptHeader_lRec."No.";
            ProductionOrder_lRec."Quality Order" := true;
            ProductionOrder_lRec.Modify(true);

            //Referash Production Order...
            FilterProductionOrder_lRec.Reset;
            FilterProductionOrder_lRec.SetRange(Status, ProductionOrder_lRec.Status);
            FilterProductionOrder_lRec.SetRange("No.", ProductionOrder_lRec."No.");
            FilterProductionOrder_lRec.FindFirst;
            RefOrder_gFnc(FilterProductionOrder_lRec);
            UpdateQualityOrderNo_lFnc(QCRcptLine_iRec, ProductionOrder_lRec);
            exit(ProductionOrder_lRec."No.");
        end;
    end;

    local procedure UpdateQualityOrderNo_lFnc(QCRcptLine_iRec: Record "QC Rcpt. Line"; ProductionOrder_iRec: Record "Production Order")//T12113-C
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
    begin
        QCRcptLine_lRec.copy(QCRcptLine_iRec);
        QCRcptLine_lRec."Quality Order No." := ProductionOrder_iRec."No.";
        QCRcptLine_lRec.Modify();
    end;

    procedure ReworkCreateProdOrder_gFnc(PostedQCRcptHeader_iRec: Record "Posted QC Rcpt. Header"): Code[20]
    var
        NewProductionOrder_lRec: Record "Production Order";
        NoSeriesMgmnt_lCdu: Codeunit "No. Series";//Old NoSeriesManagement
        ReleaseProductionOrder_lRec: Record "Production Order";
        ProductionOrder_lRec: Record "Production Order";
        Direction: Option Forward,Backward;
        CalcMethod: Option "No Levels","One level","All levels";
        FilterProductionOrder_lRec: Record "Production Order";
        MFSetup_lRec: Record "Manufacturing Setup";
        ParentProductionOrder_lRec: Record "Production Order";
    begin
        // if PostedQCRcptHeader_iRec."Document Type" <> PostedQCRcptHeader_iRec."document type"::Production then
        //     exit;

        // if PostedQCRcptHeader_iRec."Quantity to Rework" = 0 then
        //     exit;

        MFSetup_lRec.Get;
        MFSetup_lRec.Testfield("Rework Production No. Series");


        ProductionOrder_lRec.Init;
        ProductionOrder_lRec.Status := ProductionOrder_lRec.Status::Released;
        ProductionOrder_lRec."No." := NoSeriesMgmnt_lCdu.GetNextNo(MFSetup_lRec."Rework Production No. Series", 0D, true);
        ProductionOrder_lRec."No. Series" := MFSetup_lRec."Rework Production No. Series";
        if ProductionOrder_lRec.Insert(true) then begin
            ProductionOrder_lRec.Validate("Location Code", PostedQCRcptHeader_iRec."Rework Location");
            ProductionOrder_lRec."Source Type" := ProductionOrder_lRec."source type"::Item;
            ProductionOrder_lRec.Validate("Source No.", PostedQCRcptHeader_iRec."Item No.");
            ProductionOrder_lRec.Validate(Quantity, PostedQCRcptHeader_iRec."Quantity to Rework");
            if ProductionOrder_lRec."Due Date" = 0D then
                ProductionOrder_lRec.Validate("Due Date", Today);

            ProductionOrder_lRec."Dimension Set ID" := PostedQCRcptHeader_iRec."Dimension Set ID";
            ProductionOrder_lRec."Shortcut Dimension 1 Code" := PostedQCRcptHeader_iRec."Shortcut Dimension 1 Code";
            ProductionOrder_lRec."Shortcut Dimension 2 Code" := PostedQCRcptHeader_iRec."Shortcut Dimension 2 Code";
            ProductionOrder_lRec."Rework Order" := true;
            ProductionOrder_lRec.Modify(true);

            //Referash Production Order...
            FilterProductionOrder_lRec.Reset;
            FilterProductionOrder_lRec.SetRange(Status, ProductionOrder_lRec.Status);
            FilterProductionOrder_lRec.SetRange("No.", ProductionOrder_lRec."No.");
            FilterProductionOrder_lRec.FindFirst;
            RefOrder_gFnc(FilterProductionOrder_lRec);
            exit(ProductionOrder_lRec."No.");
        end;
    end;

    local procedure UpdateParentOrderNo_lFnc(ChildProductionOrder_iRec: Record "Production Order"; PostedQCRcptHeader_iRec: Record "Posted QC Rcpt. Header")//T12212-ABA-N
    var
        ParentProductionOrder_lRec: Record "Production Order";
    begin
        //Update the Child Order No on Parent Production Order No.
        if not (ChildProductionOrder_iRec."Source Order No." <> '') then
            exit;
        ParentProductionOrder_lRec.get(ChildProductionOrder_iRec.Status::Released, ChildProductionOrder_iRec."Source Order No.");
        ParentProductionOrder_lRec."Rework Order No." := ChildProductionOrder_iRec."No.";//Child No.
        ParentProductionOrder_lRec."Posted QC Receipt No" := ChildProductionOrder_iRec."Source Posted QC No.";
        ParentProductionOrder_lRec."Reject Reason" := PostedQCRcptHeader_iRec."Rejection Reason";
        ParentProductionOrder_lRec."Rework Reason" := PostedQCRcptHeader_iRec."Rework Reason";
        ParentProductionOrder_lRec."Rejected Quantity (QC)" := PostedQCRcptHeader_iRec."Rejected Quantity";
        ParentProductionOrder_lRec."Rework Quantity" := PostedQCRcptHeader_iRec."Quantity to Rework";
        ParentProductionOrder_lRec.Modify();
    end;

    Local procedure ReservationEntryMovementParentOrderToReworkProd_lFnc(ProdOrder_iRec: Record "Production Order"; PostedQCRcptHeader_iRec: Record "Posted QC Rcpt. Header")
    var
        ParentProductionOrder_lRec: Record "Production Order";
        ParentProductionOrderLine_lRec: Record "Prod. Order Line";
        ReservEntry2: Record "Reservation Entry";
        Ile_lRec: Record "Item Ledger Entry";
        PostedQCRcpt_lRec: Record "Posted QC Rcpt. Header";
    begin

        ParentProductionOrder_lRec.reset;
        if not ParentProductionOrder_lRec.get(ParentProductionOrder_lRec.Status::Released, ProdOrder_iRec."Source Order No.") then
            exit;
        ParentProductionOrderLine_lRec.reset;
        ParentProductionOrderLine_lRec.SetRange("Prod. Order No.", ParentProductionOrder_lRec."No.");
        ParentProductionOrderLine_lRec.SetRange(Status, ParentProductionOrderLine_lRec.Status::Released);
        if ParentProductionOrderLine_lRec.FindSet() then begin
            repeat
                PostedQCRcpt_lRec.Get(ParentProductionOrder_lRec."Posted QC Receipt No");
                Ile_lRec.SetCurrentKey("Entry Type", "Item No.");
                Ile_lRec.SetRange("Entry Type", Ile_lRec."Entry Type"::Output);
                Ile_lRec.SetRange("Item No.", ParentProductionOrderLine_lRec."Item No.");
                Ile_lRec.SetRange("Location Code", ParentProductionOrder_lRec."Location Code");
                Ile_lRec.SetRange("Document No.", ParentProductionOrder_lRec."No.");
                Ile_lRec.SetRange("QC No.", ParentProductionOrder_lRec."QC Receipt No");
                Ile_lRec.SetRange("Posted QC No.", ParentProductionOrder_lRec."Posted QC Receipt No");
                Ile_lRec.SetRange(Open, true);
                if PostedQCRcpt_lRec."Vendor Lot No." <> '' then
                    Ile_lRec.SetRange("Lot No.", PostedQCRcpt_lRec."Vendor Lot No.");
                Ile_lRec.SetFilter("Rework Quantity", '>%1', 0);
                if Ile_lRec.FindSet() then begin
                    Repeat
                        UpdateReservationEntry_lFnc(Ile_lRec, ProdOrder_iRec, PostedQCRcptHeader_iRec)
                    until Ile_lRec.next = 0;
                end;
            until ParentProductionOrderLine_lRec.next = 0
        end;
    end;

    local procedure UpdateReservationEntry_lFnc(Ile_iRec: record "Item Ledger Entry"; ProdOrder_iRec: Record "Production Order"; PostedQCRcptHeader_iRec: Record "Posted QC Rcpt. Header")
    var
        ReservEntry: Record "Reservation Entry";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
    begin
        ReservEntry.reset;
        ReservEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
          "Source Batch Name", "Source Prod. Order Line", "Reservation Status",
          "Shipment Date", "Expected Receipt Date");

        ReservEntry.SetRange("Source Ref. No.", Ile_iRec."Entry No.");
        ReservEntry.SetRange("Source type", Database::"Item Ledger Entry");
        ReservEntry.SetRange("Source Subtype", 0);
        ReservEntry.SetRange(Positive, true);
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        ReservEntry.SetRange("Disallow Cancellation", false);
        ReservEntry.SetRange("Location Code", Ile_iRec."Location Code");
        ReservEntry.SetRange("Item No.", Ile_iRec."Item No.");
        if ReservEntry.FindSet() then begin
            repeat
                FindSourceTrackingEntry_lFnc(ReservEntry);
                ReservEngineMgt.CancelReservation(ReservEntry);
                CloseSurplusTrackingEntry(ReservEntry);//Delete
                ReservationCreationForReworkProdOrder_lFnc(TemporaryReservationEntry_gRec, ProdOrder_iRec);
            until ReservEntry.Next() = 0;
        end;
    end;



    local procedure CloseSurplusTrackingEntry(ReservEntry_iRec: Record "Reservation Entry")
    var
        ReservEntry2_lRec: Record "Reservation Entry";
    begin
        // if TemporaryReservationEntry_gRec.Positive then
        //     exit;
        TemporaryReservationEntry_gRec.reset;
        TemporaryReservationEntry_gRec.SetRange(Positive, false);
        TemporaryReservationEntry_gRec.FindFirst();
        // ReservEntry2_lRec.reset;
        // ReservEntry2_lRec.SetRange("Source Subtype", TemporaryReservationEntry_gRec."Source Subtype");
        // ReservEntry2_lRec.SetRange("Source Type", TemporaryReservationEntry_gRec."Source Type");
        // ReservEntry2_lRec.SetRange("Source Ref. No.", TemporaryReservationEntry_gRec."Source Ref. No.");
        // ReservEntry2_lRec.SetRange("Location Code", TemporaryReservationEntry_gRec."Location Code");
        // ReservEntry2_lRec.SetRange("Item No.", TemporaryReservationEntry_gRec."Item No.");
        // if TemporaryReservationEntry_gRec."Lot No." <> '' then
        //     ReservEntry2_lRec.SetRange("Lot No.", TemporaryReservationEntry_gRec."Lot No.");
        // if TemporaryReservationEntry_gRec."Serial No." <> '' then
        //     ReservEntry2_lRec.SetRange("Serial No.", TemporaryReservationEntry_gRec."Serial No.");
        // ReservEntry2_lRec.SetRange("Source ID", TemporaryReservationEntry_gRec."Source ID");//Document No-
        // if ReservEntry2_lRec.FindSet() then
        //     ReservEntry2_lRec.Delete();
        if ReservEntry2_lRec.get(TemporaryReservationEntry_gRec."Entry No.", Not TemporaryReservationEntry_gRec.Positive) then
            ReservEntry2_lRec.Delete;
    end;

    local procedure FindSourceTrackingEntry_lFnc(ReservEntry_iRec: Record "Reservation Entry")
    var
        ReservEntry2_lRec: Record "Reservation Entry";
    begin
        //Clear(TemporaryReservationEntry_gRec);
        Clear(ReservEntry2_lRec);
        ReservEntry2_lRec.Reset();
        ReservEntry2_lRec.SetRange("Entry No.", ReservEntry_iRec."Entry No.");
        ReservEntry2_lRec.SetRange("Reservation Status", ReservEntry2_lRec."Reservation Status"::Reservation);
        if ReservEntry2_lRec.FindSet() then
            repeat
                TemporaryReservationEntry_gRec.Init;
                TemporaryReservationEntry_gRec.TransferFields(ReservEntry2_lRec);//find the Reservation Entry for Delete-There is 2 Entries on Same Entry No.
                TemporaryReservationEntry_gRec.Insert();
            until ReservEntry2_lRec.Next() = 0;
    end;

    local procedure ReservationCreationForReworkProdOrder_lFnc(ReservEntry_iRec: Record "Reservation Entry"; ReworkProductionOrder_iRec: Record "Production Order")
    var
        NewReservEntry1_lRec: Record "Reservation Entry";
        ReworkProdOrdLine_lRec: Record "Prod. Order Line";
        LastEntryNo_lInt: Integer;
    begin
        ReworkProdOrdLine_lRec.Reset();
        ReworkProdOrdLine_lRec.SetRange(Status, ReworkProductionOrder_iRec.Status);
        ReworkProdOrdLine_lRec.SetRange("Prod. Order No.", ReworkProductionOrder_iRec."No.");
        if ReworkProdOrdLine_lRec.FindFirst() then;

        TemporaryReservationEntry_gRec.Reset();
        if TemporaryReservationEntry_gRec.FindSet() then
            repeat
                NewReservEntry1_lRec.init;
                NewReservEntry1_lRec.TransferFields(TemporaryReservationEntry_gRec);
                if (NewReservEntry1_lRec."Source Type" = 32) and (NewReservEntry1_lRec.Positive) then begin
                    NewReservEntry1_lRec."Source Type" := 5406;
                    NewReservEntry1_lRec."Source Subtype" := 3;
                    NewReservEntry1_lRec."Source Ref. No." := 0;
                    NewReservEntry1_lRec."Source ID" := ReworkProdOrdLine_lRec."Prod. Order No.";
                    NewReservEntry1_lRec."Source Prod. Order Line" := ReworkProdOrdLine_lRec."Line No.";
                end;
                NewReservEntry1_lRec.Description := ReworkProdOrdLine_lRec.Description;
                NewReservEntry1_lRec."Lot No." := '';
                NewReservEntry1_lRec."Serial No." := '';
                NewReservEntry1_lRec."Warranty Date" := 0D;
                NewReservEntry1_lRec."Expiration Date" := 0D;
                //Kemibase App Custom Fields Dependency-NS
                NewReservEntry1_lRec."Manufacturing Date 2" := 0D;
                Evaluate(NewReservEntry1_lRec."Manufacturing Date 2", '');
                NewReservEntry1_lRec."Gross Weight 2" := 0;
                NewReservEntry1_lRec."Net Weight 2" := 0;
                NewReservEntry1_lRec."Supplier Batch No. 2" := '';
                NewReservEntry1_lRec."Analysis Date" := 0D;
                NewReservEntry1_lRec."New Custom BOE No." := '';
                NewReservEntry1_lRec."New Custom Lot No." := '';
                NewReservEntry1_lRec.CustomBOENumber := '';
                NewReservEntry1_lRec.CustomLotNumber := '';
                //Kemibase App Custom Fields Dependency-NE
                NewReservEntry1_lRec.Insert();
            until TemporaryReservationEntry_gRec.Next() = 0;

    end;
}

