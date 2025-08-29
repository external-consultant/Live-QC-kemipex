Report 75388 "Posted QC Receipt_Copy"
{
    // --------------------------------------------------------------------------------------------
    // Intech-Systems-info@intech-systems.com
    // --------------------------------------------------------------------------------------------
    // ID                     DATE         AUTHOR
    // --------------------------------------------------------------------------------------------
    // I-C0009-1001310-01     21/02/12     RaviShah
    //                        Added Report in QC Component
    //                        (Copy From Cadmach)
    // I-C0009-1400405-01     05/08/14    Chintan Panchal
    //                        Upgrade to NAV 2013 R2
    // --------------------------------------------------------------------------------------------
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Posted QC Receipt Copy.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;

    dataset
    {
        dataitem("Posted QC Rcpt. Header"; "Posted QC Rcpt. Header")
        {
            RequestFilterFields = "No.", "Document No.", "Item Journal Template Name";
            RequestFilterHeading = 'QC Receipt';
            column(CompanyInfo_gRec_Picture; CompanyInfo_gRec.Picture)
            {
            }
            column(DocType_gTxt; DocType_gTxt)
            { }
            column(QC_Remarks; "QC Remarks")
            { }
            column(CompAddr_gTxtArr_1_; CompAddr_gTxtArr[1])
            {
            }
            column(CompAddr_gTxtArr_2_; CompAddr_gTxtArr[2])
            {
            }
            column(CompAddr_gTxtArr_3_; CompAddr_gTxtArr[3])
            {
            }
            column(CompAddr_gTxtArr_4_; CompAddr_gTxtArr[4])
            {
            }
            column(CompAddr_gTxtArr_5_; CompAddr_gTxtArr[5])
            {
            }
            column(CompAddr_gTxtArr_6_; CompAddr_gTxtArr[6])
            {
            }
            column(CompAddr_gTxtArr_7_; CompAddr_gTxtArr[7])
            {
            }
            column(CompAddr_gTxtArr_8_; CompAddr_gTxtArr[8])
            {
            }
            column(CurrReport_PAGENO; 1)
            {
            }
            column(Posted_QC_rcpt__Header__Posted_QC_rcpt__Header___No__; "Posted QC Rcpt. Header"."No.")
            {
            }
            column(Posted_QC_rcpt__Header__Item_No__; "Item No.")
            {
            }
            column(Posted_QC_rcpt__Header__Item_Name_; "Item Description" + ' ' + "Item Description 2")
            {
            }
            column(Posted_QC_rcpt__Header__Unit_of_Measure_; "Unit of Measure")
            {
            }
            column(Posted_QC_rcpt__Header__Insp_Qty_; "Inspection Quantity")
            {
            }
            column(Posted_QC_rcpt__Header__Accepted_Qty_; "Accepted Quantity")
            {
            }
            column(Posted_QC_rcpt__Header__Under_Deviation_Accepted_Qty_; "Accepted with Deviation Qty")
            {
            }
            column(Posted_QC_rcpt__Header__Reject_Qty_; "Rejected Quantity")
            {
            }
            column(Posted_QC_rcpt__Header__QC_Date_; "QC Date")
            {
            }
            column(Posted_QC_rcpt__Header__Approved_By_; AppBy_gCod)
            {
            }
            column(Posted_QC_rcpt__Header_Approve; Approve)
            {
            }
            column(Posted_QC_rcpt__Header__Checked_By_; "Checked By")
            {
            }
            column(Posted_QC_rcpt__Header__GRN_No__; "Document No.")
            {
            }
            column(Posted_QC_rcpt__Header__Buy_from_Vendor_No__; "Buy-from Vendor No.")
            {
            }
            column(Posted_QC_rcpt__Header__Buy_from_Vendor_Name_; "Buy-from Vendor Name")
            {
            }
            column(Posted_QC_rcpt__Header__GRN_Line_No__; "Document Line No.")
            {
            }
            column(Posted_QC_rcpt__Header__Vendor_DC_No_; "Vendor DC No")
            {
            }
            column(Posted_QC_rcpt__Header__Vendor_Lot_No_; "Vendor Lot No.")
            {
            }
            column(Posted_QC_Rcpt__Header__Posting_Date_; "Receipt Date")
            {
            }
            column(Posted_QC_rcpt__Header__PR_No__; "Document No.") //"Item Journal Template Name"
            {
            }
            column(Posted_QC_rcpt__Header__PR_Line_No__; "Item General Batch Name")
            {
            }
            column(Posted_QC_rcpt__Header__PR_Operation_No__; "Operation No.")
            {
            }
            column(Posted_QC_rcpt__Header__Posted_QC_rcpt__Header___PR_Centre_Type_; "Posted QC Rcpt. Header"."Center Type")
            {
            }
            column(Posted_QC_rcpt__Header__Posted_QC_rcpt__Header___PR_Centre_No__; "Posted QC Rcpt. Header"."Center No.")
            {
            }
            column(Posted_QC_rcpt__Header__PR_Run_Time_; "Operation Name")
            {
            }
            column(Posted_QC_rcpt__Header__Party_Type_; "Party Type")
            {
            }
            column(Posted_QC_rcpt__Header__Party_No__; "Party No.")
            {
            }
            column(Posted_QC_rcpt__Header__Party_Name_; "Party Name")
            {
            }
            column(Posted_QC_rcpt__Header_Address; Address)
            {
            }
            column(Posted_QC_rcpt__Header__Phone_no__; "Phone no.")
            {
            }
            column(Posted_QC_Rcpt__Header__Sample_QC_; "Sample QC")
            {
            }
            column(Posted_QC_Rcpt__Header_Comment; Comment)
            {
            }
            column(Quality_Checking_ReceiptCaption; Quality_Checking_ReceiptCaptionLbl)
            {
            }
            column(Page__Caption; Page__CaptionLbl)
            {
            }
            column(QC_No_Caption; QC_No_CaptionLbl)
            {
            }
            column(Item_No_Caption; Item_No_CaptionLbl)
            {
            }
            column(Item_NameCaption; Item_NameCaptionLbl)
            {
            }
            column(LotNoCaption; LotNoCaptionLbl)
            {
            }
            column(SampleDateTimeCaptionLbl; SampleDateTimeCaptionLbl)
            {
            }
            column(QCReportDateTimeCaptionLbl; QCReportDateTimeCaptionLbl)
            {
            }
            column(Sample_Date_and_Time; "Sample Date and Time")
            {
            }
            column(SystemCreatedAt; SystemCreatedAt)
            {
            }
            column(Insp_QtyCaption; Insp_QtyCaptionLbl)
            {
            }
            column(Accepted_QtyCaption; Accepted_QtyCaptionLbl)
            {
            }
            column(Under_Dev__Acc__QtyCaption; Under_Dev__Acc__QtyCaptionLbl)
            {
            }
            column(Reject_QtyCaption; Reject_QtyCaptionLbl)
            {
            }
            column(QC_DateCaption; QC_DateCaptionLbl)
            {
            }
            column(Approved_ByCaption; Approved_ByCaptionLbl)
            {
            }
            column(ApprovedCaption; ApprovedCaptionLbl)
            {
            }
            column(Analysed_ByCaption; Analysed_ByCaptionLbl)
            {
            }
            column(EmptyStringCaption; EmptyStringCaptionLbl)
            {
            }
            column(EmptyStringCaption_Control1000000149; EmptyStringCaption_Control1000000149Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000150; EmptyStringCaption_Control1000000150Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000152; EmptyStringCaption_Control1000000152Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000156; EmptyStringCaption_Control1000000156Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000157; EmptyStringCaption_Control1000000157Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000158; EmptyStringCaption_Control1000000158Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000159; EmptyStringCaption_Control1000000159Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000163; EmptyStringCaption_Control1000000163Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000164; EmptyStringCaption_Control1000000164Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000165; EmptyStringCaption_Control1000000165Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000166; EmptyStringCaption_Control1000000166Lbl)
            {
            }
            column(Rework_QtyCaption; Rework_QtyCaptionLbl)
            {
            }
            column(EmptyStringCaption_Control1000000133; EmptyStringCaption_Control1000000133Lbl)
            {
            }
            column(Purchase_Receipt_No_Caption; Purchase_Receipt_No_CaptionLbl)
            {
            }
            column(Buy_from_Vendor_No_Caption; Buy_from_Vendor_No_CaptionLbl)
            {
            }
            column(Buy_from_Vendor_NameCaption; Buy_from_Vendor_NameCaptionLbl)
            {
            }
            column(Receipt_Line_No_Caption; Receipt_Line_No_CaptionLbl)
            {
            }
            column(Vendor_DC_No_Caption; Vendor_DC_No_CaptionLbl)
            {
            }
            column(Vendor_Lot_No_Caption; Vendor_Lot_No_CaptionLbl)
            {
            }
            column(Purchase_DetailCaption; Purchase_DetailCaptionLbl)
            {
            }
            column(EmptyStringCaption_Control1000000135; EmptyStringCaption_Control1000000135Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000136; EmptyStringCaption_Control1000000136Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000137; EmptyStringCaption_Control1000000137Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000138; EmptyStringCaption_Control1000000138Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000140; EmptyStringCaption_Control1000000140Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000142; EmptyStringCaption_Control1000000142Lbl)
            {
            }
            column(GRN_DateCaption; GRN_DateCaptionLbl)
            {
            }
            column(EmptyStringCaption_Control1000000009; EmptyStringCaption_Control1000000009Lbl)
            {
            }
            column(Production_Order_No_Caption; Production_Order_No_CaptionLbl)
            {
            }
            column(Production_Line_No_Caption; Production_Line_No_CaptionLbl)
            {
            }
            column(LocationCodeCaptionLbl; LocationCodeCaptionLbl)
            { }
            column(Location_Code; "Location Code")
            { }
            column(Operation_No_Caption; Operation_No_CaptionLbl)
            {
            }
            column(Centre_TypeCaption; Centre_TypeCaptionLbl)
            {
            }
            column(Centre_No_Caption; Centre_No_CaptionLbl)
            {
            }
            column(Run_TimeCaption; Run_TimeCaptionLbl)
            {
            }
            column(Production_DetailCaption; Production_DetailCaptionLbl)
            {
            }
            column(EmptyStringCaption_Control1000000122; EmptyStringCaption_Control1000000122Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000123; EmptyStringCaption_Control1000000123Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000124; EmptyStringCaption_Control1000000124Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000125; EmptyStringCaption_Control1000000125Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000127; EmptyStringCaption_Control1000000127Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000128; EmptyStringCaption_Control1000000128Lbl)
            {
            }
            column(Party_TypeCaption; Party_TypeCaptionLbl)
            {
            }
            column(Party_No_Caption; Party_No_CaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(AddressCaption; AddressCaptionLbl)
            {
            }
            column(Phone_no_Caption; Phone_no_CaptionLbl)
            {
            }
            column(Sample_DetailCaption; Sample_DetailCaptionLbl)
            {
            }
            column(EmptyStringCaption_Control1000000100; EmptyStringCaption_Control1000000100Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000102; EmptyStringCaption_Control1000000102Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000117; EmptyStringCaption_Control1000000117Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000118; EmptyStringCaption_Control1000000118Lbl)
            {
            }
            column(EmptyStringCaption_Control1000000119; EmptyStringCaption_Control1000000119Lbl)
            {
            }
            column(Remarks_Caption; Remarks_CaptionLbl)
            {
            }
            column(DocumentType_gTxt; DocumentType_gTxt)
            {
            }
            column(No_gText; No_gText)
            {
            }
            column(Name_gTxt; Name_gTxt)
            {
            }
            column(DCNo_gTxt; DCNo_gTxt)
            {
            }
            column(LotNo_gTxt; LotNo_gTxt)
            {
            }
            dataitem("Posted QC Rcpt. Line"; "Posted QC Rcpt. Line")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = sorting("No.", "Line No.") order(ascending);
                column(MinValue; MinValue)
                {
                }
                column(MaxValue; MaxValue)
                {
                }
                column(ActValue; ActualText_gTxt) //ActValue
                {
                }
                column(ActOption; "QC Status")//ActOption
                {
                }
                column(Posted_QC_Rcpt__Line_Description; Description)
                {
                }
                column(Posted_QC_Rcpt__Line__Quality_Parameter_Code_; "Quality Parameter Code")
                {
                }
                column(OptionValue; OptionValue)
                {
                }
                column(Posted_QC_Rcpt__Line__Method_Description_; "Method Description")
                {
                }
                column(ParameterCaption; ParameterCaptionLbl)
                {
                }
                column(Min__ValueCaption; Min__ValueCaptionLbl)
                {
                }
                column(Max__ValueCaption; Max__ValueCaptionLbl)
                {
                }
                column(ValueCaption; ValueCaptionLbl)
                {
                }
                column(Option_ValueCaption; Option_ValueCaptionLbl)
                {
                }
                column(OptionCaption; OptionCaptionLbl)
                {
                }
                column(SpecificationCaption; SpecificationCaptionLbl)
                {
                }
                column(Actual_ResultCaption; Actual_ResultCaptionLbl)
                {
                }
                column(ResultCaptionLbl; ResultCaptionLbl)
                { }
                column(StatusCaptionLbl; StatusCaptionLbl)
                { }
                column(Sample_No_Caption; Sample_No_CaptionLbl)
                {
                }
                column(DescriptionCaption; DescriptionCaptionLbl)
                {
                }
                column(Posted_QC_Rcpt__Line__Method_Description_Caption; FieldCaption("Method Description"))
                {
                }
                column(Posted_QC_Rcpt__Line_No_; "No.")
                {
                }
                column(Posted_QC_Rcpt__Line_Line_No_; "Line No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    MinValue := Format(0);
                    MaxValue := Format(0);
                    OptionValue := '';
                    ActValue := Format(0);
                    ActOption := '';

                    // if (Type = Type::"4") then begin
                    //     MinValue := '-';
                    //     MaxValue := '-';
                    //     OptionValue := '-';

                    //     if (("Actual Value" = 0) and ("Actual Text" = '')) then begin
                    //         ActValue := '-';
                    //         ActOption := '-';
                    //     end else
                    //         if not ("Actual Value" = 0) then begin
                    //             ActOption := '-';
                    //             ActValue := Format("Actual Value");
                    //         end else
                    //             if not ("Actual Text" = '') then begin
                    //                 ActValue := '-';
                    //                 ActOption := "Actual Text";
                    //             end;
                    // end else
                    if (Type = Type::Text) then begin
                        MinValue := '-';
                        MaxValue := '-';
                        OptionValue := "Text Value";
                        ActValue := "Actual Text";
                        ActOption := "Actual Text";
                        if "Actual Text" <> '' then
                            ActualText_gTxt := Format("Actual Text")
                        else
                            ActualText_gTxt := '';
                    end else
                        if (Type = Type::Maximum) then begin
                            MinValue := '-';
                            MaxValue := Format("Max.Value");
                            OptionValue := "Text Value";
                            ActValue := Format("Actual Value");
                            ActOption := "Actual Text";

                            if "Actual Value" <> 0 then
                                ActualText_gTxt := Format("Actual Value")
                            else
                                ActualText_gTxt := ''
                        end else
                            if (Type = Type::Minimum) then begin
                                MinValue := Format("Min.Value");
                                MaxValue := '-';
                                OptionValue := "Text Value";
                                ActValue := Format("Actual Value");
                                ActOption := "Actual Text";

                                if "Actual Value" <> 0 then
                                    ActualText_gTxt := Format("Actual Value")
                                else
                                    ActualText_gTxt := '';
                            end else
                                if (Type = Type::Range) then begin
                                    MinValue := Format("Min.Value");
                                    MaxValue := Format("Max.Value");
                                    OptionValue := "Text Value";
                                    ActValue := Format("Actual Value");
                                    ActOption := "Actual Text";

                                    if "Actual Value" <> 0 then
                                        ActualText_gTxt := Format("Actual Value")
                                    else
                                        ActualText_gTxt := '';
                                end;
                    ClearLogo_lFnc; //RptUpg-N
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) order(ascending);
                column(Integer_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ClearLogo_lFnc; //RptUpg-N
                end;

                trigger OnPreDataItem()
                begin
                    i := "Posted QC Rcpt. Line".Count;
                    j := (16 - i);
                    Integer.SetFilter(Integer.Number, '%1..%2', 1, j);
                end;
            }

            trigger OnAfterGetRecord()
            var
                User_lRec: Record User;
            begin
                FormatAddr_gCu.Company(CompAddr_gTxtArr, CompanyInfo_gRec);

                //T03668-NS
                DocumentType_gTxt := '';
                DocType_gTxt := '';
                No_gText := '';
                Name_gTxt := '';
                DCNo_gTxt := '';
                LotNo_gTxt := '';
                AppBy_gCod := '';

                if "Approved By" <> '' then
                    AppBy_gCod := "Approved By"
                else begin
                    Clear(User_lRec);
                    if User_lRec.Get(SystemCreatedBy) then
                        AppBy_gCod := User_lRec."User Name";
                end;

                DocumentType_gTxt := Format("Posted QC Rcpt. Header"."Document Type") + ' Detail';

                if "Posted QC Rcpt. Header"."Document Type" = "Posted QC Rcpt. Header"."Document Type"::Production then
                    DocType_gTxt := Format("Posted QC Rcpt. Header"."Document Type")
                else
                    DocType_gTxt := '';

                if "Posted QC Rcpt. Header"."Document Type" = "Posted QC Rcpt. Header"."document type"::"Sales Return" then begin
                    No_gText := 'Customer No.';
                    Name_gTxt := 'Customer Name';
                    DCNo_gTxt := 'Customer DC No.';
                    LotNo_gTxt := 'Customer Lot No.';
                end else begin
                    No_gText := 'Vendor No.';
                    Name_gTxt := 'Vendor Name';
                    DCNo_gTxt := 'Vendor DC No.';
                    LotNo_gTxt := 'Vendor Lot No.';
                end;
                //T03668-NE
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInfo_gRec.Get;
        CompanyInfo_gRec.CalcFields(Picture);
    end;

    var
        AppBy_gCod: Code[100];
        DocType_gTxt: Text;
        ActualText_gTxt: Text;
        MinValue: Code[10];
        MaxValue: Code[10];
        FinResult: Code[10];
        OptionValue: Text[30];
        ActValue: Code[10];
        ActOption: Text[30];
        i: Integer;
        j: Integer;
        k: Integer;
        CompanyInfo_gRec: Record "Company Information";
        CompAddr_gTxtArr: array[8] of Text[50];
        FormatAddr_gCu: Codeunit "Format Address";
        Quality_Checking_ReceiptCaptionLbl: label 'Quality Control Report';
        Page__CaptionLbl: label 'Page :';
        QC_No_CaptionLbl: label 'QC No.';
        Item_No_CaptionLbl: label 'Item No.';
        Item_NameCaptionLbl: label 'Item Name';
        LotNoCaptionLbl: label 'Lot No.';
        SampleDateTimeCaptionLbl: label 'Sample Date/Time';
        QCReportDateTimeCaptionLbl: label 'QC Report Date/Time';
        Insp_QtyCaptionLbl: label 'Insp Qty';
        Accepted_QtyCaptionLbl: label 'Accepted Qty';
        Under_Dev__Acc__QtyCaptionLbl: label 'Under Dev. Acc. Qty';
        Reject_QtyCaptionLbl: label 'Reject Qty';
        QC_DateCaptionLbl: label 'QC Date';
        Approved_ByCaptionLbl: label 'Approved By';
        ApprovedCaptionLbl: label 'Approved';
        Analysed_ByCaptionLbl: label 'Analysed By';
        EmptyStringCaptionLbl: label ': ';
        EmptyStringCaption_Control1000000149Lbl: label ': ';
        EmptyStringCaption_Control1000000150Lbl: label ': ';
        EmptyStringCaption_Control1000000152Lbl: label ': ';
        EmptyStringCaption_Control1000000156Lbl: label ': ';
        EmptyStringCaption_Control1000000157Lbl: label ': ';
        EmptyStringCaption_Control1000000158Lbl: label ': ';
        EmptyStringCaption_Control1000000159Lbl: label ': ';
        EmptyStringCaption_Control1000000163Lbl: label ': ';
        EmptyStringCaption_Control1000000164Lbl: label ': ';
        EmptyStringCaption_Control1000000165Lbl: label ': ';
        EmptyStringCaption_Control1000000166Lbl: label ': ';
        Rework_QtyCaptionLbl: label 'Rework Qty';
        EmptyStringCaption_Control1000000133Lbl: label ': ';
        Purchase_Receipt_No_CaptionLbl: label 'GRN No.';
        Buy_from_Vendor_No_CaptionLbl: label 'Vendor No.';
        Buy_from_Vendor_NameCaptionLbl: label 'Vendor Name';
        Receipt_Line_No_CaptionLbl: label 'GRN Line No.';
        Vendor_DC_No_CaptionLbl: label 'Vendor DC No.';
        Vendor_Lot_No_CaptionLbl: label 'Vendor Lot No.';
        Purchase_DetailCaptionLbl: label 'Purchase Detail';
        EmptyStringCaption_Control1000000135Lbl: label ': ';
        EmptyStringCaption_Control1000000136Lbl: label ': ';
        EmptyStringCaption_Control1000000137Lbl: label ': ';
        EmptyStringCaption_Control1000000138Lbl: label ': ';
        EmptyStringCaption_Control1000000140Lbl: label ': ';
        EmptyStringCaption_Control1000000142Lbl: label ': ';
        GRN_DateCaptionLbl: label 'GRN Date';
        EmptyStringCaption_Control1000000009Lbl: label ': ';
        Production_Order_No_CaptionLbl: label 'Production Order No.';
        Production_Line_No_CaptionLbl: label 'Production Line No.';
        Operation_No_CaptionLbl: label 'Operation No.';
        Centre_TypeCaptionLbl: label 'Centre Type';
        Centre_No_CaptionLbl: label 'Centre No.';
        Run_TimeCaptionLbl: label 'Run Time';
        Production_DetailCaptionLbl: label 'Production Detail';
        EmptyStringCaption_Control1000000122Lbl: label ': ';
        EmptyStringCaption_Control1000000123Lbl: label ': ';
        EmptyStringCaption_Control1000000124Lbl: label ': ';
        EmptyStringCaption_Control1000000125Lbl: label ': ';
        EmptyStringCaption_Control1000000127Lbl: label ': ';
        EmptyStringCaption_Control1000000128Lbl: label ': ';
        Party_TypeCaptionLbl: label 'Party Type';
        Party_No_CaptionLbl: label 'Party No.';
        NameCaptionLbl: label 'Name';
        AddressCaptionLbl: label 'Address';
        Phone_no_CaptionLbl: label 'Phone no.';
        Sample_DetailCaptionLbl: label 'Sample Detail';
        EmptyStringCaption_Control1000000100Lbl: label ': ';
        EmptyStringCaption_Control1000000102Lbl: label ': ';
        EmptyStringCaption_Control1000000117Lbl: label ': ';
        EmptyStringCaption_Control1000000118Lbl: label ': ';
        EmptyStringCaption_Control1000000119Lbl: label ': ';
        Remarks_CaptionLbl: label 'Remarks:';
        ParameterCaptionLbl: label 'Parameter Code';
        Min__ValueCaptionLbl: label 'Min. Value';
        Max__ValueCaptionLbl: label 'Max. Value';
        ValueCaptionLbl: label 'Value';
        LocationCodeCaptionLbl: label 'Location Code';
        ResultCaptionLbl: label 'Result';
        StatusCaptionLbl: label 'Status';
        Option_ValueCaptionLbl: label 'Text';
        OptionCaptionLbl: label 'Text';
        SpecificationCaptionLbl: label 'Specification';
        Actual_ResultCaptionLbl: label 'QC Result';
        Sample_No_CaptionLbl: label 'Sample No.';
        DescriptionCaptionLbl: label 'Description';
        LogoCleared_gBln: Boolean;
        ClearLogo_gBln: Boolean;
        DocumentType_gTxt: Text[100];
        No_gText: Text[20];
        Name_gTxt: Text[20];
        DCNo_gTxt: Text[20];
        LotNo_gTxt: Text[20];

    local procedure ClearLogo_lFnc()
    begin
        //RptUpg-NS
        if LogoCleared_gBln then
            exit;

        if ClearLogo_gBln then begin
            Clear(CompanyInfo_gRec.Picture);
            LogoCleared_gBln := true;
        end else
            ClearLogo_gBln := true;
        //RptUpg-NE
    end;
}

