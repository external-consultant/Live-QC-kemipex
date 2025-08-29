PageExtension 75412 Bins_75412 extends Bins
{
    layout
    {
        addafter(Dedicated)
        {
            field("Bin Category"; Rec."Bin Category")
            {
                ApplicationArea = Basic;
            }
        }
    }
}

