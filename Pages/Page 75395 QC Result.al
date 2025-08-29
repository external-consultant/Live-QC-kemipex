Page 75395 "QC Result"
{
    // ------------------------------------------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // ------------------------------------------------------------------------------------------------------------------------------
    // ID                     DATE        AUTHOR
    // ------------------------------------------------------------------------------------------------------------------------------
    // I-C0009-1001310-04     27/08/12    Dipak Patel/Nilesh Gajjar
    //                        QC Module - Redesign Released.
    // I-C0009-1400405-01     05/08/14    Chintan Panchal
    //                        Upgrade to NAV 2013 R2
    // ------------------------------------------------------------------------------------------------------------------------------

    PageType = Card;
    SourceTable = "Item Ledger Entry";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Rec."Posted QC No." = '';
                Caption = 'General';
                field("QC No."; Rec."QC No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            part(Control1000000007; "QC Line Details")
            {
                SubPageLink = "QC Rcpt No." = field("QC No."),
                              "Serial No." = field("Serial No."),
                              "Lot No." = field("Lot No.");
                ApplicationArea = all;
                Editable = Rec."Posted QC No." = '';
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("<Action1907935204>")
            {
                Caption = '&Function';
                action("Enter Details")
                {
                    ApplicationArea = Basic;

                    trigger OnAction()
                    begin
                        QCLineDetail_gRec.CopyQCLine_gFnc(Rec."QC No.", Rec."Lot No.", Rec."Serial No."); //I-C0009-1001310-01 N
                    end;
                }
            }
        }
    }

    var
        QCLineDetail_gRec: Record "QC Line Detail";
}

