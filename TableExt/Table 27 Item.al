TableExtension 75421 Item_75421 extends Item
{
    fields
    {

        modify("Allow QC in GRN")
        {

            trigger OnBeforeValidate()
            var
                Txt001_lTxt: Label 'This Boolean will help you to manage QC on Purchase Receipt.';
            begin
                if "Allow QC in GRN" then
                    Message(Txt001_lTxt);

            end;
        }
        modify("Allow QC in Production")
        {

            trigger OnBeforeValidate()
            var
                Txt001_lTxt: Label 'This Boolean will help you to manage QC in Production Order but for further Creating a QC Receipt, request you to manage QC required at Routing level.';
            begin
                if "Allow QC in Production" then
                    Message(Txt001_lTxt);

            end;
        }


    }


    //Unsupported feature: Code Modification on "PickItem(PROCEDURE 51)".

    //procedure PickItem();
    //Parameters and return type have not been exported.
    //>>>> ORIGINAL CODE:
    //begin
    /*
    ItemList.SetTempFilteredItemRec(Item);
    IF Item.FINDFIRST THEN;
    ItemList.SETTABLEVIEW(Item);
    ItemList.SETRECORD(Item);
    ItemList.LOOKUPMODE := TRUE;
    #6..8
      CLEAR(Item);

    EXIT(Item."No.");
    */
    //end;
    //>>>> MODIFIED CODE:
    //begin
    /*
    IF Item.FINDSET THEN
      REPEAT
        Item.MARK(TRUE);
      UNTIL Item.NEXT = 0;
    IF Item.FINDFIRST THEN;
    Item.MARKEDONLY := TRUE;

    #3..11
    */
    //end;

    //T12115-NS
    procedure CheckItemVendorCatelogueForQC(VendorCode: Code[20]): Boolean
    var
        ItemVendor: Record "Item Vendor";
    begin
        ItemVendor.Reset();
        ItemVendor.SetRange("Item No.", Rec."No.");
        ItemVendor.SetRange("Vendor No.", VendorCode);
        ItemVendor.SetRange("QC Required", true);
        if ItemVendor.FindFirst() then
            exit(true)
        else
            exit(false);

    end;
    //T12115-NE
}

