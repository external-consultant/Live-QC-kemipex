pageextension 75383 ProdBomLineExt extends "Production BOM Lines"
{
    layout
    {
        addlast(Control1)
        {
            //T12113-ABA-NS
            field(Viscosity; rec.Viscosity)
            {
                ApplicationArea = All;
            }
            //T12113-ABA-NE
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}