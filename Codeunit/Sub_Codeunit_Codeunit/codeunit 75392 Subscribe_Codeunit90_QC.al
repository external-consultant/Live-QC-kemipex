codeunit 75392 Subscribe_Codeunit90_QC
{
    //     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeInsertReceiptHeader', '', false, false)]
    //     local procedure OnBeforeInsertReceiptHeader(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var IsHandled: Boolean; CommitIsSuppressed: Boolean);
    //     var
    //         PurchaseLine_lRec: Record "Purchase Line";
    //         Item_lRec: Record Item;
    //         QualityControlSetup_lRec: Record "Quality Control Setup";
    //         Location_lRec: Record Location;
    //     begin
    //         Clear(QualityControlSetup_lRec);
    //         QualityControlSetup_lRec.Get();
    //         If QualityControlSetup_lRec."Allow QC in GRN" then begin
    //             PurchaseLine_lRec.Reset();
    //             PurchaseLine_lRec.SetRange("Document No.", PurchHeader."No.");
    //             PurchaseLine_lRec.SetRange("Document Type", PurchHeader."Document Type"::Order);
    //             PurchaseLine_lRec.SetRange(Type, PurchaseLine_lRec.Type::Item);
    //             PurchaseLine_lRec.SetFilter("Qty. to Receive", '<>%1', 0);
    //             If PurchaseLine_lRec.findset() then
    //                 repeat
    //                     Item_lRec.Reset();
    //                     Item_lRec.SetRange("No.", PurchaseLine_lRec."No.");
    //                     Item_lRec.SetFilter("QC Required", '=%1', true);
    //                     If Item_lRec.FindFirst() then begin
    //                         Location_lRec.Reset();
    //                         Location_lRec.SetRange(Code, PurchaseLine_lRec."Location Code");
    //                         Location_lRec.SetRange("QC Category", false);
    //                         If Location_lRec.FindFirst() then
    //                             Error('Purchase Line must have a location code having QC category true')
    //                     end;
    //                 until PurchaseLine_lRec.Next() = 0;
    //         end;
    //     end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Location Code', true, true)]
    local procedure "Purchase Line_OnAfterValidateEvent_Location Code"
    (
        var Rec: Record "Purchase Line";
        var xRec: Record "Purchase Line";
        CurrFieldNo: Integer
    )
    var
        PurchaseLine_lRec: Record "Purchase Line";
        Item_lRec: Record Item;
        QualityControlSetup_lRec: Record "Quality Control Setup";
    begin
        //T12113-ABA-OS
        // Clear(QualityControlSetup_lRec);
        // QualityControlSetup_lRec.Get();
        // If QualityControlSetup_lRec."Allow QC in GRN" then begin 
        //T12113-ABA-OE

        Clear(QualityControlSetup_lRec);
        QualityControlSetup_lRec.Get();
        If not QualityControlSetup_lRec."QC Block without Location" then begin
            PurchaseLine_lRec.Reset();
            PurchaseLine_lRec.SetRange("Document Type", Rec."Document Type"::Order);
            PurchaseLine_lRec.SetRange("Document No.", Rec."Document No.");
            PurchaseLine_lRec.SetRange("Line No.", Rec."Line No.");
            PurchaseLine_lRec.Setrange(Type, PurchaseLine_lRec.Type::Item);
            If PurchaseLine_lRec.FindFirst() then begin
                Item_lRec.Reset();
                Item_lRec.SetRange("No.", PurchaseLine_lRec."No.");
                //Item_lRec.SetRange("QC Required", True);//T12113-ABA-O
                Item_lRec.SetRange("Allow QC in GRN", true);//T12113-ABA-N         
                If Item_lRec.FindFirst() then
                    Error('You cannot change the location code for this item %1', Item_lRec."No.");
                // end;//T12113-ABA-O

            end;
        end;
    End;
}



