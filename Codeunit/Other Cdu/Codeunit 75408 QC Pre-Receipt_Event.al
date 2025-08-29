codeunit 75408 "QC Pre-Receipt_Event"
{

    //T12547-NS
    [EventSubscriber(ObjectType::Page, Page::"Purchase Order Subform", 'OnAfterValidateEvent', 'Qty. to Receive', false, false)]
    local procedure OnAfterValidateQtyToReceive(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        if not QCSetup_lRec.get then
            Exit;
        if QCSetup_lRec."Allow QC in Purchase Order" then begin
            Rec.CalcFields("Total No. of QC");
            if (Rec."Document Type" = Rec."Document Type"::order) and
            (rec."Pre-Receipt Inspection") and
            (rec."Total No. of QC" > 0) and
            (rec."QC Created") then
                Error('You cannot modify because QC No exists.');
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeletePurchaseLine(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        QCSetup_lRec: Record "Quality Control Setup";
    begin
        if rec.IsTemporary then
            exit;
        if not QCSetup_lRec.get then
            Exit;
        if QCSetup_lRec."Allow QC in Purchase Order" then begin
            if (rec."Document Type" = rec."Document Type"::Order) and rec."QC Created" then begin
                rec.CalcFields("Total No. of QC");
                if (rec."Total No. of QC" > 0) then
                    Rec.TestField("QC Created", false);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Pre-Receipt Inspection', false, false)]
    local procedure OnAfterValidateEvent(var Rec: Record "Purchase Line"; CurrFieldNo: Integer);
    var
        PurLine_LRec: Record "Sales Line";
        PurchaseHeader_lRec: Record "Purchase Header";
        QCSetup_lRec: Record "Quality Control Setup";

    begin
        if rec.IsTemporary then
            exit;
        QCSetup_lRec.get;
        if not QCSetup_lRec."Allow QC in Purchase Order" then
            exit;
        if (Rec.Type = Rec.Type::Item) and rec."Pre-Receipt Inspection" then begin
            PurchaseHeader_lRec.get(Rec."Document Type", rec."Document No.");
            if PurchaseHeader_lRec."Location Code" <> Rec."Location Code" then begin
                rec."Location Code" := PurchaseHeader_lRec."Location Code";
                rec.Modify();
            end;
        end else
            exit;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePostPurchaseDoc, '', false, false)]
    local procedure "Purch.-Post_OnBeforePostPurchaseDoc"(var Sender: Codeunit "Purch.-Post"; var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    var
        QCReceiptHeader_lRec: Record "QC Rcpt. Header";
        Text001_lTxt: Label ' On Purchase Line having Qc Rejection. Do you still want to continue with Receipt?';
        LineNo_lTxt: text;
        QCSetup_lRec: Record "Quality Control Setup";
        PurchaseLine_lRec: Record "Purchase Line";
    begin
        if not QCSetup_lRec.get then
            Exit;
        if QCSetup_lRec."Allow QC in Purchase Order" then begin
            Clear(LineNo_lTxt);
            PurchaseLine_lRec.Reset();
            PurchaseLine_lRec.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine_lRec.SetRange("Document No.", PurchaseHeader."No.");
            if PurchaseLine_lRec.FindSet() then
                repeat
                    if (PurchaseLine_lRec."Pre-Receipt Inspection") AND (PurchaseLine_lRec."Qty. to Receive" <> 0) then begin
                        PurchaseLine_lRec.TestField("QC Created");
                        QCReceiptHeader_lRec.Reset();
                        QCReceiptHeader_lRec.SetRange("Document Type", QCReceiptHeader_lRec."Document Type"::"Sales Order");
                        QCReceiptHeader_lRec.SetRange("Document No.", PurchaseHeader."No.");
                        QCReceiptHeader_lRec.SetRange("Document Line No.", PurchaseLine_lRec."Line No.");
                        If QCReceiptHeader_lRec.FindFirst() then begin
                            if (QCReceiptHeader_lRec."Quantity to Accept" + QCReceiptHeader_lRec."Qty to Accept with Deviation") <> PurchaseLine_lRec."Qty. to Receive" then
                                Error('Quantity to Receive does not match with Quantity to accept.');
                        end;
                        if PurchaseLine_lRec."QC Rejected Qty" > 0 then begin
                            IF LineNo_lTxt <> '' THEN
                                LineNo_lTxt := LineNo_lTxt + '|' + format(PurchaseLine_lRec."No.")

                            ELSE
                                LineNo_lTxt := format(PurchaseLine_lRec."No.");
                        end;
                    end;
                until PurchaseLine_lRec.Next() = 0;
            if LineNo_lTxt <> '' then
                if not Confirm(Text001_lTxt) then
                    exit;
        end;
        //T12547-NE
    end;

}
