Page 75419 "Quality Control Link"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
    }

    actions
    {
        area(processing)
        {
            group("Quality Control")
            {
                Caption = 'Quality Control';
                action("QC Parameter")
                {
                    ApplicationArea = Basic;
                    Image = LiFo;
                    RunObject = Page "QC Parameter";
                    RunPageView = sorting(Code);
                }
                action("QC Specification List")
                {
                    ApplicationArea = Basic;
                    Image = LimitedCredit;
                    RunObject = Page "QC Specification List";
                    RunPageView = sorting("No.");
                }
                action("Item List")
                {
                    ApplicationArea = Basic;
                    Image = LineDescription;
                    RunObject = Page "Item List";
                }
                action("QC Rcpt. List")
                {
                    ApplicationArea = Basic;
                    Image = Period;
                    RunObject = Page "QC Rcpt. List";
                }
                action("Posted Purchase Rcpts Details")
                {
                    ApplicationArea = Basic;
                    Image = Period;
                    RunObject = Page "Posted Purchase Rcpts Details";
                }

                action("QC Approval Entry")
                {
                    ApplicationArea = Basic;
                    Image = Period;
                    RunObject = Page "QC Approval Entry";
                }
            }
            group(History)
            {
                Caption = 'History';
                action("Posted QC Rcpt. List")
                {
                    ApplicationArea = Basic;
                    Image = History;
                    RunObject = Page "Posted QC Rcpt. List";
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action("Quality Control Setup")
                {
                    ApplicationArea = Basic;
                    Image = Salutation;
                    RunObject = Page "Quality Control Setup";
                }

            }
        }
    }
}

