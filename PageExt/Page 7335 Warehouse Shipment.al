pageextension 75391 WarehouseShipment extends "Warehouse Shipment"
{
    layout
    {

    }

    actions
    {
        addlast("&Shipment")
        {



        }
    }
    var
    //     QCControlSetup_gRec: Record "Quality Control Setup";
    // //T12113-NB-NS
    // procedure CreatePredispatchInspection_gfnc(): Boolean;
    // var
    //     WhseShipmentLine_lRec: Record "Warehouse Shipment Line";
    //     Item_lRec: Record Item;
    //     QCReceiptHeader_lRec: Record "QC Rcpt. Header";
    //     QCReciptLine_lRec: Record "QC Rcpt. Line";
    //     QCSpecificationLine_lRec: Record "QC Specification Line";
    //     NoseriesManagement_lCdu: Codeunit NoSeriesManagement;
    //     // DocumentNo_lCod: code[20];
    //     LineNo_lInt: Integer;
    //     Result_lBln: Boolean;
    // begin
    //     if not Confirm('Would you like to Create Predispatch?') then
    //         exit;

    //     WhseShipmentLine_lRec.Reset();
    //     WhseShipmentLine_lRec.SetRange("No.", rec."No.");
    //     if WhseShipmentLine_lRec.FindSet() then
    //         repeat
    //             if WhseShipmentLine_lRec."Source Type" = 37 then begin
    //                 WhseShipmentLine_lRec.TestField("PreDispatch Inspection Req", true);
    //                 if WhseShipmentLine_lRec."Qty. to Ship" = 0 then
    //                     Error('Unable to Create QC Dispatch');

    //                 QCControlSetup_gRec.Get();
    //                 QCControlSetup_gRec.TestField("PreDispatch QC Nos");

    //                 QCReceiptHeader_lRec.Reset();
    //                 QCReceiptHeader_lRec.Init();
    //                 //DocumentNo_lCod := NoseriesManagement_lCdu.GetNextNo(QCControlSetup_gRec."PreDispatch QC Nos", WorkDate(), true);
    //                 QCReceiptHeader_lRec."No." := '';
    //                 QCReceiptHeader_lRec."Document Type" := QCReceiptHeader_lRec."Document Type"::"Sales Order";
    //                 QCReceiptHeader_lRec."Document No." := WhseShipmentLine_lRec."Source No.";
    //                 QCReceiptHeader_lRec.Validate("Document Line No.", WhseShipmentLine_lRec."Source Line No.");
    //                 QCReceiptHeader_lRec.Validate("Item No.", WhseShipmentLine_lRec."Item No.");
    //                 QCReceiptHeader_lRec.Validate("Item Description", WhseShipmentLine_lRec.Description);
    //                 QCReceiptHeader_lRec.Validate("Receipt Date", rec."Posting Date");
    //                 QCReceiptHeader_lRec.Validate("Unit of Measure", WhseShipmentLine_lRec."Unit of Measure Code");
    //                 QCReceiptHeader_lRec.Validate("Order Quantity", WhseShipmentLine_lRec.Quantity);
    //                 QCReceiptHeader_lRec.Validate("Inspection Quantity", WhseShipmentLine_lRec.Quantity);
    //                 QCReceiptHeader_lRec.Validate("Location Code", WhseShipmentLine_lRec."Location Code");
    //                 QCReceiptHeader_lRec."QC Bin Code" := WhseShipmentLine_lRec."Bin Code";
    //                 QCReceiptHeader_lRec.Validate("PreDispatch QC", true);
    //                 QCReceiptHeader_lRec.Validate("Warehouse Shipment No.", WhseShipmentLine_lRec."No.");
    //                 QCReceiptHeader_lRec.Validate("Warehouse Shipment Line No.", WhseShipmentLine_lRec."Line No.");
    //                 QCReceiptHeader_lRec.Insert(true);

    //                 If Item_lRec.Get(WhseShipmentLine_lRec."Item No.") then
    //                     Item_lRec.TestField("Item Specification Code");

    //                 clear(LineNo_lInt);
    //                 QCReciptLine_lRec.Reset();
    //                 QCReciptLine_lRec.SetRange("No.", QCReceiptHeader_lRec."No.");
    //                 if QCReciptLine_lRec.FindLast() then
    //                     LineNo_lInt := QCReciptLine_lRec."Line No."
    //                 else
    //                     LineNo_lInt := 10000;

    //                 QCSpecificationLine_lRec.Reset();
    //                 QCSpecificationLine_lRec.SetRange("Item Specifiction Code", Item_lRec."Item Specification Code");
    //                 if QCSpecificationLine_lRec.FindSet() then
    //                     repeat
    //                         QCReciptLine_lRec.Init();
    //                         QCReciptLine_lRec."No." := QCReceiptHeader_lRec."No.";
    //                         QCReciptLine_lRec."Line No." := LineNo_lInt;
    //                         QCReciptLine_lRec.Code := QCSpecificationLine_lRec."Document Code";
    //                         QCReciptLine_lRec.Description := QCSpecificationLine_lRec.Description;
    //                         QCReciptLine_lRec."Unit of Measure Code" := QCSpecificationLine_lRec."Unit of Measure Code";
    //                         QCReciptLine_lRec.Method := QCSpecificationLine_lRec.Method;
    //                         QCReciptLine_lRec.Type := QCSpecificationLine_lRec.Type;
    //                         QCReciptLine_lRec."Min.Value" := QCSpecificationLine_lRec."Min.Value";
    //                         QCReciptLine_lRec."Max.Value" := QCSpecificationLine_lRec."Max.Value";
    //                         QCReciptLine_lRec.Mandatory := QCSpecificationLine_lRec.Mandatory;
    //                         QCReciptLine_lRec."Method Description" := QCSpecificationLine_lRec."Method Description";
    //                         QCReciptLine_lRec."Text Value" := QCSpecificationLine_lRec."Text Value";
    //                         QCReciptLine_lRec."Quality Parameter Code" := QCSpecificationLine_lRec."Quality Parameter Code";
    //                         QCReciptLine_lRec."Item Code" := QCSpecificationLine_lRec."Item Code";
    //                         QCReciptLine_lRec."Item Description" := QCSpecificationLine_lRec."Item Description";
    //                         QCReciptLine_lRec.Insert();
    //                         LineNo_lInt := LineNo_lInt + 10000;
    //                     until QCSpecificationLine_lRec.Next() = 0;
    //                 // WhseShipmentLine_lRec."QC No." := QCReceiptHeader_lRec."No.";
    //                 Result_lBln := WhseShipmentLine_lRec.Modify();
    //             end;
    //         until WhseShipmentLine_lRec.Next() = 0;
    //     exit(Result_lBln);
    // end;



}