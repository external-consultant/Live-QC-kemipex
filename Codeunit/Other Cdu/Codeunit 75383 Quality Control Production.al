Codeunit 75383 "Quality Control - Production"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-04     27/08/12    Dipak Patel/Nilesh Gajjar
    //                        QC Module - Redesign Released.
    // I-C0009-1400405-01     05/08/14    Chintan Panchal
    //                        Upgrade to NAV 2013 R2
    // I-C0009-1001310-08     29/11/14    Chintan Panchal
    //                        QC Enhancement.
    // ------------------------------------------------------------------------------------------------------------------------------


    trigger OnRun()
    begin
    end;

    var
        Text0000_gCtx: label 'Do you want to create QC Receipt ?';
        Text0001_gCtx: label 'Sum of "Quantity Under Inspection","Accepted Quantity","Accepted Quantity with Deviation", "Rework Quantity" and "Scrap Quantity" cannot be greater than "Output Quantity".';
        Text0002_gCtx: label 'Item Specification Code must be defined for Item No. = ''%1''.';
        ItemJnlLine_gRec: Record "Item Journal Line";
        Text0003_gCtx: label 'QC Receipt is created successfully.';
        QCRcptHeader_gRec: Record "QC Rcpt. Header";
        Text0004_gCtx: label 'Item Journal Line can not be deleted. "QC Receipt" exists for Iten Journal Line Item Journal Template = ''%1'' Item Journal Bacth = ''%2'' Line No. = ''%3''.';
        Text0005_gCtx: label 'Output Quantity must not be greater than %1 on Line No.: ''%2''.';
        Text0006_gCtx: label 'Output Quantity must be equal to Sum of "Accepted Quantity","Accepted Quantity with Deviation","Rework Quantity" and "Scrap Quantity"  in Item Journal Line Journal Template Name = ''%1'',Journal Batch Name = ''%2'',Line No. = ''%3''.';
        Text0007_gCtx: label 'Quality Control must be done in Item Journal Line Journal Template Name = ''%1'',Journal Batch Name = ''%2'',Line No. = ''%3''.';
        Text0008_gCtx: label 'Output Quantity must be equal to Rejected Quantity in Item Journal Line Journal Template Name = ''%1'',Journal Batch Name = ''%2'',Line No. = ''%3''.';
        Text0009_gCtx: label 'Output Quantity must be equal to Rework Quantity in Item Journal Line Journal Template Name = ''%1'',Journal Batch Name = ''%2'',Line No. = ''%3''.';

    procedure CreateQC_gFnc(ItemJnlLine_iRec: Record "Item Journal Line")
    var
        Item_lRec: Record Item;
        ProdOrderRtngLine_lRec: Record "Prod. Order Routing Line";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
        ProdLine_lRec: Record "Prod. Order Line";
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCSpecificHeader_lRec: Record "QC Specification Header";
        QCSpecificLine_lRec: Record "QC Specification Line";
        Bin_lRec: Record Bin;
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineDetail2_lRec: Record "QC Line Detail";
        Cnt_lInt: Integer;
        LineNo: Integer;
        Cnt2_lInt: Decimal;
        MainLocation_lRec: Record Location;
        RejectLocation_lRec: Record Location;
        ReworkLocation_lRec: Record Location;
        AlreadyBookedOutputQty_lDec: Decimal;
        AlreadyExistItemJnlQty_lDec: Decimal;
        QtyCanBeEntered_lDec: Decimal;
        ProdOrdRtngLine2_lRec: Record "Prod. Order Routing Line";
        Location2_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        CapaLdgrEntry_lRec: Record "Capacity Ledger Entry";
        ItemJnlLine_lRec: Record "Item Journal Line";
        PrevProdOrdRtngLine_lRec: Record "Prod. Order Routing Line";
        ChkProdOrderLine_lRec: Record "Prod. Order Line";
        ReservationEntry_lRec: Record "Reservation Entry";
    begin
        //Function Written to Create QC Receipt for Manufacturing Item using "Output Journal".
        //I-C0009-1001310-04 NS

        //I-C0009-1001310-08-NS
        //T12113-ABA-OS
        // Clear(QCSetup_lRec);
        // QCSetup_lRec.Get;
        // if (not QCSetup_lRec."Allow QC in Production") then
        //     exit;
        //T12113-ABA-OE
        //I-C0009-1001310-08-NE

        //T12113-ABA-NS
        Clear(Item_lRec);
        Item_lRec.get(ItemJnlLine_iRec."Item No.");
        if (not Item_lRec."Allow QC in Production") then
            exit;

        //T12113-ABA-NE

        //ManCheck-NS 121319
        if (ItemJnlLine_iRec."Stop Code" <> '') or (ItemJnlLine_iRec."Stop Time" <> 0) then begin
            Error('You cannot create QC Receipt for Stop Time Output Entry');
        end;
        //ManCheck-NE 121319

        ItemJnlLine_gRec.Copy(ItemJnlLine_iRec);
        AlreadyBookedOutputQty_lDec := 0;
        AlreadyExistItemJnlQty_lDec := 0;
        QtyCanBeEntered_lDec := 0;

        CapaLdgrEntry_lRec.Reset;
        CapaLdgrEntry_lRec.SetRange("Order Type", CapaLdgrEntry_lRec."order type"::Production);
        CapaLdgrEntry_lRec.SetRange("Order No.", ItemJnlLine_gRec."Order No.");
        CapaLdgrEntry_lRec.SetRange("Order Line No.", ItemJnlLine_gRec."Order Line No.");
        CapaLdgrEntry_lRec.SetRange("Routing No.", ItemJnlLine_gRec."Routing No.");
        CapaLdgrEntry_lRec.SetRange("Routing Reference No.", ItemJnlLine_gRec."Routing Reference No.");
        CapaLdgrEntry_lRec.SetRange("Operation No.", ItemJnlLine_gRec."Operation No.");
        if CapaLdgrEntry_lRec.FindSet then begin
            repeat
                AlreadyBookedOutputQty_lDec += CapaLdgrEntry_lRec."Output Quantity";
            until CapaLdgrEntry_lRec.Next = 0;
        end;

        ItemJnlLine_lRec.Reset;
        ItemJnlLine_lRec.SetRange("Order Type", ItemJnlLine_lRec."order type"::Production);
        ItemJnlLine_lRec.SetRange("Order No.", ItemJnlLine_gRec."Order No.");
        ItemJnlLine_lRec.SetRange("Order Line No.", ItemJnlLine_gRec."Order Line No.");
        ItemJnlLine_lRec.SetRange("Routing No.", ItemJnlLine_gRec."Routing No.");
        ItemJnlLine_lRec.SetRange("Routing Reference No.", ItemJnlLine_gRec."Routing Reference No.");
        ItemJnlLine_lRec.SetRange("Operation No.", ItemJnlLine_gRec."Operation No.");
        ItemJnlLine_lRec.SetFilter("Line No.", '<>%1', ItemJnlLine_gRec."Line No.");
        if ItemJnlLine_lRec.FindSet then begin
            repeat
                AlreadyExistItemJnlQty_lDec += ItemJnlLine_lRec."Output Quantity";
            until ItemJnlLine_lRec.Next = 0;
        end;

        QCSetup_lRec.Get;

        if ProdOrderRtngLine_lRec.Get(ProdOrderRtngLine_lRec.Status::Released, ItemJnlLine_gRec."Order No.",
                                    ItemJnlLine_gRec."Routing Reference No.", ItemJnlLine_gRec."Routing No.",
                                    ItemJnlLine_gRec."Operation No.")
        then begin
            if ProdOrderRtngLine_lRec."Previous Operation No." <> '' then begin
                if not (QCSetup_lRec."Book Out for RejQty Production") then begin
                    if PrevProdOrdRtngLine_lRec.Get(ProdOrderRtngLine_lRec.Status, ItemJnlLine_gRec."Order No.",
                       ItemJnlLine_gRec."Routing Reference No.", ItemJnlLine_gRec."Routing No.",
                       ProdOrderRtngLine_lRec."Previous Operation No.")
                    then
                        PrevProdOrdRtngLine_lRec.CalcFields("Finished Quantity QC");
                    QtyCanBeEntered_lDec := PrevProdOrdRtngLine_lRec."Finished Quantity QC" -
                                            AlreadyBookedOutputQty_lDec -
                                            AlreadyExistItemJnlQty_lDec;

                    if ItemJnlLine_gRec."Output Quantity" > QtyCanBeEntered_lDec then
                        Error(Text0005_gCtx, QtyCanBeEntered_lDec, ItemJnlLine_gRec."Line No.");
                end else begin
                    if PrevProdOrdRtngLine_lRec.Get(ProdOrderRtngLine_lRec.Status, ItemJnlLine_gRec."Order No.",
                      ItemJnlLine_gRec."Routing Reference No.", ItemJnlLine_gRec."Routing No.", ProdOrderRtngLine_lRec."Previous Operation No.")
              then
                        PrevProdOrdRtngLine_lRec.CalcFields("Finished Accepted Quantity");
                    PrevProdOrdRtngLine_lRec.CalcFields("Finished Acc with Deviation");
                    QtyCanBeEntered_lDec := (PrevProdOrdRtngLine_lRec."Finished Accepted Quantity" +
                                             PrevProdOrdRtngLine_lRec."Finished Acc with Deviation") - AlreadyBookedOutputQty_lDec
                                             - AlreadyExistItemJnlQty_lDec;
                    if QCSetup_lRec."Restrict Excess Qty. Output" then//hypercare-Yaksh
                        if ItemJnlLine_gRec."Output Quantity" > QtyCanBeEntered_lDec then
                            Error(Text0005_gCtx, QtyCanBeEntered_lDec, ItemJnlLine_gRec."Line No.");
                end;
            end else begin
                ChkProdOrderLine_lRec.Get(ProdOrderRtngLine_lRec.Status, ProdOrderRtngLine_lRec."Prod. Order No.", ProdOrderRtngLine_lRec."Routing Reference No.");  //NG-N 180919

                if not (QCSetup_lRec."Book Out for RejQty Production") then begin
                    ProdOrderRtngLine_lRec.CalcFields("Finished Quantity QC");
                    QtyCanBeEntered_lDec := ChkProdOrderLine_lRec.Quantity - (AlreadyBookedOutputQty_lDec + AlreadyExistItemJnlQty_lDec);  //NG-U 180919
                    if QCSetup_lRec."Restrict Excess Qty. Output" then//hypercare-Yaksh
                        if ItemJnlLine_gRec."Output Quantity" > QtyCanBeEntered_lDec then
                            Error(Text0005_gCtx, QtyCanBeEntered_lDec, ItemJnlLine_gRec."Line No.");
                end else begin
                    ProdOrderRtngLine_lRec.CalcFields("Finished Accepted Quantity");
                    ProdOrderRtngLine_lRec.CalcFields("Finished Acc with Deviation");
                    QtyCanBeEntered_lDec := ChkProdOrderLine_lRec.Quantity - (AlreadyBookedOutputQty_lDec + AlreadyExistItemJnlQty_lDec);  //NG-U 180919
                    if QCSetup_lRec."Restrict Excess Qty. Output" then//hypercare-Yaksh
                        if ItemJnlLine_gRec."Output Quantity" > QtyCanBeEntered_lDec then
                            Error(Text0005_gCtx, QtyCanBeEntered_lDec, ItemJnlLine_gRec."Line No.");
                end;
            end;
        end;

        if not Confirm(Text0000_gCtx) then
            exit;

        ItemJnlLine_gRec.TestField("Location Code");
        if CheckBinMandatory_lFnc(ItemJnlLine_gRec."Location Code") then
            ItemJnlLine_gRec.TestField("Bin Code");

        if not (ItemJnlLine_gRec."Output Quantity" > (ItemJnlLine_gRec."Accepted Quantity" + ItemJnlLine_gRec."Scrap Quantity" +
                                                      ItemJnlLine_gRec."Qty Accepted with Deviation" +
                                                      ItemJnlLine_gRec."Quantity Under Inspection"))
        then
            //ERROR(Text0001_gCtx);
            Error('Output Quantity must have a Value on Output line.');

        Clear(Item_lRec);
        if Item_lRec.Get(ItemJnlLine_gRec."Item No.") then begin
            //Item_lRec.TestField("QC Required");//T12113-ABA-O
            if Item_lRec."Item Specification Code" = '' then
                Error(Text0002_gCtx, Item_lRec."No.");
        end;

        QCSpecificHeader_lRec.Get(Item_lRec."Item Specification Code");
        QCSpecificHeader_lRec.TestField(Status, QCSpecificHeader_lRec.Status::Certified);

        ProdOrderRtngLine_lRec.Reset;
        ProdOrderRtngLine_lRec.SetRange(Status, ProdOrderRtngLine_lRec.Status::Released);
        ProdOrderRtngLine_lRec.SetRange("Prod. Order No.", ItemJnlLine_gRec."Order No.");
        ProdOrderRtngLine_lRec.SetRange("Routing No.", ItemJnlLine_gRec."Routing No.");
        ProdOrderRtngLine_lRec.SetRange("Routing Reference No.", ItemJnlLine_gRec."Routing Reference No.");
        ProdOrderRtngLine_lRec.SetFilter("Routing Status", '<> %1', ProdOrderRtngLine_lRec."routing status"::Finished);
        ProdOrderRtngLine_lRec.SetRange("Operation No.", ItemJnlLine_gRec."Operation No.");
        if ProdOrderRtngLine_lRec.FindFirst then begin
            ProdOrderRtngLine_lRec.TestField("QC Required");
            QCRcptHeader_lRec.Init;
            QCRcptHeader_lRec.Validate("Item No.", ItemJnlLine_gRec."Item No.");
            QCRcptHeader_lRec."Variant Code" := ItemJnlLine_gRec."Variant Code";
            QCRcptHeader_lRec."Item Name" := Item_lRec.Description;
            QCRcptHeader_lRec."Item Description" := Item_lRec.Description;
            QCRcptHeader_lRec."Item Description 2" := Item_lRec."Description 2";
            QCRcptHeader_lRec."Inspection Quantity" := ItemJnlLine_gRec."Output Quantity";
            QCRcptHeader_lRec."Remaining Quantity" := ItemJnlLine_gRec."Output Quantity";

            Clear(ProdLine_lRec);
            if ProdLine_lRec.Get(ProdLine_lRec.Status::Released, ItemJnlLine_gRec."Order No.",
                                 ItemJnlLine_gRec."Order Line No.") then
                QCRcptHeader_lRec."Order Quantity" := ProdLine_lRec.Quantity;
            //QCV3-OS 24-01-18
            //IF Item_lRec.Sample <> 0 THEN
            //  QCRcptHeader_lRec."Sample Quantity" := (QCRcptHeader_lRec."Remaining Quantity" * Item_lRec.Sample)/100
            //ELSE
            //  QCRcptHeader_lRec."Sample Quantity" := QCRcptHeader_lRec."Remaining Quantity";
            //QCV3-OE 24-01-18
            //QCV3-NS 24-01-18
            if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::Percentage then begin
                Item_lRec.TestField(Sample);
                QCRcptHeader_lRec."Sample Quantity" := ROUND((QCRcptHeader_lRec."Remaining Quantity" * Item_lRec.Sample) / 100, Item_lRec."Rounding Precision")
            end else
                if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::Quantity then begin
                    Item_lRec.TestField(Sample);
                    if QCRcptHeader_lRec."Remaining Quantity" < Item_lRec.Sample then
                        QCRcptHeader_lRec."Sample Quantity" := QCRcptHeader_lRec."Remaining Quantity"
                    else
                        QCRcptHeader_lRec."Sample Quantity" := Item_lRec.Sample;
                end else
                    if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::" " then begin
                        QCRcptHeader_lRec."Sample Quantity" := QCRcptHeader_lRec."Remaining Quantity";
                    end;
            //QCV3-NE 24-01-18

            QCRcptHeader_lRec."Receipt Date" := ItemJnlLine_gRec."Posting Date";
            QCRcptHeader_lRec."Unit of Measure" := ItemJnlLine_gRec."Unit of Measure Code";

            if ItemJnlLine_gRec.Type = ItemJnlLine_gRec.Type::"Work Center" then
                QCRcptHeader_lRec."Center Type" := QCRcptHeader_lRec."center type"::"Work Center"
            else
                if ItemJnlLine_gRec.Type = ItemJnlLine_gRec.Type::"Machine Center" then
                    QCRcptHeader_lRec."Center Type" := QCRcptHeader_lRec."center type"::"Machine Center ";

            QCRcptHeader_lRec."Center No." := ItemJnlLine_gRec."Work Center No.";
            QCRcptHeader_lRec."Document Type" := QCRcptHeader_lRec."document type"::Production;
            QCRcptHeader_lRec."Document No." := ItemJnlLine_gRec."Order No.";
            QCRcptHeader_lRec."Document Line No." := ItemJnlLine_gRec."Order Line No.";
            QCRcptHeader_lRec.Validate("Item Journal Template Name", ItemJnlLine_gRec."Journal Template Name");
            QCRcptHeader_lRec.Validate("Item General Batch Name", ItemJnlLine_gRec."Journal Batch Name");
            QCRcptHeader_lRec."Item Journal Line No." := ItemJnlLine_gRec."Line No.";
            QCRcptHeader_lRec.Validate("Location Code", ItemJnlLine_gRec."Location Code");
            QCRcptHeader_lRec.Validate("QC Location", ItemJnlLine_gRec."Location Code");  //NG-N
            // QCRcptHeader_lRec.Validate("QC Bin Code", ItemJnlLine_gRec."Bin Code");
            QCRcptHeader_lRec."QC Bin Code" := ItemJnlLine_gRec."Bin Code";
            QCRcptHeader_lRec.Validate("Operation No.", ItemJnlLine_gRec."Operation No.");
            QCRcptHeader_lRec."Operation Name" := ProdOrderRtngLine_lRec.Description;


            ReservationEntry_lRec.Reset;
            ReservationEntry_lRec.SetRange("Source Batch Name", ItemJnlLine_gRec."Journal Batch Name");
            ReservationEntry_lRec.SetRange("Source ID", ItemJnlLine_gRec."Journal Template Name");
            ReservationEntry_lRec.SetRange("Source Type", 83);
            ReservationEntry_lRec.SetRange("Source Ref. No.", ItemJnlLine_gRec."Line No.");
            ReservationEntry_lRec.SetRange("Item No.", ItemJnlLine_gRec."Item No.");
            if ReservationEntry_lRec.FindSet() then begin
                QCRcptHeader_lRec."Item Tracking" := ReservationEntry_lRec."Item Tracking".AsInteger();   //CP-N
                //T12756-NS
                if ReservationEntry_lRec."Lot No." <> '' then
                    QCRcptHeader_lRec."Vendor Lot No." := ReservationEntry_lRec."Lot No."
                else
                    QCRcptHeader_lRec."Vendor Lot No." := ReservationEntry_lRec."Serial No.";
                //T12756-NE
            end else begin
                QCRcptHeader_lRec."Item Tracking" := ItemTrackingOption_gFnc(ItemJnlLine_gRec."Lot No.", ItemJnlLine_gRec."Serial No.");   //CP-N
                //T12756-NS
                if ItemJnlLine_gRec."Lot No." <> '' then
                    QCRcptHeader_lRec."Vendor Lot No." := ItemJnlLine_gRec."Lot No."
                else
                    QCRcptHeader_lRec."Vendor Lot No." := ItemJnlLine_gRec."Serial No.";
                //T12756-NE
            end;

            // if not QCSetup_lRec."QC Block without Location" then Begin                                                                                                                               //Get the Rejection Location of Main Location >>
            QCRcptHeader_lRec.Validate("Store Location Code", ItemJnlLine_gRec."Location Code");
            MainLocation_lRec.Get(ItemJnlLine_gRec."Location Code");
            MainLocation_lRec.TestField("Rejection Location");
            QCRcptHeader_lRec.Validate("Rejection Location", MainLocation_lRec."Rejection Location");
            RejectLocation_lRec.Get(QCRcptHeader_lRec."Rejection Location");
            if CheckBinMandatory_lFnc(RejectLocation_lRec.Code) then begin
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", QCRcptHeader_lRec."Rejection Location");
                Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REJECT);
                Bin_lRec.FindFirst;
                QCRcptHeader_lRec.Validate("Reject Bin Code", Bin_lRec.Code);
            end;
            //Get the Rejection Location of Main Location <<
            //T13091-NS
            if QCSetup_lRec."Rework Location Pro. Order" <> '' then begin
                QCRcptHeader_lRec.Validate("Rework Location", QCSetup_lRec."Rework Location Pro. Order");
                ReworkLocation_lRec.Get(QCRcptHeader_lRec."Rework Location");
                if CheckBinMandatory_lFnc(ReworkLocation_lRec.Code) then begin
                    Bin_lRec.Reset;
                    Bin_lRec.SetRange("Location Code", QCRcptHeader_lRec."Rework Location");
                    Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REWORK);
                    Bin_lRec.FindFirst;
                    QCRcptHeader_lRec.Validate("Rework Bin Code", Bin_lRec.Code);
                end;
            end else begin
                //T13091-NE
                //IF Rework Location for Main Location Exists Then Fill it >>
                if MainLocation_lRec."Rework Location" <> '' then begin
                    QCRcptHeader_lRec.Validate("Rework Location", MainLocation_lRec."Rework Location");
                    ReworkLocation_lRec.Get(QCRcptHeader_lRec."Rework Location");
                    if CheckBinMandatory_lFnc(ReworkLocation_lRec.Code) then begin
                        Bin_lRec.Reset;
                        Bin_lRec.SetRange("Location Code", QCRcptHeader_lRec."Rework Location");
                        Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REWORK);
                        Bin_lRec.FindFirst;
                        QCRcptHeader_lRec.Validate("Rework Bin Code", Bin_lRec.Code);
                    end;
                end;
                //IF Rework Location for Main Location Exists Then Fill it <<  
            end;



            if CheckBinMandatory_lFnc(ItemJnlLine_gRec."Location Code") then begin
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", ItemJnlLine_gRec."Location Code");
                Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::STORE);
                Bin_lRec.FindFirst;
                QCRcptHeader_lRec.Validate("Store Bin Code", Bin_lRec.Code);
            end;

            if CheckBinMandatory_lFnc(ItemJnlLine_gRec."Location Code") then begin
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", QCRcptHeader_lRec."Rejection Location");
                Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REJECT);
                if Bin_lRec.FindFirst then
                    QCRcptHeader_lRec.Validate("Reject Bin Code", Bin_lRec.Code);
            end;


            //T01118-NS
            QCRcptHeader_lRec."Shortcut Dimension 1 Code" := ItemJnlLine_gRec."Shortcut Dimension 1 Code";
            QCRcptHeader_lRec."Dimension Set ID" := ItemJnlLine_gRec."Dimension Set ID";
            //T01118-NE
            //need to write


            QCRcptHeader_lRec.Insert(true);

            QCSpecificLine_lRec.Reset;
            QCSpecificLine_lRec.SetRange("Item Specifiction Code", Item_lRec."Item Specification Code");
            QCSpecificLine_lRec.SetRange("Standard Task Code", ProdOrderRtngLine_lRec."Standard Task Code");
            QCSpecificLine_lRec.FindFirst;

            Cnt_lInt := 10000;
            repeat
                QCRcptLine_lRec."No." := QCRcptHeader_lRec."No.";
                QCRcptLine_lRec.Print := QCSpecificLine_lRec.Print;//T13242-N 03-01-2025
                QCRcptLine_lRec."Line No." := Cnt_lInt;
                QCRcptLine_lRec.Validate("Operation No.", ItemJnlLine_gRec."Operation No.");
                QCRcptLine_lRec.Validate("Item Code", QCSpecificLine_lRec."Item Code");//31072024-N
                QCRcptLine_lRec.Validate("Item Description", QCSpecificLine_lRec."Item Description");//31072024-N
                QCRcptLine_lRec.Validate("Quality Parameter Code", QCSpecificLine_lRec."Quality Parameter Code");
                QCRcptLine_lRec.Validate("Unit of Measure Code", QCSpecificLine_lRec."Unit of Measure Code");
                QCRcptLine_lRec.Type := QCSpecificLine_lRec.Type;
                QCRcptLine_lRec."Min.Value" := QCSpecificLine_lRec."Min.Value";
                QCRcptLine_lRec."Max.Value" := QCSpecificLine_lRec."Max.Value";
                //T51170-NS            
                QCRcptLine_lRec."Rounding Precision" := QCSpecificLine_lRec."Rounding Precision";//T51170-N
                QCRcptLine_lRec."Show in COA" := QCSpecificLine_lRec."Show in COA";
                QCRcptLine_lRec."Default Value" := QCSpecificLine_lRec."Default Value";
                QCRcptLine_lRec.Description := QCSpecificLine_lRec.Description;
                QCRcptLine_lRec."Method Description" := QCSpecificLine_lRec."Method Description";
                //T51170-NE
                QCRcptLine_lRec."Decimal Places" := QCSpecificLine_lRec."Decimal Places"; //T52614-N
                //T12113-ABA-NS
                QCRcptLine_lRec."Item Code" := QCSpecificLine_lRec."Item Code";
                QCRcptLine_lRec."Item Description" := QCSpecificLine_lRec."Item Description";
                //T12113-ABA-NE
                //T13827-NS
                QCRcptLine_lRec."COA Min.Value" := QCSpecificLine_lRec."COA Min.Value";
                QCRcptLine_lRec."COA Max.Value" := QCSpecificLine_lRec."COA Max.Value";
                //T13827-NE
                QCRcptLine_lRec."Text Value" := QCSpecificLine_lRec."Text Value";
                QCRcptLine_lRec.Code := QCSpecificLine_lRec."Document Code";
                QCRcptLine_lRec.Mandatory := QCSpecificLine_lRec.Mandatory;
                QCSpecificLine_lRec.CalcFields(Method);
                QCRcptLine_lRec.Method := QCSpecificLine_lRec.Method;
                // QCRcptLine_lRec.Description := QCSpecificLine_lRec.Description;//18042025-O
                // QCRcptLine_lRec.Print := QCSpecificLine_lRec.Print;

                QCRcptLine_lRec.Insert(true);
                Cnt_lInt := Cnt_lInt + 10000;

                if Item_lRec."Entry for each Sample" then begin
                    for Cnt2_lInt := 1 to QCRcptHeader_lRec."Sample Quantity" do begin
                        QCLineDetail_lRec.Init;
                        QCLineDetail_lRec."QC Rcpt No." := QCRcptHeader_lRec."No.";
                        QCLineDetail_lRec."QC Rcpt Line No." := QCRcptLine_lRec."Line No.";
                        ;
                        QCLineDetail2_lRec.Reset;
                        QCLineDetail2_lRec.SetRange("QC Rcpt No.", QCLineDetail_lRec."QC Rcpt No.");
                        QCLineDetail2_lRec.SetRange("QC Rcpt Line No.", QCLineDetail_lRec."QC Rcpt Line No.");
                        if QCLineDetail2_lRec.FindLast then
                            QCLineDetail_lRec."Line No." := QCLineDetail2_lRec."Line No." + 10000
                        else
                            QCLineDetail_lRec."Line No." := 10000;

                        QCLineDetail_lRec."Unit of Measure Code" := QCRcptHeader_lRec."Unit of Measure";
                        QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");
                        QCLineDetail_lRec.Type := QCRcptLine_lRec.Type;
                        QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");

                        QCLineDetail_lRec."Min.Value" := QCRcptLine_lRec."Min.Value";
                        QCLineDetail_lRec."Max.Value" := QCRcptLine_lRec."Max.Value";
                        QCLineDetail_lRec."Text Value" := QCRcptLine_lRec."Text Value";

                        QCLineDetail_lRec."Lot No." := QCRcptHeader_lRec."Vendor Lot No.";
                        QCLineDetail_lRec.Description := QCRcptLine_lRec.Description;
                        QCLineDetail_lRec.Insert;
                    end;
                end;
            until QCSpecificLine_lRec.Next = 0;
            ItemJnlLine_gRec.Validate("Quantity Under Inspection", ItemJnlLine_gRec."Quantity Under Inspection" + ItemJnlLine_gRec."Output Quantity");
            ItemJnlLine_gRec."QC No." := QCRcptHeader_lRec."No.";//T12212-ABA-N                                                               
            ItemJnlLine_gRec.Modify;

            QCUpdateONProdOrder_lFnc(QCRcptHeader_lRec);//T12212-ABA-N
            Message(Text0003_gCtx);
        end;

        //I-C0009-1001310-04 NE
    end;

    local procedure QCUpdateONProdOrder_lFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header")//T12212-ABA-N
    var
        ProductionOrder_lRec: Record "Production Order";
    begin
        //Update the QC No on Production Order.        
        ProductionOrder_lRec.get(ProductionOrder_lRec.Status::Released, QCRcptHeader_iRec."Document No.");
        ProductionOrder_lRec."QC Receipt No" := QCRcptHeader_iRec."No.";//QC No.
        ProductionOrder_lRec.Modify();
    end;

    procedure CheckQuantity_lFnc(ItemJnlLine_iRec: Record "Item Journal Line")
    begin
        //Function Written to Check that "Output Quantity" can not be less than Quantity in QC and its result.

        //NG-NS
        if (ItemJnlLine_iRec."Quantity Under Inspection" = 0) and (ItemJnlLine_iRec."Accepted Quantity" = 0) and
           (ItemJnlLine_iRec."Qty Accepted with Deviation" = 0) and (ItemJnlLine_iRec."Rework Quantity" = 0)
        then
            exit;
        //NG-NE

        //I-C0009-1001310-04 NS
        //IF ItemJnlLine_iRec."Output Quantity" < (ItemJnlLine_iRec."Quantity Under Inspection"  + ItemJnlLine_iRec."Accepted Quantity" +
        //                                         ItemJnlLine_iRec."Qty Accepted with Deviation" + ItemJnlLine_iRec."Rework Quantity")
        if ItemJnlLine_iRec."Output Quantity" < (ItemJnlLine_iRec."Quantity Under Inspection" + ItemJnlLine_iRec."Accepted Quantity" +
                                                 ItemJnlLine_iRec."Qty Accepted with Deviation")
        then
            Error(Text0001_gCtx);
        //I-C0009-1001310-04 NE
    end;

    procedure InsertOutputJnlLine_lFnc(ItemJnlLine_iRec: Record "Item Journal Line")
    var
        ItemJnlLine_lRec: Record "Item Journal Line";
        WorkCenter_lRec: Record "Work Center";
        ItemJnlLine2_lRec: Record "Item Journal Line";
        ProdOrderRtngLine_lRec: Record "Prod. Order Routing Line";
        ProdOrderRtngLine2_lRec: Record "Prod. Order Routing Line";
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        //At Time of Posting Output journal for Operation If QC is required for Next Operation then
        //It will Create Output line for Next Operation in QC Batch given on Work Center card Automatically.

        //130918-NS
        exit;  //Will not use in future
        //130918-NE

        //I-C0009-1001310-04 NS
        //QCSetup_lRec.GET;
        //IF NOT QCSetup_lRec."Auto initiation of Prod QC" THEN
        //  EXIT;

        ProdOrderRtngLine_lRec.SetRange(Status, ProdOrderRtngLine_lRec.Status::Released);
        ProdOrderRtngLine_lRec.SetRange("Prod. Order No.", ItemJnlLine_iRec."Order No.");
        ProdOrderRtngLine_lRec.SetRange("Routing No.", ItemJnlLine_iRec."Routing No.");
        ProdOrderRtngLine_lRec.SetRange("Routing Reference No.", ItemJnlLine_iRec."Routing Reference No.");
        if ItemJnlLine_iRec."Operation No." <> '' then
            ProdOrderRtngLine_lRec.SetRange("Operation No.", ItemJnlLine_iRec."Operation No.");
        if not ProdOrderRtngLine_lRec.FindFirst then
            exit;
        if (ProdOrderRtngLine_lRec."Next Operation No." = '') then
            exit;

        ProdOrderRtngLine2_lRec.Reset;
        ProdOrderRtngLine2_lRec.SetRange(Status, ProdOrderRtngLine_lRec.Status::Released);
        ProdOrderRtngLine2_lRec.SetRange("Prod. Order No.", ItemJnlLine_iRec."Order No.");
        ProdOrderRtngLine2_lRec.SetRange("Routing No.", ItemJnlLine_iRec."Routing No.");
        ProdOrderRtngLine2_lRec.SetRange("Routing Reference No.", ItemJnlLine_iRec."Routing Reference No.");
        ProdOrderRtngLine2_lRec.SetRange("Operation No.", ProdOrderRtngLine_lRec."Next Operation No.");
        if not ProdOrderRtngLine2_lRec.FindFirst then
            exit;

        if not ProdOrderRtngLine2_lRec."QC Required" then
            exit;

        WorkCenter_lRec.Get(ProdOrderRtngLine2_lRec."Work Center No.");
        WorkCenter_lRec.TestField("QC Output Journal Template");
        WorkCenter_lRec.TestField("QC Output Journal Batch");

        ItemJnlLine_lRec.Init;
        ItemJnlLine_lRec.Validate("Journal Template Name", WorkCenter_lRec."QC Output Journal Template");
        ItemJnlLine_lRec.Validate("Journal Batch Name", WorkCenter_lRec."QC Output Journal Batch");

        ItemJnlLine2_lRec.Reset;
        ItemJnlLine2_lRec.SetRange("Journal Template Name", WorkCenter_lRec."QC Output Journal Template");
        ItemJnlLine2_lRec.SetRange("Journal Batch Name", WorkCenter_lRec."QC Output Journal Batch");
        if ItemJnlLine2_lRec.FindLast then
            ItemJnlLine_lRec."Line No." := ItemJnlLine2_lRec."Line No." + 10000
        else
            ItemJnlLine_lRec."Line No." := 10000;

        ItemJnlLine_lRec."Posting Date" := ItemJnlLine_iRec."Posting Date";
        ItemJnlLine_lRec.Validate("Entry Type", ItemJnlLine_lRec."entry type"::Output);
        ItemJnlLine_lRec.Validate("Item No.", ItemJnlLine_iRec."Item No.");
        ItemJnlLine_lRec.Validate("Order Type", ItemJnlLine_lRec."order type"::Production);
        ItemJnlLine_lRec.Validate("Order No.", ItemJnlLine_iRec."Order No.");
        ItemJnlLine_lRec.Validate("Order Line No.", ItemJnlLine_iRec."Order Line No.");
        ItemJnlLine_lRec.Validate("Variant Code", ItemJnlLine_iRec."Variant Code");
        ItemJnlLine_lRec.Validate("Location Code", ItemJnlLine_iRec."Location Code");
        if ItemJnlLine_iRec."Bin Code" <> '' then
            ItemJnlLine_lRec.Validate("Bin Code", ItemJnlLine_iRec."Bin Code");
        ItemJnlLine_lRec.Validate("Routing No.", ItemJnlLine_iRec."Routing No.");
        ItemJnlLine_lRec.Validate("Routing Reference No.", ItemJnlLine_iRec."Routing Reference No.");
        ItemJnlLine_lRec.Validate("Operation No.", ProdOrderRtngLine_lRec."Next Operation No.");
        ItemJnlLine_lRec.Validate("Unit of Measure Code", ItemJnlLine_iRec."Unit of Measure Code");
        ItemJnlLine_lRec.Validate("Setup Time", 0);
        ItemJnlLine_lRec.Validate("Output Quantity", ItemJnlLine_iRec.Quantity);
        ItemJnlLine_lRec.Insert;
        //I-C0009-1001310-04 NE
    end;

    procedure ShowQCRcpt_gFnc(ItemJnlLine_iRec: Record "Item Journal Line")
    var
        QCRcptHead_lRec: Record "QC Rcpt. Header";
        QCRcptList_lPge: Page "QC Rcpt. List";
    begin
        //Function written to Show create "QC Receipt" agaist perticular "Output Journal Line".
        //I-C0009-1001310-04 NS
        Clear(QCRcptList_lPge);
        QCRcptHead_lRec.Reset;
        QCRcptHead_lRec.SetRange("Document Type", QCRcptHead_lRec."document type"::Production);
        QCRcptHead_lRec.SetRange("Item Journal Template Name", ItemJnlLine_iRec."Journal Template Name");
        QCRcptHead_lRec.SetRange("Item General Batch Name", ItemJnlLine_iRec."Journal Batch Name");
        QCRcptHead_lRec.SetRange("Item Journal Line No.", ItemJnlLine_iRec."Line No.");
        if QCRcptHead_lRec.FindFirst then;
        QCRcptList_lPge.SetTableview(QCRcptHead_lRec);
        QCRcptList_lPge.Run;
        //I-C0009-1001310-04 NE
    end;

    procedure CheckQCRcptExist_gFnc(ItemJnlLine_iRec: Record "Item Journal Line")
    begin
        //I-C0009-1001310-04 NS
        if (ItemJnlLine_iRec."Journal Template Name" = '') and (ItemJnlLine_iRec."Journal Batch Name" = '') then
            exit;

        if ItemJnlLine_iRec."Line No." = 0 then
            exit;

        QCRcptHeader_gRec.Reset;
        QCRcptHeader_gRec.SetRange("Item Journal Template Name", ItemJnlLine_iRec."Journal Template Name");
        QCRcptHeader_gRec.SetRange("Item General Batch Name", ItemJnlLine_iRec."Journal Batch Name");
        QCRcptHeader_gRec.SetRange("Item Journal Line No.", ItemJnlLine_iRec."Line No.");
        if QCRcptHeader_gRec.FindFirst then
            Error(Text0004_gCtx, ItemJnlLine_iRec."Journal Template Name", ItemJnlLine_iRec."Journal Batch Name", ItemJnlLine_iRec."Line No.");
        //I-C0009-1001310-04 NE
    end;

    local procedure CheckBinMandatory_lFnc(LocationCode_iCod: Code[10]): Boolean
    var
        Location_lRec: Record Location;
    begin
        Location_lRec.Get(LocationCode_iCod);
        exit(Location_lRec."Bin Mandatory");
    end;

    procedure DrillDownFinishAccpQty_gFnc(var ProdOrderRouting_iRec: Record "Prod. Order Routing Line")
    var
        CapLegEntry_lRec: Record "Capacity Ledger Entry";
        CapLedgerEntry_lPge: Page "Capacity Ledger Entries";
    begin
        //I-C0009-1001310-04-NS
        Clear(CapLedgerEntry_lPge);
        CapLedgerEntry_lPge.Editable(false);
        CapLedgerEntry_lPge.LookupMode(true);
        CapLegEntry_lRec.SetRange("Order Type", CapLegEntry_lRec."order type"::Production);
        CapLegEntry_lRec.SetRange("Order No.", ProdOrderRouting_iRec."Prod. Order No.");
        CapLegEntry_lRec.SetRange("Routing No.", ProdOrderRouting_iRec."Routing No.");
        CapLegEntry_lRec.SetRange("Routing Reference No.", ProdOrderRouting_iRec."Routing Reference No.");
        CapLegEntry_lRec.SetRange("Operation No.", ProdOrderRouting_iRec."Operation No.");
        CapLegEntry_lRec.SetFilter("Accepted Quantity", '<>%1', 0);
        CapLedgerEntry_lPge.SetTableview(CapLegEntry_lRec);
        if CapLedgerEntry_lPge.RunModal = Action::LookupOK then;
        //I-C0009-1001310-04-NE
    end;

    procedure DrillDownFinishAccpDevQty_gFnc(var ProdOrderRouting_iRec: Record "Prod. Order Routing Line")
    var
        CapLegEntry_lRec: Record "Capacity Ledger Entry";
        CapLedgerEntry_lPge: Page "Capacity Ledger Entries";
    begin
        //I-C0009-1001310-04-NS
        Clear(CapLedgerEntry_lPge);
        CapLedgerEntry_lPge.Editable(false);
        CapLedgerEntry_lPge.LookupMode(true);
        CapLegEntry_lRec.SetRange("Order Type", CapLegEntry_lRec."order type"::Production);
        CapLegEntry_lRec.SetRange("Order No.", ProdOrderRouting_iRec."Prod. Order No.");
        CapLegEntry_lRec.SetRange("Routing No.", ProdOrderRouting_iRec."Routing No.");
        CapLegEntry_lRec.SetRange("Routing Reference No.", ProdOrderRouting_iRec."Routing Reference No.");
        CapLegEntry_lRec.SetRange("Operation No.", ProdOrderRouting_iRec."Operation No.");
        CapLegEntry_lRec.SetFilter("Qty Accepted With Deviation", '<>%1', 0);
        CapLedgerEntry_lPge.SetTableview(CapLegEntry_lRec);
        if CapLedgerEntry_lPge.RunModal = Action::LookupOK then;
        //I-C0009-1001310-04-NE
    end;

    procedure DrillDownFinishAccpRejQty_gFnc(var ProdOrderRouting_iRec: Record "Prod. Order Routing Line")
    var
        CapLegEntry_lRec: Record "Capacity Ledger Entry";
        CapLedgerEntry_lPge: Page "Capacity Ledger Entries";
    begin
        //I-C0009-1001310-04-NS
        Clear(CapLedgerEntry_lPge);
        CapLedgerEntry_lPge.Editable(false);
        CapLedgerEntry_lPge.LookupMode(true);
        CapLegEntry_lRec.SetRange("Order Type", CapLegEntry_lRec."order type"::Production);
        CapLegEntry_lRec.SetRange("Order No.", ProdOrderRouting_iRec."Prod. Order No.");
        CapLegEntry_lRec.SetRange("Routing No.", ProdOrderRouting_iRec."Routing No.");
        CapLegEntry_lRec.SetRange("Routing Reference No.", ProdOrderRouting_iRec."Routing Reference No.");
        CapLegEntry_lRec.SetRange("Operation No.", ProdOrderRouting_iRec."Operation No.");
        CapLegEntry_lRec.SetFilter("Scrap Quantity", '<>%1', 0);
        CapLedgerEntry_lPge.SetTableview(CapLegEntry_lRec);
        if CapLedgerEntry_lPge.RunModal = Action::LookupOK then;
        //I-C0009-1001310-04-NE
    end;

    procedure DrillDownRejProOrder_gFnc(var ProductionOrder_iRec: Record "Production Order")
    var
        CapLegEntry_lRec: Record "Capacity Ledger Entry";
        CapLedgerEntry_lPge: Page "Capacity Ledger Entries";
    begin
        Clear(CapLedgerEntry_lPge);
        CapLedgerEntry_lPge.Editable(false);
        CapLedgerEntry_lPge.LookupMode(true);
        CapLegEntry_lRec.SetRange("Order Type", CapLegEntry_lRec."order type"::Production);
        CapLegEntry_lRec.SetRange("Order No.", ProductionOrder_iRec."No.");
        CapLegEntry_lRec.SetRange("Routing No.", ProductionOrder_iRec."Routing No.");
        CapLegEntry_lRec.SetFilter("Scrap Quantity", '<>%1', 0);
        CapLedgerEntry_lPge.SetTableview(CapLegEntry_lRec);
        if CapLedgerEntry_lPge.RunModal = Action::LookupOK then;
    end;

    procedure DrillDownRejProdOrderLine_gFnc(var ProdOrderLine_iRec: Record "Prod. Order Line")
    var
        CapLegEntry_lRec: Record "Capacity Ledger Entry";
        CapLedgerEntry_lPge: Page "Capacity Ledger Entries";
    begin
        Clear(CapLedgerEntry_lPge);
        CapLedgerEntry_lPge.Editable(false);
        CapLedgerEntry_lPge.LookupMode(true);
        CapLegEntry_lRec.SetRange("Order Type", CapLegEntry_lRec."order type"::Production);
        CapLegEntry_lRec.SetRange("Order No.", ProdOrderLine_iRec."Prod. Order No.");
        CapLegEntry_lRec.SetRange("Routing No.", ProdOrderLine_iRec."Routing No.");
        CapLegEntry_lRec.SetRange("Routing Reference No.", ProdOrderLine_iRec."Routing Reference No.");
        CapLegEntry_lRec.SetRange("Order Line No.", ProdOrderLine_iRec."Line No.");
        CapLegEntry_lRec.SetFilter("Scrap Quantity", '<>%1', 0);
        CapLedgerEntry_lPge.SetTableview(CapLegEntry_lRec);
        if CapLedgerEntry_lPge.RunModal = Action::LookupOK then;
    end;

    procedure CheckPrevOperationPosted_gFnc(var ItemJnlLine: Record "Item Journal Line")
    var
        ProdOrdRtngLine_lRec: Record "Prod. Order Routing Line";
        ProdOrder_lRec: Record "Production Order";
        PrevProdOrdRtngLine_lRec: Record "Prod. Order Routing Line";
        MfgSetup_lRec: Record "Manufacturing Setup";
        QualityControlSetup_lRec: Record "Quality Control Setup";
    begin
        //I-C0009-1001310-04-NS
        QualityControlSetup_lRec.Get;
        if QualityControlSetup_lRec."Post Previous Oper. Mandatory" then begin
            if not (QualityControlSetup_lRec."Book Out for RejQty Production") then begin
                if ProdOrdRtngLine_lRec.Get(ProdOrdRtngLine_lRec.Status::Released, ItemJnlLine."Order No.",
                  ItemJnlLine."Routing Reference No.", ItemJnlLine."Routing No.", ItemJnlLine."Operation No.") then begin
                    if ProdOrdRtngLine_lRec."Previous Operation No." <> '' then begin
                        if PrevProdOrdRtngLine_lRec.Get(ProdOrdRtngLine_lRec.Status, ItemJnlLine."Order No.",
                          ItemJnlLine."Routing Reference No.", ItemJnlLine."Routing No.", ProdOrdRtngLine_lRec."Previous Operation No.") then
                            PrevProdOrdRtngLine_lRec.CalcFields("Finished Quantity QC");
                        if (ItemJnlLine."Output Quantity" > PrevProdOrdRtngLine_lRec."Finished Quantity QC") then
                            Error(Text0005_gCtx, PrevProdOrdRtngLine_lRec."Finished Quantity QC", ItemJnlLine."Line No.");
                    end;
                end;
            end else begin
                if ProdOrdRtngLine_lRec.Get(ProdOrdRtngLine_lRec.Status::Released, ItemJnlLine."Order No.",
                  ItemJnlLine."Routing Reference No.", ItemJnlLine."Routing No.", ItemJnlLine."Operation No.") then begin
                    if ProdOrdRtngLine_lRec."Previous Operation No." <> '' then begin
                        if PrevProdOrdRtngLine_lRec.Get(ProdOrdRtngLine_lRec.Status, ItemJnlLine."Order No.",
                          ItemJnlLine."Routing Reference No.", ItemJnlLine."Routing No.", ProdOrdRtngLine_lRec."Previous Operation No.") then
                            PrevProdOrdRtngLine_lRec.CalcFields("Finished Accepted Quantity", "Finished Acc with Deviation");
                        if (ItemJnlLine."Output Quantity" > (PrevProdOrdRtngLine_lRec."Finished Accepted Quantity" +
                            PrevProdOrdRtngLine_lRec."Finished Acc with Deviation"))
                        then
                            Error(Text0005_gCtx, PrevProdOrdRtngLine_lRec."Finished Accepted Quantity" +
                                  PrevProdOrdRtngLine_lRec."Finished Acc with Deviation", ItemJnlLine."Line No.");
                    end;
                end;
            end;
        end;
        //I-C0009-1001310-04-NE
    end;

    procedure OpenPostQCCapaLedEntry_gFnc(var CapacityLedgerEntry_vRec: Record "Capacity Ledger Entry")
    var
        PostedQCRecpHeader_lRec: Record "Posted QC Rcpt. Header";
        PostedQCRecpt_lPge: Page "Posted QC Rcpt";
    begin
        //I-C0009-1001310-04-NS
        Clear(PostedQCRecpt_lPge);
        PostedQCRecpt_lPge.Editable(false);
        PostedQCRecpt_lPge.LookupMode(true);
        CapacityLedgerEntry_vRec.TestField("Posted QC No.");
        PostedQCRecpHeader_lRec.SetRange(PostedQCRecpHeader_lRec."No.", CapacityLedgerEntry_vRec."Posted QC No.");
        PostedQCRecpt_lPge.SetTableview(PostedQCRecpHeader_lRec);
        if PostedQCRecpt_lPge.RunModal = Action::LookupOK then;
        //I-C0009-1001310-04-NE
    end;

    procedure PostOutputCheck_gFnc(var ItemJournalLine_vRec: Record "Item Journal Line")
    var
        QCSetup_gRec: Record "Quality Control Setup";
        ProdOrderRtngLine_lRec: Record "Prod. Order Routing Line";
        SourceCodeSetup_lRec: Record "Source Code Setup";
    begin
        //I-C0009-1001310-04-NS
        QCSetup_gRec.Get;
        CheckPrevOperationPosted_gFnc(ItemJournalLine_vRec);
        SourceCodeSetup_lRec.Get;
        if (ItemJournalLine_vRec.Quantity = 0) and (ItemJournalLine_vRec."Source Code" = SourceCodeSetup_lRec."Capacity Journal") then  //Capacity Jnl Posting
            exit;
        if not ItemJournalLine_vRec.Subcontracting then begin
            ProdOrderRtngLine_lRec.Reset;
            ProdOrderRtngLine_lRec.SetRange(Status, ProdOrderRtngLine_lRec.Status::Released);
            ProdOrderRtngLine_lRec.SetRange("Prod. Order No.", ItemJournalLine_vRec."Order No.");
            ProdOrderRtngLine_lRec.SetRange("Routing No.", ItemJournalLine_vRec."Routing No.");
            ProdOrderRtngLine_lRec.SetRange("Routing Reference No.", ItemJournalLine_vRec."Routing Reference No.");
            ProdOrderRtngLine_lRec.SetFilter("Routing Status", '<> %1', ProdOrderRtngLine_lRec."routing status"::Finished);
            ProdOrderRtngLine_lRec.SetRange("Operation No.", ItemJournalLine_vRec."Operation No.");
            if ProdOrderRtngLine_lRec.FindFirst then begin
                if ProdOrderRtngLine_lRec."QC Required" then begin
                    if (ItemJournalLine_vRec."Accepted Quantity" = 0) and (ItemJournalLine_vRec."Qty Accepted with Deviation" = 0) and
                       (ItemJournalLine_vRec."Rework Quantity" = 0) and (ItemJournalLine_vRec."Scrap Quantity" = 0) and (ItemJournalLine_vRec."Reject Quantity" = 0) then
                        Error(Text0007_gCtx, ItemJournalLine_vRec."Journal Template Name", ItemJournalLine_vRec."Journal Batch Name", ItemJournalLine_vRec."Line No.");
                    ItemJournalLine_vRec.TestField("Quantity Under Inspection", 0);

                    if (ItemJournalLine_vRec."Serial No." = '') and (ItemJournalLine_vRec."Lot No." = '') then begin
                        if ItemJournalLine_vRec."Reject Quantity" <> 0 then begin
                            if QCSetup_gRec."Book Out for RejQty Production" then
                                if ItemJournalLine_vRec."Output Quantity" <> ItemJournalLine_vRec."Reject Quantity" then
                                    Error(Text0008_gCtx, ItemJournalLine_vRec."Journal Template Name", ItemJournalLine_vRec."Journal Batch Name", ItemJournalLine_vRec."Line No.");
                        end;
                        /*//T12971-OS
                          if ItemJournalLine_vRec."Rework Quantity" <> 0 then begin
                             if QCSetup_gRec."Book Out for RewQty Production" then
                                 if ItemJournalLine_vRec."Output Quantity" <> ItemJournalLine_vRec."Rework Quantity" then
                                     Error(Text0009_gCtx, ItemJournalLine_vRec."Journal Template Name", ItemJournalLine_vRec."Journal Batch Name", ItemJournalLine_vRec."Line No.");
                         end; 
                         //T12971-OE*/
                        //T12971-NS
                        if ProdOrderRtngLine_lRec."Next Operation No." = '' then begin
                            if ItemJournalLine_vRec."Rework Quantity" <> 0 then begin
                                if QCSetup_gRec."Book Out for RewQty Production" then
                                    if ItemJournalLine_vRec."Output Quantity" <> ItemJournalLine_vRec."Rework Quantity" then
                                        Error(Text0009_gCtx, ItemJournalLine_vRec."Journal Template Name", ItemJournalLine_vRec."Journal Batch Name", ItemJournalLine_vRec."Line No.");
                            end;
                        end;
                        //T12971-NE
                        if ItemJournalLine_vRec."Accepted Quantity" + ItemJournalLine_vRec."Qty Accepted with Deviation" > 0 then begin
                            if ItemJournalLine_vRec."Output Quantity" <> (ItemJournalLine_vRec."Accepted Quantity" + ItemJournalLine_vRec."Qty Accepted with Deviation") then
                                Error(Text0006_gCtx, ItemJournalLine_vRec."Journal Template Name", ItemJournalLine_vRec."Journal Batch Name", ItemJournalLine_vRec."Line No.");
                        end;
                    end;

                end;
            end;
            InsertOutputJnlLine_lFnc(ItemJournalLine_vRec);
        end;
        //I-C0009-1001310-04-NE
    end;

    procedure ItemTrackingOption_gFnc(LotNo: Code[50]; SerialNo: Code[20]) OptionValue: Integer
    begin
        //CP-NS
        if LotNo <> '' then
            OptionValue := 1;

        if SerialNo <> '' then begin
            if LotNo <> '' then
                OptionValue := 2
            else
                OptionValue := 3;
        end;
        //CP-NE
    end;

    procedure ItemTrackingLine_gFnc(var QCRcptHeader_vRec: Record "QC Rcpt. Header")
    var
        ItemTrackingProdQC_lPge: Page "Item Tracking For Prod. QC";
        ReservationEntry_lRec: Record "Reservation Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
    begin
        //QCV3-NS
        QCRcptHeader_vRec.TestField("Document Type", QCRcptHeader_vRec."document type"::Production);
        QCRcptHeader_vRec.TestField("Item Journal Template Name");
        QCRcptHeader_vRec.TestField("Item General Batch Name");
        QCRcptHeader_vRec.TestField("Item Journal Line No.");

        ReservationEntry_lRec.Reset;
        ReservationEntry_lRec.SetRange("Source Batch Name", QCRcptHeader_vRec."Item General Batch Name");
        ReservationEntry_lRec.SetRange("Source ID", QCRcptHeader_vRec."Item Journal Template Name");
        ReservationEntry_lRec.SetRange("Source Type", 83);
        ReservationEntry_lRec.SetRange("Source Ref. No.", QCRcptHeader_vRec."Item Journal Line No.");
        if QCRcptHeader_vRec.Approve then
            ItemTrackingProdQC_lPge.Editable(false);

        ItemTrackingProdQC_lPge.SetTableview(ReservationEntry_lRec);
        ItemTrackingProdQC_lPge.RunModal;

        if ReservationEntry_lRec.FindSet then begin
            repeat
                TotalAccQty_lDec += ReservationEntry_lRec."Accepted Quantity";
                TotalAccWithDevi_lDec += ReservationEntry_lRec."Accepted with Deviation Qty";
                TotalRejQty_lDec += ReservationEntry_lRec."Rejected Quantity";
                TotalRewQty_lDec += ReservationEntry_lRec."Rework Quantity";

            until ReservationEntry_lRec.Next = 0;

            if (not QCRcptHeader_vRec.Approve) and (QCRcptHeader_vRec."Approval Status" = QCRcptHeader_vRec."approval status"::Open) then begin
                QCRcptHeader_vRec."Quantity to Accept" := TotalAccQty_lDec;
                QCRcptHeader_vRec."Quantity to Reject" := TotalRejQty_lDec;
                QCRcptHeader_vRec."Quantity to Rework" := TotalRewQty_lDec;
                QCRcptHeader_vRec."Qty to Accept with Deviation" := TotalAccWithDevi_lDec;
                //T12113-NS
                QCRcptHeader_vRec."Rejection Reason" := ReservationEntry_lRec."Rejection Reason";
                QCRcptHeader_vRec."Rejection Reason Description" := ReservationEntry_lRec."Rejection Reason Description";
                QCRcptHeader_vRec."Rework Reason" := ReservationEntry_lRec."Rework Reason";
                QCRcptHeader_vRec."Rework Reason Description" := ReservationEntry_lRec."Rework Reason Description";
                //T12113-NE
                //QCRcptHeader_vRec.Modify;
            end;
        end;
        //QCV3-NE
    end;

    procedure CheckEnterResult_gFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header")
    var
        ReservationEntry_lRec: Record "Reservation Entry";
        AcceptResult_lDec: Decimal;
        AccWithDeviation_lDec: Decimal;
        RejectResult_lDec: Decimal;
        ReworkResult_lDec: Decimal;
        Text5000_lCtx: label '"Quantity to Accept" must be equal to sum of Quantity Accepted in Item Tracking Lines.';
        Text5001_lCtx: label '"Quantity to Reject" must be equal to sum of Quantity Rejected in Item Tracking Lines.';
        Text5002_lCtx: label '"Quantity to Rework" must be equal to sum of Quantity Reworked in Item Tracking Lines.';
        Text5003_lCtx: label '"Quantity to Accept with Deviation" must be equal to sum of Quantity with Accepted in Item Tracking Lines.';
        Item_lRec: Record Item;
    begin
        //QCV3-NS
        Item_lRec.Get(QCRcptHeader_iRec."Item No.");
        if Item_lRec."Item Tracking Code" = '' then
            exit;

        ReservationEntry_lRec.Reset;
        ReservationEntry_lRec.SetRange("Source Batch Name", QCRcptHeader_iRec."Item General Batch Name");
        ReservationEntry_lRec.SetRange("Source ID", QCRcptHeader_iRec."Item Journal Template Name");
        ReservationEntry_lRec.SetRange("Source Type", 83);
        ReservationEntry_lRec.SetRange("Source Ref. No.", QCRcptHeader_iRec."Item Journal Line No.");
        if ReservationEntry_lRec.FindSet then begin
            repeat
                AcceptResult_lDec += ReservationEntry_lRec."Accepted Quantity";
                AccWithDeviation_lDec += ReservationEntry_lRec."Accepted with Deviation Qty";
                RejectResult_lDec += ReservationEntry_lRec."Rejected Quantity";
                ReworkResult_lDec += ReservationEntry_lRec."Rework Quantity";
            until ReservationEntry_lRec.Next = 0;

            if AcceptResult_lDec <> QCRcptHeader_iRec."Quantity to Accept" then
                Error(Text5000_lCtx);
            if AccWithDeviation_lDec <> QCRcptHeader_iRec."Qty to Accept with Deviation" then
                Error(Text5003_lCtx);
            if RejectResult_lDec <> QCRcptHeader_iRec."Quantity to Reject" then
                Error(Text5001_lCtx);
            if ReworkResult_lDec <> QCRcptHeader_iRec."Quantity to Rework" then
                Error(Text5002_lCtx);
        end;
        //QCV3-NE
    end;

    procedure InsertReservationEntryIntoQCReservation_gFnc(QCRcptHeader_iRec: Record "QC Rcpt. Header"; PostedQCRecptNo_iCod: Code[20])
    var
        QCReservationEntry_lRec: Record "QC Reservation Entry";
        ReservationEntry_lRec: Record "Reservation Entry";
    begin
        //QCV3-NE
        ReservationEntry_lRec.Reset;
        ReservationEntry_lRec.SetRange("Source Batch Name", QCRcptHeader_iRec."Item General Batch Name");
        ReservationEntry_lRec.SetRange("Source ID", QCRcptHeader_iRec."Item Journal Template Name");
        ReservationEntry_lRec.SetRange("Source Type", 83);
        ReservationEntry_lRec.SetRange("Source Ref. No.", QCRcptHeader_iRec."Item Journal Line No.");
        if ReservationEntry_lRec.FindSet then begin
            repeat
                QCReservationEntry_lRec.Init;
                QCReservationEntry_lRec.TransferFields(ReservationEntry_lRec);
                QCReservationEntry_lRec."QC No." := QCRcptHeader_iRec."No.";
                QCReservationEntry_lRec."Posted QC No." := PostedQCRecptNo_iCod;
                QCReservationEntry_lRec.Insert;
            until ReservationEntry_lRec.Next = 0;
        end;
        //QCV3-NE
    end;

    procedure ChangeIJLforSerialLotNo_gFnc(var ItemJournalLine_vRec: Record "Item Journal Line")
    var
        QCReservationEntry_lRec: Record "QC Reservation Entry";
    begin
        //QCV3-NS
        if (ItemJournalLine_vRec."Serial No." = '') and (ItemJournalLine_vRec."Lot No." = '') then
            exit;

        QCReservationEntry_lRec.Reset;
        QCReservationEntry_lRec.SetRange("Source Batch Name", ItemJournalLine_vRec."Journal Batch Name");
        QCReservationEntry_lRec.SetRange("Source ID", ItemJournalLine_vRec."Journal Template Name");
        QCReservationEntry_lRec.SetRange("Source Type", 83);
        QCReservationEntry_lRec.SetRange("Source Ref. No.", ItemJournalLine_vRec."Line No.");
        QCReservationEntry_lRec.SetRange("Posted QC No.", ItemJournalLine_vRec."Posted QC No.");
        if ItemJournalLine_vRec."Serial No." <> '' then
            QCReservationEntry_lRec.SetRange("Serial No.", ItemJournalLine_vRec."Serial No.");
        if ItemJournalLine_vRec."Lot No." <> '' then
            QCReservationEntry_lRec.SetRange("Lot No.", ItemJournalLine_vRec."Lot No.");
        if QCReservationEntry_lRec.FindFirst then begin
            ItemJournalLine_vRec."Accepted Quantity" := 0;
            ItemJournalLine_vRec."Qty Accepted with Deviation" := 0;
            ItemJournalLine_vRec."Rework Quantity" := 0;
            ItemJournalLine_vRec.Validate("Scrap Quantity", 0);

            if QCReservationEntry_lRec.Result = QCReservationEntry_lRec.Result::Accept then
                ItemJournalLine_vRec."Accepted Quantity" := Abs(QCReservationEntry_lRec.Quantity);
            if QCReservationEntry_lRec.Result = QCReservationEntry_lRec.Result::"Accepted with Deviation" then
                ItemJournalLine_vRec."Qty Accepted with Deviation" := Abs(QCReservationEntry_lRec.Quantity);
            if QCReservationEntry_lRec.Result = QCReservationEntry_lRec.Result::Reject then
                ItemJournalLine_vRec.Validate("Scrap Quantity", Abs(QCReservationEntry_lRec.Quantity));
            if QCReservationEntry_lRec.Result = QCReservationEntry_lRec.Result::Rework then
                ItemJournalLine_vRec."Rework Quantity" := Abs(QCReservationEntry_lRec.Quantity);
        end;
        //QCV3-NE
    end;

    local procedure "----Other------"()
    begin
    end;

    procedure CheckOPforRntLine_gFnc(IJL_iRec: Record "Item Journal Line")
    var
        AlreadyBookedOutputQty_lDec: Decimal;
        QtyCanBeEntered_lDec: Decimal;
        CapaLdgrEntry_lRec: Record "Capacity Ledger Entry";
        ProdOrderRtngLine_lRec: Record "Prod. Order Routing Line";
        PrevProdOrdRtngLine_lRec: Record "Prod. Order Routing Line";
        ChkProdOrderLine_lRec: Record "Prod. Order Line";
        QualityControlSetup_lRec: Record "Quality Control Setup";
    begin
        if IJL_iRec."Entry Type" <> IJL_iRec."entry type"::Output then
            exit;

        if IJL_iRec."Journal Batch Name" = '' then
            exit;

        if IJL_iRec."Output Quantity" = 0 then
            exit;

        QualityControlSetup_lRec.Get;
        if not QualityControlSetup_lRec."Post Previous Oper. Mandatory" then
            exit;

        AlreadyBookedOutputQty_lDec := 0;
        QtyCanBeEntered_lDec := 0;

        CapaLdgrEntry_lRec.Reset;
        CapaLdgrEntry_lRec.SetRange("Order Type", CapaLdgrEntry_lRec."order type"::Production);
        CapaLdgrEntry_lRec.SetRange("Order No.", IJL_iRec."Order No.");
        CapaLdgrEntry_lRec.SetRange("Order Line No.", IJL_iRec."Order Line No.");
        CapaLdgrEntry_lRec.SetRange("Routing No.", IJL_iRec."Routing No.");
        CapaLdgrEntry_lRec.SetRange("Routing Reference No.", IJL_iRec."Routing Reference No.");
        CapaLdgrEntry_lRec.SetRange("Operation No.", IJL_iRec."Operation No.");
        if CapaLdgrEntry_lRec.FindSet then begin
            repeat
                AlreadyBookedOutputQty_lDec += CapaLdgrEntry_lRec."Output Quantity";
            until CapaLdgrEntry_lRec.Next = 0;
        end;

        if ProdOrderRtngLine_lRec.Get(ProdOrderRtngLine_lRec.Status::Released, IJL_iRec."Order No.",
                                    IJL_iRec."Routing Reference No.", IJL_iRec."Routing No.",
                                    IJL_iRec."Operation No.")
        then begin
            if ProdOrderRtngLine_lRec."Previous Operation No." <> '' then begin
                if PrevProdOrdRtngLine_lRec.Get(ProdOrderRtngLine_lRec.Status, IJL_iRec."Order No.",
                   IJL_iRec."Routing Reference No.", IJL_iRec."Routing No.",
                   ProdOrderRtngLine_lRec."Previous Operation No.")
                then
                    PrevProdOrdRtngLine_lRec.CalcFields("Finished Quantity QC");

                QtyCanBeEntered_lDec := PrevProdOrdRtngLine_lRec."Finished Quantity QC" - AlreadyBookedOutputQty_lDec;

                if IJL_iRec."Output Quantity" > QtyCanBeEntered_lDec then
                    Error('Output Quantity must not be greater than %1 on Line No.: %2 and Operation No. %3', QtyCanBeEntered_lDec, IJL_iRec."Line No.", IJL_iRec."Operation No.");
            end else begin
                ChkProdOrderLine_lRec.Get(ProdOrderRtngLine_lRec.Status, ProdOrderRtngLine_lRec."Prod. Order No.", ProdOrderRtngLine_lRec."Routing Reference No.");  //NG-N 180919
                ProdOrderRtngLine_lRec.CalcFields("Finished Quantity QC");
                QtyCanBeEntered_lDec := ChkProdOrderLine_lRec.Quantity - (AlreadyBookedOutputQty_lDec);  //NG-U 180919
                if IJL_iRec."Output Quantity" > QtyCanBeEntered_lDec then
                    Error('Output Quantity must not be greater than %1 on Line No.: %2 and Operation No. %3', QtyCanBeEntered_lDec, IJL_iRec."Line No.", IJL_iRec."Operation No.");
            end;
        end;
    end;

    //T12113-NS
    procedure CheckItemTrackingLines_ForRejection_gfnc(var QCRcptHeader_vRec: Record "QC Rcpt. Header")
    var
        ItemTrackingProdQC_lPge: Page "Item Tracking For Prod. QC";
        ReservationEntry_lRec: Record "Reservation Entry";
    begin
        ReservationEntry_lRec.Reset;
        ReservationEntry_lRec.SetRange("Source Batch Name", QCRcptHeader_vRec."Item General Batch Name");
        ReservationEntry_lRec.SetRange("Source ID", QCRcptHeader_vRec."Item Journal Template Name");
        ReservationEntry_lRec.SetRange("Source Type", 83);
        ReservationEntry_lRec.SetRange("Source Ref. No.", QCRcptHeader_vRec."Item Journal Line No.");
        if ReservationEntry_lRec.FindSet() then
            repeat
                if (QCRcptHeader_vRec."Quantity to Reject" > 0) and (QCRcptHeader_vRec."Item Tracking" <> QCRcptHeader_vRec."Item Tracking"::None) then
                    if QCRcptHeader_vRec."Rejection Reason" = '' then
                        Error('Rejection Reason cannot be blank for QC Receipt No. %1', QCRcptHeader_vRec."Item Journal Line No.");
            until ReservationEntry_lRec.Next() = 0;
    end;
    //T12113-NE
    //T12113-NS
    procedure CheckItemTrackingLines_ForOutput(ItemJnlLine_iRec: Record "Item Journal Line")
    var

        ReservationEntry_lRec: Record "Reservation Entry";
        item_lRec: Record Item;
    begin
        item_lRec.Get(ItemJnlLine_iRec."Item No.");
        if not (item_lRec."Item Tracking Code" <> '') then
            exit;
        ReservationEntry_lRec.Reset;
        ReservationEntry_lRec.SetRange("Source Batch Name", ItemJnlLine_iRec."Journal Batch Name");
        ReservationEntry_lRec.SetRange("Source ID", ItemJnlLine_iRec."Journal Template Name");
        ReservationEntry_lRec.SetRange("Source Type", 83);
        ReservationEntry_lRec.SetRange("Source Ref. No.", ItemJnlLine_iRec."Line No.");
        ReservationEntry_lRec.SetRange("Item No.", ItemJnlLine_iRec."Item No.");
        if not ReservationEntry_lRec.FindSet() then
            Error('Item Tracking Line is not found.');

    end;

    // Procedure ReservationErrorAction(ItemJnlLine_iRec: Record "Item Journal Line")
    // var
    //     IN_ErrorInfor: ErrorInfo;
    //     ReservationNotification: Notification;
    //     ReservationNotificationLbl: Label 'Item Tarcking Line is not found.';
    //     CheckReservationNotification: Label 'Check Item Tracking Line?';
    //     //
    //     ReservationEntry_lRec: Record "Reservation Entry";
    //     item_lRec: Record Item;
    // //

    // begin
    //     // //Syntax-begin 
    //     // IN_ErrorInfor.DataClassification(DataClassification::SystemMetadata);
    //     // IN_ErrorInfor.ErrorType(ErrorType::Client);
    //     // IN_ErrorInfor.Verbosity(Verbosity::Error);
    //     // IN_ErrorInfor.Title('This is New Error Title');
    //     // IN_ErrorInfor.Message('This is Error Message');
    //     // IN_ErrorInfor.AddAction('Second', Codeunit::"Error Action Test", 'Test02');
    //     // IN_ErrorInfor.PageNo := Page::"Item List";
    //     // IN_ErrorInfor.AddNavigationAction('Open Item List');
    //     // Error(IN_ErrorInfor);
    //     // //Syntax-end

    //     // if Today <> rec."Allow Posting To" then begin
    //     item_lRec.Get(ItemJnlLine_iRec."Item No.");
    //     if not (item_lRec."Item Tracking Code" <> '') then
    //         exit;
    //     ReservationEntry_lRec.Reset;
    //     ReservationEntry_lRec.SetRange("Source Batch Name", ItemJnlLine_iRec."Journal Batch Name");
    //     ReservationEntry_lRec.SetRange("Source ID", ItemJnlLine_iRec."Journal Template Name");
    //     ReservationEntry_lRec.SetRange("Source Type", 83);
    //     ReservationEntry_lRec.SetRange("Source Ref. No.", ItemJnlLine_iRec."Line No.");
    //     ReservationEntry_lRec.SetRange("Item No.", ItemJnlLine_iRec."Item No.");
    //     if not ReservationEntry_lRec.FindSet() then begin
    //         ReservationNotification.Message(ReservationNotificationLbl);
    //         ReservationNotification.Scope := NotificationScope::LocalScope;
    //         ReservationNotification.AddAction(CheckReservationNotification, Codeunit::"Error Action Test", 'OpenItemTrackingLine', 'This is Notification tooltip');
    //         ReservationNotification.Send();
    //     end;
    // end;
    //T12113-NE


}

