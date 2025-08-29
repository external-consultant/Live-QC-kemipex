TableExtension 75420 Location_75420 extends Location
{
    fields
    {

        modify("Is Main Location")
        {


            trigger OnAfterValidate()
            begin
                //I-C0009-1001310-04-NS
                if "Is Main Location" then
                    "Main Location" := Code;
                //I-C0009-1001310-04-NE
            end;
        }

        modify("Rejection Category")
        {


            trigger OnBeforeValidate()
            var
                ItemLedgerEntry_lRec: Record "Item Ledger Entry";
            begin
                //I-C0009-1001310-04-NS
                ItemLedgerEntry_lRec.SetFilter("Location Code", Code);
                if ItemLedgerEntry_lRec.FindFirst then
                    Error(Text33029230_gCtx, "Rejection Category");
                //I-C0009-1001310-04-NE
            end;
        }

    }

    var
        Text33029230_gCtx: label 'You cannot change %1 because there are one or more ledger entries for this Location.';
}

