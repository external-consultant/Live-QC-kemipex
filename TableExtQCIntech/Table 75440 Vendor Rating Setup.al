
tableextension 75440 ExtVendorRatingSetup extends "Vendor Rating Setup"
{
    DrillDownPageID = "Vendor Rating Setup"; //P_ISPL-SPLIT_Q2025
    LookupPageID = "Vendor Rating Setup";

    fields
    {

        modify("To Value")
        {

            trigger OnBeforeValidate()
            begin
                if "From Value" > "To Value" then
                    Error(Text0001_gCtx);
            end;
        }

    }

    keys
    {

    }

    fieldgroups
    {
    }

    trigger OnAfterInsert()
    begin
        "Inserted DateTime" := CurrentDatetime;
        Type := Type::"Vendor Rating";
    end;

    trigger OnAfterModify()
    begin
        "Modify DateTime" := CurrentDatetime;
    end;

    var
        Text0001_gCtx: label 'From value must be less than To Value.';
}

