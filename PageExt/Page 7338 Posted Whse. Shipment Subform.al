pageextension 75390 "PostedWhseShipmentSubform" extends "Posted Whse. Shipment Subform"
{
    layout
    {
        addlast(Control1)
        {
            //T12113-NB-NS

            field("PreDispatch Inspection Req"; rec."PreDispatch Inspection Req")
            {
                ApplicationArea = all;
                Caption = 'Predispatch Inspection Required';
            }

            //T12113-NB-NE
        }

    }
}