
tableextension 75438 QualityControlSetupExt extends "Quality Control Setup"
{




    fields
    {

        modify("Automatic Posting of Prod QC")
        {
            trigger OnBeforeValidate()
            begin
                "Book Out for RejQty Production" := false;
            end;
        }

        modify("QC Journal Template Name")
        {


            trigger OnBeforeValidate()
            begin
                //I-C0009-1001310-04-NS
                if "QC Journal Template Name" <> xRec."QC Journal Template Name" then
                    "QC General Batch Name" := '';
                //I-C0009-1001310-04-NE
            end;
        }


        modify("Book Out for RejQty Production")
        {


            trigger OnBeforeValidate()
            begin
                if "Book Out for RejQty Production" then
                    TestField("Automatic Posting of Prod QC", true);
            end;
        }

        modify("Book Out for RewQty Production")
        {


            trigger OnBeforeValidate()
            begin
                if "Book Out for RejQty Production" then
                    TestField("Automatic Posting of Prod QC", true);
            end;
        }
        //T12113-ABA-NS

        modify("Email To")
        {


            trigger OnBeforeValidate()
            begin
                if "Email To" <> '' then
                    MM_gCdu.CheckValidEmailAddresses("Email To");
            end;
        }
        modify("Email CC")
        {


            trigger OnBeforeValidate()
            begin
                if "Email CC" <> '' then
                    MM_gCdu.CheckValidEmailAddresses("Email CC");
            end;
        }
        modify("Email BCC")
        {


            trigger OnBeforeValidate()
            begin
                if "Email BCC" <> '' then
                    MM_gCdu.CheckValidEmailAddresses("Email BCC");
            end;
        }

    }

    keys
    {

    }

    fieldgroups
    {
    }
    var
        MM_gCdu: Codeunit "Mail Management";//T12113-ABA-N
        PhoneNoCannotContainLettersErr: Label 'must not contain letters';
}

