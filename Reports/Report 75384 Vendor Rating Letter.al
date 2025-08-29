Report 75384 "Vendor Rating Letter"
{
    // ------------------------------------------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // ------------------------------------------------------------------------------------------------------------------------------------
    // ID                        Date            Author
    // ------------------------------------------------------------------------------------------------------------------------------------
    // I-I031-400005-01          27/11/14        Abhishek
    //                           Vendor Rating functionality
    //                           Create New Report for Vendor rating Letter
    //                           (Save As from Kastwel)
    // 
    // ------------------------------------------------------------------------------------------------------------------------------------
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Vendor Rating Letter.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.";
            dataitem("Purch. Rcpt. Header"; "Purch. Rcpt. Header")
            {
                DataItemLink = "Buy-from Vendor No." = field("No.");
                DataItemTableView = sorting("Buy-from Vendor No.");

                dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemTableView = sorting("Document No.", "Line No.") where(Type = const(Item), Quantity = filter(> 0));

                    trigger OnAfterGetRecord()
                    var
                        VendorRating_lRec: Record "Vendor Rating";
                    begin
                        InsertVendorRating_gFnc(Vendor, "Purch. Rcpt. Header", "Purch. Rcpt. Line");
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetFilter("Posting Date", '%1..%2', FromDate_gDte, ToDate_gDte);
                end;
            }

            trigger OnAfterGetRecord()
            var
                VendorRating_lRec: Record "Vendor Rating";
            begin
            end;

            trigger OnPostDataItem()
            begin
                VendorMarked_gRecTmp.Reset;
                if VendorMarked_gRecTmp.FindSet then
                    repeat
                        InsertVendorGrade_gFnc(VendorMarked_gRecTmp)
                    until VendorMarked_gRecTmp.Next = 0;
            end;

            trigger OnPreDataItem()
            begin
                VendorFilter_gRec.CopyFilters(Vendor);
                VendorMarked_gRecTmp.DeleteAll;
            end;
        }
        dataitem("Vendor Rating"; "Vendor Rating")
        {
            DataItemTableView = sorting("From Date", "To Date", "Vendor No.");

            trigger OnAfterGetRecord()
            var
                Vendor_lRec: Record Vendor;
                BreakLoop_lBln: Boolean;
            begin
                if Vendor_lRec.Get("Vendor No.") then
                    VendorName_gTxt := Vendor_lRec.Name;
                if PreVendorNo_gCod <> "Vendor No." then begin
                    SrNo_gInt := 1;
                    PreVendorNo_gCod := "Vendor No.";
                end else begin
                    SrNo_gInt += 1;
                end;

                VendorRating_gRecTemp.Reset;
                VendorRating_gRecTemp.SetRange("Vendor No.", "Vendor No.");
                if not (VendorRating_gRecTemp.FindFirst) then begin
                    AvgGrade_gCod := FindAvgGrade_gFnc(FindAvgTotal_gFnc("Vendor Rating"));
                    VendorRating_gRecTemp.Init;
                    VendorRating_gRecTemp."From Date" := "Vendor Rating"."From Date";
                    VendorRating_gRecTemp."To Date" := "Vendor Rating"."To Date";
                    VendorRating_gRecTemp."GRN No." := "Vendor Rating"."GRN No.";
                    VendorRating_gRecTemp."GRN Line No." := "Vendor Rating"."GRN Line No.";
                    VendorRating_gRecTemp."Vendor No." := "Vendor Rating"."Vendor No.";
                    VendorRating_gRecTemp.Grade := AvgGrade_gCod;
                    VendorRating_gRecTemp.Insert;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if VendorFilter_gRec.GetFilter("No.") <> '' then
                    "Vendor Rating".SetFilter("Vendor No.", '%1', VendorFilter_gRec.GetFilter("No."));

                SetRange("From Date", FromDate_gDte);
                SetRange("To Date", ToDate_gDte);
                AvgGrade_gCod := '';
            end;
        }
        dataitem("Vendor Print"; Vendor)
        {
            DataItemTableView = sorting("No.");
            column(CompanyInfo_gRec_Picture; CompanyInfo_gRec.Picture)
            {
            }
            column(CompanyAddress_gTxt; CompanyAddress_gTxt)
            {
            }
            column(ComAddre_gTxtArr_11_; '')
            {
            }
            column(ComAddre_gTxtArr_10_; '')
            {
            }
            column(ComAddre_gTxtArr_9_; '')
            {
            }
            column(ComAddre_gTxtArr_8_; '')
            {
            }
            column(ComAddre_gTxtArr_7_; '')
            {
            }
            column(ComAddre_gTxtArr_6_; '')
            {
            }
            column(ComAddre_gTxtArr_5_; '')
            {
            }
            column(ComAddre_gTxtArr_4_; '')
            {
            }
            column(ComAddre_gTxtArr_3_; '')
            {
            }
            column(ComAddre_gTxtArr_2_; '')
            {
            }
            column(ComAddre_gTxtArr_1_; ComAddre_gTxtArr[1])
            {
            }
            column(VendorAddress_gTxt; VendorAddress_gTxt)
            {
            }
            column(VendorAddr_gTxtArr_1_; '')
            {
            }
            column(VendorAddr_gTxtArr_2_; '')
            {
            }
            column(VendorAddr_gTxtArr_3_; '')
            {
            }
            column(VendorAddr_gTxtArr_4_; '')
            {
            }
            column(VendorAddr_gTxtArr_5_; '')
            {
            }
            column(VendorAddr_gTxtArr_6_; '')
            {
            }
            column(VendorAddr_gTxtArr_7_; '')
            {
            }
            column(VendorAddr_gTxtArr_8_; '')
            {
            }
            column(STRSUBSTNO_Text50003_gCtx_FromDate_gDat_ToDate_gDat_; StrSubstNo(Text50003_gCtx, FORMAT(FromDate_gDte, 0, '<Day,2>-<Month,2>-<Year4>'), FORMAT(ToDate_gDte, 0, '<Day,2>-<Month,2>-<Year4>')))
            {
            }
            column(STRSUBSTNO_Text50006_gCtx__C__; StrSubstNo(Text50006_gCtx, AvgGrade_gCod))
            {
            }
            column(Text50007_gCtx; ChangeTextAsPerGrade_gCtx)
            {
            }
            column(STRSUBSTNO_Text50010_gCtx_CompanyInfo_gRec_Name_; StrSubstNo(Text50010_gCtx, CompanyInfo_gRec.Name))
            {
            }
            column(PurchaserName_gTxt; PurchaserName_gTxt)
            {
            }
            column(Designation_gTxt; Designation_gTxt)
            {
            }
            column(Vendor_Print_No_; "No.")
            {
            }

            trigger OnAfterGetRecord()
            var
                Cnt_lInt: Integer;
            begin
                FormatAddr_gCdu.Company(ComAddre1_gTxtArr, CompanyInfo_gRec);
                CompressArray(ComAddre1_gTxtArr);
                Cnt_lInt := 0;
                repeat
                    Cnt_lInt += 1;
                    ComAddre_gTxtArr[Cnt_lInt] := ComAddre1_gTxtArr[Cnt_lInt];
                until ComAddre1_gTxtArr[Cnt_lInt] = '';
                if CompanyInfo_gRec."Phone No." <> '' then
                    ComAddre_gTxtArr[Cnt_lInt] := 'Tel. : ' + CompanyInfo_gRec."Phone No.";

                if CompanyInfo_gRec."Fax No." <> '' then
                    ComAddre_gTxtArr[Cnt_lInt + 1] := 'Fax : ' + CompanyInfo_gRec."Fax No.";

                if CompanyInfo_gRec."E-Mail" <> '' then
                    ComAddre_gTxtArr[Cnt_lInt + 2] := 'e-mail : ' + CompanyInfo_gRec."E-Mail";

                CompressArray(ComAddre_gTxtArr);

                // VG-NS
                CompanyAddress_gTxt := '';
                if Format(ComAddre_gTxtArr[2]) <> '' then
                    CompanyAddress_gTxt += 'Regd. Office & works :' + ' ' + Format(ComAddre_gTxtArr[2]);
                if Format(ComAddre_gTxtArr[3]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[3]);
                if Format(ComAddre_gTxtArr[4]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[4]);
                if Format(ComAddre_gTxtArr[5]) <> '' then
                    CompanyAddress_gTxt += '<br/>' + Format(ComAddre_gTxtArr[5]);
                if Format(ComAddre_gTxtArr[6]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[6]);
                if Format(ComAddre_gTxtArr[7]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[7]);
                if Format(ComAddre_gTxtArr[8]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[8]);
                if Format(ComAddre_gTxtArr[9]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[9]);
                if Format(ComAddre_gTxtArr[10]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[10]);
                if Format(ComAddre_gTxtArr[11]) <> '' then
                    CompanyAddress_gTxt += ' ' + Format(ComAddre_gTxtArr[11]);
                // VG-NE

                FormatAddr_gCdu.Vendor(VendorAddr_gTxtArr, "Vendor Print");
                if SalesPurchaser_gRec.Get(PurchaserCode_gCod) then
                    PurchaserName_gTxt := SalesPurchaser_gRec.Name;

                // VG-NS
                CompressArray(VendorAddr_gTxtArr);
                VendorAddress_gTxt := '';
                if Format(VendorAddr_gTxtArr[1]) <> '' then
                    VendorAddress_gTxt += '<b>' + Format(VendorAddr_gTxtArr[1]) + '</b>';
                if Format(VendorAddr_gTxtArr[2]) <> '' then
                    VendorAddress_gTxt += '<br/>' + Format(VendorAddr_gTxtArr[2]);
                if Format(VendorAddr_gTxtArr[3]) <> '' then
                    VendorAddress_gTxt += '<br/>' + Format(VendorAddr_gTxtArr[3]);
                if Format(VendorAddr_gTxtArr[4]) <> '' then
                    VendorAddress_gTxt += '<br/>' + Format(VendorAddr_gTxtArr[4]);
                if Format(VendorAddr_gTxtArr[5]) <> '' then
                    VendorAddress_gTxt += '<br/>' + Format(VendorAddr_gTxtArr[5]);
                if Format(VendorAddr_gTxtArr[6]) <> '' then
                    VendorAddress_gTxt += '<br/>' + Format(VendorAddr_gTxtArr[6]);
                if Format(VendorAddr_gTxtArr[7]) <> '' then
                    VendorAddress_gTxt += '<br/>' + Format(VendorAddr_gTxtArr[7]);
                if Format(VendorAddr_gTxtArr[8]) <> '' then
                    VendorAddress_gTxt += '<br/>' + Format(VendorAddr_gTxtArr[8]);
                // VG-NE

                VendorRating_gRecTemp.Reset;
                VendorRating_gRecTemp.SetRange("Vendor No.", "No.");
                if VendorRating_gRecTemp.FindFirst then begin
                    AvgGrade_gCod := VendorRating_gRecTemp.Grade;
                    if AvgGrade_gCod = 'A' then
                        ChangeTextAsPerGrade_gCtx := Text0000A_gCtx
                    else
                        if AvgGrade_gCod = 'B' then
                            ChangeTextAsPerGrade_gCtx := Text0000B_gCtx
                        else
                            if AvgGrade_gCod = 'C' then
                                ChangeTextAsPerGrade_gCtx := Text0000C_gCtx
                end else
                    CurrReport.Skip;

                ClearLogo_lFnc; //RptUpg-N
            end;

            trigger OnPreDataItem()
            begin
                if VendorFilter_gRec.GetFilter("No.") <> '' then
                    "Vendor Print".SetFilter("No.", '%1', VendorFilter_gRec.GetFilter("No."));
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("From Date"; FromDate_gDte)
                    {
                        ApplicationArea = Basic;
                    }
                    field("To Date"; ToDate_gDte)
                    {
                        ApplicationArea = Basic;
                    }
                    field("Purchaser Code"; PurchaserCode_gCod)
                    {
                        ApplicationArea = Basic;
                        TableRelation = "Salesperson/Purchaser".Code;
                    }
                    field(Designation; Designation_gTxt)
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

    labels
    {
        Regd__Office___works__CaptionLbl = 'Regd. Office & works :';
        Text50000_gCtx = '';
        Text50001_gCtx = 'DT. 05/10/2010';
        Text50002_gCtx = 'To,';
        Text50004_gCtx = 'Dear Sir,';
        Text50005_gCtx = 'We sincerely thank you for your kind co-operation & services provided to us. As you know that our organization is ISO 9001 & as per laid down procedure we are evaluating performance of supplier with regard to Delivery, Quality services & other commercial aspects.';
        Text50008_gCtx = 'Thank you for your patronage mutual growth.';
        Text50009_gCtx = 'Yours truly,';
    }

    trigger OnInitReport()
    begin
        if CompanyInfo_gRec.Get then
            CompanyInfo_gRec.CalcFields(Picture);
    end;

    trigger OnPreReport()
    var
        VendorRating_lRec: Record "Vendor Rating";
    begin
        if FromDate_gDte = 0D then
            Error(Text0001_gCtx);
        if ToDate_gDte = 0D then
            Error(Text0002_gCtx);
        if FromDate_gDte > ToDate_gDte then
            Error(Text0003_gCtx);

        VendorRating_lRec.Reset;
        VendorRating_lRec.DeleteAll;

        Filters_gCtx := Text0007_gCtx;
        if Vendor.GetFilters <> '' then
            Filters_gCtx += ' ' + Vendor.GetFilters;
        if "Purch. Rcpt. Header".GetFilters <> '' then
            Filters_gCtx += ' ' + "Purch. Rcpt. Header".GetFilters;
        if "Purch. Rcpt. Line".GetFilters <> '' then
            Filters_gCtx += ' ' + "Purch. Rcpt. Line".GetFilters;

        VendorFilter_gRec.CopyFilters(Vendor);
        PurchRectLineFilter_gRec.CopyFilters("Purch. Rcpt. Line");
        if PurchRectLineFilter_gRec.GetFilter("No.") <> '' then
            ItemFilterApplied_gBln := true;

        //RptDateForMgt_gCdu.SetReportID_gFnc(Report::"Vendor Rating Letter");  //DateFormat-N
    end;

    var
        Location_gRec: Record Location;
        FormatAddr_gCdu: Codeunit "Format Address";
        ComAddre1_gTxtArr: array[8] of Text[150];
        ComAddre_gTxtArr: array[11] of Text[150];
        CompanyInfo_gRec: Record "Company Information";
        Text50003_gCtx: label 'SUB.:- Evaluation for a period from %1 to %2';
        Text50006_gCtx: label 'Considering your performance we have categories you under the grade %1 & also the evaluation sheet enclosed herewith.';
        FromDate_gDte: Date;
        ToDate_gDte: Date;
        VendorAddr_gTxtArr: array[8] of Text[150];
        Designation_gTxt: Text[50];
        PurchaserCode_gCod: Code[10];
        PurchaserName_gTxt: Text[50];
        SalesPurchaser_gRec: Record "Salesperson/Purchaser";
        Text50010_gCtx: label 'For %1';
        ChangeTextAsPerGrade_gCtx: Text[500];
        Text0000A_gCtx: label 'We are expecting continuous improvment from you by maintaining the quality materials, deliveries.';
        Text0000B_gCtx: label 'We are requested please review the evaluating sheet & to improve the performance where it is require in terms of quality materials & deliveries in time. You are requested plase to co-operate with us for achiving our quality qrowth & your suggestions/queries are welcome for improving the performance. We expect to achieve the better performace for next evolution peroid.';
        Text0000C_gCtx: label 'Your performance was far below than our expectation & need to improve sincerely in many areas like quality materials & deliveries in time. You are requested to co-operate with us for achieving our quality growth & your suggestions/queries are welcome for improving the performance. We expect to achieve better performance for next evolution period.';
        VendorMarked_gRecTmp: Record Vendor temporary;
        SrNo_gInt: Integer;
        VendorName_gTxt: Text[100];
        PreVendorNo_gCod: Code[20];
        Filters_gCtx: Text[500];
        VendorFilter_gRec: Record Vendor;
        PurchRectLineFilter_gRec: Record "Purch. Rcpt. Line";
        ItemFilterApplied_gBln: Boolean;
        ShowOnlySummary_gBln: Boolean;
        AvgGrade_gCod: Code[10];
        GRNCounterforClassic_gInt: Integer;
        QtyAVG_gDec: Decimal;
        QltAvg_gDec: Decimal;
        TimeAvg_gDec: Decimal;
        Q1Avg_gDec: Decimal;
        TotalAvg_gDec: Decimal;
        VendorRating_gRecTemp: Record "Vendor Rating" temporary;
        Text0001_gCtx: label 'From Date is Required.';
        Text0002_gCtx: label 'To Date is Required.';
        Text0003_gCtx: label 'From Date Must Be Less Than To Date.';
        Text0004_gCtx: label 'Vendor Rating Entry All Ready Exists for Vendor  No. :%1,\ Item No. :%2, GRN No. :%3. \For Date Range %4 To %5.\Do you really want to replace all old Vendor Rating Entries ?';
        Text0005_gCtx: label 'Do you want to skip check all old vendor rating entries for Vendor No. :%1.';
        Text0006_gCtx: label 'Evaluation of Vendors - Products From : %1 To %2.';
        Text0007_gCtx: label 'Filters :';
        LogoCleared_gBln: Boolean;
        ClearLogo_gBln: Boolean;
        CompanyAddress_gTxt: Text;
        VendorAddress_gTxt: Text;
    //RptDateForMgt_gCdu: Codeunit UnknownCodeunit33030032;


    procedure InsertVendorRating_gFnc(Vendor_iRec: Record Vendor; PruRecHeader_iRec: Record "Purch. Rcpt. Header"; PruRecLine_iRec: Record "Purch. Rcpt. Line")
    var
        VendorRating_lRec: Record "Vendor Rating";
        GeneralUtilization_lRec: Record "Vendor Rating Setup";
        BreakLoop_lBln: Boolean;
    begin
        VendorRating_lRec.Reset;
        VendorRating_lRec."From Date" := FromDate_gDte;
        VendorRating_lRec."To Date" := ToDate_gDte;
        VendorRating_lRec."GRN No." := PruRecLine_iRec."Document No.";
        VendorRating_lRec."GRN Line No." := PruRecLine_iRec."Line No.";
        VendorRating_lRec."Item No." := PruRecLine_iRec."No.";
        VendorRating_lRec."Item Description" := PruRecLine_iRec.Description;
        VendorRating_lRec."Item Description 2" := PruRecLine_iRec."Description 2";
        VendorRating_lRec."Purchase Order No." := PruRecLine_iRec."Order No.";
        VendorRating_lRec."Purchase Order Line No." := PruRecLine_iRec."Order Line No.";
        VendorRating_lRec."Purchase Order Date" := PruRecHeader_iRec."Order Date";
        VendorRating_lRec."Vendor No." := PruRecLine_iRec."Buy-from Vendor No.";
        VendorRating_lRec."Vendor Shipment Code" := PruRecHeader_iRec."Vendor Shipment No.";
        //VendorRating_lRec."Vendor Shipment Date" := PruRecHeader_iRec."Vendor Shipment Date";
        VendorRating_lRec."GRN Date" := PruRecHeader_iRec."Posting Date";
        VendorRating_lRec."GRN Expected Recipt Date" := PruRecLine_iRec."Expected Receipt Date";
        VendorRating_lRec.Quantity := PruRecLine_iRec.Quantity;
        VendorRating_lRec."Quantity Accept" := PruRecLine_iRec.Quantity;

        if (PruRecLine_iRec."Posting Date" <> 0D) and (PruRecLine_iRec."Expected Receipt Date" <> 0D) then begin
            if (PruRecLine_iRec."Posting Date" - PruRecLine_iRec."Expected Receipt Date") >= 0 then
                VendorRating_lRec."Delivery Days" := (PruRecLine_iRec."Posting Date" - PruRecLine_iRec."Expected Receipt Date")
            else
                VendorRating_lRec."Delivery Days" := 0;
        end else
            VendorRating_lRec."Delivery Days" := 0;


        GeneralUtilization_lRec.Reset;
        GeneralUtilization_lRec.SetRange(Type, GeneralUtilization_lRec.Type::"Vendor Rating");
        GeneralUtilization_lRec.SetFilter("To Value", '>%1', 0);
        GeneralUtilization_lRec.SetFilter("Value Text", '%1', '');
        if GeneralUtilization_lRec.FindSet then begin
            BreakLoop_lBln := false;
            repeat
                if (VendorRating_lRec."Delivery Days" >= GeneralUtilization_lRec."From Value") and
                   (VendorRating_lRec."Delivery Days" <= GeneralUtilization_lRec."To Value") then begin
                    BreakLoop_lBln := true;
                    VendorRating_lRec."Delivery Percentage" := GeneralUtilization_lRec.Value;
                end;
            until (GeneralUtilization_lRec.Next = 0) or (BreakLoop_lBln);
        end;

        VendorRating_lRec."Run By" := UserId;
        VendorRating_lRec."Run DateTime" := CurrentDatetime;
        if ItemFilterApplied_gBln then
            VendorRating_lRec."Item Filter Applied" := true;
        VendorRating_lRec.Insert(true);

        if not VendorMarked_gRecTmp.Get(VendorRating_lRec."Vendor No.") then begin
            VendorMarked_gRecTmp := Vendor;
            VendorMarked_gRecTmp.Insert(false);
        end;
    end;


    procedure InsertVendorGrade_gFnc(Vendor_iRec: Record Vendor)
    var
        VendorRating_lRec: Record "Vendor Rating";
        TotalReciptQty_lDec: Decimal;
        TotalAcceptedQty_lDec: Decimal;
        TotalDeviationQty_lDec: Decimal;
        QualityFactor_lDec: Decimal;
        GenUtiliz_lRec: Record "Vendor Rating Setup";
        TotalDeliveryPerc_lDec: Decimal;
        DeliveryFactor_lDec: Decimal;
        TotalGRN_lDec: Decimal;
        QuantityFactor_lDec: Decimal;
        BreakLoop_lBln: Boolean;
    begin
        VendorRating_lRec.Reset;
        TotalReciptQty_lDec := 0;
        TotalAcceptedQty_lDec := 0;
        TotalDeviationQty_lDec := 0;
        TotalDeliveryPerc_lDec := 0;
        TotalGRN_lDec := 0;
        VendorRating_lRec.Reset;
        VendorRating_lRec.SetCurrentkey("From Date", "To Date", "Vendor No.");
        VendorRating_lRec.SetRange("From Date", FromDate_gDte);
        VendorRating_lRec.SetRange("To Date", ToDate_gDte);
        VendorRating_lRec.SetRange("Vendor No.", Vendor_iRec."No.");
        if VendorRating_lRec.FindSet() then begin
            repeat
                TotalReciptQty_lDec += VendorRating_lRec.Quantity;
                TotalAcceptedQty_lDec += VendorRating_lRec."Quantity Accept";
                TotalDeviationQty_lDec += VendorRating_lRec."Quantity Deviation";
                TotalDeliveryPerc_lDec += VendorRating_lRec."Delivery Percentage";
                TotalGRN_lDec += 1;
            until VendorRating_lRec.Next = 0;
        end;

        GenUtiliz_lRec.Reset;
        GenUtiliz_lRec.SetRange(Type, GenUtiliz_lRec.Type::"Vendor Rating");
        GenUtiliz_lRec.SetRange(Code, 'VENRATE');
        GenUtiliz_lRec.SetRange("Sub Type", 'QLTRATE');
        GenUtiliz_lRec.FindFirst;
        QualityFactor_lDec := GenUtiliz_lRec.Value;

        GenUtiliz_lRec.Reset;
        GenUtiliz_lRec.SetRange(Type, GenUtiliz_lRec.Type::"Vendor Rating");
        GenUtiliz_lRec.SetRange(Code, 'VENRATE');
        GenUtiliz_lRec.SetRange("Sub Type", 'DELRATE');
        GenUtiliz_lRec.FindFirst;
        DeliveryFactor_lDec := GenUtiliz_lRec.Value;

        GenUtiliz_lRec.Reset;
        GenUtiliz_lRec.SetRange(Type, GenUtiliz_lRec.Type::"Vendor Rating");
        GenUtiliz_lRec.SetRange(Code, 'VENRATE');
        GenUtiliz_lRec.SetRange("Sub Type", 'QTYFACT');
        GenUtiliz_lRec.FindFirst;
        QuantityFactor_lDec := GenUtiliz_lRec.Value;

        VendorRating_lRec.Reset;
        VendorRating_lRec.SetRange("From Date", FromDate_gDte);
        VendorRating_lRec.SetRange("To Date", ToDate_gDte);
        VendorRating_lRec.SetRange("Vendor No.", Vendor_iRec."No.");
        if PurchRectLineFilter_gRec.GetFilter("No.") <> '' then
            VendorRating_lRec.SetFilter("Item No.", '%1', PurchRectLineFilter_gRec.GetFilter("No."));

        if VendorRating_lRec.FindSet() then begin
            repeat
                VendorRating_lRec."Quality Factor" := ((TotalAcceptedQty_lDec + (0.5 * TotalDeviationQty_lDec)) / TotalReciptQty_lDec)
                                                      * QualityFactor_lDec;
                VendorRating_lRec."Delivery Factor" := ((TotalDeliveryPerc_lDec / TotalGRN_lDec) * DeliveryFactor_lDec) / 100;
                VendorRating_lRec."Quantity Factor" := (TotalAcceptedQty_lDec / TotalReciptQty_lDec) * QuantityFactor_lDec;
                VendorRating_lRec.Total := VendorRating_lRec."Quality Factor" + VendorRating_lRec."Delivery Factor" +
                                           VendorRating_lRec."Quantity Factor";
                if VendorRating_lRec.Total > 100 then
                    VendorRating_lRec.Total := 100;
                GenUtiliz_lRec.Reset;
                GenUtiliz_lRec.SetRange(Type, GenUtiliz_lRec.Type::"Vendor Rating");
                GenUtiliz_lRec.SetFilter("To Value", '>%1', 0);
                GenUtiliz_lRec.SetFilter(Value, '%1', 0);
                if GenUtiliz_lRec.FindSet() then begin
                    BreakLoop_lBln := false;
                    repeat
                        if (VendorRating_lRec.Total >= GenUtiliz_lRec."From Value") and
                           (VendorRating_lRec.Total <= GenUtiliz_lRec."To Value") then begin
                            VendorRating_lRec.Grade := GenUtiliz_lRec."Value Text";
                            BreakLoop_lBln := true;
                        end;
                    until (GenUtiliz_lRec.Next = 0) or (BreakLoop_lBln);
                end;
                VendorRating_lRec."Total GRN in Calculation" := TotalGRN_lDec;
                VendorRating_lRec.TestField(Grade);
                VendorRating_lRec.Modify(true);
            until VendorRating_lRec.Next = 0;
        end;
    end;


    procedure CheckOldItemFilterEntry_gFnc(VendorRating_iRec: Record "Vendor Rating")
    begin
        if (VendorRating_iRec."Item Filter Applied") and not (ItemFilterApplied_gBln) then begin
            VendorRating_iRec.Delete(true);
            InsertVendorRating_gFnc(Vendor, "Purch. Rcpt. Header", "Purch. Rcpt. Line");
        end else begin
            if not (VendorRating_iRec."Item Filter Applied") and ItemFilterApplied_gBln then begin
                VendorRating_iRec.Delete(true);
                InsertVendorRating_gFnc(Vendor, "Purch. Rcpt. Header", "Purch. Rcpt. Line");
            end;
        end;
    end;


    procedure FindAvgTotal_gFnc(VendorRating_iRec: Record "Vendor Rating") AvgTotal: Decimal
    var
        VendorRating_lRec: Record "Vendor Rating";
        GRNCount_lInt: Integer;
    begin
        VendorRating_lRec.Reset;
        VendorRating_lRec.SetCurrentkey("From Date", "To Date", "Vendor No.");
        VendorRating_lRec.SetRange("From Date", FromDate_gDte);
        VendorRating_lRec.SetRange("To Date", ToDate_gDte);
        VendorRating_lRec.SetRange("Vendor No.", VendorRating_iRec."Vendor No.");
        if PurchRectLineFilter_gRec.GetFilter("No.") <> '' then
            VendorRating_lRec.SetFilter("Item No.", '%1', PurchRectLineFilter_gRec.GetFilter("No."));
        if VendorRating_lRec.FindSet() then begin
            GRNCount_lInt := 0;
            AvgTotal := 0;
            repeat
                AvgTotal += VendorRating_lRec.Total;
                GRNCount_lInt += 1;
            until VendorRating_lRec.Next = 0;
        end;

        if GRNCount_lInt > 0 then
            exit(AvgTotal / GRNCount_lInt)
        else
            exit(AvgTotal / 1)
    end;


    procedure FindAvgGrade_gFnc(AvgTotal_iDec: Decimal) AvgGread: Code[10]
    var
        GenUtiliz_lRec: Record "Vendor Rating Setup";
        BreakLoop_lBln: Boolean;
    begin
        GenUtiliz_lRec.Reset;
        GenUtiliz_lRec.SetRange(Type, GenUtiliz_lRec.Type::"Vendor Rating");
        GenUtiliz_lRec.SetFilter("To Value", '>%1', 0);
        GenUtiliz_lRec.SetFilter(Value, '%1', 0);
        if GenUtiliz_lRec.FindSet() then begin
            BreakLoop_lBln := false;
            repeat
                if (AvgTotal_iDec >= GenUtiliz_lRec."From Value") and
                   (AvgTotal_iDec <= GenUtiliz_lRec."To Value") then begin
                    AvgGread := GenUtiliz_lRec."Value Text";
                    BreakLoop_lBln := true;
                end;
            until (GenUtiliz_lRec.Next = 0) or (BreakLoop_lBln);
        end;

        exit(AvgGread);
    end;

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

