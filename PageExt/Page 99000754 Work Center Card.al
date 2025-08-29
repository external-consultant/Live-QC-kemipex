PageExtension 75414 Work_Center_Card_75414 extends "Work Center Card"
{
    layout
    {
        addafter("From-Production Bin Code")
        {
            group("Quality Control")
            {
                Caption = 'Quality Control';
                field("QC Work Center"; Rec."QC Work Center")
                {
                    ApplicationArea = Basic;
                }
                field("QC Output Journal Template"; Rec."QC Output Journal Template")
                {
                    ApplicationArea = Basic;
                    Editable = Rec."QC Work Center";
                }
                field("QC Output Journal Batch"; Rec."QC Output Journal Batch")
                {
                    ApplicationArea = Basic;
                    Editable = Rec."QC Work Center";
                }
            }
        }
    }
}

