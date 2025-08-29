report 75386 "Attachment Details"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    Description = 'T12113';
    RDLCLayout = './Layouts/Item Ledger Entries_.rdl';

    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            RequestFilterFields = "Entry No.", "Item No.";
            column(Item_No_; "Item No.")
            {

            }
            column(Description; Description)
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Entry_No_; "Entry No.")
            {

            }
            column(Lot_No_; "Lot No.")
            {

            }
            column(Remaining_Quantity; "Remaining Quantity")
            {

            }
            column(Expiration_Date; "Expiration Date")
            {

            }
            column(Companyinfo_gRec_picture; Companyinfo_gRec.Picture)
            {

            }

            trigger OnAfterGetRecord()
            begin
                ExpDate_gDte := CalcDate(QCSetup_gRec."Expiration Due Alert", Today);
                SetRange("Expiration Date", ExpDate_gDte);
                // Message('Date is %1', ExpDate_gDte);
            end;

            trigger OnPreDataItem()
            begin
                SetFilter("Remaining Quantity", '>0');
                SetFilter(Open, 'Yes');

            end;
        }
    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {

                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }



    trigger OnPreReport()
    begin
        Companyinfo_gRec.Get;
        Companyinfo_gRec.CalcFields(Picture);
        QCSetup_gRec.Get();
    end;

    var
        Companyinfo_gRec: Record "Company Information";
        QCSetup_gRec: Record "Quality Control Setup";
        ExpDate_gDte: Date;

}