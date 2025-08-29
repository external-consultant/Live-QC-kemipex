pageextension 75398 WhseReceiptSubform extends "Whse. Receipt Subform"
{
    layout
    {
        addlast(Control1)
        {

            //T12547-NS
            field("Pre-Receipt Inspection"; Rec."Pre-Receipt Inspection")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Pre-Receipt Inspection field.', Comment = '%';
                Editable = false;
            }
            field("QC Created"; Rec."QC Created")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the QC Created field.', Comment = '%';
                Editable = false;
            }
            //12547-NE
        }
    }
    actions
    {


    }

}