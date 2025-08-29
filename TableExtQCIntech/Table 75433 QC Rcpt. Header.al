tableextension 75433 QCExtrecptHdr extends "QC Rcpt. Header"
{
    LookupPageID = "QC Rcpt. List";
    DrillDownPageId = "QC Rcpt. List";
    fields
    {


        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-04-NS
                Item_gRec.Get("Item No.");
                "Item Name" := Item_gRec.Description;
                //I-C0009-1001310-04-NE
            end;
        }



        modify("Quantity to Accept")
        {

            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                TestStatus_lFnc;
                CheckRemainingQty_lFnc;
                CheckPartialQtyForLotItemQC_lFnc;//T12113-N
                //I-C0009-1001310-02 NE
            end;
        }
        modify("Qty to Accept with Deviation")
        {
            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                TestStatus_lFnc;
                CheckRemainingQty_lFnc;
                CheckPartialQtyForLotItemQC_lFnc;//T12113-N
                //I-C0009-1001310-02 NE
            end;
        }
        modify("Quantity to Reject")
        {
            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                // if "Quantity to Reject" < "Inspection Quantity" then
                //     Error('Partial Rejection is not accepted.');
                TestStatus_lFnc;
                CheckRemainingQty_lFnc;
                if ("Item Tracking" = "Item Tracking"::None) and ("Quantity to Reject" > 0) then
                    TestField("Rejection Reason");
                CheckPartialQtyForLotItemQC_lFnc;//T12113-N
                //I-C0009-1001310-02 NE
            end;
        }

        modify("QC Date")
        {
            //T12204-NS
            trigger OnAfterValidate()
            var
                QCRcptHeader_lRec: Record "QC Rcpt. Header";
                QCRcptLine_lRec: Record "QC Rcpt. Line";
            begin
                //T52538-OS
                // TestField("Date of Sample Collection");
                // if Rec."Date of Sample Collection" > Rec."QC Date" then
                //     Rec.FieldError("QC Date", StrSubstNo('can not be less than %1 Date of Sample Collection', Rec."Date of Sample Collection"));
                //T52538-OE

                //T52538-NS
                TestField("Sample Date and Time");

                if DT2Date(Rec."Sample Date and Time") > Rec."QC Date" then
                    Rec.FieldError("QC Date", StrSubstNo('can not be less than %1 Date of Sample Collection', DT2Date(Rec."Sample Date and Time")));

                QCRcptLine_lRec.Reset();
                QCRcptLine_lRec.SetRange("No.", Rec."No.");
                QCRcptLine_lRec.SetFilter("QC Status", '= %1|%2', QCRcptLine_lRec."QC Status"::" ", QCRcptLine_lRec."QC Status"::Fail);
                if not QCRcptLine_lRec.FindFirst() then begin
                    IF Rec."QC Remarks" = '' then
                        Rec."QC Remarks" := 'ALL TESTED PARAMETERS ARE QC PASSED AND ACCEPTED';
                    // Clear(QCRcptHeader_lRec);
                    // if QCRcptHeader_lRec.Get(Rec."No.") then begin
                    //     QCRcptHeader_lRec."QC Remarks" := 'ALL TESTED PARAMETERS ARE QC PASSED AND ACCEPTED';
                    //     QCRcptHeader_lRec.Modify(true);
                end;
                //T52538-NE
            end;
            //end;
            //T12204-NE
        }

        modify("Item Journal Template Name")
        {


            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-02 NS
                if "Item Journal Template Name" <> xRec."Item Journal Template Name" then
                    "Item General Batch Name" := '';
                //I-C0009-1001310-02 NE
            end;
        }





        modify(Approve)
        {
            trigger OnBeforeValidate()
            begin
                ApproveCheckQCLineDetails_lFnc;   //QCV3-N  24-01-18
                ApproveCheck_lFnc; //I-C0009-1001310-02 N
            end;
        }

        modify("Party No.")
        {


            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-02 NS
                if "Party Type" = "party type"::Vendor then begin
                    Vendor.SetRange("No.", "Party No.");
                    if Vendor.Find('-') then begin
                        "Party Name" := Vendor.Name;
                        Address := Vendor.Address;
                        "Phone no." := Vendor."Phone No.";
                    end;
                end else
                    if "Party Type" = "party type"::Customer then begin
                        Customer.SetRange("No.", "Party No.");
                        if Customer.Find('-') then begin
                            "Party Name" := Customer.Name;
                            Address := Customer.Address;
                            "Phone no." := Customer."Phone No.";
                        end;
                    end;
                //I-C0009-1001310-02 NE
            end;
        }

        modify("Sample Quantity")
        {
            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                TestStatus_lFnc;
                if "Sample Quantity" > "Inspection Quantity" then
                    Error(Text0006_gCtx);
                //I-C0009-1001310-02 NE
            end;
        }
        modify("Quantity to Rework")
        {
            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                TestStatus_lFnc;
                TestField("Document Type", "document type"::Production);
                TestField("Rework Reason");
                CheckRemainingQty_lFnc;
                CheckTotalReworkQty_lFnc;//T12212-N
                //I-C0009-1001310-02 NE
            end;
        }



        modify("QC Bin Code")
        {
            trigger OnBeforeValidate()
            begin
                TestStatus_lFnc;
            end;
        }

        modify("Store Bin Code")
        {


            trigger OnBeforeValidate()
            begin
                TestStatus_lFnc; //I-C0009-1001310-02 N
            end;
        }

        modify("Rework Bin Code")
        {

            trigger OnBeforeValidate()
            begin
                TestStatus_lFnc;
            end;
        }

        modify("Reject Bin Code")
        {


            trigger OnBeforeValidate()
            begin
                TestStatus_lFnc;
            end;
        }

        modify("Rejection Reason")
        {

            trigger OnAfterValidate()
            var
                Reason_lRec: Record "Reason Code";
            begin
                if Reason_lRec.Get(Rec."Rejection Reason") then
                    Rec."Rejection Reason Description" := Reason_lRec.Description
                else
                    Rec."Rejection Reason Description" := '';
            end;
        }


        modify("Rework Reason")
        {

            trigger OnBeforeValidate()
            var
                Rework_lRec: Record "Rework Code";
            begin
                if Rework_lRec.Get(Rec."Rework Reason") then
                    Rec."Rework Reason Description" := Rework_lRec.Description
                else
                    Rec."Rework Reason Description" := '';
            end;
        }



        modify("Date of Sample Collection")
        {

            trigger OnBeforeValidate()
            var
                myInt: Integer;
            begin
                if rec."QC Date" <> 0D then
                    //T52538-NS
                    if DT2Date(Rec."Sample Date and Time") > Rec."QC Date" then
                        Rec.FieldError("QC Date", StrSubstNo('can not be less than %1 Date of Sample Collection', DT2Date(Rec."Sample Date and Time")));
                //T52538-NE

                //T52538-OS
                // if Rec."Date of Sample Collection" > Rec."QC Date" then 
                // Rec.FieldError("QC Date", StrSubstNo('can not be less than %1 Date of Sample Collection', Rec."Date of Sample Collection"));
                //T52538-OE
            end;
            //T12204-NE

        }


    }

    keys
    {

    }

    fieldgroups
    {
    }


    trigger OnBeforeDelete()
    var
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        ItemJnlLine_lRec: Record "Item Journal Line";
        SalesReturnRcptLine_lRec: Record "Return Receipt Line";
        TransferRcptLine_lRec: Record "Transfer Receipt Line";
        SalesLine_lRec: Record "Sales Line";
        QCSalesTracking_lRec: Record "QC Sales Tracking";
        QCSalesOrder_lCdu: Codeunit "Quality Control - Sales";//T12703
    begin
        //I-C0009-1001310-04-NS    
        TestField("Total Accepted Quantity", 0);
        TestField("Total Under Deviation Acc. Qty", 0);
        TestField("Total Rejected Quantity", 0);
        TestField(Approve, false);

        //T12968-NS 02122024
        UpdateQCatMaterialonILE_lFnc(Rec);
        //T12968-NE 02122024

        QCRcptLine_gRec.Reset;
        QCRcptLine_gRec.SetRange("No.", "No.");

        if QCRcptLine_gRec.FindFirst then
            QCRcptLine_gRec.DeleteAll(true);

        QCLineDetail_gRec.Reset;
        QCLineDetail_gRec.SetRange("QC Rcpt No.", "No.");
        if QCLineDetail_gRec.FindFirst then
            QCLineDetail_gRec.DeleteAll(true);

        PurchRcptLine_lRec.Reset;
        if "Document Type" = "document type"::Purchase then begin
            PurchRcptLine_lRec.SetRange("Document No.", "Document No.");
            PurchRcptLine_lRec.SetRange("Line No.", "Document Line No.");
            if PurchRcptLine_lRec.FindFirst then begin
                PurchRcptLine_lRec."Under Inspection Quantity" := PurchRcptLine_lRec."Under Inspection Quantity" - "Inspection Quantity";
                PurchRcptLine_lRec.Modify;
            end;
        end else
            if "Document Type" = "document type"::Production then begin
                ItemJnlLine_lRec.Reset;
                ItemJnlLine_lRec.SetRange("Journal Template Name", "Item Journal Template Name");
                ItemJnlLine_lRec.SetRange("Journal Batch Name", "Item General Batch Name");
                ItemJnlLine_lRec.SetRange("Line No.", "Item Journal Line No.");
                if ItemJnlLine_lRec.FindFirst then begin
                    ItemJnlLine_lRec.Validate("Quantity Under Inspection", ItemJnlLine_lRec."Quantity Under Inspection" - "Inspection Quantity");
                    ItemJnlLine_lRec.Modify;
                end;
                //END;    //I-C0009-1001310-05-O
                //I-C0009-1001310-05-NS
            end else
                if "Document Type" = "document type"::"Sales Return" then begin
                    SalesReturnRcptLine_lRec.SetRange("Document No.", "Document No.");
                    SalesReturnRcptLine_lRec.SetRange("Line No.", "Document Line No.");
                    if SalesReturnRcptLine_lRec.FindFirst then begin
                        SalesReturnRcptLine_lRec."Under Inspection Quantity" := SalesReturnRcptLine_lRec."Under Inspection Quantity" - "Inspection Quantity";
                        SalesReturnRcptLine_lRec.Modify;
                    end;
                    //END;  //I-C0009-1001310-06-O
                    //I-C0009-1001310-05-NE
                    //I-C0009-1001310-06-NS
                end else
                    if "Document Type" = "document type"::"Transfer Receipt" then begin
                        TransferRcptLine_lRec.SetRange("Document No.", "Document No.");
                        TransferRcptLine_lRec.SetRange("Line No.", "Document Line No.");
                        if TransferRcptLine_lRec.FindFirst then begin
                            TransferRcptLine_lRec."Under Inspection Quantity" := TransferRcptLine_lRec."Under Inspection Quantity" - "Inspection Quantity";
                            TransferRcptLine_lRec.Modify;
                        end;
                    end else if "Document Type" = "Document Type"::"Sales Order" then begin //T12703-N
                        QCSalesOrder_lCdu.ModifyReservationEntryforSOQC(Rec);
                    end;
        //I-C0009-1001310-06-NE
        //I-C0009-1001310-04-NE 

    end;

    trigger OnBeforeInsert()
    Var
        ProductionOrder_lRec: Record "Production Order";
    begin
        //I-C0009-1001310-04-NS
        if "No." = '' then begin
            QCSetup_gRec.Get;
            Location_gRec.Get("Location Code");

            if "Document Type" = xRec."document type"::Purchase then begin
                if Location_gRec."Purchase QC Nos." <> '' then
                    // NoSeriesMgt_gCdu.InitSeries(Location_gRec."Purchase QC Nos.", xRec."No Series", 0D, "No.", "No Series")
                     "No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Purchase QC Nos.", Today, true)//12092024
                else begin
                    QCSetup_gRec.TestField("Purchase QC Nos.");
                    // NoSeriesMgt_gCdu.InitSeries(QCSetup_gRec."Purchase QC Nos.", xRec."No Series", 0D, "No.", "No Series");
                    "No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Purchase QC Nos.", Today, true);//12092024

                end;
            end else
                if "Document Type" = xRec."document type"::Production then begin
                    if (Location_gRec."Prodution QC Nos." <> '') then
                        // NoSeriesMgt_gCdu.InitSeries(Location_gRec."Prodution QC Nos.", xRec."No Series", 0D, "No.", "No Series")
                       "No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Prodution QC Nos.", Today, true)//12092024
                    else begin
                        QCSetup_gRec.TestField("Prodution QC Nos.");
                        // NoSeriesMgt_gCdu.InitSeries(QCSetup_gRec."Prodution QC Nos.", xRec."No Series", 0D, "No.", "No Series");
                        "No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Prodution QC Nos.", Today, true)//12092024
                    end;
                    //END;   //I-C0009-1001310-05-O
                    //I-C0009-1001310-05-NS
                end else
                    if "Document Type" = xRec."document type"::"Sales Return" then begin
                        if (Location_gRec."Sales Return QC No." <> '') then
                            // NoSeriesMgt_gCdu.InitSeries(Location_gRec."Sales Return QC No.", xRec."No Series", 0D, "No.", "No Series")
                            "No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Sales Return QC No.", Today, true)//12092024
                        else begin
                            QCSetup_gRec.TestField("Sales Return QC Nos.");
                            // NoSeriesMgt_gCdu.InitSeries(QCSetup_gRec."Sales Return QC Nos.", xRec."No Series", 0D, "No.", "No Series");
                            "No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Sales Return QC Nos.", Today, true);//12092024
                        end;
                        //END;   //I-C0009-1001310-06-O
                        //I-C0009-1001310-05-NE
                        //I-C0009-1001310-06-NS
                    end else
                        if "Document Type" = xRec."document type"::Ile then begin//T12113
                            QCSetup_gRec.TestField("Retest QC Nos");
                            // NoSeriesMgt_gCdu.InitSeries(QCSetup_gRec."Retest QC Nos", xRec."No Series", 0D, "No.", "No Series");                            
                            "No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Retest QC Nos", Today, true);//12092024
                        end else
                            if "Document Type" = xRec."document type"::"Transfer Receipt" then begin
                                if (Location_gRec."Transfer Receipt QC No." <> '') then
                                    // NoSeriesMgt_gCdu.InitSeries(Location_gRec."Transfer Receipt QC No.", xRec."No Series", 0D, "No.", "No Series")
                                     "No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Transfer Receipt QC No.", Today, true)//12092024
                                else begin
                                    QCSetup_gRec.TestField("Transfer Receipt QC No.");
                                    // NoSeriesMgt_gCdu.InitSeries(QCSetup_gRec."Transfer Receipt QC No.", xRec."No Series", 0D, "No.", "No Series");
                                    "No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Transfer Receipt QC No.", Today, true)//12092024
                                end;
                            end else
                                if "Document Type" = xRec."Document Type"::"Sales Order" then begin//T12113-NB
                                    QCSetup_gRec.TestField("PreDispatch QC Nos");
                                    // NoSeriesMgt_gCdu.InitSeries(QCSetup_gRec."PreDispatch QC Nos", xRec."No Series", 0D, "No.", "No Series");
                                    "No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."PreDispatch QC Nos", Today, true)//12092024
                                end;
            //I-C0009-1001310-06-NE
        end;
        //I-C0009-1001310-04-NE
        //T12542-NS  
        If ProductionOrder_lRec.Get(ProductionOrder_lRec.Status::Released, Rec."Document No.") then Begin
            ProductionOrder_lRec."QC Status" := ProductionOrder_lRec."QC Status"::Open;
            ProductionOrder_lRec.Modify();
        End;
        //T12542-NE
    end;

    trigger OnBeforeRename()
    begin
        TestStatus_lFnc; //I-C0009-1001310-04-N
    end;

    procedure CheckDecimalPlace_lFnc(QcRcptLine_iRec: Record "QC Rcpt. Line")
    var
        DecimalPlaces_lInt: Integer;
        String_lTxt: Text;
        Position_lInt: Integer;
        StringLen_lInt: Integer;
    begin
        DecimalPlaces_lInt := 0;
        String_lTxt := '';
        Position_lInt := 0;
        StringLen_lInt := 0;
        QcRcptLine_iRec.TestField("Rounding Precision");
        if StrPos(Format(QcRcptLine_iRec."Rounding Precision"), '.') > 0 then begin
            String_lTxt := Format(QcRcptLine_iRec."Rounding Precision");
            Position_lInt := StrPos(Format(QcRcptLine_iRec."Rounding Precision"), '.');
            StringLen_lInt := StrLen(Format(QcRcptLine_iRec."Rounding Precision"));
            DecimalPlaces_lInt := StrLen(CopyStr(String_lTxt, Position_lInt + 1, StringLen_lInt));
            if QcRcptLine_iRec."Decimal Places" < DecimalPlaces_lInt then
                Error('One must enter decimal places greater than or equal to %1 for %2 which has QC Receipt No. %3 and Line No. %4.', DecimalPlaces_lInt, QcRcptLine_iRec."Quality Parameter Code", QcRcptLine_iRec."No.", QcRcptLine_iRec."Line No.");
        end else begin
            if QcRcptLine_iRec."Decimal Places" > 0 then
                Error('Decimal place must be 0 for %1 which has QC Receipt No. %2 and Line No. %3.', QcRcptLine_iRec."Quality Parameter Code", QcRcptLine_iRec."No.", QcRcptLine_iRec."Line No.");
        end;
    end;

    var
        QCRcptLine_gRec: Record "QC Rcpt. Line";
        NoSeriesMgt_gCdu: Codeunit "No. Series";
        Length: Integer;
        str: Code[100];
        Pos: Integer;
        PurchSetup: Record "Purchases & Payables Setup";
        Item_gRec: Record Item;
        Vendor: Record Vendor;
        Customer: Record Customer;
        QCRcptLine1: Record "QC Rcpt. Line";
        ItemSpecificLine: Record "QC Specification Line";
        QCRcptLine: Record "QC Rcpt. Line";
        GRNLine: Record "Purch. Rcpt. Line";
        TotRejQty: Decimal;
        QCSetup_gRec: Record "Quality Control Setup";
        Text0001_gCtx: label 'Rejected Qty must be equal to rejection caused in Parameters.';
        Text0002_gCtx: label 'Output Quantity must be equal to Sum of "Accepted Quantity","Accepted Quantity with Deviation","Rework Quantity" and "Scrap Quantity"  in Item Journal Line Journal Template Name = ''%1'',Journal Batch Name = ''%2'',Line No. = ''%3''.';
        Text0003_gCtx: label 'QC Receipt No. = ''%1'' must be approved. ';
        Text0004_gCtx: label 'Please Enter Result to approve QC Receipt No. = ''%1''.';
        Text0005_gCtx: label 'Do you want to post the QC Receipt ?';
        QCLineDetail_gRec: Record "QC Line Detail";
        Text0006_gCtx: label '"Sample Quantity" cannot be greater than "Inspection Quantity".';
        Text0007_gCtx: label 'Please Enter Result for Quality Parameter Code = ''%1'' to approve \QC Receipt = ''%2''.';
        Text0008_gCtx: label 'Sum of "Quantity to Accept","Quantity to Accept with Deviation" and "Quantity to Reject" cannot be greater than "Remaining Quantity".';
        Text0009_gCtx: label 'There is no sufficient Inventory for Item No. = ''%1'' in Location Code = ''%2'' Bin Code = ''%3''.';
        Text0010_gCtx: label 'There is no sufficent Inventory for Item No. = ''%1''.';
        ItemLdgrEntry_gRec: Record "Item Ledger Entry";
        Text0011_gCtx: label '"Quantity to Accept" and "Quantity to Accept with Deviation" must be equal to sum of Quantity Accepted in Item Tracking Lines.';
        Text0012_gCtx: label '"Quantity to Reject" must be equal to sum of Quantity Rejected in Item Tracking Lines.';
        PostedQCRcptHead_gRec: Record "Posted QC Rcpt. Header";
        PostedQCRcptLine_gRec: Record "Posted QC Rcpt. Line";
        ItemJnlPost_gCdu: Codeunit "Item Jnl.-Post";
        PostedQCRecptNo_gCod: Code[20];
        QCRcptNo_gCod: Code[20];
        Text0013_gCtx: label 'Sum of "Quantity to Accept","Quantity to Accept with Deviation","Quantity to Rework" and "Quantity to Reject" cannot be greater than "Remaining Quantity".';
        Text0014_gCtx: label 'Sum of "Quantity to Accept","Quantity to Accept with Deviation","Quantity to Rework" and "Quantity to Reject" must be equal to "Inspection Quantity".';
        Location_gRec: Record Location;
        Text0015_gCtx: label 'QC Receipt is posted successfully.';
        Result_Opt: Option ACCEPT,REJECT,REWORK;
        ReworkedQty_gDec: Decimal;
        Text0016_gCtx: label '"Quantity to Rework" must be equal to sum of Quantity Reworked in Item Tracking Lines.';
        Text0017_gCtx: label '"Quantity to Rework" must be equal to sum of Quantity Reworked in QC Receipt Lines.';
        Text00018_gCtx: label 'This QC receipt is linked to the Output Journal process line, where the current setup or runtime values are found to be blank. Do you still want to post the QC Receipt?';
        Text00019_gCtx: label 'Partial Quality Verification Should not be allowed when the document type is Sales Order.';
        IJLCreated_gBol: Boolean;//T12750
        CheckExpLot_gBol: Boolean;//T51170;
        ExpChange_gBol: Boolean;//T51170;
        ManufChange_gBol: Boolean;//T51170;
        OverallChange_gBol: Boolean;//T51170;


    procedure TestStatus_lFnc()
    begin
        TestField(Approve, false); //I-C0009-1001310-02 N
        TestField("Approval Status", "approval status"::Open);  //QCApproval-N
    end;

    //T12113-NS
    procedure CheckQCCheck_gfnc()
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";//T12544-N
    begin
        //T12541-NS
        Rec.TestField("QC Date");
        Rec.TestField("Sample Collector ID");
        // Rec.TestField("Date of Sample Collection");//T52538-O
        Rec.TestField("Sample Date and Time"); //T52538-N
        //T12541-NE
        if Rec."Item Tracking" = Rec."Item Tracking"::None then
            if "Quantity to Reject" > 0 then
                Rec.TestField("Rejection Reason");
        //T12544-NS
        QCRcptLine_lRec.Reset;
        QCRcptLine_lRec.SetRange(QCRcptLine_lRec."No.", "No.");
        QCRcptLine_lRec.SetRange(Required, True);
        if QCRcptLine_lRec.FindSet() then
            repeat
                QCRcptLine_lRec.TestField(Result);
            until QCRcptLine_lRec.next = 0;

        //T12544-NE
    end;

    procedure SendQCMail(PostedQCRcptHead: Record "Posted QC Rcpt. Header"; QCRcptHead: Record "QC Rcpt. Header")
    var
        EmailMessage_lCdu: Codeunit "Email Message";
        Email_lCdu: Codeunit Email;
        CompanyInfo_lRec: Record "Company Information";
        QCSetup_lrec: Record "Quality Control Setup";
        Ile_lRec: Record "Item Ledger Entry";
        QCReserveEntry_lRec: Record "QC Reservation Entry";
        EmailReceipent: List of [Text];
        CC: List of [Text];
        BCC: List of [Text];
        Subject: Text[100];
        Body: Text;
        TempBlob_lCdu: Codeunit "Temp Blob";
        Out: OutStream;
        Instr: InStream;

    begin

        QCSetup_lrec.Get();
        if not QCSetup_lrec."Enable Noti. QC Rcpt. Reject." then
            exit;

        CompanyInfo_lRec.Get();
        if (Rec."Quantity to Reject" > 0) and (Rec."Item Tracking" = Rec."Item Tracking"::None) then begin

            Subject := '';
            Subject := PostedQCRcptHead."No.";

            QCSetup_lrec.TestField("Rejection Email To");
            EmailReceipent.Add(QCSetup_lrec."Rejection Email To");
            if QCSetup_lrec."Rejection Email CC" <> '' then
                CC.Add(QCSetup_lrec."Rejection Email CC");
            if QCSetup_lrec."Rejection Email BCC" <> '' then
                BCC.Add(QCSetup_lrec."Rejection Email BCC");

            Body := '';
            Body += 'Dear Sir/Ma`am,';
            Body += '<BR/>';
            Body += '<BR/>';
            Body += 'Please find the QC Rejection Details below:';
            Body += '<BR/>';
            Body += '<BR/>';
            Body += '<B> Rejection QC details </B>';
            Body += '<BR/>';
            Body += '<table width="100%"><tr><td>';
            Body += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
            TableBodyAppend_gFnc(Body, 'Document Type', Format(PostedQCRcptHead."Document Type"));
            TableBodyAppend_gFnc(Body, 'Document No', PostedQCRcptHead."Document No.");
            TableBodyAppend_gFnc(Body, 'Document Line No.', Format(PostedQCRcptHead."Document Line No."));
            TableBodyAppend_gFnc(Body, 'Item No.', PostedQCRcptHead."Item No.");
            TableBodyAppend_gFnc(Body, 'Item Description', PostedQCRcptHead."Item Description");
            TableBodyAppend_gFnc(Body, 'Quantity', Format(PostedQCRcptHead."Order Quantity"));
            TableBodyAppend_gFnc(Body, 'Quantity Rejected', Format(PostedQCRcptHead."Rejected Quantity"));
            TableBodyAppend_gFnc(Body, 'Rejected Reason', PostedQCRcptHead."Rejection Reason");
            TableBodyAppend_gFnc(Body, 'Rejected Reason Description', PostedQCRcptHead."Rejection Reason Description");
            TableBodyAppend_gFnc(Body, 'Rejected Date Time', Format(PostedQCRcptHead.SystemCreatedAt));
            Body += '</table>';
            Body += '<BR/>';
            Body += '<BR/>';
            Body += 'Thanks & Regards';
            Body += '<BR/>';
            Body += CompanyInfo_lRec.Name;

            EmailMessage_lCdu.Create(EmailReceipent, Subject, Body, true, CC, BCC);
            Email_lCdu.Send(EmailMessage_lCdu);
        end else
            if (Rec."Quantity to Reject" > 0) and (Rec."Item Tracking" <> Rec."Item Tracking"::None) then begin

                Subject := '';
                Subject := PostedQCRcptHead."No.";

                QCSetup_lrec.TestField("Rejection Email To");
                EmailReceipent.Add(QCSetup_lrec."Rejection Email To");
                if QCSetup_lrec."Rejection Email CC" <> '' then
                    CC.Add(QCSetup_lrec."Rejection Email CC");
                if QCSetup_lrec."Rejection Email BCC" <> '' then
                    BCC.Add(QCSetup_lrec."Rejection Email BCC");

                Body := '';
                Body += 'Dear Sir/Ma`am,';
                Body += '<BR/>';
                Body += '<BR/>';
                Body += 'Please find the QC Rejection Details below:';
                Body += '<BR/>';
                Body += '<BR/>';
                Body += '<B> Rejection QC details </B>';
                Body += '<BR/>';
                Body += '<table width="100%"><tr><td>';
                Body += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
                TableBodyAppend_gFnc(Body, 'Document Type', Format(PostedQCRcptHead."Document Type"));
                TableBodyAppend_gFnc(Body, 'Document No', PostedQCRcptHead."Document No.");
                TableBodyAppend_gFnc(Body, 'Document Line No.', Format(PostedQCRcptHead."Document Line No."));
                TableBodyAppend_gFnc(Body, 'Item No.', PostedQCRcptHead."Item No.");
                TableBodyAppend_gFnc(Body, 'Item Description', PostedQCRcptHead."Item Description");
                TableBodyAppend_gFnc(Body, 'Rejected Date Time', Format(PostedQCRcptHead.SystemCreatedAt));
                Body += '</table>';
                Body += '<BR/>';
                Body += '<BR/>';
                Body += '<B> Tracking Information</B>';
                Body += '<BR/>';

                if PostedQCRcptHead."Document Type" in [PostedQCRcptHead."Document Type"::Purchase, PostedQCRcptHead."Document Type"::"Sales Order",
                      PostedQCRcptHead."Document Type"::"Sales Return", PostedQCRcptHead."Document Type"::"Transfer Receipt"] then begin
                    Ile_lRec.Reset();
                    Ile_lRec.SetRange("Posted QC No.", PostedQCRcptHead."No.");
                    Ile_lRec.SetRange("Document No.", PostedQCRcptHead."Document No.");
                    Ile_lRec.SetRange("Lot No.", PostedQCRcptHead."Vendor Lot No.");
                    if Ile_lRec.FindSet() then
                        repeat
                            Body += '<table width="100%"><tr><td>';
                            Body += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
                            TableBodyAppend_gFnc(Body, 'Lot No.', Ile_lRec."Lot No.");
                            TableBodyAppend_gFnc(Body, 'Quantity', Format(Ile_lRec.Quantity));
                            TableBodyAppend_gFnc(Body, 'Quantity to Reject', Format(Ile_lRec."Rejected Quantity"));
                            TableBodyAppend_gFnc(Body, 'Rejected Reason', Ile_lRec."Rejection Reason");
                            TableBodyAppend_gFnc(Body, 'Rejected Reason Description', Ile_lRec."Rejection Reason Description");
                            Body += '</table>';
                            Body += '<BR/>';

                        until Ile_lRec.Next() = 0;
                end else
                    if PostedQCRcptHead."Document Type" in [PostedQCRcptHead."Document Type"::Production] then begin
                        QCReserveEntry_lRec.Reset();
                        QCReserveEntry_lRec.SetRange("Posted QC No.", PostedQCRcptHead."No.");
                        QCReserveEntry_lRec.SetRange("Lot No.", PostedQCRcptHead."Vendor Lot No.");
                        QCReserveEntry_lRec.SetRange("Source Batch Name", PostedQCRcptHead."Item General Batch Name");
                        QCReserveEntry_lRec.SetRange("Source ID", PostedQCRcptHead."Item Journal Template Name");
                        QCReserveEntry_lRec.SetRange("Source Type", 83);
                        QCReserveEntry_lRec.SetRange("Source Ref. No.", PostedQCRcptHead."Item Journal Line No.");
                        if QCReserveEntry_lRec.FindSet() then
                            repeat
                                Body += '<table width="100%"><tr><td>';
                                Body += '<table cellpadding="0" cellspacing="0" style="border:0.3px solid black;" align="left" width="100%">';
                                TableBodyAppend_gFnc(Body, 'Lot No.', QCReserveEntry_lRec."Lot No.");
                                TableBodyAppend_gFnc(Body, 'Quantity', Format(QCReserveEntry_lRec."Quantity"));
                                TableBodyAppend_gFnc(Body, 'Quantity to Reject', Format(QCReserveEntry_lRec."Rejected Quantity"));
                                TableBodyAppend_gFnc(Body, 'Rejected Reason', QCReserveEntry_lRec."Rejection Reason");
                                TableBodyAppend_gFnc(Body, 'Rejected Reason Description', QCReserveEntry_lRec."Rejection Reason Description");
                                Body += '</table>';
                                Body += '<BR/>';
                            until QCReserveEntry_lRec.Next() = 0;
                    end;
                Body += '<BR/>';
                Body += '<BR/>';
                Body += 'Thanks & Regards';
                Body += '<BR/>';
                Body += CompanyInfo_lRec.Name;

                EmailMessage_lCdu.Create(EmailReceipent, Subject, Body, true, CC, BCC);
                Email_lCdu.Send(EmailMessage_lCdu);

            end;
    end;

    procedure TableBodyAppend_gFnc(var Body_vTxt: Text; Caption_iTxt: Text; Value_iTxt: Text)
    begin
        Body_vTxt += '<tr><td align="left" Style="border:0.3px solid Black; font-weight:bold;padding:0px 5px 0px 5px;background-color: #DEF3F9"  Width="30%">' + Caption_iTxt + '</td>';
        Body_vTxt += '<td Style="border:0.3px solid Black;padding:0px 5px 0px 5px" align="left" Width="70%">' + Value_iTxt + '</td></tr>';
    end;
    //T12113-NE
    procedure ShowItemTrackingLines_gFnc()
    var
        ItemTrackingMgt: Codeunit "QC Mgt";
        PurchHeader_lRec: Record "Purchase Header";
        SalesOrderQC_lCdu: Codeunit "Quality Control - Sales";
        PreReceiptQC_lCdu: Codeunit "Quality Control Pre-Receipt";
    begin
        //Created Function to show Item Tracking Line.    
        //I-C0009-1001310-02 NS    
        if "Vendor Lot No." <> '' then
            ItemTrackingMgt.SetLotNo_gFnc("Vendor Lot No.");
        //ItemTrackingMgt.CallPostedItemTrackingFrm_gFnc(DATABASE::"Purch. Rcpt. Line",0,"Document No.",'',0,"Document Line No.");    //I-C0009-1001310-08-O
        //I-C0009-1001310-08-NS
        if "Document Type" = "document type"::Purchase then begin
            PurchHeader_lRec.Get(PurchHeader_lRec."document type"::Order, "Purchase Order No.");
            //if PurchHeader_lRec.Subcontracting then  //SubConQCV2-NS
            //  ItemTrackingMgt.CallPostedItemTrackingForSubConGRN_gFnc(Rec)  //SubConQCV2-NE
            //else
            ItemTrackingMgt.CallPostedItemTrackingFrm_gFnc(Database::"Purch. Rcpt. Line", 0, "Document No.", '', 0, "Document Line No.", Rec);
        end else
            if "Document Type" = "document type"::"Sales Return" then
                ItemTrackingMgt.CallPostedItemTrackingSalesReturn_gFnc(Database::"Return Receipt Line", 0, "Document No.", '', 0, "Document Line No.", Rec)//T12113-N
            else
                if "Document Type" = "document type"::"Transfer Receipt" then
                    ItemTrackingMgt.CallPostedItemTrackingFrm_gFnc(Database::"Transfer Receipt Line", 0, "Document No.", '', 0, "Document Line No.", Rec)
                else
                    if "Document Type" = "Document type"::ile then  //T12113-ABA-N
                        ItemTrackingMgt.Retest_CallPostedItemTrackingFrm_gFnc(Database::"Item Ledger Entry", 0, "Document No.", '', 0, "Document Line No.", Rec)
                    else if "Document Type" = "Document Type"::"Sales Order" then//T12113-ABA-N
                        SalesOrderQC_lCdu.ItemTrackingLine_gFnc(Rec)
                    else if "Document Type" = "Document Type"::"Purchase Pre-Receipt" then//T12547-ABA-N
                        PreReceiptQC_lCdu.ItemTrackingLine_gFnc(Rec);

        //I-C0009-1001310-08-NE
        if "Vendor Lot No." <> '' then
            ItemTrackingMgt.SetLotNo_gFnc('');
        //I-C0009-1001310-02 NE

    end;

    procedure PostQCRcpt_gFnc(SkipConfirm: Boolean)
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        NewQCRcptLine_lRec: Record "QC Rcpt. Line";
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        BinContent_lRec: Record "Bin Content";
        Location_lRec: Record Location;
        ItemJnlLine_lRec: Record "Item Journal Line";
        ItemJnlLine2_lRec: Record "Item Journal Line";
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        PurchHeader_lRec: Record "Purchase Header";
        ProdQCMgmt_lCdu: Codeunit "Quality Control - Production";
        ReservationEntry_lRec: Record "Reservation Entry";
        ModifyReservationEntry_lRec: Record "Reservation Entry";
        QCReservationEntry_lRec: Record "QC Reservation Entry";
        ItemJnlLine3_lRec: Record "Item Journal Line";
        BkpReservationEntry_lRecTmp: Record "Reservation Entry" temporary;
        AcceptIJL_lRec: Record "Item Journal Line";
        AcceptWithDevIJL_lRec: Record "Item Journal Line";
        RejectIJL_lRec: Record "Item Journal Line";
        ReworkIJL_lRec: Record "Item Journal Line";
        Item_lRec: Record Item;
        SingFactor_lInt: Integer;
        Result_lOpt: Option ACCEPT,REJECT,REWORK;
        CalRunTime_lDec: Decimal;
        SetupTime_lDec: Decimal;
        CreateReworkProdOrderQC_lCdu: Codeunit "Create Rework Prod. Order QC";
        ProductionOrder_lRec: Record "Production Order";//T12113-ABA-N
        QualityControlSalesOrderMgmt_lCdu: Codeunit "Quality Control - Sales";
        QualityControlPreRceiptMgmt_lCdu: Codeunit "Quality Control Pre-Receipt";//T12547-N      
        ProdOrderRtngLine_lRec: Record "Prod. Order Routing Line";
    begin
        //CONSISTENT(FALSE);  //Temp
        //Created Function to Post QC Receipt.
        //I-C0009-1001310-04-NS
        //T12212-NS
        QCSetup_gRec.get;
        if (QCSetup_gRec."Enable QC Approval") and (QCSetup_gRec."Specific for Rejection") and (rec."Quantity to Reject" > 0) then
            TestField(Approve, true)
        else if (QCSetup_gRec."Enable QC Approval") and not (QCSetup_gRec."Specific for Rejection") then
            TestField(Approve, true);

        //T12212-NE

        //T52614-NS
        NewQCRcptLine_lRec.Reset();
        NewQCRcptLine_lRec.SetRange("No.", Rec."No.");
        NewQCRcptLine_lRec.SetFilter("Decimal Places", '<> %1', 0);
        if NewQCRcptLine_lRec.FindSet() then begin
            repeat
                CheckDecimalPlace_lFnc(NewQCRcptLine_lRec);
            until NewQCRcptLine_lRec.Next() = 0;
        end;
        //T52614-NE

        //T12113-ABA-NS
        ProductionOrder_lRec.reset;
        ProductionOrder_lRec.SetRange("QC Receipt No", Rec."No.");
        ProductionOrder_lRec.SetRange("Quality Order", true);
        if ProductionOrder_lRec.FindSet() then
            repeat
                if ProductionOrder_lRec.Status <> ProductionOrder_lRec.Status::Finished then
                    Error('Production Order Status must be Finished against QC Receipt No. %1', ProductionOrder_lRec."QC Receipt No");
            until ProductionOrder_lRec.next = 0;
        //T12113-ABA-NE


        CheckTablePermission_lFnc;

        // if QCSetup_gRec."QC Movement Based on BIN" then begin
        //     if ("Quantity to Accept" <> 0) or ("Qty to Accept with Deviation" <> 0) then
        //         TestField("Store Bin Code");
        //     if "Quantity to Reject" <> 0 then
        //         TestField("Reject Bin Code");
        //     if "Quantity to Rework" <> 0 then
        //         TestField("Rework Bin Code");
        // end else begin
        if ("Quantity to Accept" <> 0) or ("Qty to Accept with Deviation" <> 0) then
            TestField("Store Location Code");
        if "Quantity to Reject" <> 0 then
            TestField("Rejection Location");
        if "Quantity to Rework" <> 0 then
            TestField("Rework Location");
        // end;

        if SkipConfirm then
            if not Confirm(Text0005_gCtx) then
                exit;

        if "Document Type" = "document type"::Purchase then begin
            if ("Qty to Accept with Deviation" = 0) and ("Quantity to Accept" = 0) and ("Quantity to Reject" = 0) and ("Quantity to Rework" = 0) then
                Error(Text0004_gCtx, "No.");
        end else
            if "Document Type" = "document type"::Production then begin
                if ("Qty to Accept with Deviation" = 0) and ("Quantity to Accept" = 0) and ("Quantity to Reject" = 0) and ("Quantity to Rework" = 0) then
                    Error('');
            end else
                if "Document Type" = "document type"::"Sales Return" then begin
                    if ("Qty to Accept with Deviation" = 0) and ("Quantity to Accept" = 0) and ("Quantity to Reject" = 0) and ("Quantity to Rework" = 0) then
                        Error(Text0004_gCtx, "No.");
                end else
                    if "Document Type" = "document type"::"Transfer Receipt" then begin
                        if ("Qty to Accept with Deviation" = 0) and ("Quantity to Accept" = 0) and ("Quantity to Reject" = 0) and ("Quantity to Rework" = 0) then
                            Error(Text0004_gCtx, "No.");
                    end else
                        if ("Document Type" = "Document type"::"Sales Order") or ("Document Type" = "Document type"::"Purchase Pre-Receipt") then begin
                            //if "Document Type" = "Document type"::"Sales Order" then begin
                            if ("Qty to Accept with Deviation" = 0) and ("Quantity to Accept" = 0) and ("Quantity to Reject" = 0) and ("Quantity to Rework" = 0) then
                                Error(Text0004_gCtx, "No.");
                        end;

        //Posting in Posted Purch. Rcpt Line
        if "Document Type" = "document type"::Purchase then begin
            CreatePostedQCRcpt_lFnc;

            Location_lRec.Get("Location Code");
            if Location_lRec."Require Put-away" or Location_lRec."Require Pick" or Location_lRec."Directed Put-away and Pick" then begin
                ReInitVariable_lFnc;
                exit;
            end;
            if PurchHeader_lRec.Get(PurchHeader_lRec."document type"::Order, "Purchase Order No.") then;

            //if not PurchHeader_lRec.Subcontracting then begin
            ItemLdgrEntry_gRec.Reset;
            ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Purchase Receipt");
            ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
            ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
            // end else begin
            //     ItemLdgrEntry_gRec.SetRange("Entry Type", ItemLdgrEntry_gRec."entry type"::Output);
            //     ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::" ");
            //     ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
            //     ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");

            //     PurchRcptLine_lRec.Reset;
            //     PurchRcptLine_lRec.SetRange("Document No.", "Document No.");
            //     PurchRcptLine_lRec.SetRange("Line No.", "Document Line No.");
            //     if PurchRcptLine_lRec.FindFirst then begin
            //         if (PurchRcptLine_lRec."Prod. Order No." <> '') and (PurchRcptLine_lRec."Prod. Order Line No." <> 0) then begin
            //             ItemLdgrEntry_gRec.Setfilter("Document No.", '%1|%2', PurchRcptLine_lRec."Document No.", PurchRcptLine_lRec."Prod. Order No.");
            //             ItemLdgrEntry_gRec.Setfilter("Document Line No.", '%1|%2', "Document Line No.", 0);
            //             ItemLdgrEntry_gRec.SETRANGE("Order No.", PurchRcptLine_lRec."Prod. Order No.");
            //             ItemLdgrEntry_gRec.SETRANGE("Order Line No.", PurchRcptLine_lRec."Prod. Order Line No.");
            //         End;
            //     end;

            //end;

            if "Vendor Lot No." <> '' then
                ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");

            if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No."] then begin
                ItemLdgrEntry_gRec.SetFilter("Remaining Quantity", '>%1', 0);
                ItemLdgrEntry_gRec.SetRange(Open, true);
            end;
            ItemLdgrEntry_gRec.SetRange(Open, true);

            if ItemLdgrEntry_gRec.FindSet then begin

                //T51170-N
                if "Item Tracking" = "item tracking"::None then begin
                    CheckEnteredResult_lFnc(ItemLdgrEntry_gRec);
                    QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_gRec);
                    ReInitVariable_lFnc;
                end else
                    if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No.", "item tracking"::"Lot No."] then begin
                        CheckEnteredResult_lFnc(ItemLdgrEntry_gRec);
                        ItemLdgrEntry_gRec.FindSet;   //I-C0009-1001310-11-N
                        repeat
                            if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" > Abs(ItemLdgrEntry_gRec."Remaining Quantity") then
                                Error('Total result quanity (%1) cannot be morethan available quantity %2, check the Tracking Result',
                                   ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity", Abs(ItemLdgrEntry_gRec."Remaining Quantity"));

                            //IF ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" = 0 THEN
                            //  ERROR('Enter Result in Item Tracking for Item Ledger Entry No. %1',ItemLdgrEntry_gRec."Entry No.");

                            if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" > 0 then begin
                                QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::ACCEPT, ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty");
                            end;

                            if ItemLdgrEntry_gRec."Rejected Quantity" > 0 then begin
                                QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REJECT, ItemLdgrEntry_gRec."Rejected Quantity");
                            end;

                            if ItemLdgrEntry_gRec."Rework Quantity" > 0 then begin
                                QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REWORK, ItemLdgrEntry_gRec."Rework Quantity");
                            end;
                        until ItemLdgrEntry_gRec.Next = 0;
                        if IJLCreated_gBol then //T12750-N
                            PostItemJnlLine_lFnc();
                        ReInitVariable_lFnc;
                    end;
            end else
                Error('Item Ledger Entry Not found for QC = %1', "No.");

            PurchRcptLine_lRec.Reset;
            PurchRcptLine_lRec.SetRange("Document No.", "Document No.");
            PurchRcptLine_lRec.SetRange("Line No.", "Document Line No.");
            if PurchRcptLine_lRec.FindFirst then begin
                if (PurchRcptLine_lRec."Prod. Order No." <> '') and (PurchRcptLine_lRec."Prod. Order Line No." <> 0) then begin
                    UpdateCapacityLdgrEntry_lFnc();
                    ReInitVariable_lFnc;
                end;
            end;
        end else
            if "Document Type" = "document type"::Production then begin
                //QCV4-NS
                //Posting in Output Journal
                if "Inspection Quantity" <> ("Quantity to Accept" + "Qty to Accept with Deviation" +
                                                         "Quantity to Rework" + "Quantity to Reject")
                then
                    Error(Text0014_gCtx);
                //T12212-ABA-NS
                QCSetup_gRec.Get;
                if ItemJnlLine_lRec.Get("Item Journal Template Name", "Item General Batch Name", "Item Journal Line No.") then begin
                    if QCSetup_gRec."Automatic Posting of Prod QC" then begin
                        if (ItemJnlLine_lRec."Run Time" = 0) or (ItemJnlLine_lRec."Setup Time" = 0) then begin
                            if not Confirm(Text00018_gCtx) then
                                exit;

                        end;
                    end;
                end;
                //T12212-ABA-NE
                //QCV3-NS  30-01-18
                Item_lRec.Get("Item No.");
                if Item_lRec."Item Tracking Code" <> '' then
                    ProdQCMgmt_lCdu.CheckEnterResult_gFnc(Rec);
                //QCV3-NE  30-01-18


                CreatePostedQCRcpt_lFnc;

                //QCV3-NS 30-01-18
                //Copy Item Tracking Lines
                ProdQCMgmt_lCdu.InsertReservationEntryIntoQCReservation_gFnc(Rec, PostedQCRecptNo_gCod);
                //QCV3-NE 30-01-18

                //TakeBkpReservatiob-NS
                BkpReservationEntry_lRecTmp.Reset;
                ReservationEntry_lRec.Reset;
                ReservationEntry_lRec.SetRange("Source Batch Name", "Item General Batch Name");
                ReservationEntry_lRec.SetRange("Source ID", "Item Journal Template Name");
                ReservationEntry_lRec.SetRange("Source Type", 83);
                ReservationEntry_lRec.SetRange("Source Ref. No.", "Item Journal Line No.");
                if ReservationEntry_lRec.FindSet then begin
                    repeat
                        BkpReservationEntry_lRecTmp.Init;
                        BkpReservationEntry_lRecTmp := ReservationEntry_lRec;
                        BkpReservationEntry_lRecTmp.Insert;
                        ReservationEntry_lRec.Delete;
                    until ReservationEntry_lRec.Next = 0;
                end;
                //TakeBkpReservatiob-NE

                if ItemJnlLine_lRec.Get("Item Journal Template Name", "Item General Batch Name", "Item Journal Line No.") then begin
                    ItemJnlLine_lRec."Quantity Under Inspection" := ItemJnlLine_lRec."Quantity Under Inspection" -
                                                                    ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework");
                    ItemJnlLine_lRec."Accepted Quantity" := 0;
                    ItemJnlLine_lRec."Qty Accepted with Deviation" := 0;
                    ItemJnlLine_lRec."Rework Quantity" := 0;
                    ItemJnlLine_lRec."Reject Quantity" := 0;
                    ItemJnlLine_lRec.Validate("Scrap Quantity", 0);
                    ItemJnlLine_lRec."QC No." := "No.";
                    ItemJnlLine_lRec."Posted QC No." := PostedQCRecptNo_gCod;
                    ItemJnlLine_lRec."Skip Confirm Msg" := true;
                    ItemJnlLine_lRec.Modify;

                    if ("Quantity to Accept") > 0 then begin
                        AcceptIJL_lRec.Init;
                        AcceptIJL_lRec := ItemJnlLine_lRec;
                        AcceptIJL_lRec."Line No." := ItemJnlLine_lRec."Line No." + 2;
                        AcceptIJL_lRec."Skip Confirm Msg" := true;
                        AcceptIJL_lRec.Insert;

                        AcceptIJL_lRec."Accepted Quantity" := "Quantity to Accept";
                        AcceptIJL_lRec."Qty Accepted with Deviation" := 0;
                        AcceptIJL_lRec.Validate("Output Quantity", "Quantity to Accept");

                        CalRunTime_lDec := (AcceptIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                        AcceptIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                        SetupTime_lDec := (AcceptIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                        AcceptIJL_lRec.Validate("Setup Time", SetupTime_lDec);

                        AcceptIJL_lRec.Modify;

                        //TakeBkpReservatiob-NS
                        BkpReservationEntry_lRecTmp.Reset;
                        BkpReservationEntry_lRecTmp.Reset;
                        BkpReservationEntry_lRecTmp.SetRange("Source Batch Name", ItemJnlLine_lRec."Journal Batch Name");
                        BkpReservationEntry_lRecTmp.SetRange("Source ID", ItemJnlLine_lRec."Journal Template Name");
                        BkpReservationEntry_lRecTmp.SetRange("Source Type", 83);
                        BkpReservationEntry_lRecTmp.SetRange("Source Ref. No.", ItemJnlLine_lRec."Line No.");
                        if BkpReservationEntry_lRecTmp.FindSet then begin
                            repeat
                                if BkpReservationEntry_lRecTmp."Accepted Quantity" <> 0 then begin
                                    if BkpReservationEntry_lRecTmp."Quantity (Base)" < 0 then
                                        SingFactor_lInt := -1
                                    else
                                        SingFactor_lInt := 1;

                                    ReservationEntry_lRec.Init;
                                    ReservationEntry_lRec := BkpReservationEntry_lRecTmp;
                                    ReservationEntry_lRec."Entry No." := ReservationEntry_lRec.GetNextEntryNo_gFnc;
                                    ReservationEntry_lRec."Source Ref. No." := AcceptIJL_lRec."Line No.";
                                    ReservationEntry_lRec.Validate("Quantity (Base)", SingFactor_lInt * BkpReservationEntry_lRecTmp."Accepted Quantity");
                                    ReservationEntry_lRec.Insert;
                                end;
                            until BkpReservationEntry_lRecTmp.Next = 0;
                        end;
                        //TakeBkpReservatiob-NE
                    end;


                    if "Qty to Accept with Deviation" > 0 then begin
                        AcceptIJL_lRec.Init;
                        AcceptWithDevIJL_lRec := ItemJnlLine_lRec;
                        AcceptWithDevIJL_lRec."Line No." := ItemJnlLine_lRec."Line No." + 3;
                        AcceptWithDevIJL_lRec."Skip Confirm Msg" := true;
                        AcceptWithDevIJL_lRec.Insert;

                        AcceptWithDevIJL_lRec."Accepted Quantity" := 0;
                        AcceptWithDevIJL_lRec."Qty Accepted with Deviation" := "Qty to Accept with Deviation";
                        AcceptWithDevIJL_lRec.Validate("Output Quantity", "Qty to Accept with Deviation");

                        CalRunTime_lDec := (AcceptWithDevIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                        AcceptWithDevIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                        SetupTime_lDec := (AcceptWithDevIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                        AcceptWithDevIJL_lRec.Validate("Setup Time", SetupTime_lDec);

                        AcceptWithDevIJL_lRec.Modify;

                        //TakeBkpReservatiob-NS
                        BkpReservationEntry_lRecTmp.Reset;
                        BkpReservationEntry_lRecTmp.Reset;
                        BkpReservationEntry_lRecTmp.SetRange("Source Batch Name", ItemJnlLine_lRec."Journal Batch Name");
                        BkpReservationEntry_lRecTmp.SetRange("Source ID", ItemJnlLine_lRec."Journal Template Name");
                        BkpReservationEntry_lRecTmp.SetRange("Source Type", 83);
                        BkpReservationEntry_lRecTmp.SetRange("Source Ref. No.", ItemJnlLine_lRec."Line No.");
                        if BkpReservationEntry_lRecTmp.FindSet then begin
                            repeat
                                if BkpReservationEntry_lRecTmp."Accepted with Deviation Qty" <> 0 then begin
                                    if BkpReservationEntry_lRecTmp."Quantity (Base)" < 0 then
                                        SingFactor_lInt := -1
                                    else
                                        SingFactor_lInt := 1;

                                    ReservationEntry_lRec.Init;
                                    ReservationEntry_lRec := BkpReservationEntry_lRecTmp;
                                    ReservationEntry_lRec."Entry No." := ReservationEntry_lRec.GetNextEntryNo_gFnc;
                                    ReservationEntry_lRec."Source Ref. No." := AcceptWithDevIJL_lRec."Line No.";
                                    ReservationEntry_lRec.Validate("Quantity (Base)", SingFactor_lInt * (BkpReservationEntry_lRecTmp."Accepted with Deviation Qty"));
                                    ReservationEntry_lRec.Insert;
                                end;
                            until BkpReservationEntry_lRecTmp.Next = 0;
                        end;
                        //TakeBkpReservatiob-NE
                    end;



                    if "Quantity to Reject" > 0 then begin
                        RejectIJL_lRec.Init;
                        RejectIJL_lRec := ItemJnlLine_lRec;
                        RejectIJL_lRec."Line No." := ItemJnlLine_lRec."Line No." + 4;
                        RejectIJL_lRec."Skip Confirm Msg" := true;
                        RejectIJL_lRec.Insert;

                        RejectIJL_lRec."Reject Quantity" := "Quantity to Reject";
                        if QCSetup_gRec."Book Out for RejQty Production" then begin
                            RejectIJL_lRec.Validate("Scrap Quantity", 0);
                            RejectIJL_lRec.Validate("Output Quantity", "Quantity to Reject");
                        end else begin
                            RejectIJL_lRec.Validate("Output Quantity", 0);
                            RejectIJL_lRec.Validate("Scrap Quantity", "Quantity to Reject");
                        end;
                        //T12113-NS
                        RejectIJL_lRec.Validate("Rejection Reason", "Rejection Reason");
                        RejectIJL_lRec.Validate("Rejection Reason Description", "Rejection Reason Description");
                        //T12113-NE
                        // if QCSetup_gRec."QC Block without Location" then begin
                        //     RejectIJL_lRec.Validate("Location Code", "QC Location");
                        //     RejectIJL_lRec.Validate("Bin Code", "Reject Bin Code");
                        // end else begin
                        TestField("Rejection Location");
                        RejectIJL_lRec.Validate("Location Code", "Rejection Location");
                        RejectIJL_lRec.Validate("Bin Code", "Reject Bin Code");
                        // end;

                        if QCSetup_gRec."Book Out for RejQty Production" then begin
                            CalRunTime_lDec := (RejectIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                            RejectIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                            SetupTime_lDec := (RejectIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                            RejectIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                        end else begin
                            CalRunTime_lDec := (RejectIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                            RejectIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                            SetupTime_lDec := (RejectIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                            RejectIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                        end;

                        RejectIJL_lRec.Modify;

                        //TakeBkpReservatiob-NS
                        if QCSetup_gRec."Book Out for RejQty Production" then begin
                            BkpReservationEntry_lRecTmp.Reset;
                            BkpReservationEntry_lRecTmp.Reset;
                            BkpReservationEntry_lRecTmp.SetRange("Source Batch Name", ItemJnlLine_lRec."Journal Batch Name");
                            BkpReservationEntry_lRecTmp.SetRange("Source ID", ItemJnlLine_lRec."Journal Template Name");
                            BkpReservationEntry_lRecTmp.SetRange("Source Type", 83);
                            BkpReservationEntry_lRecTmp.SetRange("Source Ref. No.", ItemJnlLine_lRec."Line No.");
                            BkpReservationEntry_lRecTmp.SetFilter("Rejected Quantity", '<>%1', 0);
                            if BkpReservationEntry_lRecTmp.FindSet then begin
                                repeat
                                    if BkpReservationEntry_lRecTmp."Quantity (Base)" < 0 then
                                        SingFactor_lInt := -1
                                    else
                                        SingFactor_lInt := 1;

                                    ReservationEntry_lRec.Init;
                                    ReservationEntry_lRec := BkpReservationEntry_lRecTmp;
                                    ReservationEntry_lRec."Entry No." := ReservationEntry_lRec.GetNextEntryNo_gFnc;
                                    ReservationEntry_lRec."Source Ref. No." := RejectIJL_lRec."Line No.";
                                    ReservationEntry_lRec."Location Code" := RejectIJL_lRec."Location Code";
                                    ReservationEntry_lRec.Validate("Quantity (Base)", (SingFactor_lInt) * BkpReservationEntry_lRecTmp."Rejected Quantity");
                                    ReservationEntry_lRec.Insert;
                                until BkpReservationEntry_lRecTmp.Next = 0;
                            end;
                        end;
                        //TakeBkpReservatiob-NE
                    end;


                    if "Quantity to Rework" > 0 then begin
                        ReworkIJL_lRec.Init;
                        ReworkIJL_lRec := ItemJnlLine_lRec;
                        ReworkIJL_lRec."Line No." := ItemJnlLine_lRec."Line No." + 6;
                        ReworkIJL_lRec."Skip Confirm Msg" := true;
                        ReworkIJL_lRec.Insert;

                        ReworkIJL_lRec."Rework Quantity" := "Quantity to Rework";
                        //T12971-OS
                        // if QCSetup_gRec."Book Out for RewQty Production" then begin
                        //     ReworkIJL_lRec.Validate("Output Quantity", "Quantity to Rework");
                        //     ReworkIJL_lRec.Validate("Scrap Quantity", 0);
                        // end else begin
                        //     ReworkIJL_lRec.Validate("Output Quantity", 0);
                        //     ReworkIJL_lRec.Validate("Scrap Quantity", "Quantity to Rework");
                        // end;
                        //T12971-OE
                        //T12971-NS
                        ProdOrderRtngLine_lRec.reset;
                        ProdOrderRtngLine_lRec.SetRange(Status, ProdOrderRtngLine_lRec.Status::Released);
                        ProdOrderRtngLine_lRec.SetRange("Prod. Order No.", "Document No.");
                        ProdOrderRtngLine_lRec.SetRange("Operation No.", "Operation No.");
                        ProdOrderRtngLine_lRec.SetRange("Routing Reference No.", "Document Line No.");
                        if ProdOrderRtngLine_lRec.FindFirst then begin
                            if (ProdOrderRtngLine_lRec."Next Operation No." = '') then begin
                                if QCSetup_gRec."Book Out for RewQty Production" then begin
                                    ReworkIJL_lRec.Validate("Output Quantity", "Quantity to Rework");
                                    ReworkIJL_lRec.Validate("Scrap Quantity", 0);
                                    if QCSetup_gRec."Rework Location Pro. Order" <> '' then begin
                                        ReworkIJL_lRec.Validate("Location Code", QCSetup_gRec."Rework Location Pro. Order");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end else begin
                                        TestField("Rework Location");
                                        ReworkIJL_lRec.Validate("Location Code", "Rework Location");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end;
                                    CalRunTime_lDec := (ReworkIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                                    SetupTime_lDec := (ReworkIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                                end else begin
                                    ReworkIJL_lRec.Validate("Output Quantity", 0);
                                    ReworkIJL_lRec.Validate("Scrap Quantity", "Quantity to Rework");
                                    if QCSetup_gRec."Rework Location Pro. Order" <> '' then begin
                                        ReworkIJL_lRec.Validate("Location Code", QCSetup_gRec."Rework Location Pro. Order");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end else begin
                                        TestField("Rework Location");
                                        ReworkIJL_lRec.Validate("Location Code", "Rework Location");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end;
                                    CalRunTime_lDec := (ReworkIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                                    SetupTime_lDec := (ReworkIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                                end;
                            end else begin
                                if QCSetup_gRec."Book Out for RewQty Production" then begin
                                    ReworkIJL_lRec.Validate("Output Quantity", 0);
                                    ReworkIJL_lRec.Validate("Scrap Quantity", 0);
                                    if QCSetup_gRec."Rework Location Pro. Order" <> '' then begin
                                        ReworkIJL_lRec.Validate("Location Code", QCSetup_gRec."Rework Location Pro. Order");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end else begin
                                        TestField("Rework Location");
                                        ReworkIJL_lRec.Validate("Location Code", "Rework Location");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end;
                                    CalRunTime_lDec := (ReworkIJL_lRec."Rework Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                                    SetupTime_lDec := (ReworkIJL_lRec."Rework Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                                end else begin
                                    ReworkIJL_lRec.Validate("Output Quantity", 0);
                                    ReworkIJL_lRec.Validate("Scrap Quantity", "Quantity to Rework");
                                    if QCSetup_gRec."Rework Location Pro. Order" <> '' then begin
                                        ReworkIJL_lRec.Validate("Location Code", QCSetup_gRec."Rework Location Pro. Order");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end else begin
                                        TestField("Rework Location");
                                        ReworkIJL_lRec.Validate("Location Code", "Rework Location");
                                        ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                                    end;
                                    CalRunTime_lDec := (ReworkIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                                    SetupTime_lDec := (ReworkIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                                    ReworkIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                                end;
                            end;
                        end;
                        //T12971-NE
                        //T13091-NS
                        // if QCSetup_gRec."Rework Location Pro. Order" <> '' then begin
                        //     ReworkIJL_lRec.Validate("Location Code", QCSetup_gRec."Rework Location Pro. Order");
                        //     ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                        // end else begin
                        //     TestField("Rework Location");
                        //     ReworkIJL_lRec.Validate("Location Code", "Rework Location");
                        //     ReworkIJL_lRec.Validate("Bin Code", "Rework Bin Code");
                        // end;
                        //T13091-NE

                        // if QCSetup_gRec."Book Out for RewQty Production" then begin
                        //     CalRunTime_lDec := (ReworkIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                        //     ReworkIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                        //     SetupTime_lDec := (ReworkIJL_lRec."Output Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                        //     ReworkIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                        // end else begin
                        //     CalRunTime_lDec := (ReworkIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Run Time") / ItemJnlLine_lRec."Output Quantity";
                        //     ReworkIJL_lRec.Validate("Run Time", CalRunTime_lDec);

                        //     SetupTime_lDec := (ReworkIJL_lRec."Scrap Quantity" * ItemJnlLine_lRec."Setup Time") / ItemJnlLine_lRec."Output Quantity";
                        //     ReworkIJL_lRec.Validate("Setup Time", SetupTime_lDec);
                        // end;

                        ReworkIJL_lRec.Modify;

                        //TakeBkpReservatiob-NS
                        if QCSetup_gRec."Book Out for RewQty Production" then begin
                            BkpReservationEntry_lRecTmp.Reset;
                            BkpReservationEntry_lRecTmp.Reset;
                            BkpReservationEntry_lRecTmp.SetRange("Source Batch Name", ItemJnlLine_lRec."Journal Batch Name");
                            BkpReservationEntry_lRecTmp.SetRange("Source ID", ItemJnlLine_lRec."Journal Template Name");
                            BkpReservationEntry_lRecTmp.SetRange("Source Type", 83);
                            BkpReservationEntry_lRecTmp.SetRange("Source Ref. No.", ItemJnlLine_lRec."Line No.");
                            BkpReservationEntry_lRecTmp.SetFilter("Rework Quantity", '<>%1', 0);
                            if BkpReservationEntry_lRecTmp.FindSet then begin
                                repeat

                                    if BkpReservationEntry_lRecTmp."Quantity (Base)" < 0 then
                                        SingFactor_lInt := -1
                                    else
                                        SingFactor_lInt := 1;

                                    ReservationEntry_lRec.Init;
                                    ReservationEntry_lRec := BkpReservationEntry_lRecTmp;
                                    ReservationEntry_lRec."Entry No." := ReservationEntry_lRec.GetNextEntryNo_gFnc;
                                    ReservationEntry_lRec."Source Ref. No." := ReworkIJL_lRec."Line No.";
                                    ReservationEntry_lRec."Location Code" := ReworkIJL_lRec."Location Code";
                                    ReservationEntry_lRec.Validate("Quantity (Base)", (SingFactor_lInt) * BkpReservationEntry_lRecTmp."Rework Quantity");
                                    ReservationEntry_lRec.Insert;
                                until BkpReservationEntry_lRecTmp.Next = 0;
                            end;
                        end;
                        //TakeBkpReservatiob-NE
                    end;
                    ItemJnlLine_lRec.Delete(false);  //Delete the main line and create 3 new lines  for (Accept, Rework and Reject)

                    ItemJnlLine_lRec.Reset;
                    ItemJnlLine_lRec.SetRange("Journal Template Name", "Item Journal Template Name");
                    ItemJnlLine_lRec.SetRange("Journal Batch Name", "Item General Batch Name");
                    ItemJnlLine_lRec.SetRange("QC No.", "No."); //QCV3-N 24-01-18
                    ItemJnlLine_lRec.FindFirst;

                    if QCSetup_gRec."Automatic Posting of Prod QC" then
                        Codeunit.Run(Codeunit::"Item Jnl.-Post", ItemJnlLine_lRec);



                    ReInitVariable_lFnc;
                end else begin
                    "Remaining Quantity" := 0;  //Delete QC Receipt if Item Journal Line Deleted
                    ReInitVariable_lFnc;
                end;
                //END;    //I-C0009-1001310-05-O
                //I-C0009-1001310-05-NS
                //QCV4-NE

                //T07638-NS
                Clear(CreateReworkProdOrderQC_lCdu);
                CreateReworkProdOrderQC_lCdu.CreateProdOrder_gFnc(PostedQCRcptHead_gRec);
                //T07638-NE
            end else
                if "Document Type" = "Document type"::"Sales Return" then begin
                    CreatePostedQCRcpt_lFnc;
                    //PostSalesReturnQCRcpt_gFnc; //T12113-O
                    PostSalesReturnQCRcptREDEV_gFnc;//T12113-N 
                                                    //END;  //I-C0009-1001310-06-O
                                                    //I-C0009-1001310-05-NE
                                                    //I-C0009-1001310-06-NS
                end else
                    if "Document Type" = "Document type"::"Transfer Receipt" then begin
                        CreatePostedQCRcpt_lFnc;
                        PostTransferQCRcpt_gFnc;
                    end else
                        if "Document Type" = "Document type"::"Sales Order" then begin
                            CheckRemainingQtyForSalesOrderQC_lFnc;
                            CheckPartialQtyForLotItemQC_lFnc;
                            CreatePostedQCRcpt_lFnc;
                            QualityControlSalesOrderMgmt_lCdu.InsertReservationEntryIntoQCReservation_gFnc(Rec, PostedQCRecptNo_gCod);//21082024
                            if "Quantity to Reject" > 0 then
                                DeleteReservationEntryforSOQC(Rec);
                            ReInitVariable_lFnc();
                        end else
                            if "Document Type" = "Document type"::Ile then begin
                                CreatePostedQCRcpt_lFnc;
                                PostTransferILEQCRcpt_gFnc;
                            end else
                                //T12547-NS
                                if "Document Type" = "Document type"::"Purchase Pre-Receipt" then begin
                                    CheckRemainingQtyForSalesOrderQC_lFnc;
                                    CheckPartialQtyForLotItemQC_lFnc;
                                    CreatePostedQCRcpt_lFnc;
                                    QualityControlPreRceiptMgmt_lCdu.InsertReservationEntryIntoQCReservation_gFnc(Rec, PostedQCRecptNo_gCod);
                                    if "Quantity to Reject" > 0 then
                                        QualityControlPreRceiptMgmt_lCdu.DeleteReservationEntryforPreReceiptQC(Rec);
                                    ReInitVariable_lFnc();
                                    //T12547-NE
                                end;

        //I-C0009-1001310-06-NE

        //I-C0009-1001310-04-NE
    end;

    procedure QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_iRec: Record "Item Ledger Entry")
    var
        BinContent_lRec: Record "Bin Content";
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        //Written Funciton to Posted "QC Receipt" for Items having "Lot No."/Without "Lot No."
        //I-C0009-1001310-02 NS
        if "Item Tracking" = "item tracking"::"Lot No." then
            CheckLotSerialExistsinBin_lFnc(ItemLdgrEntry_iRec); //Checking Lot No. is available in Warehouse or Not.

        if CheckBinMandatory_lFnc("QC Location") then begin
            BinContent_lRec.Reset;
            BinContent_lRec.SetRange("Location Code", "QC Location");
            BinContent_lRec.SetRange("Bin Code", "QC Bin Code");
            BinContent_lRec.SetRange("Item No.", "Item No.");
            if "Variant Code" <> '' then
                BinContent_lRec.SetRange("Variant Code", "Variant Code");
            if BinContent_lRec.FindFirst then begin
                BinContent_lRec.CalcFields(Quantity);
                if (BinContent_lRec.Quantity < ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject"
                                                 + "Quantity to Rework"))
                then
                    Error(Text0009_gCtx, BinContent_lRec."Item No.", BinContent_lRec."Location Code", BinContent_lRec."Bin Code");
            end else
                Error(Text0009_gCtx, "Item No.", "QC Location", "QC Bin Code");
        end;

        if (ItemLdgrEntry_iRec."Remaining Quantity" < ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" +
                                                       +"Quantity to Rework"))
        then
            Error(Text0010_gCtx, "Item No.", ItemLdgrEntry_iRec."Entry No.");

        Clear(IJLCreated_gBol);//T12750-N
        if (not QCSetup_gRec."QC Block without Location") and (not ItemLedgerEntry_lRec."Material at QC") then //T12750-N 25112024
            if (("Quantity to Accept" > 0) or ("Qty to Accept with Deviation" > 0)) then
                IJLCreated_gBol := CreateItemJnlLine_lFnc(ItemLdgrEntry_iRec, Result_opt::ACCEPT, "Quantity to Accept" + "Qty to Accept with Deviation");//T12750-N add Return flag value
        if ("Quantity to Reject" > 0) then
            IJLCreated_gBol := CreateItemJnlLine_lFnc(ItemLdgrEntry_iRec, Result_opt::REJECT, "Quantity to Reject");//T12750-N
        if ("Quantity to Rework" > 0) then
            IJLCreated_gBol := CreateItemJnlLine_lFnc(ItemLdgrEntry_iRec, Result_opt::REWORK, "Quantity to Rework");//T12750-N

        ItemLedgerEntry_lRec.Get(ItemLdgrEntry_gRec."Entry No.");
        ItemLedgerEntry_lRec."Posted QC No." := PostedQCRcptHead_gRec."No.";
        //T12750-NS 25112024
        if (QCSetup_gRec."QC Block without Location") and (ItemLedgerEntry_lRec."Material at QC") then
            ItemLedgerEntry_lRec."Material at QC" := false;
        //T12750-NE 25112024
        ItemLedgerEntry_lRec.Modify;

        if IJLCreated_gBol then  //T12750-N
            PostItemJnlLine_lFnc();

    end;

    procedure QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_iRec: Record "Item Ledger Entry"; InsertEntry_vBln: Boolean; Result_iOpt: Option ACCEPT,REJECT,REWORK; Qty_iDec: Decimal)
    var
        BinContent_lRec: Record "Bin Content";
        Item_lRec: Record Item;
        ItemTrackingCode_lRec: Record "Item Tracking Code";
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        //Written Funciton to Posted "QC Receipt" for Items having "Seril No." or ("Lot No." and "Serial No.")
        //I-C0009-1001310-02 NS

        Item_lRec.Reset;
        Item_lRec.Get(ItemLdgrEntry_iRec."Item No.");
        ItemTrackingCode_lRec.Get(Item_lRec."Item Tracking Code");

        CheckLotSerialExistsinBin_lFnc(ItemLdgrEntry_iRec);

        if CheckBinMandatory_lFnc("QC Location") then begin
            BinContent_lRec.Reset;
            BinContent_lRec.SetRange("Location Code", "QC Location");
            BinContent_lRec.SetRange("Bin Code", "QC Bin Code");
            BinContent_lRec.SetRange("Item No.", "Item No.");
            if "Variant Code" <> '' then
                BinContent_lRec.SetRange("Variant Code", "Variant Code");
            if ItemTrackingCode_lRec."SN Warehouse Tracking" then
                BinContent_lRec.SetRange("Serial No. Filter", ItemLdgrEntry_iRec."Serial No.");
            if ItemTrackingCode_lRec."Lot Warehouse Tracking" then
                BinContent_lRec.SetRange("Lot No. Filter", ItemLdgrEntry_iRec."Lot No.");
            if BinContent_lRec.FindFirst then begin
                BinContent_lRec.CalcFields(Quantity);
                if not (BinContent_lRec.Quantity >= 0) then
                    Error(Text0009_gCtx, BinContent_lRec."Item No.", BinContent_lRec."Location Code", BinContent_lRec."Bin Code");
            end else
                Error(Text0009_gCtx, "Item No.", "QC Location", "QC Bin Code");
        end;

        if InsertEntry_vBln then begin
            if (ItemLdgrEntry_iRec."Remaining Quantity" >= 0) then begin
                clear(IJLCreated_gBol);//T12750-N
                                       //if Result_iOpt = Result_iopt::ACCEPT then//T12750-O
                if (Result_iOpt = Result_iopt::ACCEPT) then  //and (not QCSetup_gRec."QC Block without Location") then//T12750-N
                    IJLCreated_gBol := CreateItemJnlLine_lFnc(ItemLdgrEntry_iRec, Result_opt::ACCEPT, Qty_iDec);//T12750-N //T51170-N                
                if Result_iOpt = Result_iopt::REJECT then
                    IJLCreated_gBol := CreateItemJnlLine_lFnc(ItemLdgrEntry_iRec, Result_opt::REJECT, Qty_iDec);//T12750-N
                if Result_iOpt = Result_iopt::REWORK then
                    IJLCreated_gBol := CreateItemJnlLine_lFnc(ItemLdgrEntry_iRec, Result_opt::REWORK, Qty_iDec);//T12750-N
            end else
                Error(Text0010_gCtx, BinContent_lRec."Item No.", ItemLdgrEntry_iRec."Entry No.");
        end;

        ItemLedgerEntry_lRec.Get(ItemLdgrEntry_gRec."Entry No.");
        ItemLedgerEntry_lRec."Posted QC No." := PostedQCRcptHead_gRec."No.";
        //T12750-NS 25112024
        if (QCSetup_gRec."QC Block without Location") and (ItemLedgerEntry_lRec."Material at QC") then
            ItemLedgerEntry_lRec."Material at QC" := false;
        //T12750-NE 25112024
        ItemLedgerEntry_lRec.Modify;

        //I-C0009-1001310-04-NE
    end;


    //T51170-NS
    local procedure FindLotforExpiration_lFnc(Var ResEntry_lRec: Record "Reservation Entry"; ItemLedgEntry_iRec: Record "Item Ledger Entry")
    var
        CheckCountLedgerEntry_lRec: Record "Item Ledger Entry";
        CheckCount_lInt: Integer;
        CutUnderScoreLotStr_lInt: Code[3];
        FindIle_lRec: Record "Item Ledger Entry";

    begin
        FindIle_lRec.reset;
        FindIle_lRec.SetRange("Item No.", ItemLedgEntry_iRec."Item No.");
        FindIle_lRec.SetRange("Location Code", ItemLedgEntry_iRec."Location Code");
        FindIle_lRec.SetRange("Variant Code", ItemLedgEntry_iRec."Variant Code");
        FindIle_lRec.SetRange("Overall Changes", true);
        FindIle_lRec.Setfilter("Lot No.", '@' + '*' + ItemLedgEntry_iRec."Lot No." + '*');
        FindIle_lRec.SetRange(positive, true);
        if FindIle_lRec.FindLast then begin
            if (STRPOS(FindIle_lRec."Lot No.", '_') > 0) then begin
                CutUnderScoreLotStr_lInt := CopyStr(FindIle_lRec."Lot No.", 1, StrPos(FindIle_lRec."Lot No.", '_') - 1);
                if CutUnderScoreLotStr_lInt <> '' then
                    ResEntry_lRec.Validate("New Lot No.", (IncStr(CutUnderScoreLotStr_lInt) + '_' + CopyStr(FindIle_lRec."Lot No.", StrPos(FindIle_lRec."Lot No.", '_') + 1, MaxStrLen(FindIle_lRec."Lot No."))))
            End else
                Error('There is some issue in Logic. Please contact Admin Team');
        end else
            ResEntry_lRec.Validate("New Lot No.", ('R1_' + ItemLedgEntry_iRec."Lot No."));
    end;
    //T51170-NE

    procedure InsertReservationEntry_gFnc(var ItemJnlLine_vRec: Record "Item Journal Line"; ItemLedgEntry_iRec: Record "Item Ledger Entry"; SaveTracking_iBln: Boolean; Result_iOpt: Option ACCEPT,REJECT,REWORK)
    var
        ResEntry_lRec: Record "Reservation Entry";
        EntryNo_lInt: Integer;
        NextEntryNo_lInt: Integer;
        DelR337_lRec: Record "Reservation Entry";
        DelR337OppLag_lRec: Record "Reservation Entry";
        SaveR337_lRec: Record "Reservation Entry Save";
        DelSaveR337_lRec: Record "Reservation Entry Save";
        UniqueIDSave_lInt: Integer;
        //T51170-NS
        ExpDate_lDte: Date;
        DateDiff_iInt: Integer;
        ConvertDate_lTxt: Text;
        Dateformula_lDF: DateFormula;
    //T51170-NE
    begin
        //To Insert the Reservation Entry for Item Journal Line.
        //I-C0009-1001310-02 NS
        QCSetup_gRec.Get;
        QCSetup_gRec.TestField("QC Journal Template Name");
        QCSetup_gRec.TestField("QC General Batch Name");

        if ResEntry_lRec.FindLast then
            EntryNo_lInt := ResEntry_lRec."Entry No." + 1
        else
            EntryNo_lInt := 1;

        ResEntry_lRec.Lock;
        ResEntry_lRec.Init;
        ResEntry_lRec."Entry No." := EntryNo_lInt;

        ResEntry_lRec.Validate("Item No.", "Item No.");
        ResEntry_lRec.Validate("Variant Code", "Variant Code");
        ResEntry_lRec.Validate("Location Code", ItemLedgEntry_iRec."Location Code");
        if ItemJnlLine_vRec."Variant Code" <> '' then
            ResEntry_lRec.Validate("Variant Code", ItemJnlLine_vRec."Variant Code");

        ResEntry_lRec."Source Type" := Database::"Item Journal Line";
        ResEntry_lRec."Source Subtype" := ItemJnlLine_vRec."Entry Type".AsInteger();
        ResEntry_lRec."Source ID" := QCSetup_gRec."QC Journal Template Name";
        ResEntry_lRec."Source Batch Name" := QCSetup_gRec."QC General Batch Name";
        ResEntry_lRec."Source Ref. No." := ItemJnlLine_vRec."Line No.";
        ResEntry_lRec."Creation Date" := ItemJnlLine_vRec."Posting Date";
        //T12113-NS
        //if CheckWarrantyDateExist_lFnc(ItemLedgEntry_iRec) then
        if (ItemLedgEntry_iRec."Warranty Date" <> 0D) and ("Mfg. Date" <> 0D) and (ItemLedgEntry_iRec."Warranty Date" <> "Mfg. Date") then
            ResEntry_lRec."Warranty Date" := "Mfg. Date"
        else if (ResEntry_lRec."Warranty Date" = 0D) and (ItemLedgEntry_iRec."Warranty Date" <> 0D) then
            ResEntry_lRec."Warranty Date" := ItemLedgEntry_iRec."Warranty Date";

        Clear(ExpDate_lDte);

        ResEntry_lRec."Manufacturing Date 2" := ResEntry_lRec."Warranty Date";
        ResEntry_lRec."Supplier Batch No. 2" := ItemLedgEntry_iRec."Supplier Batch No. 2";



        if CheckExpirationDateExist_lFnc(ItemLedgEntry_iRec) then begin
            ResEntry_lRec."Expiration Date" := ItemLedgEntry_iRec."Expiration Date";
            /* ResEntry_lRec."New Expiration Date" := ItemLedgEntry_iRec."Expiration Date";
        end else if not CheckExpirationDateExist_lFnc(ItemLedgEntry_iRec) then begin
            //T12113-NE       
            ResEntry_lRec."Expiration Date" := "Exp. Date"; */ //T51170-N
            ResEntry_lRec."New Expiration Date" := "Exp. Date";
        End;//T12113-N

        Clear(DateDiff_iInt);
        Clear(ConvertDate_lTxt);
        Clear(Dateformula_lDF);

        if (ResEntry_lRec."New Expiration Date" <> 0D) and (ResEntry_lRec."Warranty Date" <> 0D) then begin
            DateDiff_iInt := ResEntry_lRec."New Expiration Date" - ResEntry_lRec."Warranty Date";//Warranty Date is manufacturing Date 
            ConvertDate_lTxt := Format(ABS(DateDiff_iInt)) + 'D';
            if Evaluate(Dateformula_lDF, ConvertDate_lTxt) then
                ResEntry_lRec."Expiry Period 2" := Dateformula_lDF;
        end;

        ResEntry_lRec."Created By" := UserId;
        if ItemLedgEntry_iRec."Lot No." <> '' then begin
            ResEntry_lRec.Validate("Lot No.", ItemLedgEntry_iRec."Lot No.");
            //T51170-NS
            if OverallChange_gBol then
                FindLotforExpiration_lFnc(ResEntry_lRec, ItemLedgEntry_iRec)
            else
                ResEntry_lRec.Validate("New Lot No.", ItemLedgEntry_iRec."Lot No.");
            //T51170-NE
        end;
        if ItemLedgEntry_iRec."Serial No." <> '' then begin
            ResEntry_lRec.Validate("Serial No.", ItemLedgEntry_iRec."Serial No.");
            ResEntry_lRec.Validate("New Serial No.", ItemLedgEntry_iRec."Serial No.");
        end;
        ResEntry_lRec."Shipment Date" := ItemLedgEntry_iRec."Posting Date";
        ResEntry_lRec."Reservation Status" := ResEntry_lRec."reservation status"::Prospect;
        ResEntry_lRec."Item Tracking" := ItemLedgEntry_iRec."Item Tracking";
        ResEntry_lRec.Quantity := -1 * ItemJnlLine_vRec.Quantity;
        ResEntry_lRec.Validate("Quantity (Base)", -1 * ItemJnlLine_vRec.Quantity);
        ResEntry_lRec."Qty. per Unit of Measure" := 1;
        ResEntry_lRec.Validate("Appl.-to Item Entry", ItemLedgEntry_iRec."Entry No."); //I-C0009-1400405-02-N       

        ResEntry_lRec.Insert;
        //I-C0009-1001310-02 NE


        //SubConQCV2-NS  //Delete the Reservation Entry and Create it again in Post Document
        if SaveTracking_iBln then begin
            ItemLedgEntry_iRec.CalcFields("Reserved Quantity");
            UniqueIDSave_lInt := 0;
            if ItemLedgEntry_iRec."Reserved Quantity" > 0 then begin
                if Result_iOpt = Result_iopt::ACCEPT then begin
                    if ItemJnlLine_vRec."Unique Batch ID in Save Res En" = 0 then begin
                        SaveR337_lRec.Reset;
                        SaveR337_lRec.SetCurrentkey("Unique Batch ID in Save Res En");
                        if SaveR337_lRec.FindLast then
                            UniqueIDSave_lInt += SaveR337_lRec."Unique Batch ID in Save Res En" + 1
                        else
                            UniqueIDSave_lInt := 1;
                    end else
                        UniqueIDSave_lInt := ItemJnlLine_vRec."Unique Batch ID in Save Res En";
                end;


                DelR337_lRec.Reset;
                DelR337_lRec.SetRange("Source ID", '');
                DelR337_lRec.SetRange("Source Ref. No.", ItemLedgEntry_iRec."Entry No.");
                DelR337_lRec.SetRange("Source Type", 32);
                DelR337_lRec.SetRange("Source Subtype", 0);
                DelR337_lRec.SetRange("Source Batch Name", '');
                DelR337_lRec.SetRange("Source Prod. Order Line", 0);
                DelR337_lRec.SetRange("Reservation Status", DelR337_lRec."reservation status"::Reservation);
                if DelR337_lRec.FindSet then begin
                    repeat
                        if DelR337OppLag_lRec.Get(DelR337_lRec."Entry No.", not DelR337_lRec.Positive) then begin
                            if UniqueIDSave_lInt > 0 then begin
                                Clear(SaveR337_lRec);
                                SaveR337_lRec.TransferFields(DelR337OppLag_lRec);
                                SaveR337_lRec."Entry No." := DelR337OppLag_lRec."Entry No.";
                                SaveR337_lRec.Positive := DelR337OppLag_lRec.Positive;
                                SaveR337_lRec."Unique Batch ID in Save Res En" := UniqueIDSave_lInt;
                                SaveR337_lRec."Remain Qty for Allocation" := Abs(SaveR337_lRec."Quantity (Base)");

                                if DelSaveR337_lRec.Get(SaveR337_lRec."Entry No.", SaveR337_lRec.Positive) then begin  //Del Line if already exists any old entry
                                    DelSaveR337_lRec.Delete
                                end;

                                SaveR337_lRec.Insert;
                            end;

                            DelR337OppLag_lRec.Delete;
                        end;

                        if UniqueIDSave_lInt > 0 then begin
                            Clear(SaveR337_lRec);
                            SaveR337_lRec.TransferFields(DelR337_lRec);
                            SaveR337_lRec."Entry No." := DelR337_lRec."Entry No.";
                            SaveR337_lRec.Positive := DelR337_lRec.Positive;
                            SaveR337_lRec."Unique Batch ID in Save Res En" := UniqueIDSave_lInt;
                            SaveR337_lRec."Remain Qty for Allocation" := Abs(SaveR337_lRec."Quantity (Base)");

                            if DelSaveR337_lRec.Get(SaveR337_lRec."Entry No.", SaveR337_lRec.Positive) then begin  //Del Line if already exists any old entry
                                DelSaveR337_lRec.Delete
                            end;

                            SaveR337_lRec.Insert;
                        end;

                        DelR337_lRec.Delete;

                    until DelR337_lRec.Next = 0;
                end;

                if (UniqueIDSave_lInt <> 0) and (ItemJnlLine_vRec."Unique Batch ID in Save Res En" = 0) then
                    ItemJnlLine_vRec."Unique Batch ID in Save Res En" := UniqueIDSave_lInt;
            end;
        end;
        //SubConQCV2-NE
    end;

    procedure CheckLotSerialExistsinBin_lFnc(ItemLdgrEntry_iRec: Record "Item Ledger Entry")
    var
        ItemTrackingCode_gRec: Record "Item Tracking Code";
        WarehouseEntry_gRec: Record "Warehouse Entry";
        Location_lRec: Record Location;
    begin
        //To Check warehouse Tracking for Particular "Lot No." AND/OR "Serial No."
        //I-C0009-1001310-02 NS
        Item_gRec.Get(ItemLdgrEntry_iRec."Item No.");

        if Item_gRec."Item Tracking Code" <> '' then begin
            ItemTrackingCode_gRec.Get(Item_gRec."Item Tracking Code");
            if (ItemTrackingCode_gRec."Lot Warehouse Tracking") and
               ("Item Tracking" = "item tracking"::"Lot No.")
            then begin
                Location_lRec.Get(ItemLdgrEntry_iRec."Location Code");
                if Location_lRec."Bin Mandatory" then begin
                    WarehouseEntry_gRec.Reset;
                    WarehouseEntry_gRec.SetRange("Item No.", ItemLdgrEntry_iRec."Item No.");
                    WarehouseEntry_gRec.SetRange("Location Code", ItemLdgrEntry_iRec."Location Code");
                    //WarehouseEntry_gRec.SetRange("Bin Code", "QC Bin Code");//T12750-O as per YT
                    WarehouseEntry_gRec.SetRange("Lot No.", ItemLdgrEntry_iRec."Lot No.");
                    WarehouseEntry_gRec.FindFirst;
                end;
            end else
                if (ItemTrackingCode_gRec."SN Warehouse Tracking") and
                   ("Item Tracking" = "item tracking"::"Serial No.")
       then begin
                    Location_lRec.Get(ItemLdgrEntry_iRec."Location Code");
                    if Location_lRec."Bin Mandatory" then begin
                        WarehouseEntry_gRec.Reset;
                        WarehouseEntry_gRec.SetRange("Item No.", ItemLdgrEntry_iRec."Item No.");
                        WarehouseEntry_gRec.SetRange("Location Code", ItemLdgrEntry_iRec."Location Code");
                        // WarehouseEntry_gRec.SetRange("Bin Code", "QC Bin Code");//T12750-O as per YT
                        WarehouseEntry_gRec.SetRange("Serial No.", ItemLdgrEntry_iRec."Serial No.");
                        WarehouseEntry_gRec.FindFirst;
                    end;
                end else
                    if (ItemTrackingCode_gRec."Lot Warehouse Tracking") and
                       (ItemTrackingCode_gRec."SN Warehouse Tracking") and
                       ("Item Tracking" = "item tracking"::"Lot and Serial No.")
           then begin
                        Location_lRec.Get(ItemLdgrEntry_iRec."Location Code");
                        if Location_lRec."Bin Mandatory" then begin
                            WarehouseEntry_gRec.Reset;
                            WarehouseEntry_gRec.SetRange("Item No.", ItemLdgrEntry_iRec."Item No.");
                            WarehouseEntry_gRec.SetRange("Location Code", ItemLdgrEntry_iRec."Location Code");
                            //WarehouseEntry_gRec.SetRange("Bin Code", "QC Bin Code");//T12750-O as per YT
                            WarehouseEntry_gRec.SetRange("Lot No.", ItemLdgrEntry_iRec."Lot No.");
                            WarehouseEntry_gRec.SetRange("Serial No.", ItemLdgrEntry_iRec."Serial No.");
                            WarehouseEntry_gRec.FindFirst;
                        end;
                    end;
        end;
        //I-C0009-1001310-02 NE
    end;

    procedure CheckEnteredResult_lFnc(var ItemLdgrEntry_vRec: Record "Item Ledger Entry")
    var
        TrackingFound_lBln: Boolean;
        AcceptedQty_lDec: Decimal;
        RejectedQty_lDec: Decimal;
        ReworkedQty_lDec: Decimal;
    begin
        //To Check Entered Result with the result entered in Item Tracking Lines.

        AcceptedQty_lDec := 0;
        RejectedQty_lDec := 0;
        ReworkedQty_lDec := 0;
        TrackingFound_lBln := false;
        repeat
            if ItemLdgrEntry_vRec."Remaining Quantity" >= 0 then begin
                AcceptedQty_lDec += ItemLdgrEntry_vRec."Accepted Quantity" + ItemLdgrEntry_vRec."Accepted with Deviation Qty";
                RejectedQty_lDec += ItemLdgrEntry_vRec."Rejected Quantity";
                ReworkedQty_lDec += ItemLdgrEntry_vRec."Rework Quantity";
                if (ItemLdgrEntry_vRec."Serial No." <> '') or (ItemLdgrEntry_vRec."Lot No." <> '') then
                    TrackingFound_lBln := true;
            end;
        until ItemLdgrEntry_vRec.Next = 0;

        if TrackingFound_lBln then begin
            if AcceptedQty_lDec <> ("Quantity to Accept" + "Qty to Accept with Deviation") then
                Error('"Quantity to Accept" and "Quantity to Accept with Deviation" (%1) must be equal to sum of Quantity Accepted in Item Tracking Lines(%2)', ("Quantity to Accept" + "Qty to Accept with Deviation"), AcceptedQty_lDec);
            if RejectedQty_lDec <> "Quantity to Reject" then
                Error('"Quantity to Reject" (%1) must be equal to sum of Quantity Rejected in Item Tracking Lines (%2)', "Quantity to Reject", RejectedQty_lDec);
            if ReworkedQty_lDec <> "Quantity to Rework" then
                Error('"Quantity to Rework" (%1) must be equal to sum of Quantity Reworked in Item Tracking Lines (%2)', "Quantity to Rework", ReworkedQty_lDec);
        end;
    end;

    procedure CreatePostedQCRcpt_lFnc()
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        ProductionOrder_lRec: Record "Production Order";//12113-ABA-N
        ProductionOrderLine_lRec: Record "Prod. Order Line";
        QCSubscribMgmt_lCdu: Codeunit "QC Subscribe Mgt.";//T12530-NS
    begin
        //Posting into Posted QC rcpt header Table
        //I-C0009-1001310-02 NS
        QCSetup_gRec.Get;

        PostedQCRcptHead_gRec.Init;
        PostedQCRcptHead_gRec.TransferFields(Rec);
        PostedQCRcptHead_gRec."PreAssigned No." := "No.";
        if "Document Type" = "Document type"::Purchase then begin
            Location_gRec.Get("Location Code");
            if Location_gRec."Posted Purchase  QC Nos." <> '' then
                PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Posted Purchase  QC Nos.", "Receipt Date", true)
            else begin
                QCSetup_gRec.TestField("Posted Purchase  QC Nos.");
                PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Posted Purchase  QC Nos.", "Receipt Date", true);
            end;
            PostedQCRcptHead_gRec."Outstanding Returned Qty." := "Quantity to Reject"; //I-C0009-1001310-07-N
            PostedQCRcptHead_gRec."Purchase Order No." := "Purchase Order No.";   //I-C0009-1001311-11-N
        end else
            if "Document Type" = "Document type"::Production then begin
                Location_gRec.Get("Location Code");
                if Location_gRec."Post Productiuon QC Nos." <> '' then
                    PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Post Productiuon QC Nos.", "Receipt Date", true)
                else begin
                    QCSetup_gRec.TestField("Post Productiuon QC Nos.");
                    PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Post Productiuon QC Nos.", "Receipt Date", true);
                end;
                //END;    //I-C0009-1001310-05-O
                //I-C0009-1001310-05-NS
            end else
                if "Document Type" = "Document type"::"Sales Return" then begin
                    Location_gRec.Get("Location Code");
                    if Location_gRec."Posted Sales Return QC No." <> '' then
                        PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Posted Sales Return QC No.", "Receipt Date", true)
                    else begin
                        QCSetup_gRec.TestField("Posted Sales Return QC Nos.");
                        PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Posted Sales Return QC Nos.", "Receipt Date", true);
                    end;
                    //END;  //I-C0009-1001310-06-O
                    //I-C0009-1001310-05-NE
                    //I-C0009-1001310-06-NS
                end else
                    if "Document Type" = "Document type"::ile then begin//T12113-ABA-N
                        QCSetup_gRec.TestField("Posted Retest QC Nos");
                        PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Posted Retest QC Nos", "Receipt Date", true);
                    end else
                        if "Document Type" = "Document type"::"Sales Order" then begin//T12113-ABA-N
                            QCSetup_gRec.TestField("Posted PreDispatch QC Nos");
                            PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Posted PreDispatch QC Nos", "Receipt Date", true);
                        end else
                            if "Document Type" = "Document type"::"Purchase Pre-Receipt" then begin//T12547-ABA-N
                                QCSetup_gRec.TestField("Posted Pre-Receipt QC Nos");
                                PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Posted Pre-Receipt QC Nos", "Receipt Date", true);
                            end else
                                if "Document Type" = "Document type"::"Transfer Receipt" then begin
                                    Location_gRec.Get("Location Code");
                                    if Location_gRec."Posted Transfer Receipt QC No." <> '' then
                                        PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(Location_gRec."Posted Transfer Receipt QC No.", "Receipt Date", true)
                                    else begin
                                        QCSetup_gRec.TestField("Posted Transfer Receipt QC No.");
                                        PostedQCRcptHead_gRec."No." := NoSeriesMgt_gCdu.GetNextNo(QCSetup_gRec."Posted Transfer Receipt QC No.", "Receipt Date", true);
                                    end;
                                end;
        //I-C0009-1001310-06-NE

        PostedQCRcptHead_gRec.Insert(true);

        QCRcptNo_gCod := '';
        PostedQCRecptNo_gCod := '';
        PostedQCRecptNo_gCod := PostedQCRcptHead_gRec."No.";
        QCRcptNo_gCod := "No.";
        //Document Attachemnt Insert
        QCSubscribMgmt_lCdu.DocumentAttachmentInsert_gFnc(Rec, PostedQCRecptNo_gCod);//T12530-N
        //Document Attachmemt Insert
        //Posting into Posted QC Rcpt Line Table
        QCRcptLine_lRec.Reset;
        QCRcptLine_lRec.SetRange("No.", "No.");
        if QCRcptLine_lRec.FindFirst then
            repeat
                PostedQCRcptLine_gRec.Init;
                PostedQCRcptLine_gRec.TransferFields(QCRcptLine_lRec, true);
                PostedQCRcptLine_gRec."No." := PostedQCRcptHead_gRec."No.";
                PostedQCRcptLine_gRec.Insert;
            until QCRcptLine_lRec.Next = 0;

        //I-C0009-1001310-08-NS
        if "Document Type" = "Document type"::Purchase then
            UpdateQCRcpt_lFnc
        //I-C0009-1001310-09-NS
        else
            if "Document Type" = "Document type"::Production then
                UpdateProdQCRcpt_lFnc
            //I-C0009-1001310-09-NE
            else
                if "Document Type" = "Document type"::"Sales Return" then
                    UpdateReturnRcptLine_lFnc
                else
                    if "Document Type" = "Document type"::"Sales Order" then
                        UpdateSalesOrderQCRcpt_lFnc
                    else
                        if "Document Type" = "Document type"::"Purchase Pre-Receipt" then
                            UpdatePurchaseOrderQCRcpt_lFnc
                        else
                            if "Document Type" = "Document type"::"Transfer Receipt" then
                                UpdateTransferRcptLine_lFnc
                            else
                                if "Document Type" = "Document type"::Ile then
                                    UpdateILEQCRcpt_lFnc();
        //I-C0009-1001310-08-NE 
        //I-C0009-1001310-02 NE
        UpdateProductionOrder_lFnc(PostedQCRcptHead_gRec);//T12113-ABA-N Posted QC No. Update on Quality Prod Order
        //T12113-ABA-NS
        ProductionOrder_lRec.reset;
        ProductionOrder_lRec.SetRange(Status, ProductionOrder_lRec.Status::Finished);
        ProductionOrder_lRec.SetRange("QC Receipt No", Rec."No.");
        ProductionOrder_lRec.SetRange("Quality Order", true);
        if ProductionOrder_lRec.FindSet() then
            repeat
                ProductionOrderLine_lRec.reset;
                ProductionOrderLine_lRec.SetRange("Prod. Order No.", ProductionOrder_lRec."No.");
                ProductionOrderLine_lRec.SetRange(status, ProductionOrder_lRec.Status::Finished);
                if ProductionOrderLine_lRec.FindSet() then
                    repeat
                        InsertNegAdjJnlLine_lFnc(ProductionOrderLine_lRec);
                        PostNegAdjItemJnlLine_lFnc(ProductionOrderLine_lRec);
                        FindNewLdgrEntryForUpdate_lFnc(ProductionOrderLine_lRec);//Update on Ledger Entry
                    until ProductionOrderLine_lRec.next = 0;
            until ProductionOrder_lRec.next = 0;
        //T12113-ABA-NE

        SendQCMail(PostedQCRcptHead_gRec, Rec);
    end;

    //T12113-ABA-NS
    local procedure UpdateProductionOrder_lFnc(PostedQCRcpt_iRec: Record "Posted QC Rcpt. Header")
    var
        ProductionOrder_lRec: Record "Production Order";
    begin
        Clear(ProductionOrder_lRec);
        ProductionOrder_lRec.SetRange("QC Receipt No", PostedQCRcpt_iRec."PreAssigned No.");
        ProductionOrder_lRec.SetRange("Quality Order", true);
        if ProductionOrder_lRec.FindSet() then
            repeat
                ProductionOrder_lRec."Posted QC Receipt No" := PostedQCRcpt_iRec."No.";
                ProductionOrder_lRec.Modify();
            until ProductionOrder_lRec.next = 0;
    end;
    //T12113-ABA-NE

    procedure UpdateQCRcpt_lFnc()
    var
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        QCRcptLine_lRec: Record "QC Rcpt. Line";
    begin
        //To Update  the posted QC Receipt result into Purchase Receipt Line.
        //I-C0009-1001310-02 NS
        PurchRcptLine_lRec.Reset;
        PurchRcptLine_lRec.SetRange("Document No.", "Document No.");
        PurchRcptLine_lRec.SetRange("Line No.", "Document Line No.");
        if PurchRcptLine_lRec.FindFirst then begin
            PurchRcptLine_lRec."Under Inspection Quantity" := PurchRcptLine_lRec."Under Inspection Quantity" -
                                                                ("Qty to Accept with Deviation" + "Quantity to Accept" +
                                                                "Quantity to Reject" + "Quantity to Rework");

            PurchRcptLine_lRec.Validate("Accepted with Deviation Qty", PurchRcptLine_lRec."Accepted with Deviation Qty" +
                                        "Qty to Accept with Deviation");
            PurchRcptLine_lRec.Validate("Accepted Quantity", PurchRcptLine_lRec."Accepted Quantity" + "Quantity to Accept");
            PurchRcptLine_lRec.Validate("Rejected Quantity", PurchRcptLine_lRec."Rejected Quantity" + "Quantity to Reject");
            PurchRcptLine_lRec.Validate("Reworked Quantity", PurchRcptLine_lRec."Reworked Quantity" + "Quantity to Rework"); //I-C0009-1001310-07-N
            if PurchRcptLine_lRec."Under Inspection Quantity" = 0 then
                PurchRcptLine_lRec."QC Pending" := false;
            PurchRcptLine_lRec.Modify;
        end;

        "Total Accepted Quantity" := "Total Accepted Quantity" + "Quantity to Accept";
        "Total Under Deviation Acc. Qty" := "Total Under Deviation Acc. Qty" + "Qty to Accept with Deviation";
        "Total Rejected Quantity" := "Total Rejected Quantity" + "Quantity to Reject";
        "Total Rework Quantity" := "Total Rework Quantity" + "Quantity to Rework"; //I-C0009-1001310-07-N
        "Remaining Quantity" := "Remaining Quantity" - ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework");
        Modify(true);

        //I-C0009-1001310-02 NE
    end;

    procedure UpdateProdQCRcpt_lFnc()
    var
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        QCRcptLine_lRec: Record "QC Rcpt. Line";
    begin
        //I-C0009-1001310-09-NS
        //To Update  the posted QC Receipt result into Production QC
        "Total Accepted Quantity" := "Total Accepted Quantity" + "Quantity to Accept";
        "Total Under Deviation Acc. Qty" := "Total Under Deviation Acc. Qty" + "Qty to Accept with Deviation";
        "Total Rejected Quantity" := "Total Rejected Quantity" + "Quantity to Reject";
        "Total Rework Quantity" := "Total Rework Quantity" + "Quantity to Rework"; //I-C0009-1001310-07-N
        "Remaining Quantity" := "Remaining Quantity" - ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework");
        Modify(true);
        //I-C0009-1001310-09-NE
    end;

    procedure UpdateSalesOrderQCRcpt_lFnc()
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        SalesLine_lRec: Record "Sales Line";
    begin
        //To Update  the posted QC Receipt result into Sales Order QC
        "Total Accepted Quantity" := "Total Accepted Quantity" + "Quantity to Accept";
        "Total Under Deviation Acc. Qty" := "Total Under Deviation Acc. Qty" + "Qty to Accept with Deviation";
        "Total Rejected Quantity" := "Total Rejected Quantity" + "Quantity to Reject";
        "Total Rework Quantity" := "Total Rework Quantity" + "Quantity to Rework";
        "Remaining Quantity" := "Remaining Quantity" - ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework");
        Modify(true);
        SalesLine_lRec.get(SalesLine_lRec."Document Type"::Order, "Document No.", "Document Line No.");
        SalesLine_lRec."QC Accepted Qty" := SalesLine_lRec."QC Accepted Qty" + "Quantity to Accept" + "Qty to Accept with Deviation";
        SalesLine_lRec."QC Rejected Qty" := SalesLine_lRec."QC Rejected Qty" + "Quantity to Reject";
        SalesLine_lRec.Modify();
    end;

    procedure UpdatePurchaseOrderQCRcpt_lFnc()//T12547-N
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        PurchaseLine_lRec: Record "Purchase Line";
    begin
        //To Update  the posted QC Receipt result into Pre-Rceipt Order QC
        "Total Accepted Quantity" := "Total Accepted Quantity" + "Quantity to Accept";
        "Total Under Deviation Acc. Qty" := "Total Under Deviation Acc. Qty" + "Qty to Accept with Deviation";
        "Total Rejected Quantity" := "Total Rejected Quantity" + "Quantity to Reject";
        "Total Rework Quantity" := "Total Rework Quantity" + "Quantity to Rework";
        "Remaining Quantity" := "Remaining Quantity" - ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework");
        Modify(true);
        PurchaseLine_lRec.get(PurchaseLine_lRec."Document Type"::Order, "Document No.", "Document Line No.");
        PurchaseLine_lRec."QC Accepted Qty" := PurchaseLine_lRec."QC Accepted Qty" + "Quantity to Accept" + "Qty to Accept with Deviation";
        PurchaseLine_lRec."QC Rejected Qty" := PurchaseLine_lRec."QC Rejected Qty" + "Quantity to Reject";
        PurchaseLine_lRec.Modify();
    end;

    procedure UpdateILEQCRcpt_lFnc()
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        Ile_lRec: Record "Item Ledger Entry";
    begin
        //To Update  the posted QC Receipt result into Ile QC
        "Total Accepted Quantity" := "Total Accepted Quantity" + "Quantity to Accept";
        "Total Under Deviation Acc. Qty" := "Total Under Deviation Acc. Qty" + "Qty to Accept with Deviation";
        "Total Rejected Quantity" := "Total Rejected Quantity" + "Quantity to Reject";
        "Total Rework Quantity" := "Total Rework Quantity" + "Quantity to Rework";
        "Remaining Quantity" := "Remaining Quantity" - ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework");
        Modify(true);
        Ile_lRec.get("ILE No.");
        Ile_lRec."Posted QC No." := PostedQCRecptNo_gCod;
        Ile_lRec.Modify();
    end;


    procedure CheckRemainingQty_lFnc()
    begin
        //To Check Quantity Remaining for QC and entered result.
        //I-C0009-1001310-08-OS
        //I-C0009-1001310-02 NS
        //IF "Document Type" = "Document Type":: Purchase THEN BEGIN
        //  IF  "Remaining Quantity"  < ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework") THEN
        //     ERROR(Text0008_gCtx)
        //END ELSE IF "Document Type" = "Document Type":: Production THEN BEGIN
        //  IF  "Remaining Quantity"  < ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework") THEN
        //     ERROR(Text0013_gCtx);
        //END;
        //I-C0009-1001310-02 NE
        //I-C0009-1001310-08-OE
        //I-C0009-1001310-08-NS
        if "Remaining Quantity" < ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework") then
            Error(Text0013_gCtx);
        //I-C0009-1001310-08-NE
    end;

    procedure CheckRemainingQtyForSalesOrderQC_lFnc()
    begin
        if "Remaining Quantity" > ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" + "Quantity to Rework") then
            Error(Text00019_gCtx);
    end;

    procedure CheckPartialQtyForLotItemQC_lFnc()
    begin
        if ("Item Tracking" = "Item Tracking"::"Lot No.") then begin
            if ("Quantity to Accept" <> 0) or ("Qty to Accept with Deviation" <> 0) then
                if "Quantity to Reject" > 0 then
                    Error('If Rejection Quantity has a value, Accepted and Accepted with Deviation fields cannot be filled. Conversely, if Accepted or Accepted with Deviation fields are filled, Rejection Quantity must be blank. This condition applies to Lot Item on QC Receipt.');
        end else
            exit;
    end;


    procedure CheckTotalReworkQty_lFnc()
    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
        TotRQty: Decimal;
    begin
        //T12212-NS
        if "Document Type" <> "Document Type"::Production then
            exit;
        Clear(TotRQty);
        QCRcptLine_lRec.reset;
        QCRcptLine_lRec.SetRange("No.", "No.");
        if QCRcptLine_lRec.FindSet() then
            repeat
                TotRQty += QCRcptLine_lRec."Quantity to Rework";
            until QCRcptLine_lRec.next = 0;
        if TotRQty > "Quantity to Rework" then
            Error(Text0017_gCtx);
        //T12212-NE
    end;

    procedure ReInitVariable_lFnc()

    var
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        DelQCRcptHeader_lRec: Record "QC Rcpt. Header";
    begin
        //Written function to Reinitialize Variables after Posting QC Receipt.

        //I-C0009-1001310-02 NS
        if "Remaining Quantity" = 0 then begin
            //DELETE;
            if DelQCRcptHeader_lRec.Get("No.") then begin
                DelQCRcptHeader_lRec.Delete;
                if ("Previous Posted QC No." = '') and (not "COA AutoPost") then//T13919-N
                    Message(Text0015_gCtx);
            end;

            QCRcptLine_lRec.Reset;
            QCRcptLine_lRec.SetRange("No.", "No.");
            if QCRcptLine_lRec.FindFirst then
                QCRcptLine_lRec.DeleteAll(true);
        end else begin
            "Quantity to Accept" := 0;
            "Qty to Accept with Deviation" := 0;
            "Quantity to Reject" := 0;
            "Quantity to Rework" := 0;
            Approve := false;
            "Approval Status" := "Approval Status"::Open;//T12113-C QC Approval Workflow-010724
            "Approved By" := '';//T12113-C
            Modify;

            QCRcptLine_lRec.Reset;
            QCRcptLine_lRec.SetRange("No.", "No.");
            if QCRcptLine_lRec.FindFirst then begin
                repeat
                    QCRcptLine_lRec."Actual Value" := 0;
                    QCRcptLine_lRec."Actual Text" := '';
                    QCRcptLine_lRec.Rejection := false;
                    QCRcptLine_lRec."Rejected Qty." := 0;
                    QCRcptLine_lRec.Modify;
                until QCRcptLine_lRec.Next = 0;
            end;
            if ("Previous Posted QC No." = '') and (not "COA AutoPost") then//T13919-N
                Message(Text0015_gCtx);
        end;
        //I-C0009-1001310-02 NE
    end;

    procedure ApproveCheck_lFnc()
    var
        Location_lRec: Record Location;
        ProdQCMgmt_lCdu: Codeunit "Quality Control - Production";
        Ile_lRec: Record "Item Ledger Entry";//T12113-N
        QcSetup_lRec: Record "Quality Control Setup";
    begin
        //I-C0009-1001310-02 NS
        if Approve then begin
            "Approved By" := UserId;
            "QC Date" := WorkDate;
        end else begin
            "Approved By" := '';
            "QC Date" := 0D;
        end;

        if not Approve then
            exit;
        QcSetup_lRec.Reset();
        QcSetup_lRec.GET();

        if Approve then begin
            if Not QcSetup_lRec."QC Block without Location" then begin
                if Location_lRec.Get("Store Location Code") and Location_lRec."Bin Mandatory" then
                    TestField("Store Bin Code");
                if Location_lRec.Get("Rejection Location") and Location_lRec."Bin Mandatory" then
                    TestField("Reject Bin Code");
            end;
        end;

        if (("Quantity to Accept" = 0) and ("Qty to Accept with Deviation" = 0) and ("Quantity to Reject" = 0) and
            ("Quantity to Rework" = 0)
           ) then
            Error(Text0004_gCtx, "No.");

        QCRcptLine.Reset;
        QCRcptLine.SetRange(QCRcptLine."No.", "No.");
        QCRcptLine.SetRange(Required, true);//T12544-N
        if QCRcptLine.FindFirst then begin
            repeat
                if (QCRcptLine.Mandatory) then
                    if ((QCRcptLine."Actual Value" = 0) and (QCRcptLine."Actual Text" = '')) then
                        Error(Text0007_gCtx, QCRcptLine."Quality Parameter Code", "No.");

                if (QCRcptLine.Rejection = true) then
                    if (QCRcptLine."Rejected Qty." = 0) then
                        QCRcptLine.FieldError("Rejected Qty.");

                TotRejQty := TotRejQty + QCRcptLine."Rejected Qty.";
            until QCRcptLine.Next = 0;
            if ("Quantity to Reject" <> TotRejQty) then
                Error(Text0001_gCtx);
            if (Approve = true) then begin
                "Approved By" := UserId;
                "QC Date" := WorkDate;
            end else begin
                "Approved By" := '';
                "QC Date" := 0D;
            end;
        end;

        // IF (("Item Tracking" = "Item Tracking"::"Serial No.") OR  ("Item Tracking" = "Item Tracking"::"Lot and Serial No."))
        //  AND (("Document Type" = "Document Type"::Purchase) OR ("Document Type" = "Document Type"::"Sales Return") OR
        //                           ("Document Type" = "Document Type"::"Transfer Receipt"))
        // THEN BEGIN
        ItemLdgrEntry_gRec.Reset;
        ItemLdgrEntry_gRec.SetFilter("Document Type", '%1|%2|%3', ItemLdgrEntry_gRec."document type"::"Purchase Receipt", ItemLdgrEntry_gRec."document type"::"Sales Return Receipt",
                                                               ItemLdgrEntry_gRec."document type"::"Transfer Receipt");
        ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
        ItemLdgrEntry_gRec.SetRange("Item No.", "Item No.");//T12113-N filter is applied due to double entry 
        if "Vendor Lot No." <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");

        if ItemLdgrEntry_gRec.FindSet then begin
            //T12113-NS QC-Sales Return
            if ItemLdgrEntry_gRec."Document Type" in [ItemLdgrEntry_gRec."Document Type"::"Sales Return Receipt"] then begin
                Ile_lRec.reset;
                Ile_lRec.SetRange("Entry Type", Ile_lRec."Entry Type"::Transfer);
                Ile_lRec.SetRange("Document No.", "Document No.");
                Ile_lRec.SetRange("Document Line No.", "Document Line No.");
                Ile_lRec.Setfilter("QC Relation Entry No.", '<>%1', 0);
                Ile_lRec.Setfilter("Remaining Quantity", '>%1', 0);
                if Ile_lRec.FindSet() then
                    CheckEnteredResult_lFnc(Ile_lRec);
            end else if ItemLdgrEntry_gRec."Document Type" in [ItemLdgrEntry_gRec."Document Type"::"Purchase Receipt", ItemLdgrEntry_gRec."Document Type"::"Transfer Receipt"] then begin
                //T12113-NE QC-Sales Return
                CheckEnteredResult_lFnc(ItemLdgrEntry_gRec);
            end;
        END;//T12113-N
            //I-C0009-1001310-02 NE        

        //QCV3-NS  30-01-18
        if "Document Type" = "document type"::Production then
            ProdQCMgmt_lCdu.CheckEnterResult_gFnc(Rec);
        //QCV3-NE  30-01-18
        //T12113-NS
        if "Document Type" = "document type"::"Sales Order" then
            CheckRemainingQtyForSalesOrderQC_lFnc();
        //T12113-NE
    end;

    procedure UpdateCapacityLdgrEntry_lFnc()
    var
        CapacityLdgrEntry_lRec: Record "Capacity Ledger Entry";
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine_lRec.Reset;
        PurchRcptLine_lRec.SetRange("Document No.", "Document No.");
        PurchRcptLine_lRec.SetRange("Line No.", "Document Line No.");
        PurchRcptLine_lRec.FindFirst;

        CapacityLdgrEntry_lRec.Reset;
        CapacityLdgrEntry_lRec.SetRange("Order Type", CapacityLdgrEntry_lRec."order type"::Production);
        CapacityLdgrEntry_lRec.SetRange("Order No.", PurchRcptLine_lRec."Prod. Order No.");
        CapacityLdgrEntry_lRec.SetRange("Order Line No.", PurchRcptLine_lRec."Prod. Order Line No.");
        CapacityLdgrEntry_lRec.SetRange(Type, "Center Type");
        CapacityLdgrEntry_lRec.SetRange("Document No.", "Document No.");
        CapacityLdgrEntry_lRec.SetRange("Item No.", "Item No.");
        if CapacityLdgrEntry_lRec.FindSet then begin
            CapacityLdgrEntry_lRec."Input Quantity" := "Quantity to Accept" + "Qty to Accept with Deviation" +
                                                       "Quantity to Reject" + "Quantity to Rework";
            CapacityLdgrEntry_lRec."Accepted Quantity" := "Quantity to Accept";
            CapacityLdgrEntry_lRec."Qty Accepted With Deviation" := "Qty to Accept with Deviation";
            CapacityLdgrEntry_lRec."Rework Quantity" := "Quantity to Rework";
            CapacityLdgrEntry_lRec."QC No." := "No.";
            CapacityLdgrEntry_lRec."Posted QC No." := PostedQCRecptNo_gCod;
            CapacityLdgrEntry_lRec.Validate("Output Quantity", "Quantity to Accept" + "Qty to Accept with Deviation");
            CapacityLdgrEntry_lRec.Modify(true);
        end;
    end;

    local procedure CreateItemJnlLine_lFnc(ItemLedgEntry_iRec: Record "Item Ledger Entry"; Result_iOpt: Option ACCEPT,REJECT,REWORK; Qty_iDec: Decimal) ReturnFlag: Boolean
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
        //T51170-NS
        ExpDate_lDte: Date;
        DateDiff_iInt: Integer;
        ConvertDate_lTxt: Text;
        Dateformula_lDF: DateFormula;
    //T51170-NE
    begin
        //T51170-NS
        Clear(ExpChange_gBol);
        Clear(ManufChange_gBol);
        Clear(OverallChange_gBol);
        if (ItemLedgEntry_iRec."Expiration Date" <> 0D) and ("Exp. Date" <> 0D) and (ItemLedgEntry_iRec."Expiration Date" <> "Exp. Date") then
            ExpChange_gBol := true;
        if (ItemLedgEntry_iRec."Warranty Date" <> 0D) and ("Mfg. Date" <> 0D) and (ItemLedgEntry_iRec."Warranty Date" <> "Mfg. Date") then
            ManufChange_gBol := true;

        if ExpChange_gBol or ManufChange_gBol then
            OverallChange_gBol := true;




        //T51170-NE

        //Create Function for Item Reclassification for Entered Result in "QC Receipt".
        //Previous Name : Reclassification1_lFnc
        //I-C0009-1001310-04-NS
        SourceCodeSetup_lRec.Get;
        QCSetup_gRec.Get;
        QCSetup_gRec.TestField("QC Journal Template Name");
        QCSetup_gRec.TestField("QC General Batch Name");

        ItemJnlLine_lRec.Init;
        ItemJnlLine_lRec."Journal Template Name" := QCSetup_gRec."QC Journal Template Name";
        ItemJnlLine_lRec."Journal Batch Name" := QCSetup_gRec."QC General Batch Name";

        ItemJnlLine1_lRec.Reset;
        ItemJnlLine1_lRec.SetRange("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
        ItemJnlLine1_lRec.SetRange("Journal Batch Name", QCSetup_gRec."QC General Batch Name");
        if ItemJnlLine1_lRec.FindLast then
            ItemJnlLine_lRec."Line No." := ItemJnlLine1_lRec."Line No." + 10000
        else
            ItemJnlLine_lRec."Line No." := 10000;

        ItemJnlLine_lRec.Insert(true);
        ItemJnlLine_lRec."Entry Type" := ItemJnlLine_lRec."entry type"::Transfer;
        ItemJnlLine_lRec."Source Code" := SourceCodeSetup_lRec."Item Reclass. Journal";
        ItemJnlLine_lRec.Validate("Item No.", "Item No.");
        ItemJnlLine_lRec.Validate("Variant Code", "Variant Code");
        ItemJnlLine_lRec.Validate("Unit of Measure Code", "Unit of Measure");

        TestField("Receipt Date");
        TestField("QC Date");

        ItemJnlLine_lRec."Posting Date" := "Receipt Date";
        ItemJnlLine_lRec."Posting Date" := "QC Date";
        ItemJnlLine_lRec."Document Date" := "Receipt Date";
        ItemJnlLine_lRec."Document No." := "No.";
        //T12113-NS
        ItemJnlLine_lRec."Rejection Reason" := "Rejection Reason";
        ItemJnlLine_lRec."Rejection Reason Description" := "Rejection Reason Description";
        //T12113-NE
        ItemJnlLine_lRec.Validate("Location Code", "QC Location");
        ItemJnlLine_lRec.Validate("Bin Code", "QC Bin Code");

        if QCSetup_gRec."QC Block without Location" then begin
            //     if "Store Bin Code" = "QC Bin Code" then
            //         Error('Store Bin and QC Bin cannot be same');

            //     if "Store Bin Code" = "Rework Bin Code" then
            //         Error('Store Bin and  Rework cannot be same');

            //     if "Store Bin Code" = "Reject Bin Code" then
            //         Error('Store Bin and Rejection Bin cannot be same');

            //     if (Result_iOpt = Result_iopt::ACCEPT) then begin
            //         ItemJnlLine_lRec.Validate("New Location Code", "Location Code");
            //         ItemJnlLine_lRec.Validate("New Bin Code", "Store Bin Code")
            //     end else
            //         if (Result_iOpt = Result_iopt::REJECT) then begin
            //             ItemJnlLine_lRec.Validate("New Location Code", "Location Code");
            //             ItemJnlLine_lRec.Validate("New Bin Code", "Reject Bin Code")
            //         end else
            //             if (Result_iOpt = Result_iopt::REWORK) then begin
            //                 ItemJnlLine_lRec.Validate("New Location Code", "Location Code");
            //                 ItemJnlLine_lRec.Validate("New Bin Code", "Rework Bin Code");
            //             end;



            if (Result_iOpt = Result_iopt::REJECT) then begin
                if "Store Location Code" = "Rejection Location" then
                    Error('Rejection Location and Store location cannot be same');
                ItemJnlLine_lRec.Validate("New Location Code", "Rejection Location");
                if CheckBinMandatory_lFnc("Rejection Location") then
                    ItemJnlLine_lRec.Validate("New Bin Code", "Reject Bin Code")
            end else
                if (Result_iOpt = Result_iopt::REWORK) then begin
                    if "Store Location Code" = "Rework Location" then
                        Error('Rework Location and Store location cannot be same');
                    ItemJnlLine_lRec.Validate("New Location Code", "Rework Location");
                    if CheckBinMandatory_lFnc("Rework Location") then
                        ItemJnlLine_lRec.Validate("New Bin Code", "Rework Bin Code");
                end;
        end else begin
            if "Store Location Code" = "QC Location" then
                Error('Store Location and QC location cannot be same');

            if "Store Location Code" = "Rework Location" then
                Error('Rework Location and Store location cannot be same');

            if "Store Location Code" = "Rejection Location" then
                Error('Rejection Location and Store location cannot be same');

            if (Result_iOpt = Result_iopt::ACCEPT) then begin
                ItemJnlLine_lRec.Validate("New Location Code", "Store Location Code");
                if CheckBinMandatory_lFnc("Store Location Code") then
                    ItemJnlLine_lRec.Validate("New Bin Code", "Store Bin Code")
            end else
                if (Result_iOpt = Result_iopt::REJECT) then begin
                    ItemJnlLine_lRec.Validate("New Location Code", "Rejection Location");
                    if CheckBinMandatory_lFnc("Rejection Location") then
                        ItemJnlLine_lRec.Validate("New Bin Code", "Reject Bin Code")
                end else
                    if (Result_iOpt = Result_iopt::REWORK) then begin
                        ItemJnlLine_lRec.Validate("New Location Code", "Rework Location");
                        if CheckBinMandatory_lFnc("Rework Location") then
                            ItemJnlLine_lRec.Validate("New Bin Code", "Rework Bin Code");
                    end;

        end;
        //T51170-NS
        if (QCSetup_gRec."QC Block without Location" and OverallChange_gBol and (Result_iOpt = Result_iOpt::ACCEPT)) then begin
            ItemJnlLine_lRec.Validate("New Location Code", "Store Location Code");
            if CheckBinMandatory_lFnc("Store Location Code") then
                ItemJnlLine_lRec.Validate("New Bin Code", "Store Bin Code")
        end else if (QCSetup_gRec."QC Block without Location" and not OverallChange_gBol and (Result_iOpt = Result_iOpt::ACCEPT)) then begin
            exit;
        end;
        if OverallChange_gBol then
            ItemJnlLine_lRec."Overall Changes" := OverallChange_gBol;


        // ItemJnlLine_lRec.Validate("New Location Code", "Store Location Code");
        // ItemJnlLine_lRec.Validate("New Bin Code", "Store Bin Code");

        ItemJnlLine_lRec.Validate(Quantity, Qty_iDec);

        //T12113-NS
        // if ItemLedgEntry_iRec."Warranty Date" <> 0D then
        //     ItemJnlLine_lRec.Validate("Warranty Date", ItemLedgEntry_iRec."Warranty Date");
        // if (ItemLedgEntry_iRec."Warranty Date" <> 0D) and ("Mfg. Date" <> 0D) and (ItemLedgEntry_iRec."Warranty Date" <> "Mfg. Date") then begin
        //     ItemJnlLine_lRec."Warranty Date" := "Mfg. Date";
        // end else if (ItemJnlLine_lRec."Warranty Date" = 0D) and (ItemLedgEntry_iRec."Warranty Date" <> 0D) then begin
        //     ItemJnlLine_lRec."Warranty Date" := ItemLedgEntry_iRec."Warranty Date";
        // end;
        // if ItemLedgEntry_iRec."Expiration Date" <> 0D then
        //     ItemJnlLine_lRec.Validate("Expiration Date", ItemLedgEntry_iRec."Expiration Date");
        // if ItemLedgEntry_iRec."Warranty Date" <> 0D then begin
        //     ItemJnlLine_lRec."Manufacturing Date 2" := ItemLedgEntry_iRec."Warranty Date";
        // end;
        /* Clear(ExpDate_lDte);
        Clear(DateDiff_iInt);
        Clear(ConvertDate_lTxt);
        Clear(Dateformula_lDF);
        if CheckExpirationDateExist_lFnc(ItemLedgEntry_iRec) then begin
            if (ItemLedgEntry_iRec."Expiration Date" <> 0D) and ("Exp. Date" <> 0D) and (ItemLedgEntry_iRec."Expiration Date" <> "Exp. Date") then begin
                ExpDate_lDte := "Exp. Date";
            end else begin
                if ItemLedgEntry_iRec."Expiration Date" <> 0D then
                    ExpDate_lDte := ItemLedgEntry_iRec."Expiration Date";
            end;
        end;
        if (ExpDate_lDte <> 0D) and (ItemLedgEntry_iRec."Warranty Date" <> 0D) then begin
            DateDiff_iInt := ExpDate_lDte - ItemLedgEntry_iRec."Warranty Date";//Warranty Date is manufacturing Date 
            ConvertDate_lTxt := Format(ABS(DateDiff_iInt)) + 'D';
            if Evaluate(Dateformula_lDF, ConvertDate_lTxt) then
                ItemJnlLine_lRec."Expiry Period 2" := Dateformula_lDF;
        end; */
        //T51170-NE

        //T12113-NE
        if ItemLedgEntry_iRec."Item Tracking" = ItemLedgEntry_iRec."item tracking"::None then begin
            ChkILE_lRec.GET(ItemLedgEntry_iRec."Entry No.");
            IF ChkILE_lRec."Location Code" <> "QC Location" then
                Error('Source Ledger Entry must be created in QC Location %1 Current Location %2 for Entry No. %3', "QC Location", ChkILE_lRec."Location Code", ChkILE_lRec."Entry No.");
            ItemJnlLine_lRec.Validate("Applies-to Entry", ItemLedgEntry_iRec."Entry No.");
        End;

        ItemJnlLine_lRec."Skip Confirm Msg" := true;

        ItemJnlLine_lRec."QC No." := "No.";
        ItemJnlLine_lRec."Posted QC No." := PostedQCRcptHead_gRec."No.";
        if "Document Type" = "document type"::Purchase then begin
            if PurchRcptLine_lRec.Get("Document No.", "Document Line No.") then begin
                //I-C0009-1001310-10-NS
                ItemJnlLine_lRec."Shortcut Dimension 1 Code" := PurchRcptLine_lRec."Shortcut Dimension 1 Code";
                ItemJnlLine_lRec."Shortcut Dimension 2 Code" := PurchRcptLine_lRec."Shortcut Dimension 2 Code";
                ItemJnlLine_lRec."Dimension Set ID" := PurchRcptLine_lRec."Dimension Set ID";
                ItemJnlLine_lRec."New Shortcut Dimension 1 Code" := PurchRcptLine_lRec."Shortcut Dimension 1 Code";
                ItemJnlLine_lRec."New Shortcut Dimension 2 Code" := PurchRcptLine_lRec."Shortcut Dimension 2 Code";
                ItemJnlLine_lRec."New Dimension Set ID" := PurchRcptLine_lRec."Dimension Set ID";
                //I-C0009-1001310-10-NE
            end;
        end else
            if "Document Type" = "document type"::"Sales Return" then begin
                if ReturnRcptLine_lRec.Get("Document No.", "Document Line No.") then begin
                    ItemJnlLine_lRec."Shortcut Dimension 1 Code" := ReturnRcptLine_lRec."Shortcut Dimension 1 Code";
                    ItemJnlLine_lRec."Shortcut Dimension 2 Code" := ReturnRcptLine_lRec."Shortcut Dimension 2 Code";
                    ItemJnlLine_lRec."Dimension Set ID" := ReturnRcptLine_lRec."Dimension Set ID";
                    ItemJnlLine_lRec."New Shortcut Dimension 1 Code" := ReturnRcptLine_lRec."Shortcut Dimension 1 Code";
                    ItemJnlLine_lRec."New Shortcut Dimension 2 Code" := ReturnRcptLine_lRec."Shortcut Dimension 2 Code";
                    ItemJnlLine_lRec."New Dimension Set ID" := ReturnRcptLine_lRec."Dimension Set ID";
                end;
            end else
                if "Document Type" = "document type"::"Transfer Receipt" then begin
                    if TransferRcptLine_lRec.Get("Document No.", "Document Line No.") then begin
                        ItemJnlLine_lRec."Shortcut Dimension 1 Code" := TransferRcptLine_lRec."Shortcut Dimension 1 Code";
                        ItemJnlLine_lRec."Shortcut Dimension 2 Code" := TransferRcptLine_lRec."Shortcut Dimension 2 Code";
                        ItemJnlLine_lRec."Dimension Set ID" := TransferRcptLine_lRec."Dimension Set ID";
                        ItemJnlLine_lRec."New Shortcut Dimension 1 Code" := TransferRcptLine_lRec."Shortcut Dimension 1 Code";
                        ItemJnlLine_lRec."New Shortcut Dimension 2 Code" := TransferRcptLine_lRec."Shortcut Dimension 2 Code";
                        ItemJnlLine_lRec."New Dimension Set ID" := TransferRcptLine_lRec."Dimension Set ID";
                    end;
                end else begin//T51170-NS
                    ItemJnlLine_lRec."Dimension Set ID" := ItemLedgEntry_iRec."Dimension Set ID";
                    ItemJnlLine_lRec."New Dimension Set ID" := ItemLedgEntry_iRec."Dimension Set ID";
                end;//T51170-NE

        //SubConQCV2-NS  //Delete the Reservation Entry and Create it again in Post Document        
        ItemLedgEntry_iRec.CalcFields("Reserved Quantity");
        UniqueIDSave_lInt := 0;
        if ItemLedgEntry_iRec."Reserved Quantity" > 0 then begin
            if Result_iOpt = Result_iopt::ACCEPT then begin
                SaveR337_lRec.Reset;
                SaveR337_lRec.SetCurrentkey("Unique Batch ID in Save Res En");
                if SaveR337_lRec.FindLast then
                    UniqueIDSave_lInt += SaveR337_lRec."Unique Batch ID in Save Res En" + 1
                else
                    UniqueIDSave_lInt := 1;
            end;




            DelR337_lRec.Reset;
            DelR337_lRec.SetRange("Source ID", '');
            DelR337_lRec.SetRange("Source Ref. No.", ItemLedgEntry_iRec."Entry No.");
            DelR337_lRec.SetRange("Source Type", 32);
            DelR337_lRec.SetRange("Source Subtype", 0);
            DelR337_lRec.SetRange("Source Batch Name", '');
            DelR337_lRec.SetRange("Source Prod. Order Line", 0);
            DelR337_lRec.SetRange("Reservation Status", DelR337_lRec."reservation status"::Reservation);
            if DelR337_lRec.FindSet then begin
                repeat
                    if DelR337OppLag_lRec.Get(DelR337_lRec."Entry No.", not DelR337_lRec.Positive) then begin
                        if UniqueIDSave_lInt > 0 then begin
                            Clear(SaveR337_lRec);
                            SaveR337_lRec.TransferFields(DelR337OppLag_lRec);
                            SaveR337_lRec."Entry No." := DelR337OppLag_lRec."Entry No.";
                            SaveR337_lRec.Positive := DelR337OppLag_lRec.Positive;
                            SaveR337_lRec."Unique Batch ID in Save Res En" := UniqueIDSave_lInt;
                            SaveR337_lRec."Remain Qty for Allocation" := Abs(SaveR337_lRec."Quantity (Base)");

                            if DelSaveR337_lRec.Get(SaveR337_lRec."Entry No.", SaveR337_lRec.Positive) then begin  //Del Line if already exists any old entry
                                DelSaveR337_lRec.Delete
                            end;

                            SaveR337_lRec.Insert;
                        end;

                        DelR337OppLag_lRec.Delete;
                    end;

                    if UniqueIDSave_lInt > 0 then begin
                        Clear(SaveR337_lRec);
                        SaveR337_lRec.TransferFields(DelR337_lRec);
                        SaveR337_lRec."Entry No." := DelR337_lRec."Entry No.";
                        SaveR337_lRec.Positive := DelR337_lRec.Positive;
                        SaveR337_lRec."Unique Batch ID in Save Res En" := UniqueIDSave_lInt;
                        SaveR337_lRec."Remain Qty for Allocation" := Abs(SaveR337_lRec."Quantity (Base)");

                        if DelSaveR337_lRec.Get(SaveR337_lRec."Entry No.", SaveR337_lRec.Positive) then begin  //Del Line if already exists any old entry
                            DelSaveR337_lRec.Delete
                        end;

                        SaveR337_lRec.Insert;
                    end;

                    DelR337_lRec.Delete;

                until DelR337_lRec.Next = 0;
            end;
        end;
        ItemJnlLine_lRec."Unique Batch ID in Save Res En" := UniqueIDSave_lInt;
        //SubConQCV2-NE

        ItemJnlLine_lRec."Skip Confirm Msg" := true;
        ItemJnlLine_lRec.Modify(true);

        //NG-NS 180222
        /*  IF "Document Type" = "Document Type"::Purchase THen begin
             IF (ItemJnlLine_lRec."Location Code" = ItemJnlLine_lRec."New Location Code") AND (ItemJnlLine_lRec."Bin Code" = ItemJnlLine_lRec."New Bin Code") then begin
                 ItemJnlLine_lRec.Delete(true);
                 Exit;
             End;
         End; *///01042025-as per mayank-anoop
                //NG-NE 180222

        if ItemLedgEntry_iRec."Item Tracking" <> ItemLedgEntry_iRec."item tracking"::None then
            InsertReservationEntry_gFnc(ItemJnlLine_lRec, ItemLedgEntry_iRec, false, 0);
        ReturnFlag := true;
        exit(ReturnFlag);
    end;

    local procedure CheckBinMandatory_lFnc(LocationCode_iCod: Code[10]): Boolean
    var
        Location_lRec: Record Location;
    begin
        Location_lRec.Get(LocationCode_iCod);
        exit(Location_lRec."Bin Mandatory");
    end;

    local procedure PostItemJnlLine_lFnc()
    var
        ItemJnlLine_lRec: Record "Item Journal Line";
    begin
        QCSetup_gRec.Get;
        QCSetup_gRec.TestField("QC Journal Template Name");
        QCSetup_gRec.TestField("QC General Batch Name");

        ItemJnlLine_lRec.Reset;
        ItemJnlLine_lRec.SetRange("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
        ItemJnlLine_lRec.SetRange("Journal Batch Name", QCSetup_gRec."QC General Batch Name");

        //The Below cannot be used because It doesnot close the Progress Bar if any error come
        //while posting Item Journal for Reclassification
        //CLEAR(ItemJnlPost_gCdu);
        //ItemJnlPost_gCdu.SetQCFlag_gFnc(TRUE);
        //ItemJnlPost_gCdu.RUN(ItemJnlLine_gRec);
        //ItemJnlPost_gCdu.SetQCFlag_gFnc(FALSE);

        ItemJnlLine_lRec.SetRange("Document No.", "No.");
        IF ItemJnlLine_lRec.FindFirst Then
            Codeunit.Run(Codeunit::"Item Jnl.-Post", ItemJnlLine_lRec);
        //I-C0009-1001310-04-NE
    end;

    procedure OpenPreviouslyPostedQC_gFnc()
    var
        PostedQCRcptHeder_lRec: Record "Posted QC Rcpt. Header";
    begin
        //I-C0009-1001310-04-NS
        PostedQCRcptHeder_lRec.Reset;
        PostedQCRcptHeder_lRec.SetRange("PreAssigned No.", "No.");
        Page.RunModal(Page::"Posted QC Rcpt. List", PostedQCRcptHeder_lRec);
        //I-C0009-1001310-04-NE
    end;

    procedure OpenAccpItemLedgerEntries_gFnc()
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        //I-C0009-1001310-04-NS
        ItemLedgerEntry_lRec.Reset;
        ItemLedgerEntry_lRec.SetRange("Document No.", "No.");
        ItemLedgerEntry_lRec.SetRange("QC No.", "No.");
        ItemLedgerEntry_lRec.SetFilter("Posted QC No.", '<>%1', '');
        ItemLedgerEntry_lRec.SetRange(Open, true);
        if "QC Location" <> "Store Location Code" then
            ItemLedgerEntry_lRec.SetFilter("Location Code", '%1|%2', "QC Location", "Store Location Code")
        else
            ItemLedgerEntry_lRec.SetRange("Location Code", "Store Location Code");
        Page.RunModal(Page::"Item Ledger Entries", ItemLedgerEntry_lRec);
        //I-C0009-1001310-04-NE
    end;

    procedure OpenRejeItemLedgerEntries_gFnc()
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        //I-C0009-1001310-04-NS
        ItemLedgerEntry_lRec.Reset;
        ItemLedgerEntry_lRec.SetRange("Document No.", "No.");
        ItemLedgerEntry_lRec.SetRange("QC No.", "No.");
        ItemLedgerEntry_lRec.SetFilter("Posted QC No.", '<>%1', '');
        ItemLedgerEntry_lRec.SetRange(Open, true);
        if "QC Location" <> "Rejection Location" then
            ItemLedgerEntry_lRec.SetFilter("Location Code", '%1|%2', "QC Location", "Rejection Location")
        else
            ItemLedgerEntry_lRec.SetRange("Location Code", "Rejection Location");
        Page.RunModal(Page::"Item Ledger Entries", ItemLedgerEntry_lRec);
        //I-C0009-1001310-04-NE
    end;

    procedure ValidateTrackResultEntry_gFnc(QCNo_iCod: Code[20])
    var
        QCRecptHeader_lRec: Record "QC Rcpt. Header";
    begin
        //I-C0009-1001310-04-NS
        QCRecptHeader_lRec.Get(QCNo_iCod);
        QCRecptHeader_lRec.TestField(Approve, false);
        //I-C0009-1001310-04-NE
    end;

    procedure PostSalesReturnQCRcpt_gFnc()
    var
        Location_lRec: Record Location;
        Result_lOpt: Option ACCEPT,REJECT,REWORK;
    begin
        //I-C0009-1001310-05-NS
        Location_lRec.Get("Location Code");
        if Location_lRec."Require Put-away" or Location_lRec."Require Pick" or Location_lRec."Directed Put-away and Pick" then begin
            ReInitVariable_lFnc;
            exit;
        end;

        ItemLdgrEntry_gRec.Reset;
        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Sales Return Receipt");
        ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
        if "Vendor Lot No." <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");
        if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No."] then begin
            ItemLdgrEntry_gRec.SetFilter("Remaining Quantity", '>%1', 0);
            //ItemLdgrEntry_gRec.SETFILTER(Result,'<>%1',ItemLdgrEntry_gRec.Result::"0");
            ItemLdgrEntry_gRec.SetRange(Open, true);
        end;

        if ItemLdgrEntry_gRec.FindSet then begin
            if "Item Tracking" = "item tracking"::None then begin
                QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_gRec);
                ReInitVariable_lFnc;
                //  END ELSE IF "Item Tracking" = "Item Tracking"::"Lot No." THEN BEGIN
                //    QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_gRec);
                //    ReInitVariable_lFnc;
            end else
                if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No.", "item tracking"::"Lot No."] then begin
                    CheckEnteredResult_lFnc(ItemLdgrEntry_gRec);
                    ItemLdgrEntry_gRec.FindSet;   //I-C0009-1001310-11-N
                    repeat

                        if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" > Abs(ItemLdgrEntry_gRec."Remaining Quantity") then
                            Error('Total result quanity (%1) cannot be morethan available quantity %2, check the Tracking Result',
                                ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity", Abs(ItemLdgrEntry_gRec."Remaining Quantity"));

                        //IF ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" = 0 THEN
                        //  ERROR('Enter Result in Item Tracking for Item Ledger Entry No. %1',ItemLdgrEntry_gRec."Entry No.");

                        if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::ACCEPT, ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty");
                        end;

                        if ItemLdgrEntry_gRec."Rejected Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REJECT, ItemLdgrEntry_gRec."Rejected Quantity");
                        end;

                        if ItemLdgrEntry_gRec."Rework Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REWORK, ItemLdgrEntry_gRec."Rework Quantity");
                        end;
                    until ItemLdgrEntry_gRec.Next = 0;
                    if IJLCreated_gBol then
                        PostItemJnlLine_lFnc();
                    ReInitVariable_lFnc;
                end;
        end;
        //I-C0009-1001310-05-NE
    end;

    procedure PostSalesReturnQCRcptREDEV_gFnc()//T12113-NS QC-Sales Return
    var
        Location_lRec: Record Location;
        Result_lOpt: Option ACCEPT,REJECT,REWORK;
    begin
        //I-C0009-1001310-05-NS
        Location_lRec.Get("Location Code");
        if Location_lRec."Require Put-away" or Location_lRec."Require Pick" or Location_lRec."Directed Put-away and Pick" then begin
            ReInitVariable_lFnc;
            exit;
        end;
        /* //T12113-OS
        ItemLdgrEntry_gRec.Reset;
        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Sales Return Receipt");
        ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
        ItemLdgrEntry_gRec.SetRange("Item No.", "Item No.");//T12113-N filter is applied due to duplicate Document No.
        if "Vendor Lot No." <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");
        if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No."] then begin
            ItemLdgrEntry_gRec.SetFilter("Remaining Quantity", '>%1', 0);
            ItemLdgrEntry_gRec.SetRange(Open, true);
        end;
       //T12113-OE */

        // if ItemLdgrEntry_gRec.FindSet then begin
        //T12113-NS QC-Sales Return
        ItemLdgrEntry_gRec.reset;
        if QCSetup_gRec."QC Block without Location" then
            ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Sales Return Receipt")
        else
            ItemLdgrEntry_gRec.SetRange("Entry Type", ItemLdgrEntry_gRec."Entry Type"::Transfer);
        ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
        ItemLdgrEntry_gRec.SetRange("Item No.", "Item No.");//T12113-N filter is applied due to duplicate Document No.
        if "Vendor Lot No." <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");
        ItemLdgrEntry_gRec.Setfilter("Remaining Quantity", '>%1', 0);
        if ItemLdgrEntry_gRec.FindSet() then begin
            if "Item Tracking" = "item tracking"::None then begin
                QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_gRec);
                ReInitVariable_lFnc;
            end else
                if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No.", "item tracking"::"Lot No."] then begin
                    CheckEnteredResult_lFnc(ItemLdgrEntry_gRec);
                    ItemLdgrEntry_gRec.FindSet;   //I-C0009-1001310-11-N
                    repeat

                        if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" > Abs(ItemLdgrEntry_gRec."Remaining Quantity") then
                            Error('Total result quanity (%1) cannot be morethan available quantity %2, check the Tracking Result',
                                ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity", Abs(ItemLdgrEntry_gRec."Remaining Quantity"));

                        if (ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" > 0) then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::ACCEPT, ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty");
                        end;

                        if ItemLdgrEntry_gRec."Rejected Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REJECT, ItemLdgrEntry_gRec."Rejected Quantity");
                        end;

                        if ItemLdgrEntry_gRec."Rework Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REWORK, ItemLdgrEntry_gRec."Rework Quantity");
                        end;
                    until ItemLdgrEntry_gRec.Next = 0;
                    if IJLCreated_gBol then //T12750-N
                        PostItemJnlLine_lFnc();
                    ReInitVariable_lFnc;
                end;
        end;
        //end;//T12113-O
    end;

    procedure PostTransferQCRcpt_gFnc()
    var
        Location_lRec: Record Location;
        Result_lOpt: Option ACCEPT,REJECT,REWORK;
    begin
        //I-C0009-1001310-06-NS
        Location_lRec.Get("Location Code");
        if Location_lRec."Require Put-away" or Location_lRec."Require Pick" or Location_lRec."Directed Put-away and Pick" then begin
            ReInitVariable_lFnc;
            exit;
        end;

        ItemLdgrEntry_gRec.Reset;
        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Transfer Receipt");
        ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
        ItemLdgrEntry_gRec.SetRange(Open, true);   //CP-N
        if "Vendor Lot No." <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");
        if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No."] then begin
            ItemLdgrEntry_gRec.SetFilter("Remaining Quantity", '>%1', 0);
            //ItemLdgrEntry_gRec.SETFILTER(Result,'<>%1',ItemLdgrEntry_gRec.Result::"0");
            ItemLdgrEntry_gRec.SetRange(Open, true);
        end;

        if ItemLdgrEntry_gRec.FindSet then begin
            if "Item Tracking" = "item tracking"::None then begin
                QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_gRec);
                ReInitVariable_lFnc;
                //  END ELSE IF "Item Tracking" = "Item Tracking"::"Lot No." THEN BEGIN
                //    QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_gRec);
                //    ReInitVariable_lFnc;
            end else
                if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No.", "item tracking"::"Lot No."] then begin
                    CheckEnteredResult_lFnc(ItemLdgrEntry_gRec);
                    ItemLdgrEntry_gRec.FindSet;   //I-C0009-1001310-11-N
                    repeat

                        if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" > Abs(ItemLdgrEntry_gRec."Remaining Quantity") then
                            Error('Total result quanity (%1) cannot be morethan available quantity %2, check the Tracking Result',
                                ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity", Abs(ItemLdgrEntry_gRec."Remaining Quantity"));

                        if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" = 0 then
                            Error('Enter Result in Item Tracking for Item Ledger Entry No. %1', ItemLdgrEntry_gRec."Entry No.");

                        if (ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" > 0) then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::ACCEPT, ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty");
                        end;

                        if ItemLdgrEntry_gRec."Rejected Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REJECT, ItemLdgrEntry_gRec."Rejected Quantity");
                        end;

                        if ItemLdgrEntry_gRec."Rework Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REWORK, ItemLdgrEntry_gRec."Rework Quantity");
                        end;
                    until ItemLdgrEntry_gRec.Next = 0;

                    if IJLCreated_gBol then //T12750-N
                        PostItemJnlLine_lFnc();
                    ReInitVariable_lFnc;
                end;
        end;
        //I-C0009-1001310-06-NE
    end;

    procedure PostTransferILEQCRcpt_gFnc()//T12113-NS QC-Ile
    var
        Location_lRec: Record Location;
        Result_lOpt: Option ACCEPT,REJECT,REWORK;
    begin
        //I-C0009-1001310-05-NS
        Location_lRec.Get("Location Code");
        if Location_lRec."Require Put-away" or Location_lRec."Require Pick" or Location_lRec."Directed Put-away and Pick" then begin
            ReInitVariable_lFnc;
            exit;
        end;
        /* //T12113-OS
        ItemLdgrEntry_gRec.Reset;
        ItemLdgrEntry_gRec.SetRange("Document Type", ItemLdgrEntry_gRec."document type"::"Sales Return Receipt");
        ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
        ItemLdgrEntry_gRec.SetRange("Item No.", "Item No.");//T12113-N filter is applied due to duplicate Document No.
        if "Vendor Lot No." <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");
        if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No."] then begin
            ItemLdgrEntry_gRec.SetFilter("Remaining Quantity", '>%1', 0);
            ItemLdgrEntry_gRec.SetRange(Open, true);
        end;
       //T12113-OE */

        // if ItemLdgrEntry_gRec.FindSet then begin
        //T12113-NS QC-ILE
        ItemLdgrEntry_gRec.reset;
        if not QCSetup_gRec."QC Block without Location" then//12968-N 
            ItemLdgrEntry_gRec.SetRange("Entry Type", ItemLdgrEntry_gRec."Entry Type"::Transfer);
        ItemLdgrEntry_gRec.SetRange("Document No.", "Document No.");
        ItemLdgrEntry_gRec.SetRange("Document Line No.", "Document Line No.");
        ItemLdgrEntry_gRec.SetRange("Item No.", "Item No.");//T12113-N filter is applied due to duplicate Document No.
        if "Vendor Lot No." <> '' then
            ItemLdgrEntry_gRec.SetRange("Lot No.", "Vendor Lot No.");
        ItemLdgrEntry_gRec.Setfilter("Remaining Quantity", '>%1', 0);
        ItemLdgrEntry_gRec.SetRange("Entry No.", "ILE No."); //21032025;
        if ItemLdgrEntry_gRec.FindSet() then begin
            if "Item Tracking" = "item tracking"::None then begin
                QCforItemLotorWithoutLot_lFnc(ItemLdgrEntry_gRec);
                ReInitVariable_lFnc;
            end else
                if "Item Tracking" in ["item tracking"::"Serial No.", "item tracking"::"Lot and Serial No.", "item tracking"::"Lot No."] then begin
                    CheckEnteredResult_lFnc(ItemLdgrEntry_gRec);
                    ItemLdgrEntry_gRec.FindSet;   //I-C0009-1001310-11-N
                    repeat

                        if ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity" > Abs(ItemLdgrEntry_gRec."Remaining Quantity") then
                            Error('Total result quanity (%1) cannot be morethan available quantity %2, check the Tracking Result',
                                ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" + ItemLdgrEntry_gRec."Rejected Quantity" + ItemLdgrEntry_gRec."Rework Quantity", Abs(ItemLdgrEntry_gRec."Remaining Quantity"));

                        if (ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty" > 0) then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::ACCEPT, ItemLdgrEntry_gRec."Accepted Quantity" + ItemLdgrEntry_gRec."Accepted with Deviation Qty");
                        end;

                        if ItemLdgrEntry_gRec."Rejected Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REJECT, ItemLdgrEntry_gRec."Rejected Quantity");
                        end;

                        if ItemLdgrEntry_gRec."Rework Quantity" > 0 then begin
                            QCforItemLotSeriaTracking_lFnc(ItemLdgrEntry_gRec, true, Result_lopt::REWORK, ItemLdgrEntry_gRec."Rework Quantity");
                        end;
                    until ItemLdgrEntry_gRec.Next = 0;
                    if IJLCreated_gBol then //T12750-N
                        PostItemJnlLine_lFnc();
                    ReInitVariable_lFnc;
                end;
        end else
            Error('Item Ledger Entry Not found for QC = %1', "No."); //21032025

        //do coding if required. Its better to place an error so that Posted QC is not made by system, so that wrong data is not there in system.
        // "Remaining Quantity" := 0;  //Delete QC Receipt if Item Journal Line Deleted
        //   ReInitVariable_lFnc;
        //end;//T12113-O
    end;

    local procedure UpdateReturnRcptLine_lFnc()
    var
        ReturnRcptLine_lRec: Record "Return Receipt Line";
        QCRcptLine_lRec: Record "QC Rcpt. Line";
    begin
        //To Update  the posted QC Receipt result into Return Receipt Line.
        //I-C0009-1001310-08-NS
        ReturnRcptLine_lRec.Reset;
        ReturnRcptLine_lRec.SetRange("Document No.", "Document No.");
        ReturnRcptLine_lRec.SetRange("Line No.", "Document Line No.");
        if ReturnRcptLine_lRec.FindFirst then begin
            ReturnRcptLine_lRec."Under Inspection Quantity" := ReturnRcptLine_lRec."Under Inspection Quantity" -
                                                                ("Qty to Accept with Deviation" + "Quantity to Accept" +
                                                                "Quantity to Reject" + "Quantity to Rework");

            ReturnRcptLine_lRec.Validate("Accepted with Deviation Qty", ReturnRcptLine_lRec."Accepted with Deviation Qty" +
                                        "Qty to Accept with Deviation");
            ReturnRcptLine_lRec.Validate("Accepted Quantity", ReturnRcptLine_lRec."Accepted Quantity" + "Quantity to Accept");
            ReturnRcptLine_lRec.Validate("Rejected Quantity", ReturnRcptLine_lRec."Rejected Quantity" + "Quantity to Reject");
            ReturnRcptLine_lRec.Validate("Reworked Quantity", ReturnRcptLine_lRec."Reworked Quantity" + "Quantity to Rework");
            if ReturnRcptLine_lRec."Under Inspection Quantity" = 0 then
                ReturnRcptLine_lRec."QC Pending" := false;
            ReturnRcptLine_lRec.Modify;
        end;

        "Total Accepted Quantity" := "Total Accepted Quantity" + "Quantity to Accept";
        "Total Under Deviation Acc. Qty" := "Total Under Deviation Acc. Qty" + "Qty to Accept with Deviation";
        "Total Rejected Quantity" := "Total Rejected Quantity" + "Quantity to Reject";
        "Total Rework Quantity" := "Total Rework Quantity" + "Quantity to Rework";
        "Remaining Quantity" := "Remaining Quantity" - ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" +
                                "Quantity to Rework");
        Modify(true);
        //I-C0009-1001310-08-NE
    end;

    local procedure UpdateTransferRcptLine_lFnc()
    var
        TransferRcptLine_lRec: Record "Transfer Receipt Line";
        QCRcptLine_lRec: Record "QC Rcpt. Line";
    begin
        //To Update  the posted QC Receipt result into Transfer Receipt Line.
        //I-C0009-1001310-08-NS
        TransferRcptLine_lRec.Reset;
        TransferRcptLine_lRec.SetRange("Document No.", "Document No.");
        TransferRcptLine_lRec.SetRange("Line No.", "Document Line No.");
        if TransferRcptLine_lRec.FindFirst then begin
            TransferRcptLine_lRec."Under Inspection Quantity" := TransferRcptLine_lRec."Under Inspection Quantity" -
                                                                ("Qty to Accept with Deviation" + "Quantity to Accept" +
                                                                "Quantity to Reject" + "Quantity to Rework");

            TransferRcptLine_lRec.Validate("Accepted with Deviation Qty", TransferRcptLine_lRec."Accepted with Deviation Qty" +
                                        "Qty to Accept with Deviation");
            TransferRcptLine_lRec.Validate("Accepted Quantity", TransferRcptLine_lRec."Accepted Quantity" + "Quantity to Accept");
            TransferRcptLine_lRec.Validate("Rejected Quantity", TransferRcptLine_lRec."Rejected Quantity" + "Quantity to Reject");
            TransferRcptLine_lRec.Validate("Reworked Quantity", TransferRcptLine_lRec."Reworked Quantity" + "Quantity to Rework");
            if TransferRcptLine_lRec."Under Inspection Quantity" = 0 then
                TransferRcptLine_lRec."QC Pending" := false;
            TransferRcptLine_lRec.Modify;
        end;

        "Total Accepted Quantity" := "Total Accepted Quantity" + "Quantity to Accept";
        "Total Under Deviation Acc. Qty" := "Total Under Deviation Acc. Qty" + "Qty to Accept with Deviation";
        "Total Rejected Quantity" := "Total Rejected Quantity" + "Quantity to Reject";
        "Total Rework Quantity" := "Total Rework Quantity" + "Quantity to Rework"; //I-C0009-1001310-07-N
        "Remaining Quantity" := "Remaining Quantity" - ("Quantity to Accept" + "Qty to Accept with Deviation" + "Quantity to Reject" +
                                "Quantity to Rework");
        Modify(true);
        //I-C0009-1001310-08-NE
    end;

    local procedure CheckTablePermission_lFnc()
    var
        PostedQCRcptHeader_lRec: Record "Posted QC Rcpt. Header";
        PostedQCRcptLine_lRec: Record "Posted QC Rcpt. Line";
        QCRcptHeader_lRec: Record "QC Rcpt. Header";
        QCRcptLine_lRec: Record "QC Rcpt. Line";
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        ReturnReceiptLine_lRec: Record "Return Receipt Line";
        TransferReceiptLine_lRec: Record "Transfer Receipt Line";
    begin
        if not PostedQCRcptHeader_lRec.ReadPermission then
            Error('You do not have Permission to access Posted QC Receipt Header Table');

        if not PostedQCRcptHeader_lRec.WritePermission then
            Error('You do not have Permission to access Posted QC Receipt Header Table');

        if not PostedQCRcptLine_lRec.ReadPermission then
            Error('You do not have Permission to access Posted QC Receipt Line Table');

        if not PostedQCRcptLine_lRec.WritePermission then
            Error('You do not have Permission to access Posted QC Receipt Line Table');

        if not QCRcptHeader_lRec.ReadPermission then
            Error('You do not have Permission to access QC Receipt Header Table');

        if not QCRcptHeader_lRec.WritePermission then
            Error('You do not have Permission to access QC Receipt Header Table');

        if not QCRcptLine_lRec.ReadPermission then
            Error('You do not have Permission to access QC Receipt Line Table');

        if not QCRcptLine_lRec.WritePermission then
            Error('You do not have Permission to access QC Receipt Line Table');
        /*
        IF NOT PurchRcptLine_lRec.READPERMISSION THEN
          ERROR('You do not have Permission to access Purchase Receipt Line Table');
        
        IF NOT PurchRcptLine_lRec.WRITEPERMISSION THEN
          ERROR('You do not have Permission to access Purchase Receipt Line Table');
        
        IF NOT ReturnReceiptLine_lRec.READPERMISSION THEN
          ERROR('You do not have Permission to access Return Receipt Line Table');
        
        IF NOT ReturnReceiptLine_lRec.WRITEPERMISSION THEN
          ERROR('You do not have Permission to access Return Receipt Line Table');
        
        IF NOT TransferReceiptLine_lRec.READPERMISSION THEN
          ERROR('You do not have Permission to access Transfer Receipt Line Table');
        
        IF NOT TransferReceiptLine_lRec.WRITEPERMISSION THEN
          ERROR('You do not have Permission to access Transfer Receipt Line Table');
        */

    end;

    local procedure ApproveCheckQCLineDetails_lFnc()
    var
        Item_lRec: Record Item;
        QCLineDetail_lRec: Record "QC Line Detail";
        QCRcptLine_lRec: Record "QC Rcpt. Line";
    begin
        Clear(Item_lRec);
        Item_lRec.Get("Item No.");
        if not Item_lRec."Entry for each Sample" then
            exit;

        if "Document Type" = "document type"::Production then
            exit;

        QCLineDetail_lRec.Reset;
        QCLineDetail_lRec.SetRange("QC Rcpt No.", "No.");
        if QCLineDetail_lRec.FindSet then begin
            repeat
                if QCLineDetail_lRec.Type = QCLineDetail_lRec.Type::Text then begin
                    QCLineDetail_lRec.TestField("Actual Text");
                end else
                    if QCLineDetail_lRec.Type = QCLineDetail_lRec.Type::Range then begin
                        QCLineDetail_lRec.TestField("Actual Value");
                    end else
                        if ((QCLineDetail_lRec.Type = QCLineDetail_lRec.Type::Maximum) or (QCLineDetail_lRec.Type = QCLineDetail_lRec.Type::Minimum)) then begin
                            QCLineDetail_lRec.TestField("Actual Value");
                        end;
            until QCLineDetail_lRec.Next = 0;
        end else
            Error('QC Line Details does not exist. Please insert it.');
        //QCV3-NE  24-01-18
    end;

    local procedure "--------T01118--------"()
    begin
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."));  //T01118-N
    end;
    //T12113-NB-NS
    procedure PostQCReceipt_gFnc(QCReceiptHdr_PRec: Record "QC Rcpt. Header"): Boolean
    var
        PostedQCReceiptHdr_lRec: Record "Posted QC Rcpt. Header";
        PostedQCReceiptLine_lRec: Record "Posted QC Rcpt. Line";
        QCReceiptLine_lRec: Record "QC Rcpt. Line";
        SalesLine_lRec: Record "Sales Line";
        QualityControlSetup_lRec: Record "Quality Control Setup";
        NoseriesManagement_lCdu: Codeunit "No. Series";//12092024
        Result_lBln: Boolean;
    begin
        if not confirm('Would you like to Post the QC Receipt?') then
            Exit;

        if QCReceiptHdr_PRec.FindFirst() then begin
            QualityControlSetup_lRec.Get();
            PostedQCReceiptHdr_lRec.Init();
            PostedQCReceiptHdr_lRec."No." := NoSeriesMgt_gCdu.GetNextNo(QualityControlSetup_lRec."Posted PreDispatch QC Nos", WorkDate(), true);
            PostedQCReceiptHdr_lRec.TransferFields(QCReceiptHdr_PRec);
            PostedQCReceiptHdr_lRec.Insert(true);
            QCReceiptLine_lRec.Reset();
            QCReceiptLine_lRec.SetRange("No.", QCReceiptHdr_PRec."No.");
            if QCReceiptLine_lRec.FindSet() then
                repeat
                    PostedQCReceiptLine_lRec.Init();
                    PostedQCReceiptLine_lRec.TransferFields(QCReceiptLine_lRec);
                    Result_lBln := PostedQCReceiptLine_lRec.Insert(true);
                until QCReceiptLine_lRec.Next() = 0;

            if SalesLine_lRec.Get(SalesLine_lRec."Document Type"::Order, QCReceiptHdr_PRec."Document No.", QCReceiptHdr_PRec."Document Line No.") then begin
                //SalesLine_lRec."QC No." := '';
                if (QCReceiptHdr_PRec."Quantity to Accept" + QCReceiptHdr_PRec."Qty to Accept with Deviation") = SalesLine_lRec."Qty. to Ship" then
                    //SalesLine_lRec."Posted QC No." := PostedQCReceiptHdr_lRec."No.";
                SalesLine_lRec.Modify();
            end;
        end;
        if Result_lBln then
            Message('QC Receipt is Posted Successfully.');
    end;
    //T12113-NB-NE

    //T12213-ABA ForQualityOrderOutputJournalLine-NS
    procedure InsertNegAdjJnlLine_lFnc(ProductionOrderLine_iRec: Record "Prod. Order Line")
    var
        ItemJnlLine_lRec: Record "Item Journal Line";
        QC_lRec: Record "Quality Control Setup";
        ItemJnlLine2_lRec: Record "Item Journal Line";
        ProdOrderRtngLine_lRec: Record "Prod. Order Routing Line";
        ProdOrderRtngLine2_lRec: Record "Prod. Order Routing Line";
        QCRcptHdr_lRec: Record "QC Rcpt. Header";
        ProdOrder_lRec: Record "Production Order";
        ProdOrderLine_lRec: Record "Prod. Order Line";
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";

    begin

        QCSetup_gRec.Get();
        QCSetup_gRec.TestField("QC Journal Template Name");
        QCSetup_gRec.TestField("QC General Batch Name");

        ProdOrder_lRec.get(ProdOrder_lRec.Status::Finished, ProductionOrderLine_iRec."Prod. Order No.");
        ProdOrderLine_lRec.Copy(ProductionOrderLine_iRec);
        QCRcptHdr_lRec.get(ProdOrder_lRec."QC Receipt No");

        // ProdOrderRtngLine_lRec.SetRange(Status, ProdOrderRtngLine_lRec.Status::Released);
        // ProdOrderRtngLine_lRec.SetRange("Prod. Order No.", ProdOrderLine_lRec."Prod. Order No.");
        // ProdOrderRtngLine_lRec.SetRange("Routing No.", ProdOrderLine_lRec."Routing No.");
        // ProdOrderRtngLine_lRec.SetRange("Routing Reference No.", ProdOrderLine_lRec."Routing Reference No.");
        // if not ProdOrderRtngLine_lRec.FindFirst then
        //     exit;
        // if (ProdOrderRtngLine_lRec."Next Operation No." = '') then
        //     exit;

        ItemJnlLine_lRec.Init;
        ItemJnlLine_lRec.Validate("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
        ItemJnlLine_lRec.Validate("Journal Batch Name", QCSetup_gRec."QC General Batch Name");

        ItemJnlLine2_lRec.Reset;
        ItemJnlLine2_lRec.SetRange("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
        ItemJnlLine2_lRec.SetRange("Journal Batch Name", QCSetup_gRec."QC General Batch Name");
        if ItemJnlLine2_lRec.FindLast then
            ItemJnlLine_lRec."Line No." := ItemJnlLine2_lRec."Line No." + 10000
        else
            ItemJnlLine_lRec."Line No." := 10000;

        ItemJnlLine_lRec."Document No." := ProdOrderLine_lRec."Prod. Order No.";
        ItemJnlLine_lRec."Posting Date" := QCRcptHdr_lRec."QC Date";
        ItemJnlLine_lRec."Document Date" := QCRcptHdr_lRec."QC Date";
        ItemJnlLine_lRec.Validate("Entry Type", ItemJnlLine_lRec."entry type"::"Negative Adjmt.");
        ItemJnlLine_lRec.Validate("Item No.", ProdOrderLine_lRec."Item No.");
        ItemJnlLine_lRec.Validate("Variant Code", ProdOrderLine_lRec."Variant Code");
        ItemJnlLine_lRec.Validate("Location Code", ProdOrderLine_lRec."Location Code");
        if ProdOrderLine_lRec."Bin Code" <> '' then
            ItemJnlLine_lRec.Validate("Bin Code", ProdOrderLine_lRec."Bin Code");
        ProdOrderLine_lRec.TestField("Finished Quantity");
        ItemJnlLine_lRec.Validate(quantity, ProdOrderLine_lRec."Finished Quantity");
        //ItemJnlLine_lRec.Validate("Lot No.", ItemLedgerEntry_lRec."Lot No.");
        ItemJnlLine_lRec.Insert;
        ItemLedgerEntry_lRec.Reset;
        ItemLedgerEntry_lRec.SetRange("Entry Type", ItemLedgerEntry_lRec."Entry Type"::Output);
        ItemLedgerEntry_lRec.SetRange("Document No.", ItemJnlLine_lRec."Document No.");//Finished Prod no.        
        ItemLedgerEntry_lRec.SetRange("Item No.", ItemJnlLine_lRec."Item No.");
        ItemLedgerEntry_lRec.SetRange("Location Code", ItemJnlLine_lRec."Location Code");
        ItemLedgerEntry_lRec.SetRange(Open, true);
        ItemLedgerEntry_lRec.SetFilter("Remaining Quantity", '>%1', 0);
        if ItemLedgerEntry_lRec.FindFirst then begin
            if ItemLedgerEntry_lRec."Item Tracking" <> ItemLedgerEntry_lRec."Item Tracking"::None then
                NegReservationEntry_lFnc(ItemJnlLine_lRec, ItemLedgerEntry_lRec);
        end;
    end;



    local procedure NegReservationEntry_lFnc(ItemJnlLine_iRec: Record "Item Journal Line"; ILE_lRec: Record "Item Ledger Entry")
    var
        ResEntry_lRec: Record "Reservation Entry";
        EntryNo_lInt: Integer;
        NextEntryNo_lInt: Integer;
    begin
        //To Insert the Reservation Entry for Negative Item Journal Line.

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
            //ResEntry_lRec.Validate("New Lot No.", ILE_lRec."Lot No.");
        end;
        if ILE_lRec."Serial No." <> '' then begin
            ResEntry_lRec.Validate("Serial No.", ILE_lRec."Serial No.");
            //ResEntry_lRec.Validate("New Serial No.", ILE_lRec."Serial No.");
        end;
        ResEntry_lRec."Shipment Date" := ILE_lRec."Posting Date";
        ResEntry_lRec."Reservation Status" := ResEntry_lRec."reservation status"::Prospect;
        ResEntry_lRec."Item Tracking" := ILE_lRec."Item Tracking";
        ResEntry_lRec.Quantity := -1 * Abs(ItemJnlLine_iRec.Quantity);
        ResEntry_lRec.Validate("Quantity (Base)", -1 * Abs(ItemJnlLine_iRec.Quantity));
        ResEntry_lRec."Qty. per Unit of Measure" := 1;
        ResEntry_lRec.Validate("Appl.-to Item Entry", ILE_lRec."Entry No.");
        ResEntry_lRec.Insert;
    end;

    local procedure FindNewLdgrEntryForUpdate_lFnc(ProductionOrderLine_iRec: Record "Prod. Order Line")
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
        PrOrderNo_lRec: Record "Production Order";
    begin
        if not PrOrderNo_lRec.get(PrOrderNo_lRec.Status::Finished, ProductionOrderLine_iRec."Prod. Order No.") then
            exit;
        ItemLedgerEntry_lRec.Reset;
        ItemLedgerEntry_lRec.SetRange("Entry Type", ItemLedgerEntry_lRec."Entry Type"::"Negative Adjmt.");
        ItemLedgerEntry_lRec.SetRange("Document No.", ProductionOrderLine_iRec."Prod. Order No.");//Finished Prod no.        
        ItemLedgerEntry_lRec.SetRange("Item No.", ProductionOrderLine_iRec."Item No.");
        ItemLedgerEntry_lRec.SetRange("Location Code", ProductionOrderLine_iRec."Location Code");
        if "Vendor Lot No." <> '' then
            ItemLedgerEntry_lRec.SetRange("Lot No.", "Vendor Lot No.");
        if ItemLedgerEntry_lRec.FindFirst then begin
            ItemLedgerEntry_lRec."QC No." := PrOrderNo_lRec."QC Receipt No";
            ItemLedgerEntry_lRec."Posted QC No." := PrOrderNo_lRec."Posted QC Receipt No";
            ItemLedgerEntry_lRec.Modify();
        end;

    end;

    local procedure PostNegAdjItemJnlLine_lFnc(ProductionOrderLine_iRec: Record "Prod. Order Line")
    var
        OutputItemJnlLine_lRec: Record "Item Journal Line";
    begin
        QCSetup_gRec.Get;
        QCSetup_gRec.TestField("QC Journal Template Name");
        QCSetup_gRec.TestField("QC General Batch Name");

        OutputItemJnlLine_lRec.Reset;
        OutputItemJnlLine_lRec.SetRange("Journal Template Name", QCSetup_gRec."QC Journal Template Name");
        OutputItemJnlLine_lRec.SetRange("Journal Batch Name", QCSetup_gRec."QC General Batch Name");
        OutputItemJnlLine_lRec.SetRange("Document No.", ProductionOrderLine_iRec."Prod. Order No.");
        IF OutputItemJnlLine_lRec.FindFirst Then
            Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", OutputItemJnlLine_lRec);

    end;

    procedure CheckWarrantyDateExist_lFnc(ItemLdgrEntry_iRec: Record "Item Ledger Entry"): Boolean
    var
        ItemTrackingCode_gRec: Record "Item Tracking Code";
        Location_lRec: Record Location;
    begin
        //To Check 'Require Warranty Date Entry Setup for IJL

        Item_gRec.Get(ItemLdgrEntry_iRec."Item No.");
        if Item_gRec."Item Tracking Code" <> '' then begin
            ItemTrackingCode_gRec.Get(Item_gRec."Item Tracking Code");
            if (ItemTrackingCode_gRec."Man. Warranty Date Entry Reqd.") then
                exit(true)
            else
                exit(false);
        end;
    end;

    procedure CheckExpirationDateExist_lFnc(ItemLdgrEntry_iRec: Record "Item Ledger Entry"): Boolean
    var
        ItemTrackingCode_gRec: Record "Item Tracking Code";
        Location_lRec: Record Location;
    begin
        //To Check 'Require Expiration Date Entry' in Setup for IJL

        Item_gRec.Get(ItemLdgrEntry_iRec."Item No.");
        if Item_gRec."Item Tracking Code" <> '' then begin
            ItemTrackingCode_gRec.Get(Item_gRec."Item Tracking Code");
            if (ItemTrackingCode_gRec."Man. Expir. Date Entry Reqd.") then
                exit(true)
            else
                exit(false);
        end;
    end;
    //T12213-ABA ForQualityOrderOutputJournalLine-NE
    procedure RemoveTrackingLines()
    var
        QCSalesTracking_lRec: Record "QC Sales Tracking";
    begin
        QCSalesTracking_lRec.Reset();
        QCSalesTracking_lRec.SetRange("QC No.", Rec."No.");
        if QCSalesTracking_lRec.FindFirst() then
            QCSalesTracking_lRec.Delete();
    end;

    procedure CheckOutputJournalLine_gRec()
    var
        IJL_lRec: Record "Item Journal Line";
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        QCSetup_lRec.Get();
        if IJL_lRec.Get("Item Journal Template Name", "Item General Batch Name", "Item Journal Line No.") then begin
            if QCSetup_lRec."Automatic Posting of Prod QC" then begin
                if (IJL_lRec."Run Time" = 0) or (IJL_lRec."Setup Time" = 0) then begin
                    if not Confirm(Text00018_gCtx) then
                        exit;

                end;
            end;
        end;
    end;

    // Procedure NotificationAction(ItemJnlLine_iRec: Record "Item Journal Line")
    // var
    //     IN_ErrorInfor: ErrorInfo;
    //     ReservationNotification: Notification;
    //     ReservationNotificationLbl: Label 'Output Journal Line is not found.';
    //     CheckReservationNotification: Label 'Check Output Journal Line?';
    //     //        
    //     item_lRec: Record Item;
    // //

    // begin

    //     item_lRec.Get(ItemJnlLine_iRec."Item No.");
    //     if not (item_lRec."Item Tracking Code" <> '') then
    //         exit;
    //     if ItemJnlLine_iRec.Get("Item Journal Template Name", "Item General Batch Name", "Item Journal Line No.") then begin
    //         ReservationNotification.Message(ReservationNotificationLbl);
    //         ReservationNotification.Scope := NotificationScope::LocalScope;
    //         ReservationNotification.AddAction(CheckReservationNotification, Codeunit::"Error Action Test", 'OpenItemTrackingLine', 'This is Notification tooltip');
    //         ReservationNotification.Send();
    //     end;

    // end;

    local procedure DeleteReservationEntryforSOQC(QCRcptHdr_iRec: Record "QC Rcpt. Header")
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

    //T12968-NS 02122024
    local procedure UpdateQCatMaterialonILE_lFnc(QCRcpt_lrec: Record "QC Rcpt. Header")
    var
        ile_lRec: Record "Item Ledger Entry";
    begin
        if QCRcpt_lrec."Remaining Quantity" = 0 then
            exit;

        ile_lRec.Reset();
        ile_lRec.SetRange("QC No.", QCRcpt_lrec."No.");
        ile_lRec.SetRange("Material at QC", true);
        if ile_lRec.FindSet() then
            repeat
                ile_lRec."Material at QC" := false;
                ile_lRec.Modify();
            until Next() = 0;

        //T12968-NE 02122024

    end;
}

