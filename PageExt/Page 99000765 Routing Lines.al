PageExtension 75415 Routing_Lines_75415 extends "Routing Lines"
{
    layout
    {
        addafter(Description)
        {
            field("QC Required"; Rec."QC Required")
            {
                ApplicationArea = Basic;
            }
        }
    }
}

