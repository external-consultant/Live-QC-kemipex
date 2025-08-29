tableextension 75423 QCItemJnlLine extends "Item journal line" //ISPL-SPLIT_Q2025
{
    fields
    {
        modify("Quantity Under Inspection")
        {
            trigger OnAfterValidate()
            var
                QualityControlProduction_lCdu: Codeunit "Quality Control - Production";
            begin
                QualityControlProduction_lCdu.CheckQuantity_lFnc(Rec); //I-C0009-1001310-04-N
            end;         // Make field read-only
        }
    }
}