pageextension 75388 Item_Vendor_Catalog_75388 extends "Item Vendor Catalog"
{
    layout
    {
        addlast(Control1)
        {
            field("QC Required"; Rec."QC Required")
            {
                ApplicationArea = All;
                Description = 'T12115-N';
                Caption = 'QC Required';
            }
        }
    }
}