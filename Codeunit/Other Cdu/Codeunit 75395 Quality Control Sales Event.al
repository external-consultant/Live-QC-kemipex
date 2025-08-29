codeunit 75395 "Codeunit 75395 QC Sales_Event"
{
    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnAfterValidateEvent', 'Qty. to Ship', false, false)]
    local procedure OnAfterValidateQtyToShip(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        QCSetup_lRec: Record "Quality Control Setup";//T12166-N
    begin
        //T12166-NS
        if not QCSetup_lRec.get then
            Exit;
        if QCSetup_lRec."Allow QC in Sales Order" then begin
            //T12166-NE
            Rec.CalcFields("Total No. of QC");
            if (Rec."Document Type" = Rec."Document Type"::order) and
            (rec."PreDispatch Inspection Req") and
            (rec."Total No. of QC" > 0) and
            (rec."QC Created") then
                Error('You cannot modify because QC No exists.');
        end;//T12166-N
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        QCSetup_lRec: Record "Quality Control Setup";//T12166-N
    begin
        //T12166-NS
        if not QCSetup_lRec.get then
            Exit;
        if QCSetup_lRec."Allow QC in Sales Order" then begin
            //T12166-NE
            if (rec."Document Type" = rec."Document Type"::Order) and rec."QC Created" then begin
                rec.CalcFields("Total No. of QC");
                if (rec."Total No. of QC" > 0) then
                    Rec.TestField("QC Created", false);
            end;
        end;//T12166-N
    end;

    //T12113-NB-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        SalesLine_lRec: Record "Sales Line";
        QCReceiptHeader_lRec: Record "QC Rcpt. Header";
        Text001_lTxt: Label ' On Sales Line having Qc Rejection. Do you still want to continue with Shipment?';
        LineNo_lTxt: text;
        QCSetup_lRec: Record "Quality Control Setup";//T12166-N
    begin
        //code will check Sales post/Whse Shipment Post
        //T12166-NS
        if not QCSetup_lRec.get then
            Exit;
        if QCSetup_lRec."Allow QC in Sales Order" then begin
            //T12166-NE
            Clear(LineNo_lTxt);
            SalesLine_lRec.Reset();
            SalesLine_lRec.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine_lRec.SetRange("Document No.", SalesHeader."No.");
            if SalesLine_lRec.FindSet() then
                repeat
                    if (SalesLine_lRec."PreDispatch Inspection Req") AND (SalesLine_lRec."Qty. to Ship" <> 0) then begin
                        SalesLine_lRec.TestField("QC Created");
                        QCReceiptHeader_lRec.Reset();
                        QCReceiptHeader_lRec.SetRange("Document Type", QCReceiptHeader_lRec."Document Type"::"Sales Order");
                        QCReceiptHeader_lRec.SetRange("Document No.", SalesHeader."No.");
                        QCReceiptHeader_lRec.SetRange("Document Line No.", SalesLine_lRec."Line No.");
                        If QCReceiptHeader_lRec.FindFirst() then begin
                            if (QCReceiptHeader_lRec."Quantity to Accept" + QCReceiptHeader_lRec."Qty to Accept with Deviation") <> SalesLine_lRec."Qty. to Ship" then
                                Error('Quantity to ship does not match with Quantity to accept.');
                        end;
                        if SalesLine_lRec."QC Rejected Qty" > 0 then begin
                            IF LineNo_lTxt <> '' THEN
                                LineNo_lTxt := LineNo_lTxt + '|' + format(SalesLine_lRec."No.")

                            ELSE
                                LineNo_lTxt := format(SalesLine_lRec."No.");
                        end;
                    end;
                until SalesLine_lRec.Next() = 0;
            if LineNo_lTxt <> '' then
                if not Confirm(Text001_lTxt) then
                    exit;
        end;//T12166-N
    end;
    //T12113-NB-NE
}
