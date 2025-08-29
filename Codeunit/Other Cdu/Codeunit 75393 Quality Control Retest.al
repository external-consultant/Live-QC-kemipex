codeunit 75393 "Quality Control Retest"//T12113-ABA-N
{
    SingleInstance = true;
    Permissions = TableData "Item Ledger Entry" = rm;
    trigger OnRun()
    begin

    end;

    var
        QCSpecificationHeader_lRec: Record "QC Specification Header";
        QCSetup_gRec: Record "Quality Control Setup";
        CreatedQCNo_gTxt: Text;
        RetestFromItemLdgrEntry_gRec: Record "Item Ledger Entry";
        Location_gRec: Record location;
        Text0001_gCtx: label 'QC Receipt = ''%1'' is created for Document No = ''%2'', Item Ledger Entry No. = ''%3'' sucessfully.';
        Text0000_gCtx: label 'Do you want to create QC Receipt for Document No = ''%1'', Item Ledger Entry No. = ''%2'' ?';

        Text0005_gCtx: label 'QC is not required for Location %1 in Item Ledger Entry. = %2.';



    procedure CreateQCRcpt_gFnc(ItemLdgrEntry_iRec: Record "Item Ledger Entry"; ShowConfirmMsg_iBln: Boolean)
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        IleCount_lRec: Record "Item Ledger Entry";
        ItemEntryRel_lRec: Record "Item Entry Relation";
        Item_lRec: Record Item;
        LotNo_lCod: Code[50];
        SampleQty_lDec: Decimal;
        Location_lRec: Record Location;
        QCSetup_lRec: Record "Quality Control Setup";
        NewItemJnlLine_gRec: Record "Item Journal Line";

    begin
        QCSetup_lRec.Get();
        if not QCSetup_lRec."Allow Retest QC" then
            Exit;

        //Written Function to create "QC Receipt" for Item ledger Item.
        RetestFromItemLdgrEntry_gRec.Copy(ItemLdgrEntry_iRec);
        RetestFromItemLdgrEntry_gRec.TestField("Location Code");



        Clear(Item_lRec);
        Item_lRec.Get(RetestFromItemLdgrEntry_gRec."Item No.");
        Item_lRec.TestField("Allow to Retest Material");


        Clear(Location_lRec);
        Location_lRec.get(RetestFromItemLdgrEntry_gRec."Location Code");
        Location_lRec.TestField("QC Category", false);
        Location_lRec.TestField("Rejection Category", false);




        RetestFromItemLdgrEntry_gRec.CalcFields("Reserved Quantity");

        if ((RetestFromItemLdgrEntry_gRec."Remaining Quantity" - RetestFromItemLdgrEntry_gRec."Reserved Quantity") = 0) then
            Error('Available Quantity must be greater than Zero.');

        Location_lRec.TestField("Rejection Location");
        Location_lRec.TestField("Rework Location");
        Location_lRec.TestField("QC Location");
        Item_lRec.TestField("Item Specification Code");
        QCSpecificationHeader_lRec.Get(Item_lRec."Item Specification Code");
        QCSpecificationHeader_lRec.TestField(Status, QCSpecificationHeader_lRec.Status::Certified);

        if ShowConfirmMsg_iBln then
            if not Confirm(StrSubstNo(Text0000_gCtx, RetestFromItemLdgrEntry_gRec."Document No.", RetestFromItemLdgrEntry_gRec."Entry No.")) then
                exit;

        QCSetup_lRec.Get();
        QCSetup_lRec.TestField("QC Journal Template Name");
        QCSetup_lRec.TestField("QC General Batch Name");

        if not QCSetup_lRec."QC Block without Location" then begin //T12968-N 
            CreateItemJnlLine_lFnc(RetestFromItemLdgrEntry_gRec);//Item Reclass Creation 

            NewItemJnlLine_gRec.Reset();
            NewItemJnlLine_gRec.SetRange("Journal Template Name", QCSetup_lRec."QC Journal Template Name");
            NewItemJnlLine_gRec.SetRange("Journal Batch Name", QCSetup_lRec."QC General Batch Name");
            NewItemJnlLine_gRec.SetRange("Document No.", RetestFromItemLdgrEntry_gRec."Document No.");
            if NewItemJnlLine_gRec.FindSet() then begin

                Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", NewItemJnlLine_gRec);//Item Reclass Post          

                if ShowConfirmMsg_iBln then
                    Message(Text0001_gCtx, CreatedQCNo_gTxt, RetestFromItemLdgrEntry_gRec."Document No.", RetestFromItemLdgrEntry_gRec."Entry No.");
            end;
        end;
        //T12968-NS
        if QCSetup_lRec."QC Block without Location" then begin
            //t51170 Pass Expiration Date in function
            CreateQCRcpt_lFnc(RetestFromItemLdgrEntry_gRec."Remaining Quantity" - RetestFromItemLdgrEntry_gRec."Reserved Quantity", RetestFromItemLdgrEntry_gRec."Lot No.", RetestFromItemLdgrEntry_gRec, RetestFromItemLdgrEntry_gRec."Expiration Date");
            if ShowConfirmMsg_iBln then
                Message(Text0001_gCtx, CreatedQCNo_gTxt, RetestFromItemLdgrEntry_gRec."Document No.", RetestFromItemLdgrEntry_gRec."Entry No.");
        end;
        ClearLast_gVarFnc();//var clear for event Codeunit::"Item Jnl.-Post Batch" OnAfterPostLines.
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnAfterPostLines', '', false, false)]
    local procedure "Item Jnl.-Post Batch_OnAfterPostLines"(var ItemJournalLine: Record "Item Journal Line"; var ItemRegNo: Integer; var WhseRegNo: Integer)
    var
        ItemLdgrEntry_lRec: Record "Item Ledger Entry";
    begin
        if (RetestFromItemLdgrEntry_gRec."Remaining Quantity" > 0) then//create QCRcpt from Ledger Entry
                                                                       //t51170 Pass Expiration Date in function
            CreateQCRcpt_lFnc(RetestFromItemLdgrEntry_gRec."Remaining Quantity" - RetestFromItemLdgrEntry_gRec."Reserved Quantity", RetestFromItemLdgrEntry_gRec."Lot No.", RetestFromItemLdgrEntry_gRec, RetestFromItemLdgrEntry_gRec."Expiration Date")
    end;


    local procedure CreateItemJnlLine_lFnc(ItemLedgEntry_iRec: Record "Item Ledger Entry")
    var
        ItemJnlLine_lRec: Record "Item Journal Line";
        ItemJnlLine1_lRec: Record "Item Journal Line";
        ItemJnlBatch_lRec: Record "Item Journal Batch";
        LedgeEnt: Record "Item Ledger Entry";
        ReservEntry_lRec: Record "Reservation Entry";
        SourceCodeSetup_lRec: Record "Source Code Setup";
        EntryNo_lInt: Integer;
        Location_lRec: Record Location;
        Bin_lRec: Record Bin;
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        TransferRcptLine_lRec: Record "Transfer Receipt Line";
        ReturnRcptLine_lRec: Record "Return Receipt Line";
        DelR337_lRec: Record "Reservation Entry";
        DelR337OppLag_lRec: Record "Reservation Entry";
        SaveR337_lRec: Record "Reservation Entry Save";
        DelSaveR337_lRec: Record "Reservation Entry Save";
        UniqueIDSave_lInt: Integer;
        ChkILE_lRec: Record "Item Ledger Entry";
        ILE_lRec: Record "Item Ledger Entry";
        Item_lRec: Record Item;
        OldLoc_lRec: Record Location;
        WhseEntry: Record "Warehouse Entry";
        BinCode: Code[20];
    begin
        //Create Function for Item Reclassification for Entered Result in "QC Receipt"


        SourceCodeSetup_lRec.Get;
        QCSetup_gRec.Get;
        QCSetup_gRec.TestField("QC Journal Template Name");
        QCSetup_gRec.TestField("QC General Batch Name");
        ILE_lRec.copy(ItemLedgEntry_iRec);//-

        ItemJnlLine_lRec.Init;
        ItemJnlLine_lRec."Journal Template Name" := QCSetup_gRec."QC Journal Template Name";
        ItemJnlLine_lRec."Journal Batch Name" := QCSetup_gRec."QC General Batch Name";
        ItemJnlLine_lRec."Line No." := GetLstIJLineNo_lFnc(ItemJnlLine_lRec);
        ItemJnlLine_lRec."Document No." := ILE_lRec."Document No.";
        ItemJnlLine_lRec."Document Line No." := ILE_lRec."Document Line No.";
        ItemJnlLine_lRec.Insert(true);
        ItemJnlLine_lRec."Entry Type" := ItemJnlLine_lRec."entry type"::Transfer;
        ItemJnlLine_lRec.SetUpNewLine(ItemJnlLine_lRec);

        ItemJnlLine_lRec.Validate("Item No.", ILE_lRec."Item No.");
        ItemJnlLine_lRec.Validate("Variant Code", ILE_lRec."Variant Code");
        Item_lRec.Get(ILE_lRec."Item No.");

        ItemJnlLine_lRec.Validate("Posting Date", Today);
        ItemJnlLine_lRec.Validate("Document Date", ILE_lRec."Posting Date");

        ItemJnlLine_lRec.Validate("Location Code", ILE_lRec."Location Code");
        ItemJnlLine_lRec."Document No." := ILE_lRec."Document No.";
        WhseEntry.Reset();
        WhseEntry.SetRange("Reference No.", ILE_lRec."Document No.");
        WhseEntry.SetRange("Registering Date", ILE_lRec."Posting Date");
        WhseEntry.SetRange("Item No.", ILE_lRec."Item No.");
        WhseEntry.SetRange("Item No.", ILE_lRec."Variant Code");
        if WhseEntry.FindFirst() then
            ItemJnlLine_lRec.Validate("Bin Code", WhseEntry."Bin Code");
        Location_gRec.get(ILE_lRec."Location Code");

        ItemJnlLine_lRec.Validate("New Location Code", Location_gRec."QC Location");

        Bin_lRec.Reset;
        Bin_lRec.SetRange("Location Code", Location_gRec.Code);
        Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::TESTING);
        if Bin_lRec.FindFirst then begin
            BinCode := Bin_lRec.Code;
            ItemJnlLine_lRec.Validate("New Bin Code", BinCode);
        end;
        ILE_lRec.CalcFields("Reserved Quantity");
        ItemJnlLine_lRec.Validate(Quantity, (ILE_lRec."Remaining Quantity" - ILE_lRec."Reserved Quantity"));

        ItemJnlLine_lRec."Shortcut Dimension 1 Code" := ILE_lRec."Global Dimension 1 Code";
        ItemJnlLine_lRec."Shortcut Dimension 2 Code" := ILE_lRec."Global Dimension 2 Code";
        ItemJnlLine_lRec."Dimension Set ID" := ILE_lRec."Dimension Set ID";
        ItemJnlLine_lRec."Skip Confirm Msg" := true;
        ItemJnlLine_lRec.Retest := true;
        ItemJnlLine_lRec."Warranty Date" := ILE_lRec."Warranty Date";//29/11/2024/ D
        ItemJnlLine_lRec.Modify(true);

        if Item_lRec."Item Tracking Code" = '' then begin
            ItemJnlLine_lRec.Validate("Applies-to Entry", ILE_lRec."Entry No.");
            ItemJnlLine_lRec.Modify(true);
        end
        else
            InsertReservationEntryRetest_lFnc(ItemJnlLine_lRec, ILE_lRec);
    end;

    local procedure GetLstIJLineNo_lFnc(IJL_iRec: Record "Item Journal Line"): Integer
    var
        ItemJnlLine_lRec: Record "Item Journal Line";
    begin
        //Get Line No.
        ItemJnlLine_lRec.Reset;
        ItemJnlLine_lRec.SetRange("Journal Template Name", IJL_iRec."Journal Template Name");
        ItemJnlLine_lRec.SetRange("Journal Batch Name", IJL_iRec."Journal Batch Name");
        if ItemJnlLine_lRec.FindLast then
            exit(ItemJnlLine_lRec."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure InsertReservationEntryRetest_lFnc(ItemJnlLine_iRec: Record "Item Journal Line"; ILE_lRec: Record "Item Ledger Entry")
    var
        ResEntry_lRec: Record "Reservation Entry";
        EntryNo_lInt: Integer;
        NextEntryNo_lInt: Integer;
    begin
        //To Insert the Reservation Entry for Item Journal Line.

        if ResEntry_lRec.FindLast then
            EntryNo_lInt := ResEntry_lRec."Entry No." + 1
        else
            EntryNo_lInt := 1;

        ResEntry_lRec.Lock;
        ResEntry_lRec.Init;
        ResEntry_lRec."Entry No." := EntryNo_lInt;

        ResEntry_lRec.Validate("Item No.", ILE_lRec."Item No.");
        ResEntry_lRec.Validate("Variant Code", ILE_lRec."Variant Code");
        ResEntry_lRec.Validate("Location Code", ILE_lRec."Location Code");
        if ItemJnlLine_iRec."Variant Code" <> '' then
            ResEntry_lRec.Validate("Variant Code", ItemJnlLine_iRec."Variant Code");

        ResEntry_lRec."Source Type" := Database::"Item Journal Line";
        ResEntry_lRec."Source Subtype" := ItemJnlLine_iRec."Entry Type".AsInteger();
        ResEntry_lRec."Source ID" := ItemJnlLine_iRec."Journal Template Name";
        ResEntry_lRec."Source Batch Name" := ItemJnlLine_iRec."Journal Batch Name";
        ResEntry_lRec."Source Ref. No." := ItemJnlLine_iRec."Line No.";
        ResEntry_lRec."Creation Date" := ItemJnlLine_iRec."Posting Date";
        ResEntry_lRec."Expiration Date" := ILE_lRec."Expiration Date";
        ResEntry_lRec."New Expiration Date" := ILE_lRec."Expiration Date";
        ResEntry_lRec."Created By" := UserId;
        if ILE_lRec."Lot No." <> '' then begin
            ResEntry_lRec.Validate("Lot No.", ILE_lRec."Lot No.");
            ResEntry_lRec.Validate("New Lot No.", ILE_lRec."Lot No.");
        end;
        if ILE_lRec."Serial No." <> '' then begin
            ResEntry_lRec.Validate("Serial No.", ILE_lRec."Serial No.");
            ResEntry_lRec.Validate("New Serial No.", ILE_lRec."Serial No.");
        end;
        ResEntry_lRec."Shipment Date" := ILE_lRec."Posting Date";
        ResEntry_lRec."Warranty Date" := ILE_lRec."Warranty Date";//29/11/2024/ D
        ResEntry_lRec."Reservation Status" := ResEntry_lRec."reservation status"::Prospect;
        ResEntry_lRec."Item Tracking" := ILE_lRec."Item Tracking";
        ResEntry_lRec.Quantity := -1 * Abs(ItemJnlLine_iRec.Quantity);
        ResEntry_lRec.Validate("Quantity (Base)", -1 * Abs(ItemJnlLine_iRec.Quantity));
        ResEntry_lRec."Qty. per Unit of Measure" := 1;
        ResEntry_lRec.Validate("Appl.-to Item Entry", ILE_lRec."Entry No.");
        ResEntry_lRec.Insert;
    end;

    local procedure CreateQCRcpt_lFnc(Quantity_iDec: Decimal; LotNo_iCod: Code[50]; ItemLedgerEntry_iRec: Record "Item Ledger Entry"; ExpDate_iDat: Date)
    var
        QCRcptHead_lRec: Record "QC Rcpt. Header";
        QCRcptHead2_lRec: Record "QC Rcpt. Header";
        Item_lRec: Record Item;
        Customer_lRec: Record Customer;
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCSpecificationLine_lRec: Record "QC Specification Line";
        TransferRcptHeader_lRec: Record "Transfer Receipt Header";
        QCSpecificationHeader_lRec: Record "QC Specification Header";
        Bin_lRec: Record Bin;
        QCLineDetail_lRec: Record "QC Line Detail";
        QCLineDetail2_lRec: Record "QC Line Detail";
        QtyUnderQC_lDec: Decimal;
        Cnt_lInt: Decimal;
        TransferRcptLine_lRec: Record "Transfer Receipt Line";
        Location_lRec: Record Location;
        TransferLine_lRec: Record "Transfer Line";
        NoSeriesMgmnt_lCdu: Codeunit "No. Series";//Old NoSeriesManagement
        Ile_lRec: Record "Item Ledger Entry";
        NewItemLdgrEntry_lRec: Record "Item Ledger Entry";
        QCSetup_lRec: Record "Quality Control Setup";
        PostedQCRcptHeader_lRec: Record "Posted QC Rcpt. Header";
        PostedQCRcptLine_lRec: Record "Posted QC Rcpt. Line";

    begin
        Clear(Ile_lRec);
        Clear(CreatedQCNo_gTxt);
        Ile_lRec.Get(ItemLedgerEntry_iRec."Entry No.");

        QCSetup_gRec.Get();
        Item_lRec.Reset;

        QCSpecificationHeader_lRec.Reset;
        Item_lRec.Get(Ile_lRec."Item No.");

        Item_lRec.TestField("Item Specification Code");
        QCSpecificationHeader_lRec.Get(Item_lRec."Item Specification Code");
        QCSpecificationHeader_lRec.TestField(Status, QCSpecificationHeader_lRec.Status::Certified);

        QCRcptHead_lRec.Init;
        QCRcptHead_lRec."Document Type" := QCRcptHead_lRec."Document Type"::Ile;
        QCRcptHead_lRec."No Series" := QCSetup_gRec."Retest QC Nos";
        QCRcptHead_lRec."Document Line No." := Ile_lRec."Document Line No.";

        QCRcptHead_lRec."Item No." := Ile_lRec."Item No.";
        QCRcptHead_lRec."Variant Code" := Ile_lRec."Variant Code";
        QCRcptHead_lRec."Item Name" := Item_lRec.Description;
        QCRcptHead_lRec."Unit of Measure" := Item_lRec."Base Unit of Measure";
        QCRcptHead_lRec."Item Description" := Item_lRec.Description;
        QCRcptHead_lRec."Item Description 2" := Item_lRec."Description 2";
        QCRcptHead_lRec."Receipt Date" := Today;
        QCRcptHead_lRec.Retest := Ile_lRec.Retest;
        QCRcptHead_lRec."Item Tracking" := Ile_lRec."Item Tracking".AsInteger();




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
        QCRcptHead_lRec."Mfg. Date" := ItemLedgerEntry_iRec."Warranty Date"; //T12204-N

        QCRcptHead_lRec."Inspection Quantity" := Quantity_iDec;
        QCRcptHead_lRec."Remaining Quantity" := Quantity_iDec;


        QCSetup_lRec.Reset();
        QCSetup_lRec.GET();

        if not QCSetup_lRec."QC Block without Location" then
            SetLocationAndBin_lFnc(QCRcptHead_lRec, Ile_lRec)
        else
            SetLocationAndBinNew_lFnc(QCRcptHead_lRec, Ile_lRec);
        //T51170-NS
        if FindPostedQCRcptHeader(PostedQCRcptHeader_lRec, QCRcptHead_lRec) then begin
            QCRcptHead_lRec."Sample Collector ID" := PostedQCRcptHeader_lRec."Sample Collector ID";
            QCRcptHead_lRec."Sample Provider ID" := PostedQCRcptHeader_lRec."Sample Provider ID";
            QCRcptHead_lRec."Date of Sample Collection" := PostedQCRcptHeader_lRec."Date of Sample Collection";
            QCRcptHead_lRec."Sample Date and Time" := PostedQCRcptHeader_lRec."Sample Date and Time";
        end;
        //T51170-NE
        QCRcptHead_lRec.Insert(true);

        if CreatedQCNo_gTxt <> '' then
            CreatedQCNo_gTxt += ' , ' + QCRcptHead_lRec."No."
        else
            CreatedQCNo_gTxt := QCRcptHead_lRec."No.";


        //T12968-NS
        if QCSetup_lRec."QC Block without Location" then begin
            QCRcptHead_lRec."ILE No." := Ile_lRec."Entry No.";
            QCRcptHead_lRec."Document No." := Ile_lRec."Document No.";
            QCRcptHead_lRec.Modify();
        end;


        // //T12968-NE
        // NewItemLdgrEntry_lRec.Reset;
        // NewItemLdgrEntry_lRec.SetRange("Entry Type", NewItemLdgrEntry_lRec."Entry Type"::Transfer);
        // NewItemLdgrEntry_lRec.SetRange("Document No.", Ile_lRec."Document No.");
        // NewItemLdgrEntry_lRec.SetRange("Item No.", Ile_lRec."Item No.");
        // NewItemLdgrEntry_lRec.SetRange("Document Line No.", Ile_lRec."Document Line No.");
        // NewItemLdgrEntry_lRec.SetRange(open, true);
        // NewItemLdgrEntry_lRec.SetFilter("Remaining Quantity", '>%1', 0);
        // NewItemLdgrEntry_lRec.SetFilter("Entry No.", '<>%1', Ile_lRec."Entry No."); //Hypercare 25022025
        // if LotNo_iCod <> '' then
        //     NewItemLdgrEntry_lRec.SetRange("Lot No.", LotNo_iCod);

        // if NewItemLdgrEntry_lRec.FindSet() then begin
        //     QCRcptHead_lRec."ILE No." := NewItemLdgrEntry_lRec."Entry No.";//New Item Ledger Entry No of QC Location
        //     QCRcptHead_lRec."Document No." := NewItemLdgrEntry_lRec."Document No.";
        //     QCRcptHead_lRec.Modify();
        //     repeat
        //         NewItemLdgrEntry_lRec."QC No." := QCRcptHead_lRec."No.";
        //         NewItemLdgrEntry_lRec."QC Relation Entry No." := Ile_lRec."Entry No.";
        //         NewItemLdgrEntry_lRec.Modify;
        //     until NewItemLdgrEntry_lRec.Next = 0;
        // end;


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

                //T51170-NS
                if FindPostedQCRcptHeader(PostedQCRcptHeader_lRec, QCRcptHead_lRec) then begin
                    PostedQCRcptLine_lRec.Reset();
                    PostedQCRcptLine_lRec.SetRange("No.", PostedQCRcptHeader_lRec."No.");
                    PostedQCRcptLine_lRec.SetRange("Quality Parameter Code", QCRcptLine_lRec."Quality Parameter Code");
                    if PostedQCRcptLine_lRec.FindLast() then begin
                        QCRcptLine_lRec."Vendor COA Text Result" := PostedQCRcptLine_lRec."Vendor COA Text Result";
                        QCRcptLine_lRec."Vendor COA Value Result" := PostedQCRcptLine_lRec."Vendor COA Value Result"
                    end;

                end;
                //T51170-NE
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
        //T12750-NS 25112024
        if (QCSetup_lRec."QC Block without Location") and (Not Ile_lRec."Material at QC") then begin
            Ile_lRec."Material at QC" := true;
            Ile_lRec."QC No." := QCRcptHead_lRec."No.";
            Ile_lRec.Modify();
        end;
        //T12750-NE 25112024

        //T12968-NE
        if not (QCSetup_lRec."QC Block without Location") then begin
            NewItemLdgrEntry_lRec.Reset;
            NewItemLdgrEntry_lRec.SetRange("Entry Type", NewItemLdgrEntry_lRec."Entry Type"::Transfer);
            NewItemLdgrEntry_lRec.SetRange("Document No.", Ile_lRec."Document No.");
            NewItemLdgrEntry_lRec.SetRange("Item No.", Ile_lRec."Item No.");
            NewItemLdgrEntry_lRec.SetRange("Document Line No.", Ile_lRec."Document Line No.");
            NewItemLdgrEntry_lRec.SetRange(open, true);
            NewItemLdgrEntry_lRec.SetFilter("Remaining Quantity", '>%1', 0);
            NewItemLdgrEntry_lRec.SetFilter("Entry No.", '<>%1', Ile_lRec."Entry No."); //Hypercare 25022025
            if LotNo_iCod <> '' then
                NewItemLdgrEntry_lRec.SetRange("Lot No.", LotNo_iCod);

            if NewItemLdgrEntry_lRec.FindSet() then begin
                QCRcptHead_lRec."ILE No." := NewItemLdgrEntry_lRec."Entry No.";//New Item Ledger Entry No of QC Location
                QCRcptHead_lRec."Document No." := NewItemLdgrEntry_lRec."Document No.";
                QCRcptHead_lRec.Modify();
                repeat
                    NewItemLdgrEntry_lRec."QC No." := QCRcptHead_lRec."No.";
                    NewItemLdgrEntry_lRec."QC Relation Entry No." := Ile_lRec."Entry No.";
                    NewItemLdgrEntry_lRec.Modify;
                until NewItemLdgrEntry_lRec.Next = 0;
            end;
        end;

    end;


    //T51170-NS
    local procedure FindPostedQCRcptHeader(var PostedQCRcptHeader_lRec: Record "Posted QC Rcpt. Header"; QCRcptheader_Lrec: Record "QC Rcpt. Header"): Boolean
    var
        myInt: Integer;
    begin
        PostedQCRcptHeader_lRec.Reset();
        PostedQCRcptHeader_lRec.SetRange("Item No.", QCRcptheader_Lrec."Item No.");
        PostedQCRcptHeader_lRec.SetRange("Variant Code", QCRcptheader_Lrec."Variant Code");
        PostedQCRcptHeader_lRec.SetRange("Vendor Lot No.", QCRcptheader_Lrec."Vendor Lot No.");
        if PostedQCRcptHeader_lRec.FindLast() then
            exit(true)
        else
            exit(false);

    end;
    //T51170-NE

    local procedure SetLocationAndBinNew_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; ItemLedgerEntry_iRec: Record "Item Ledger Entry")
    var
        TransferRcptHeader_lRec: Record "Transfer Receipt Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
        QCBin_lRec: Record Bin;
        Ile_lRec: Record "Item Ledger Entry";
    begin

        Ile_lRec.get(ItemLedgerEntry_iRec."Entry No.");
        // QCRcptHead_vRec.Validate("Location Code", Ile_lRec."Location Code");
        // QCRcptHead_vRec.Validate("QC Location", Ile_lRec."Location Code");
        //

        QCRcptHead_vRec.Validate("Location Code", ItemLedgerEntry_iRec."Location Code");
        QCRcptHead_vRec.Validate("QC Location", ItemLedgerEntry_iRec."Location Code");
        QCRcptHead_vRec.TestField("QC Location");

        //QC Location & Bin Assign Start
        MainLocation_lRec.get(ItemLedgerEntry_iRec."Location Code");
        if MainLocation_lRec."Bin Mandatory" then begin
            Bin_lRec.Reset;
            Bin_lRec.SetRange("Location Code", QCRcptHead_vRec."QC Location");
            Bin_lRec.SetRange("Bin Category", Bin_lRec."bin category"::QC);
            Bin_lRec.FindLast;
            QCRcptHead_vRec.Validate("QC Bin Code", Bin_lRec.Code);
            QCRcptHead_vRec.TestField("QC Bin Code");
        End;
        //QC Location & Bin Assign End

        //Store Location & Bin Assign Start
        MainLocation_lRec.Get(ItemLedgerEntry_iRec."Location Code");

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
        //I-C0009-1001310-04-NE

        //



    end;

    local procedure SetLocationAndBin_lFnc(var QCRcptHead_vRec: Record "QC Rcpt. Header"; ItemLedgerEntry_iRec: Record "Item Ledger Entry")
    var
        TransferRcptHeader_lRec: Record "Transfer Receipt Header";
        MainLocation_lRec: Record Location;
        Bin_lRec: Record Bin;
        Location_lRec: Record Location;
        QCBin_lRec: Record Bin;
        Ile_lRec: Record "Item Ledger Entry";
    begin

        Ile_lRec.get(ItemLedgerEntry_iRec."Entry No.");
        QCRcptHead_vRec.Validate("Location Code", Ile_lRec."Location Code");//Store Location
        MainLocation_lRec.Get(Ile_lRec."Location Code");
        //QC Location & Bin Assign Start
        QCRcptHead_vRec.Validate("QC Location", MainLocation_lRec."QC Location");

        QCBin_lRec.Reset;
        QCBin_lRec.SetRange("Location Code", Location_gRec."QC Location");
        QCBin_lRec.SetRange("Bin Category", QCBin_lRec."Bin Category"::TESTING);
        if QCBin_lRec.FindFirst then
            QCRcptHead_vRec.Validate("QC Bin Code", QCBin_lRec.Code);
        QCRcptHead_vRec.TestField("QC Location");
        Location_gRec.Get(QCRcptHead_vRec."QC Location");

        if Location_gRec."Bin Mandatory" then
            QCRcptHead_vRec.TestField("QC Bin Code");
        //QC Location & Bin Assign End

        //Store Location & Bin Assign Start
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
        Clear(Location_lRec);
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
        Clear(Location_lRec);
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

    Local procedure ClearLast_gVarFnc()
    begin
        Clear(RetestFromItemLdgrEntry_gRec);
    end;



}