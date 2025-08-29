Page 75406 "Vendor Rating Setup"
{
    Editable = true;
    PageType = List;
    SourceTable = "Vendor Rating Setup";
    UsageCategory = Administration;
    SourceTableView = sorting(Type, Code, "Sub Type")
                      where(Type = const("Vendor Rating"));

    ApplicationArea = all;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic;
                }
                field("Sub Type"; Rec."Sub Type")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("From Value"; Rec."From Value")
                {
                    ApplicationArea = Basic;
                }
                field("To Value"; Rec."To Value")
                {
                    ApplicationArea = Basic;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = Basic;
                }
                field("Inserted DateTime"; Rec."Inserted DateTime")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Modify DateTime"; Rec."Modify DateTime")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Value Text"; Rec."Value Text")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }


}

