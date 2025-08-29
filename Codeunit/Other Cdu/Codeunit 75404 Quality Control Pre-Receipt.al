Codeunit 75404 "Quality Control Pre-Receipt"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    //                        17/07/24    Anoop Babu Azad
    //                        QC Module - Released(Purchase Order QC).   
    // ------------------------------------------------------------------------------------------------------------------------------

    Permissions = TableData "Item Ledger Entry" = rm;

    trigger OnRun()
    begin
    end;

    var
        PurchLine_gRec: Record "Purchase Line";
        ItemLdgrEntry_gRec: Record "Item Ledger Entry";
        Text0000_gCtx: label 'Do you want to create QC Receipt for \ Purchase Order = ''%1'', Line No. = ''%2'' ?';
        Text0001_gCtx: label 'QC Receipt = ''%1'' is created for \ Purchase Order = ''%2'', Line No. = ''%3'' sucessfully.';
        Text0002_gCtx: label 'Sum of "Under Inspection Quantity","Accepted Quantity","Accepted Quantity with Deviation" and "Rejected Quantity" cannot be greater than Quantity.';
        Text0003_gCtx: label 'QC is not required for Item No.= ''%1'' in \ Purchase Order No = ''%2''.';
        Location_gRec: Record Location;
        CreatedQCNo_gTxt: Text;
        Text0004_gCtx: label 'Items are Received and \Related QC Receipts are created successfully.';
        Text0005_gCtx: label 'Please be informed that due to Quality Control requirements for Item No: %1, the system will halt Reservation entries associated with  Document Type and Document No. %2. \This is an acknowledgment message for your attention.';//T12113-N
        Text0006_gCtx: label 'If Rejection Quantity has a value, Accepted and Accepted with Deviation fields cannot be filled. Conversely, if Accepted or Accepted with Deviation fields are filled, Rejection Quantity must be blank. This condition applies to Purchase Order Document Type on QC Receipt.';
        QCControlSetup_gRec: Record "Quality Control Setup";
        TotalResQty_gDec: Decimal;

    procedure CreateQCRcpt_gFnc(PurchLine_iRec: Record "Purchase Line"; ShowConfirmMsg_iBln: Boolean; RejectionFlag_iBln: Boolean): Text
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        ItemEntryRel_lRec: Record "Item Entry Relation";
        Item_lRec: Record Item;
        LotNo_lCod: Code[50];
        SampleQty_lDec: Decimal;
        QCSetup_lRec: Record "Quality Control Setup";
        PurchHeader_lRec: Record "Purchase Header";
        Location_lRec: Record Location;
        ReservationEntry_lRec: Record "Reservation Entry";
        SourceLineNo_lInt: Integer;
        ResEntry_lRec: Record "Reservation Entry";
    begin
        //Written Function to create "QC Receipt" for Purchase Order Item.
        QCSetup_lRec.get;
        QCSetup_lRec.TestField("Allow QC in Purchase Order");

        PurchHeader_lRec.Get(PurchHeader_lRec."Document Type"::Order, PurchLine_iRec."Document No.");

        PurchLine_gRec.Copy(PurchLine_iRec);
        PurchLine_gRec.TestField(Type, PurchLine_gRec.Type::Item);
        PurchLine_gRec.TestField("Location Code");
        if not PurchLine_gRec."Pre-Receipt Inspection" then
            Error(Text0003_gCtx, PurchLine_gRec."No.", PurchLine_gRec."Document No.");

        AvailableInventory_lFnc(PurchLine_gRec, RejectionFlag_iBln);

        Clear(Item_lRec);
        Item_lRec.Get(PurchLine_gRec."No.");

        if ShowConfirmMsg_iBln then
            if not Confirm(StrSubstNo(Text0000_gCtx, PurchLine_gRec."Document No.", PurchLine_gRec."Line No.")) then
                exit;
        if CheckItemTrackingOnPurchaseOrderQC_lFnc(PurchLine_gRec) then begin//Item Tracking code on Item- True
            Clear(TotalResQty_gDec);

            TotalResQty_gDec := FindTotalQtyofReservationEntry_lFnc(PurchLine_gRec, RejectionFlag_iBln);//Item Tracking/Quantity found

            ReservationEntry_lRec.Reset();
            ReservationEntry_lRec.SetRange("Item No.", PurchLine_gRec."No.");
            ReservationEntry_lRec.SetRange("Location Code", PurchLine_gRec."Location Code");
            ReservationEntry_lRec.SetRange("Source Type", 39);
            ReservationEntry_lRec.SetRange("Source Subtype", PurchLine_gRec."Document Type");
            ReservationEntry_lRec.SetRange("Source ID", PurchLine_gRec."Document No.");
            ReservationEntry_lRec.SetRange("Source Ref. No.", PurchLine_gRec."Line No.");
            if (PurchLine_gRec."QC Created") and RejectionFlag_iBln then //in Rejection
                ReservationEntry_lRec.SetRange("QC Created", false);
            ReservationEntry_lRec.SetFilter("Item Tracking", '<>%1', ReservationEntry_lRec."Item Tracking"::None);
            if ReservationEntry_lRec.FindSet() then begin
                if (ReservationEntry_lRec."Item Tracking" in [ReservationEntry_lRec."Item Tracking"::"Serial No."]) and (TotalResQty_gDec > 0) then begin
                    CreateQCRcpt_lFnc(ABS(TotalResQty_gDec), ReservationEntry_lRec."Lot No.",
                                                     ReservationEntry_lRec, ReservationEntry_lRec."Expiration Date");
                end;
                repeat
                    if ReservationEntry_lRec."Item Tracking" in [ReservationEntry_lRec."Item Tracking"::"Lot No."] then begin
                        clear(LotNo_lCod);
                        LotNo_lCod := ReservationEntry_lRec."Lot No.";

                        CreateQCRcpt_lFnc(ABS(ReservationEntry_lRec.Quantity), ReservationEntry_lRec."Lot No.",
                                                 ReservationEntry_lRec, ReservationEntry_lRec."Expiration Date");
                        ReservationEntry_lRec."QC Created" := true;
                        ReservationEntry_lRec.Modify;
                    end else if ReservationEntry_lRec."Item Tracking" in [ReservationEntry_lRec."Item Tracking"::"Serial No."] then begin
                        ReservationEntry_lRec."QC Created" := true;
                        ReservationEntry_lRec.Modify;
                    end;
                until ReservationEntry_lRec.next = 0;

            end;
        end else begin//Item Tracking False
            if not RejectionFlag_iBln then begin
                if (PurchLine_gRec."Outstanding Quantity" > 0) then
                    CreateQCRcpt_lFnc(PurchLine_gRec."Outstanding Quantity", '', ReservationEntry_lRec, 0D);
            end else
                if (PurchLine_gRec."QC Rejected Qty" > 0) then//In Rejection
                    CreateQCRcpt_lFnc(PurchLine_gRec."QC Rejected Qty", '', ReservationEntry_lRec, 0D);
        end;
        UpdatePurchaseLine_lFnc(PurchLine_gRec, RejectionFlag_iBln);//Update Purchase Line
        if ShowConfirmMsg_iBln then
            Message(Text0001_gCtx, CreatedQCNo_gTxt, PurchLine_gRec."Document No.", PurchLine_gRec."Line No.");
        if CreatedQCNo_gTxt <> '' then
            exit(CreatedQCNo_gTxt);
    end;

    local procedure FindTotalQtyofReservationEntry_lFnc(PurchLine_iRec: Record "Purchase Line"; RejectionFlag_iBln: Boolean): Decimal
    var
        TotalResQty_lDec: Decimal;
        ResEntry_lRec: Record "Reservation Entry";
    begin
        Clear(TotalResQty_lDec);
        ResEntry_lRec.Reset();
        ResEntry_lRec.SetRange("Item No.", PurchLine_iRec."No.");
        ResEntry_lRec.SetRange("Location Code", PurchLine_iRec."Location Code");
        ResEntry_lRec.SetRange("Source Type", PurchLine_iRec.RecordId.TableNo);//Neeed to check
        ResEntry_lRec.SetRange("Source Subtype", PurchLine_iRec."Document Type");
        ResEntry_lRec.SetRange("Source ID", PurchLine_iRec."Document No.");
        ResEntry_lRec.SetRange("Source Ref. No.", PurchLine_iRec."Line No.");

        if (PurchLine_iRec."QC Created") and RejectionFlag_iBln then //in Rejection
            ResEntry_lRec.SetRange("QC Created", false);

        ResEntry_lRec.SetFilter("Item Tracking", '<>%1', ResEntry_lRec."Item Tracking"::None);
        if ResEntry_lRec.FindSet() then begin
            repeat
                if ResEntry_lRec."Item Tracking" in [ResEntry_lRec."Item Tracking"::"Serial No."] then
                    TotalResQty_lDec += Abs(ResEntry_lRec.Quantity)
                else if ResEntry_lRec."Item Tracking" in [ResEntry_lRec."Item Tracking"::"Lot No."] then
                    TotalResQty_lDec += Abs(ResEntry_lRec.Quantity);
            until ResEntry_lRec.next = 0;
            //31072024-NS
            if not RejectionFlag_iBln then begin
                if TotalResQty_lDec <> (PurchLine_iRec."Outstanding Quantity") then
                    Error('Quantity in Purchase Line for Item %1 is not reserved completely.', PurchLine_iRec."No.");
            end else
                if TotalResQty_lDec <> (PurchLine_iRec."QC Rejected Qty") then
                    Error('Quantity in Purchase Line for Item %1 is not reserved completely.', PurchLine_iRec."No.");
            //31072024-NE
            exit(TotalResQty_lDec);
        end else
            Error('Item Tracking Line is not found of the  - %1', PurchLine_iRec."Line No.");
    end;

    local procedure CreateQCRcpt_lFnc(Quantity_iDec: Decimal; LotNo_iCod: Code[50]; ResEntry_iRec: Record "Reservation Entry"; ExpDate_iDat: Date)
    var
        QCRcptHead_lRec: Record "QC Rcpt. Header";
        QCRcptHead2_lRec: Record "QC Rcpt. Header";
        Item_lRec: Record Item;
        Vendor_lRec: Record Vendor;
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCSpecificationLine_lRec: Record "QC Specification Line";
        PurchHeader_lRec: Record "Purchase Header";
        QCSpecificationHeader_lRec: Record "QC Specification Header";
        PurchLine_lRec: Record "Purchase Line";
        Bin_lRec: Record Bin;
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineDetail2_lRec: Record "QC Line Detail";
        ProdOrderRoutingLine_lRec: Record "Prod. Order Routing Line";
        QtyUnderQC_lDec: Decimal;
        Cnt_lInt: Decimal;
        Location_lRec: Record Location;
        MainLocation_lRec: Record Location;
        NoseriesManagement_lCdu: Codeunit "No. Series";//Old NoSeriesManagement
        ItemtrackingCode_lRec: Record "Item Tracking Code";
        QCSetup_lRec: Record "Quality Control Setup";

    begin
        PurchLine_gRec.TestField("Pre-Receipt Inspection", true);

        Item_lRec.Reset;
        QCSpecificationHeader_lRec.Reset;
        Item_lRec.Get(PurchLine_gRec."No.");
        Item_lRec.TestField("Item Specification Code");
        QCSpecificationHeader_lRec.Get(Item_lRec."Item Specification Code");
        QCSpecificationHeader_lRec.TestField(Status, QCSpecificationHeader_lRec.Status::Certified);
        QCControlSetup_gRec.get;
        QCControlSetup_gRec.TestField("Pre-Receipt QC Nos");
        QCControlSetup_gRec.TestField("Posted Pre-Receipt QC Nos");
        QCRcptHead_lRec.Init;
        QCRcptHead_lRec."No." := NoseriesManagement_lCdu.GetNextNo(QCControlSetup_gRec."Pre-Receipt QC Nos", WorkDate(), true);
        QCRcptHead_lRec."Document Type" := QCRcptHead_lRec."Document Type"::"Purchase Pre-Receipt";
        QCRcptHead_lRec."Document No." := PurchLine_gRec."Document No.";
        QCRcptHead_lRec."Document Line No." := PurchLine_gRec."Line No.";
        Clear(Vendor_lRec);
        if Vendor_lRec.Get(PurchLine_gRec."Buy-from Vendor No.") then begin
            QCRcptHead_lRec."Buy-from Vendor No." := PurchLine_gRec."Buy-from Vendor No.";
            QCRcptHead_lRec."Buy-from Vendor Name" := Vendor_lRec.Name;
        end;

        QCRcptHead_lRec."Item No." := PurchLine_gRec."No.";
        QCRcptHead_lRec."Variant Code" := PurchLine_gRec."Variant Code";
        QCRcptHead_lRec."Item Name" := Item_lRec.Description;
        QCRcptHead_lRec."Unit of Measure" := Item_lRec."Base Unit of Measure";
        QCRcptHead_lRec."Item Description" := Item_lRec.Description;
        QCRcptHead_lRec."Item Description 2" := Item_lRec."Description 2";
        QCRcptHead_lRec."Pre-Receipt QC" := true;

        Clear(PurchHeader_lRec);
        if PurchHeader_lRec.Get(PurchHeader_lRec."Document Type"::Order, PurchLine_gRec."Document No.") then begin
            QCRcptHead_lRec."Receipt Date" := PurchHeader_lRec."Posting Date";
        end;

        if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::Percentage then begin
            Item_lRec.TestField(Sample);
            QCRcptHead_lRec."Sample Quantity" := ROUND((Quantity_iDec * Item_lRec.Sample) / 100, Item_lRec."Rounding Precision")
        end else
            if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::Quantity then begin
                Item_lRec.TestField(Sample);
                if Quantity_iDec < Item_lRec.Sample then
                    QCRcptHead_lRec."Sample Quantity" := Quantity_iDec
                else
                    QCRcptHead_lRec."Sample Quantity" := Item_lRec.Sample;
            end else
                if Item_lRec."Sampling Plan" = Item_lRec."sampling plan"::" " then begin
                    QCRcptHead_lRec."Sample Quantity" := Quantity_iDec;
                end;

        QCRcptHead_lRec."Vendor Lot No." := LotNo_iCod;
        QCRcptHead_lRec."Exp. Date" := ExpDate_iDat;
        QCRcptHead_lRec."Mfg. Date" := ResEntry_iRec."Warranty Date"; //T12204-N

        Clear(PurchLine_lRec);
        if PurchLine_lRec.Get(PurchLine_lRec."document type"::Order, PurchLine_gRec."Document No.", PurchLine_gRec."Line No.") then
            QCRcptHead_lRec."Order Quantity" := PurchLine_lRec.Quantity;

        QCRcptHead_lRec."Inspection Quantity" := Quantity_iDec;
        QCRcptHead_lRec."Remaining Quantity" := Quantity_iDec;

        QCSetup_lRec.Reset();
        QCSetup_lRec.GET();

        If not QCSetup_lRec."QC Block without Location" then
            SetLocationAndBin_lFnc(QCRcptHead_lRec, PurchLine_gRec)
        else
            SetLocationAndBinNew_lFnc(QCRcptHead_lRec, PurchLine_gRec);

        QCRcptHead_lRec.Insert(true);

        if CreatedQCNo_gTxt <> '' then
            CreatedQCNo_gTxt += ' , ' + QCRcptHead_lRec."No."
        else
            CreatedQCNo_gTxt := QCRcptHead_lRec."No.";

        if Item_lRec."Item Tracking Code" <> '' then
            QCRcptHead_lRec."Item Tracking" := ResEntry_iRec."Item Tracking".AsInteger()
        else
            QCRcptHead_lRec."Item Tracking" := QCRcptHead_lRec."Item Tracking"::None;

        QCRcptHead_lRec.Modify;

        QCSpecificationLine_lRec.Reset;
        QCSpecificationLine_lRec.SetRange("Item Specifiction Code", Item_lRec."Item Specification Code");
        if QCSpecificationLine_lRec.FindFirst then begin
            repeat
                QCRcptLine_lRec.Required := true;//T12544-N
                QCRcptLine_lRec.Print := QCSpecificationLine_lRec.Print; //T13242-N 03-01-2025
                QCRcptLine_lRec."No." := QCRcptHead_lRec."No.";
                QCRcptLine_lRec."Line No." := QCSpecificationLine_lRec."Line No.";
                QCRcptLine_lRec.Validate("Quality Parameter Code", QCSpecificationLine_lRec."Quality Parameter Code");
                //T51170-NS
                QCRcptLine_lRec.Description := QCSpecificationLine_lRec.Description;
                QCRcptLine_lRec."Method Description" := QCSpecificationLine_lRec."Method Description";
                //T51170-NE
                QCRcptLine_lRec.Validate("Unit of Measure Code", QCSpecificationLine_lRec."Unit of Measure Code");
                QCRcptLine_lRec.Type := QCSpecificationLine_lRec.Type;
                QCSpecificationLine_lRec.CalcFields(Method);
                QCRcptLine_lRec.Method := QCSpecificationLine_lRec.Method;
                QCRcptLine_lRec.Type := QCSpecificationLine_lRec.Type;
                QCRcptLine_lRec."Min.Value" := QCSpecificationLine_lRec."Min.Value";
                QCRcptLine_lRec."Max.Value" := QCSpecificationLine_lRec."Max.Value";
                //T13827-NS
                QCRcptLine_lRec."COA Min.Value" := QCSpecificationLine_lRec."COA Min.Value";
                QCRcptLine_lRec."COA Max.Value" := QCSpecificationLine_lRec."COA Max.Value";
                //T13827-NE
                //T51170-NS            
                QCRcptLine_lRec."Rounding Precision" := QCSpecificationLine_lRec."Rounding Precision";//T51170-N
                QCRcptLine_lRec."Show in COA" := QCSpecificationLine_lRec."Show in COA";
                QCRcptLine_lRec."Default Value" := QCSpecificationLine_lRec."Default Value";
                //T51170-NE
                QCRcptLine_lRec."Decimal Places" := QCSpecificationLine_lRec."Decimal Places"; //T52614-N
                QCRcptLine_lRec.Code := QCSpecificationLine_lRec."Document Code";
                QCRcptLine_lRec.Mandatory := QCSpecificationLine_lRec.Mandatory;
                QCRcptLine_lRec."Text Value" := QCSpecificationLine_lRec."Text Value";
                QCRcptLine_lRec."Item Code" := QCSpecificationLine_lRec."Item Code";
                QCRcptLine_lRec."Item Description" := QCSpecificationLine_lRec."Item Description";
                QCRcptLine_lRec.Insert;

                if (Item_lRec."Entry for each Sample") and
                   (QCRcptHead_lRec."Item Tracking" <> QCRcptHead_lRec."item tracking"::"Lot and Serial No.") and
                   (QCRcptHead_lRec."Item Tracking" <> QCRcptHead_lRec."item tracking"::"Serial No.")
                then begin
                    for Cnt_lInt := 1 to QCRcptHead_lRec."Sample Quantity" do begin
                        QCLineDetail_lRec.Init;
                        QCLineDetail_lRec."QC Rcpt No." := QCRcptHead_lRec."No.";
                        QCLineDetail_lRec."QC Rcpt Line No." := QCRcptLine_lRec."Line No.";
                        QCLineDetail2_lRec.Reset;
                        QCLineDetail2_lRec.SetRange("QC Rcpt No.", QCLineDetail_lRec."QC Rcpt No.");
                        QCLineDetail2_lRec.SetRange("QC Rcpt Line No.", QCLineDetail_lRec."QC Rcpt Line No.");

                        if QCLineDetail2_lRec.FindLast then
                            QCLineDetail_lRec."Line No." := QCLineDetail2_lRec."Line No." + 10000
                        else
                            QCLineDetail_lRec."Line No." := 10000;

                        QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");
                        QCLineDetail_lRec.Type := QCRcptLine_lRec.Type;
                        QCLineDetail_lRec.Validate("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");

                        QCLineDetail_lRec."Min.Value" := QCRcptLine_lRec."Min.Value";
                        QCLineDetail_lRec."Max.Value" := QCRcptLine_lRec."Max.Value";
                        QCLineDetail_lRec."Text Value" := QCRcptLine_lRec."Text Value";
                        QCLineDetail_lRec."Lot No." := QCRcptHead_lRec."Vendor Lot No.";
                        QCLineDetail_lRec."Unit of Measure Code" := QCRcptLine_lRec."Unit of Measure Code";
                        QCLineDetail_lRec.Insert;
                    end;
                end;

            until QCSpecificationLine_lRec.Next = 0;
        end;
    end;

    local procedure SetLocationAndBinNew_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; PurchLine_iRec: Record "Purchase Line")
    var
        PurchHeader_lRec: Record "Purchase Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
        QCBin_lRec: Record Bin;
    begin
        // PurchHeader_lRec.Get(PurchLine_iRec."Document Type"::Order, PurchLine_iRec."Document No.");
        // QCRcptHead_vRec.Validate("Location Code", PurchHeader_lRec."Location Code");
        // QCRcptHead_vRec.Validate("QC Location", PurchHeader_lRec."Location Code");

        PurchHeader_lRec.Get(PurchLine_iRec."Document Type"::Order, PurchLine_iRec."Document No.");
        QCRcptHead_vRec.Validate("Location Code", PurchLine_iRec."Location Code");
        //QC Location & Bin Assign Start        
        MainLocation_lRec.Get(PurchLine_iRec."Location Code");
        QCRcptHead_vRec.Validate("QC Location", MainLocation_lRec.Code);

        //Find QCBin T12113-NS
        QCBin_lRec.Reset;
        QCBin_lRec.SetRange("Location Code", MainLocation_lRec.code);
        QCBin_lRec.SetRange("Bin Category", QCBin_lRec."Bin Category"::TESTING);
        if QCBin_lRec.FindFirst then
            QCRcptHead_vRec.Validate("QC Bin Code", QCBin_lRec.Code);
        //Find QCBin T12113-NE

        QCRcptHead_vRec.TestField("QC Location");
        Location_gRec.Get(QCRcptHead_vRec."QC Location");

        if Location_gRec."Bin Mandatory" then
            QCRcptHead_vRec.TestField("QC Bin Code");
        //QC Location & Bin Assign End
        //Store Location & Bin Assign Start
        MainLocation_lRec.Get(PurchLine_iRec."Location Code");

        QCRcptHead_vRec.Validate("Store Location Code", MainLocation_lRec.Code);
        if MainLocation_lRec."Accept Bin Code" <> '' then
            QCRcptHead_vRec.Validate("Store Bin Code", MainLocation_lRec."Accept Bin Code")
        else begin
            if MainLocation_lRec."Bin Mandatory" then begin
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", QCRcptHead_vRec."Store Location Code");
                Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::STORE);
                Bin_lRec.FindLast;
                QCRcptHead_vRec.Validate("Store Bin Code", Bin_lRec.Code);
            end;
        end;
        //Store Location & Bin Assign End

        //Rejection Location & Bin Assign Start
        MainLocation_lRec.TestField("Rejection Location");
        QCRcptHead_vRec.Validate("Rejection Location", MainLocation_lRec."Rejection Location");
        Location_lRec.Get(QCRcptHead_vRec."Rejection Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rejection Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REJECT);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Reject Bin Code", Bin_lRec.Code);
        end;
        //Rejection Location & Bin Assign End

        //Rework Location & Bin Assign Start
        MainLocation_lRec.TestField("Rework Location");
        QCRcptHead_vRec.Validate("Rework Location", MainLocation_lRec."Rework Location");
        Location_lRec.Get(QCRcptHead_vRec."Rework Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rework Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REWORK);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Rework Bin Code", Bin_lRec.Code);
        end;
        //Rework Location & Bin Assign End

    End;

    local procedure SetLocationAndBin_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; PurchLine_iRec: Record "Purchase Line")
    var
        PurchHeader_lRec: Record "Purchase Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
        QCBin_lRec: Record Bin;
    begin
        PurchHeader_lRec.Get(PurchLine_iRec."Document Type"::Order, PurchLine_iRec."Document No.");
        QCRcptHead_vRec.Validate("Location Code", PurchHeader_lRec."Location Code");
        //QC Location & Bin Assign Start        
        MainLocation_lRec.Get(PurchHeader_lRec."Location Code");
        QCRcptHead_vRec.Validate("QC Location", MainLocation_lRec."QC Location");

        //Find QCBin T12113-NS
        QCBin_lRec.Reset;
        QCBin_lRec.SetRange("Location Code", MainLocation_lRec."QC Location");
        QCBin_lRec.SetRange("Bin Category", QCBin_lRec."Bin Category"::TESTING);
        if QCBin_lRec.FindFirst then
            QCRcptHead_vRec.Validate("QC Bin Code", QCBin_lRec.Code);
        //Find QCBin T12113-NE

        QCRcptHead_vRec.TestField("QC Location");
        Location_gRec.Get(QCRcptHead_vRec."QC Location");

        if Location_gRec."Bin Mandatory" then
            QCRcptHead_vRec.TestField("QC Bin Code");
        //QC Location & Bin Assign End
        //Store Location & Bin Assign Start
        MainLocation_lRec.Get(PurchHeader_lRec."Location Code");

        QCRcptHead_vRec.Validate("Store Location Code", MainLocation_lRec.Code);
        if MainLocation_lRec."Accept Bin Code" <> '' then
            QCRcptHead_vRec.Validate("Store Bin Code", MainLocation_lRec."Accept Bin Code")
        else begin
            if MainLocation_lRec."Bin Mandatory" then begin
                Bin_lRec.Reset;
                Bin_lRec.SetRange("Location Code", QCRcptHead_vRec."Store Location Code");
                Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::STORE);
                Bin_lRec.FindLast;
                QCRcptHead_vRec.Validate("Store Bin Code", Bin_lRec.Code);
            end;
        end;
        //Store Location & Bin Assign End

        //Rejection Location & Bin Assign Start
        MainLocation_lRec.TestField("Rejection Location");
        QCRcptHead_vRec.Validate("Rejection Location", MainLocation_lRec."Rejection Location");
        Location_lRec.Get(QCRcptHead_vRec."Rejection Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rejection Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REJECT);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Reject Bin Code", Bin_lRec.Code);
        end;
        //Rejection Location & Bin Assign End

        //Rework Location & Bin Assign Start
        MainLocation_lRec.TestField("Rework Location");
        QCRcptHead_vRec.Validate("Rework Location", MainLocation_lRec."Rework Location");
        Location_lRec.Get(QCRcptHead_vRec."Rework Location");
        if Location_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", MainLocation_lRec."Rework Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::REWORK);
            Bin_lRec.FindFirst;
            QCRcptHead_vRec.Validate("Rework Bin Code", Bin_lRec.Code);
        end;
        //Rework Location & Bin Assign End        
    end;





    local procedure AvailableInventory_lFnc(PurchLine_iRec: Record "Purchase Line"; RejectionFlag_iBln: Boolean): Decimal
    var
        Item: Record item;
    begin
        // Clear(Item);
        // Item.SetRange("No.", PurchLine_iRec."No.");
        // Item.SetFilter("Location Filter", '%1', PurchLine_iRec."Location Code");
        // if Item.FindSet() then
        //     Item.CalcFields(Inventory);



        if (PurchLine_iRec."QC Created") AND (RejectionFlag_iBln) then begin //in Rejection
            PurchLine_iRec.TestField("QC Rejected Qty");
            // if Item.Inventory < PurchLine_iRec."QC Rejected Qty" then
            //     Error('Inventory is not Available.');
        end else if (PurchLine_iRec."QC Created") And (Not RejectionFlag_iBln) then begin
            if (PurchLine_iRec."QC Created") then
                Error('QC is Already Created.');
        end else if (Not PurchLine_iRec."QC Created") AND (Not RejectionFlag_iBln) then begin
            if (PurchLine_iRec."QC Created") then
                Error('QC is Already Created.');
            // if Item.Inventory < PurchLine_iRec."Outstanding Quantity" then
            //     Error('Inventory is not Available.');
        end;

    end;

    procedure ItemTrackingLine_gFnc(var QCRcptHeader_vRec: Record "QC Rcpt. Header")
    var
        ItemTrackingSOQC_lPge: Page "Item Tracking For SalesOdr QC";
        ReservationEntry_lRec: Record "Reservation Entry";
        TotalAccQty_lDec: Decimal;
        TotalAccWithDevi_lDec: Decimal;
        TotalRejQty_lDec: Decimal;
        TotalRewQty_lDec: Decimal;
        Rejection_lcde: Code[20];//T12113
        Rework_lCde: code[20];//T12113

    begin
        QCRcptHeader_vRec.TestField("Document Type", QCRcptHeader_vRec."Document Type"::"Purchase Pre-Receipt");

        ReservationEntry_lRec.Reset;
        ReservationEntry_lRec.SetRange("Source Batch Name", QCRcptHeader_vRec."Item General Batch Name");
        ReservationEntry_lRec.SetRange("Source ID", QCRcptHeader_vRec."Document No.");
        ReservationEntry_lRec.SetRange("Source Type", 39);
        ReservationEntry_lRec.SetRange("Source Ref. No.", QCRcptHeader_vRec."Document Line No.");
        if QCRcptHeader_vRec."Vendor Lot No." <> '' then
            ReservationEntry_lRec.SetRange("Lot No.", QCRcptHeader_vRec."Vendor Lot No.");
        ReservationEntry_lRec.SetFilter("Item Tracking", '<>%1', ReservationEntry_lRec."Item Tracking"::None);
        if QCRcptHeader_vRec.Approve then
            ItemTrackingSOQC_lPge.Editable(false);

        ItemTrackingSOQC_lPge.SetTableview(ReservationEntry_lRec);
        ItemTrackingSOQC_lPge.RunModal;

        if ReservationEntry_lRec.FindSet then begin
            repeat
                TotalAccQty_lDec += ReservationEntry_lRec."Accepted Quantity";
                TotalAccWithDevi_lDec += ReservationEntry_lRec."Accepted with Deviation Qty";
                TotalRejQty_lDec += ReservationEntry_lRec."Rejected Quantity";
                TotalRewQty_lDec += ReservationEntry_lRec."Rework Quantity";
                if ReservationEntry_lRec."Rejection Reason" <> '' then
                    Rejection_lcde := ReservationEntry_lRec."Rejection Reason";
                if ReservationEntry_lRec."Rework Reason" <> '' then
                    Rework_lCde := ReservationEntry_lRec."Rework Reason";

            until ReservationEntry_lRec.Next = 0;

            if (not QCRcptHeader_vRec.Approve) and (QCRcptHeader_vRec."Approval Status" = QCRcptHeader_vRec."approval status"::Open) then begin
                QCRcptHeader_vRec."Quantity to Accept" := TotalAccQty_lDec;
                QCRcptHeader_vRec."Quantity to Reject" := TotalRejQty_lDec;
                QCRcptHeader_vRec."Quantity to Rework" := TotalRewQty_lDec;
                QCRcptHeader_vRec."Qty to Accept with Deviation" := TotalAccWithDevi_lDec;
                QCRcptHeader_vRec.Validate("Rejection Reason", Rejection_lcde);
                QCRcptHeader_vRec.Validate("Rework Reason", Rework_lCde);
                //only for Purchase Order
                if (QCRcptHeader_vRec."Quantity to Accept" <> 0) or (QCRcptHeader_vRec."Qty to Accept with Deviation" <> 0) then
                    if (QCRcptHeader_vRec."Quantity to Reject" > 0) and (QCRcptHeader_vRec."Item Tracking" in [QCRcptHeader_vRec."Item Tracking"::"Lot No."]) then
                        Error(Text0006_gCtx);
                //only for Purchase Order
                QCRcptHeader_vRec.Modify;
            end;
        end;
    end;



    local procedure UpdatePurchaseLine_lFnc(PL_iRec: Record "Purchase Line"; CheckRejFlag_iBol: Boolean)
    var
        PurchOrderLine_lRec: Record "Purchase Line";
    begin
        Clear(PurchOrderLine_lRec);
        PurchOrderLine_lRec.Get(PL_iRec."Document Type"::Order, PL_iRec."Document No.", PL_iRec."Line No.");
        PurchOrderLine_lRec."QC Created" := true;
        if (CheckRejFlag_iBol) and (PurchOrderLine_lRec."QC Rejected Qty" > 0) then
            PurchOrderLine_lRec."QC Rejected Qty" := 0;
        PurchOrderLine_lRec.Modify;
    end;


    procedure ItemTrackingOption_gFnc(LotNo: Code[50]; SerialNo: Code[20]) OptionValue: Integer
    begin
        if LotNo <> '' then
            OptionValue := 1;

        if SerialNo <> '' then begin
            if LotNo <> '' then
                OptionValue := 2
            else
                OptionValue := 3;
        end;
    end;

    procedure CheckItemTrackingOnPurchaseOrderQC_lFnc(PurchLine_iRec: Record "Purchase Line"): Boolean
    var
        item_lRec: Record Item;
    begin
        item_lRec.get(PurchLine_iRec."No.");
        if item_lRec."Item Tracking Code" <> '' then
            exit(true)
        else
            exit(False);
    end;

    procedure InsertReservationEntryIntoQCReservation_gFnc(QCRcptHdr_iRec: Record "QC Rcpt. Header"; PostedQCRecptNo_iCod: Code[20])
    var
        QCReservationEntry_lRec: Record "QC Reservation Entry";
        ReservationEntry_lRec: Record "Reservation Entry";
    begin
        ReservationEntry_lRec.Reset();
        ReservationEntry_lRec.SetRange("Source Type", 39);
        ReservationEntry_lRec.SetRange("Source Subtype", ReservationEntry_lRec."Source Subtype"::"1");
        ReservationEntry_lRec.SetRange("Source ID", QCRcptHdr_iRec."Document No.");
        ReservationEntry_lRec.SetRange("Source Ref. No.", QCRcptHdr_iRec."Document Line No.");
        ReservationEntry_lRec.SetRange("Item No.", QCRcptHdr_iRec."Item No.");
        ReservationEntry_lRec.SetRange("Location Code", QCRcptHdr_iRec."Location Code");
        if QCRcptHdr_iRec."Vendor Lot No." <> '' then
            ReservationEntry_lRec.SetRange("Lot No.", QCRcptHdr_iRec."Vendor Lot No.");
        ReservationEntry_lRec.SetRange("QC Created", true);
        if ReservationEntry_lRec.FindSet() then begin
            repeat
                QCReservationEntry_lRec.Init;
                QCReservationEntry_lRec.TransferFields(ReservationEntry_lRec);
                QCReservationEntry_lRec."QC No." := QCRcptHdr_iRec."No.";
                QCReservationEntry_lRec."Posted QC No." := PostedQCRecptNo_iCod;
                QCReservationEntry_lRec.Insert;
            until ReservationEntry_lRec.Next = 0;
        end;
    end;

    procedure DeleteReservationEntryforPreReceiptQC(QCRcptHdr_iRec: Record "QC Rcpt. Header")
    var
        ReservationEntry_lRec: Record "Reservation Entry";
    begin
        ReservationEntry_lRec.Reset();
        ReservationEntry_lRec.SetRange("Source Type", 37);
        ReservationEntry_lRec.SetRange("Source Subtype", ReservationEntry_lRec."Source Subtype"::"1");
        ReservationEntry_lRec.SetRange("Source ID", QCRcptHdr_iRec."Document No.");
        ReservationEntry_lRec.SetRange("Source Ref. No.", QCRcptHdr_iRec."Document Line No.");
        ReservationEntry_lRec.SetRange("Item No.", QCRcptHdr_iRec."Item No.");
        ReservationEntry_lRec.SetRange("Location Code", QCRcptHdr_iRec."Location Code");
        if QCRcptHdr_iRec."Vendor Lot No." <> '' then
            ReservationEntry_lRec.SetRange("Lot No.", QCRcptHdr_iRec."Vendor Lot No.");
        ReservationEntry_lRec.SetRange("QC Created", true);
        if ReservationEntry_lRec.FindSet() then begin
            ReservationEntry_lRec.Delete(true);
        end;
    end;





}

