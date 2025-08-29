
tableextension 75429 PostedQCExtrecptHdr extends "Posted QC Rcpt. Header"
{

    DrillDownPageId = "Posted QC Rcpt. List";//T12113-N  //P_ISPL-SPLIT_Q2025
    LookupPageID = "Posted QC Rcpt. List";

    fields
    {
        modify("Item Journal Template Name")
        {


            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-02 NS
                if "Item Journal Template Name" <> xRec."Item Journal Template Name" then
                    "Item General Batch Name" := '';
                //I-C0009-1001310-02 NE
            end;

        }
        modify("Returned Quantity")
        {


            trigger OnBeforeValidate()
            begin
                "Outstanding Returned Qty." := "Rejected Quantity" - "Returned Quantity"; //I-C0009-1001310-07-N
            end;
        }
        modify("Rejection Reason")
        {

            trigger OnBeforeValidate()
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
    }

    keys
    {

    }

    fieldgroups
    {
    }
    trigger OnAfterInsert()
    var
        ProductionOrder_lRec: Record "Production Order";
    begin
        //T12542-NS
        If ProductionOrder_lRec.Get(ProductionOrder_lRec.Status::Released, Rec."Document No.") then Begin
            ProductionOrder_lRec."QC Status" := ProductionOrder_lRec."QC Status"::Completed;
            ProductionOrder_lRec.Modify();
        End;
    end;
    //T12542-NE

    trigger OnAfterDelete()
    begin
        //I-C0009-1001310-01 NS
        PostedQCrcptLine_Rec.SetRange(PostedQCrcptLine_Rec."No.", "No.");
        if PostedQCrcptLine_Rec.FindFirst then
            repeat
                PostedQCrcptLine_Rec.Delete;
            until PostedQCrcptLine_Rec.Next = 0;
        //I-C0009-1001310-01 NE
    end;

    var
        PostedQCrcptLine_Rec: Record "Posted QC Rcpt. Line";

    procedure ShowItemTrackingLines()
    var
        ItemTrackingMgt: Codeunit "QC Mgt";
    begin
        //I-C0009-1001310-02 NS
        if "Vendor Lot No." <> '' then
            ItemTrackingMgt.SetLotNo_gFnc("Vendor Lot No.");
        //ItemTrackingMgt.CallPostedItemTrackingFrm_gFnc(DATABASE::"Purch. Rcpt. Line",0,"Document No.",'',0,"Document Line No.");    //I-C0009-1001310-08-O
        //I-C0009-1001310-08-NS
        if "Document Type" = "document type"::Purchase then
            ItemTrackingMgt.CallPostedItemTrackingFrmPosted_gFnc(Database::"Purch. Rcpt. Line", 0, "Document No.", '', 0, "Document Line No.", Rec)
        else
            if "Document Type" = "document type"::"Sales Return" then
                ItemTrackingMgt.CallPostedItemTrackingFrmPosted_gFnc(Database::"Return Receipt Line", 0, "Document No.", '', 0, "Document Line No.", Rec)
            else
                if "Document Type" = "document type"::"Transfer Receipt" then
                    ItemTrackingMgt.CallPostedItemTrackingFrmPosted_gFnc(Database::"Transfer Receipt Line", 0, "Document No.", '', 0, "Document Line No.", Rec)
                else
                    if "Document Type" = "Document type"::ile then  //T12113-ABA-N
                        ItemTrackingMgt.Retest_CallPostedItemTrackingFrmPosted_gFnc(Database::"Item Ledger Entry", 0, "Document No.", '', 0, "Document Line No.", Rec);
        //I-C0009-1001310-08-NE
        if "Vendor Lot No." <> '' then
            ItemTrackingMgt.SetLotNo_gFnc('');
        //I-C0009-1001310-02 NE
    end;

    procedure OpenAccpItemLedgerEntries_gFnc()
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        //I-C0009-1001310-04-NS
        ItemLedgerEntry_lRec.Reset;
        if "Document Type" = "document type"::Purchase then
            ItemLedgerEntry_lRec.SetRange("Document No.", "PreAssigned No.");
        ItemLedgerEntry_lRec.SetRange("Document No.", "PreAssigned No.");
        ItemLedgerEntry_lRec.SetRange("QC No.", "PreAssigned No.");
        ItemLedgerEntry_lRec.SetRange("Posted QC No.", "No.");
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
        if "Document Type" = "document type"::Purchase then
            ItemLedgerEntry_lRec.SetRange("Document No.", "PreAssigned No.");
        ItemLedgerEntry_lRec.SetRange("QC No.", "PreAssigned No.");
        ItemLedgerEntry_lRec.SetRange("Posted QC No.", "No.");
        ItemLedgerEntry_lRec.SetRange(Open, true);
        if "QC Location" <> "Rejection Location" then
            ItemLedgerEntry_lRec.SetFilter("Location Code", '%1|%2', "QC Location", "Rejection Location")
        else
            ItemLedgerEntry_lRec.SetRange("Location Code", "Rejection Location");
        Page.RunModal(Page::"Item Ledger Entries", ItemLedgerEntry_lRec);
        //I-C0009-1001310-04-NE
    end;

    procedure OpenReworkItemLedgerEntries_gFnc()
    var
        ItemLedgerEntry_lRec: Record "Item Ledger Entry";
    begin
        //I-C0009-1001310-08-NS
        ItemLedgerEntry_lRec.Reset;
        if "Document Type" = "document type"::Purchase then
            ItemLedgerEntry_lRec.SetRange("Document No.", "PreAssigned No.");
        ItemLedgerEntry_lRec.SetRange("QC No.", "PreAssigned No.");
        ItemLedgerEntry_lRec.SetRange("Posted QC No.", "No.");
        ItemLedgerEntry_lRec.SetRange(Open, true);
        if "QC Location" <> "Rework Location" then
            ItemLedgerEntry_lRec.SetFilter("Location Code", '%1|%2', "QC Location", "Rework Location")
        else
            ItemLedgerEntry_lRec.SetRange("Location Code", "Rework Location");
        Page.RunModal(Page::"Item Ledger Entries", ItemLedgerEntry_lRec);
        //I-C0009-1001310-08-NE
    end;
}

