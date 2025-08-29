Report 75381 "QC Rejection Comments"
{
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(RejectionComment_gTxt; RejectionComment_gTxt)
                {
                    ApplicationArea = Basic;
                    Caption = 'Rejection Comment';
                    MultiLine = true;
                    ShowMandatory = true;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        RejectionComment_gTxt: Text[250];

    procedure GetRejComm_gFnc(): Text
    begin
        exit(RejectionComment_gTxt);
    end;
}

