codeunit 75396 SalesLineTableSub
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeUpdateUnitPrice, '', false, false)]
    local procedure "Sales Line_OnBeforeUpdateUnitPrice"(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean)
    var
        Cust_lRec: Record Customer;
    begin
        Cust_lRec.Reset();
        IF Cust_lRec.GET(SalesLine."Sell-to Customer No.") then begin
            If Cust_lRec."IC Partner Code" <> '' then begin
                Handled := true;
                if Not GetInterCompanyTransferPrice(SalesLine) then
                    Message('Inter-Company Transfer Price is not defined for the given combination.');
            end;
        end;
    end;


    procedure GetInterCompanyTransferPrice(Var SalesLine_iRec: Record "Sales Line"): Boolean
    var
        Cust_lRec: Record Customer;
        SalesHdr_lRec: Record "Sales Header";
        TransPriceLt_Rec: Record "Transfer Price List";
        Item_lRec: Record Item;
        CurrencyFactor_lDec: Decimal;
    begin
        If SalesLine_iRec.Type <> SalesLine_iRec.Type::Item then
            exit;
        if SalesLine_iRec."No." = '' then
            Exit;
        // If SalesLine_iRec."Unit of Measure Code" = '' then
        //     exit;

        CurrencyFactor_lDec := 0;
        Cust_lRec.Reset();
        If Cust_lRec.GET(SalesLine_iRec."Sell-to Customer No.") then
            If Cust_lRec."IC Partner Code" <> '' then begin
                SalesHdr_lRec.Reset();
                SalesHdr_lRec.SetRange("Document Type", SalesLine_iRec."Document Type");
                SalesHdr_lRec.SetRange("No.", SalesLine_iRec."Document No.");
                If SalesHdr_lRec.FindFirst() then begin

                    TransPriceLt_Rec.Reset();
                    TransPriceLt_Rec.SetRange("Type Of Transaction", TransPriceLt_Rec."Type Of Transaction"::Sales);
                    TransPriceLt_Rec.SetRange("IC Partner Code", Cust_lRec."IC Partner Code");
                    TransPriceLt_Rec.SetFilter("Starting Date", '<=%1', SalesHdr_lRec."Order Date");
                    TransPriceLt_Rec.SetFilter("Ending Date", '>=%1', SalesHdr_lRec."Order Date");
                    If TransPriceLt_Rec.FindFirst() then begin
                        IF (TransPriceLt_Rec."Margin %" = 0) then
                            Error('Margin % should have value in Transfer Price for Customer No. %1', SalesLine_iRec."Sell-to Customer No.");

                        // Item_lRec.Reset();
                        // IF Item_lRec.GET(SalesLine_iRec."No.") then begin
                        SalesLine_iRec.Validate("Unit Price Base UOM 2", ((SalesLine_iRec."Unit Cost" / SalesLine_iRec."Qty. per Unit of Measure") * (1 + (TransPriceLt_Rec."Margin %" / 100))));
                        Exit(True);
                        // end;
                    end;
                end;
            end else
                Exit(true);
    end;


    var
}