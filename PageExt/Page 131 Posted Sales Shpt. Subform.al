pageextension 75386 "Posted Sales Shpt. Subform Ext" extends "Posted Sales Shpt. Subform"
{
    layout
    {
        addafter("Quantity Invoiced")
        {

            field("PreDispatch Inspection Req."; Rec."PreDispatch Inspection Req.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the PreDispatch Inspection Required field.', Comment = '%';
            }
            // field("QC No"; Rec."QC No")
            // {
            //     ApplicationArea = All;
            //     ToolTip = 'Specifies the value of the QC No field.', Comment = '%';
            //     trigger OnDrillDown()
            //     var
            //         QCRcptHeader_lRec: Record "QC Rcpt. Header";
            //     begin
            //         if QCRcptHeader_lRec.Get(Rec."No.") then
            //             Page.Run(75383, QCRcptHeader_lRec);
            //     end;
            // }
            // field("Posted QC No"; Rec."Posted QC No")
            // {
            //     ApplicationArea = All;
            //     ToolTip = 'Specifies the value of the Posted QC No field.', Comment = '%';
            //     trigger OnDrillDown()
            //     var
            //         PostQCRcptHeader_lRec: Record "Posted QC Rcpt. Header";
            //     begin
            //         if PostQCRcptHeader_lRec.Get(Rec."No.") then
            //             Page.Run(75386, PostQCRcptHeader_lRec);
            //     end;
            // }
        }
    }
}
