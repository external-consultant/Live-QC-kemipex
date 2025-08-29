Page 75398 "Item Tracking For Prod. QC"
{
    PageType = List;
    SourceTable = "Reservation Entry";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Accepted Quantity"; Rec."Accepted Quantity")
                {
                    ApplicationArea = Basic;
                    Style = Favorable;
                    StyleExpr = true;
                }
                field("Accepted with Deviation Qty"; Rec."Accepted with Deviation Qty")
                {
                    ApplicationArea = Basic;
                    Style = Strong;
                    StyleExpr = true;
                }
                field("Rejected Quantity"; Rec."Rejected Quantity")
                {
                    ApplicationArea = Basic;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                field("Rework Quantity"; Rec."Rework Quantity")
                {
                    ApplicationArea = Basic;
                    Style = StrongAccent;
                    StyleExpr = true;
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rejection Reason field.', Comment = '%';
                    Description = 'T12113';
                }
                field("Rejection Reason Description"; Rec."Rejection Reason Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rejection Reason Description field.', Comment = '%';
                    Description = 'T12113';
                }
                field("Rework Reason"; Rec."Rework Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rework Reason field.', Comment = '%';
                }
                field("Rework Reason Description"; Rec."Rework Reason Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rework Reason Description field.', Comment = '%';
                }
                //T12545-NS
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ApplicationArea = All;
                    Caption = 'Manufacturing Date';
                    ToolTip = 'Specifies the Manufacturing Date for the item on the line.';
                }
                //T12545-NE

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Update All")
            {
                ApplicationArea = Basic;
                Image = MapDimensions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //QCV3-NS 24-01-18
                    Selection := StrMenu(Text0002_gCxt, 3);
                    if Selection = 0 then
                        exit;

                    /* Accept_gBln := Selection in [1, 3];
                    Reject_gBln := Selection in [2, 3];
                    Rework_gBln := Selection in [3, 3]; *///12072024-N OLD as per DD-ABA

                    if Rec.FindSet then begin
                        repeat
                            Rec."Accepted Quantity" := 0;
                            Rec."Accepted with Deviation Qty" := 0;
                            Rec."Rejected Quantity" := 0;
                            Rec."Rework Quantity" := 0;
                            /* if Accept_gBln then begin
                                Rec."Accepted Quantity" := Abs(Rec.Quantity);
                            end else
                                if Reject_gBln then begin
                                    Rec."Rejected Quantity" := Abs(Rec.Quantity);
                                end else
                                    if Rework_gBln then begin
                                        Rec."Rework Quantity" := Abs(Rec.Quantity);
                                    end;
                            Rec.Modify;   */ //12072024-N OLD as per DD-ABA                         

                            //12072024-NS OLD as per DD-ABA 
                            case Selection of
                                1:
                                    Rec."Accepted Quantity" := Abs(Rec.Quantity);
                                2:
                                    Rec."Rejected Quantity" := Abs(Rec.Quantity);
                                3:
                                    Rec."Rework Quantity" := Abs(Rec.Quantity);
                            end;
                            //12072024-NE OLD as per DD-ABA
                            Rec.Modify;
                        until Rec.Next = 0;
                    end;
                    //QCV3-NE 24-01-18
                end;
            }
            action("UnSelect Update All")
            {
                ApplicationArea = Basic;
                Image = DeleteQtyToHandle;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //QCV3-NS 24-01-18
                    if Rec.FindSet then begin
                        repeat
                            Rec."Accepted Quantity" := 0;
                            Rec."Accepted with Deviation Qty" := 0;
                            Rec."Rejected Quantity" := 0;
                            Rec."Rework Quantity" := 0;
                            Rec.Modify;
                        until Rec.Next = 0;
                    end;
                    //QCV3-NE 24-01-18
                end;
            }
        }
    }

    //T12113-NS
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        CheckRejectedReason;
    end;
    //T12113-NE
    var
        Selection: Integer;
        Accept_gBln: Boolean;
        Reject_gBln: Boolean;
        Rework_gBln: Boolean;
        Text0001_gCtx: label '%1 - %2';
        Text0002_gCxt: label '&Accept,&Reject,Rework';

    //T12113-NS

    local procedure CheckRejectedReason()
    var
    begin
        if Rec."Rejected Quantity" > 0 then
            Rec.TestField("Rejection Reason");
    end;
    //T12113-NE
}

