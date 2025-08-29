Report 75383 "Vendor Rating in Details"
{
    // ------------------------------------------------------------------------------------------------------------------------------------
    // Intech Systems Pvt. Ltd.
    // ------------------------------------------------------------------------------------------------------------------------------------
    // ID                        Date            Author
    // ------------------------------------------------------------------------------------------------------------------------------------
    // I-I031-400005-01          27/11/14        Abhishek
    //                           Vendor Rating functionality
    //                           Create New Report for Vendor rating in Details
    //                           (Save As from Kastwel)
    // I-I031-400006-01          07/12/14        Ganesh
    //                           Adding New Filed ISO No Captipn.
    // ------------------------------------------------------------------------------------------------------------------------------------
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Vendor Rating in Details.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;
    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Vendor No.';

            dataitem("Purch. Rcpt. Header"; "Purch. Rcpt. Header")
            {
                DataItemLink = "Buy-from Vendor No." = field("No.");
                DataItemTableView = sorting("Buy-from Vendor No.");
                PrintOnlyIfDetail = true;

                dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemTableView = sorting("Document No.", "Line No.") where(Type = const(Item), Quantity = filter(> 0));
                    PrintOnlyIfDetail = true;
                    RequestFilterFields = "No.";
                    RequestFilterHeading = 'Item No.';

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
                VendorMarked_gRecTmp.Reset;
                VendorMarked_gRecTmp.DeleteAll;
            end;
        }
        dataitem("Vendor Rating"; "Vendor Rating")
        {
            DataItemTableView = sorting("From Date", "To Date", "Vendor No.");

            column(FORMAT_TODAY_0_4_; FORMAT(Today, 0, '<Day,2>-<Month,2>-<Year4>'))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(CurrReport_PAGENO; 1)
            {
            }
            column(UserId; UserId)
            {
            }
            column(STRSUBSTNO_Text0006_gCtx_FromDate_gDte_ToDate_gDte_; StrSubstNo(Text0006_gCtx, FORMAT(FromDate_gDte, 0, '<Day,2>-<Month,2>-<Year4>'), FORMAT(ToDate_gDte, 0, '<Day,2>-<Month,2>-<Year4>')))
            {
            }
            column(Filters_gCtx; Filters_gCtx)
            {
            }
            column(VendorName_gTxt; VendorName_gTxt)
            {
            }
            column(Vendor_Rating__Vendor_No__; "Vendor No.")
            {
            }
            column(ShowOnlySummary_gBln; ShowOnlySummary_gBln)
            {
            }
            column(PageBreakNewRec_gBln; PageBreakNewRec_gBln)
            {
            }
            column(Vendor_Rating__GRN_No__; "GRN No.")
            {
            }
            column(Vendor_Rating__Item_Description_; "Item Description")
            {
            }
            column(Vendor_Rating__Purchase_Order_No__; "Purchase Order No.")
            {
            }
            column(Vendor_Rating__Purchase_Order_Date_; FORMAT("Purchase Order Date", 0, '<Day,2>-<Month,2>-<Year4>'))
            {
            }
            column(Vendor_Rating__GRN_Date_; FORMAT("GRN Date", 0, '<Day,2>-<Month,2>-<Year4>'))
            {
            }
            column(Vendor_Rating__GRN_Expected_Recipt_Date_; FORMAT("GRN Expected Recipt Date", 0, '<Day,2>-<Month,2>-<Year4>'))
            {
            }
            column(Vendor_Rating_Quantity; Quantity)
            {
            }
            column(Vendor_Rating__Quantity_Accept_; "Quantity Accept")
            {
            }
            column(Vendor_Rating__Quantity_Deviation_; "Quantity Deviation")
            {
            }
            column(Vendor_Rating__Rejected_Quantity_; "Rejected Quantity")
            {
            }
            column(Vendor_Rating__Quality_Factor_; "Quality Factor")
            {
            }
            column(Vendor_Rating__Delivery_Factor_; "Delivery Factor")
            {
            }
            column(Vendor_Rating__Quantity_Factor_; "Quantity Factor")
            {
            }
            column(Vendor_Rating_Total; Total)
            {
            }
            column(Vendor_Rating_Grade; Grade)
            {
            }
            column(SrNo_gInt; SrNo_gInt)
            {
            }
            column(Vendor_Rating__Item_Description_2_; "Item Description 2")
            {
            }
            column(TotalOrderQtyFinal_gDec; Quantity)
            {
            }
            column(AvgGrade_gCod; AvgGrade_gCod)
            {
            }
            column(Quality_Factor__GRNCounterforClassic_gInt; QltAvg_gDec)
            {
            }
            column(Delivery_Factor__GRNCounterforClassic_gInt; TimeAvg_gDec)
            {
            }
            column(Quantity_Factor__GRNCounterforClassic_gInt; QtyAVG_gDec)
            {
            }
            column(Total_GRNCounterforClassic_gInt; TotalAvg_gDec)
            {
            }
            column(TotalAvg_gDec; TotalAvg_gDec)
            {
            }
            column(QtyAVG_gDec; QtyAVG_gDec)
            {
            }
            column(TimeAvg_gDec; TimeAvg_gDec)
            {
            }
            column(QltAvg_gDec; QltAvg_gDec)
            {
            }
            column(Vendor_Rating_From_Date; FORMAT("From Date", 0, '<Day,2>-<Month,2>-<Year4>'))
            {
            }
            column(Vendor_Rating_To_Date; FORMAT("To Date", 0, '<Day,2>-<Month,2>-<Year4>'))
            {
            }
            column(Vendor_Rating_GRN_Line_No_; "GRN Line No.")
            {
            }

            trigger OnAfterGetRecord()
            var
                Vendor_lRec: Record Vendor;
                BreakLoop_lBln: Boolean;
            begin
                if Vendor_lRec.Get("Vendor No.") then
                    VendorName_gTxt := Vendor_lRec.Name;
                if PreVendorNo_gCod <> "Vendor No." then begin
                    if (SrNo_gInt <> 0) and (PageBreakNewRec_gBln) then begin
                        //CurrReport.Newpage;
                        ActualBreakIt_gBln := true;
                    end;
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
                    VendorRating_gRecTemp.Insert;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if VendorFilter_gRec.GetFilter("No.") <> '' then
                    "Vendor Rating".SetFilter("Vendor No.", '%1', VendorFilter_gRec.GetFilter("No."));
                if PurchRectLineFilter_gRec.GetFilter("No.") <> '' then
                    "Vendor Rating".SetFilter("Item No.", '%1', PurchRectLineFilter_gRec.GetFilter("No."));

                SetRange("From Date", FromDate_gDte);
                SetRange("To Date", ToDate_gDte);
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
                group(Option)
                {
                    Caption = 'Option';
                    field(FromDate_gDte; FromDate_gDte)
                    {
                        ApplicationArea = Basic;
                        Caption = 'From Date';
                    }
                    field(ToDate_gDte; ToDate_gDte)
                    {
                        ApplicationArea = Basic;
                        Caption = 'To Date';
                    }
                    field(ShowOnlySummary_gBln; ShowOnlySummary_gBln)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Show Only Summary';
                    }
                    field(PageBreakNewRec_gBln; PageBreakNewRec_gBln)
                    {
                        ApplicationArea = Basic;
                        Caption = 'New Page per Vendor';
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
        CurrReport_PAGENOCaptionLbl = 'Page';
        Vendor_Rating_CaptionLbl = 'Vendor Rating';
        FORMAT_No___CaptionLbl = 'FORMAT No. :';
        QR_740_06_Rev__No___00CaptionLbl = 'QR-740-06 Rev. No. :00';
        SrNo_gIntCaptionLbl = 'Sr No.';
        Vendor_Rating__Purchase_Order_No__CaptionLbl = 'PO No.';
        Vendor_Rating__Purchase_Order_Date_CaptionLbl = 'PO Date';
        Vendor_Rating_QuantityCaptionLbl = 'GRN Qty.';
        Vendor_Rating__Quantity_Accept_CaptionLbl = 'Qty. Accepted';
        Vendor_Rating__GRN_Expected_Recipt_Date_CaptionLbl = 'Ex. Recipt Date';
        Vendor_Rating__Quantity_Deviation_CaptionLbl = 'Qty. Deviation';
        Vendor_Rating__Rejected_Quantity_CaptionLbl = 'Qty. Rejected';
        Vendor_Rating__Quality_Factor_CaptionLbl = 'QTY. Factor';
        Vendor_Rating__Delivery_Factor_CaptionLbl = 'Delivery Rate';
        Vendor_Rating__Quantity_Factor_CaptionLbl = 'Quality Rate';
        Rating__Score_CaptionLbl = 'Rating (Score)';
        VendorName_gTxtCaptionLbl = 'Vendor Name :';
        Vendor_Rating__Vendor_No__CaptionLbl = 'Vendor Code :';
        Average_Vendor_RatingCaptionLbl = 'Average Rating';
        Average_Rating___Transfooter_CaptionLbl = 'Average Rating - Transfooter';
        //   ISONo_CaptionLbl = 'F:PU:06';
        ISONo_CaptionLbl = '';

        VendorRating_ItemDescriptionCaptionLbl = 'Item Description';
        VendorRating_GRNNoCaptionLbl = 'GRN No.';
        VendorRating_GRNDateCaptionLbl = 'GRN Date';
        VendorRating_TotalCaptionLbl = 'Total';
        VendorRating_GradeCaptionLbl = 'Grade';
    }

    trigger OnPreReport()
    var
        GotFiler_lBln: Boolean;
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
        GotFiler_lBln := false;
        if Vendor.GetFilters <> '' then begin
            Filters_gCtx += ' ' + Vendor.GetFilters;
            GotFiler_lBln := true;
        end;

        if "Purch. Rcpt. Header".GetFilters <> '' then begin
            Filters_gCtx += ' ' + "Purch. Rcpt. Header".GetFilters;
            GotFiler_lBln := true;
        end;

        if "Purch. Rcpt. Line".GetFilters <> '' then begin
            Filters_gCtx += ' ' + "Purch. Rcpt. Line".GetFilters;
            GotFiler_lBln := true;
        end;

        if not (GotFiler_lBln) then
            Filters_gCtx := '';

        VendorFilter_gRec.CopyFilters(Vendor);
        PurchRectLineFilter_gRec.CopyFilters("Purch. Rcpt. Line");
        if PurchRectLineFilter_gRec.GetFilter("No.") <> '' then
            ItemFilterApplied_gBln := true;

        //RptDateForMgt_gCdu.SetReportID_gFnc(Report::"Vendor Rating in Details");  //DateFormat-N
    end;

    var
        FromDate_gDte: Date;
        ToDate_gDte: Date;
        Text0001_gCtx: label 'From Date is Required.';
        Text0002_gCtx: label 'To Date is Required.';
        Text0003_gCtx: label 'From Date Must Be Less Than To Date.';
        Text0004_gCtx: label 'Vendor Rating Entry All Ready Exists for Vendor  No. :%1,\ Item No. :%2, GRN No. :%3. \For Date Range %4 To %5.\Do you really want to replace all old Vendor Rating Entries ?';
        Text0005_gCtx: label 'Do you want to skip check all old vendor rating entries for Vendor No. :%1.';
        VendorMarked_gRecTmp: Record Vendor temporary;
        SrNo_gInt: Integer;
        Text0006_gCtx: label 'Evaluation of Vendors - Products From : %1 To %2.';
        VendorName_gTxt: Text[100];
        PreVendorNo_gCod: Code[20];
        Text0007_gCtx: label 'Filters :';
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
        PageBreakNewRec_gBln: Boolean;
        ActualBreakIt_gBln: Boolean;
    //RptDateForMgt_gCdu: Codeunit Report d;


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

        //Disha
        if not (PruRecLine_iRec."QC Required" and ((PruRecLine_iRec."Accepted Quantity" > 0) or (PruRecLine_iRec."Rejected Quantity" > 0) or (PruRecLine_iRec."Accepted with Deviation Qty" > 0))) then
            CurrReport.Skip();
        //

        if PruRecLine_iRec."QC Required" then begin
            VendorRating_lRec."Quantity Accept" := PruRecLine_iRec."Accepted Quantity";
            //RaviShah-NS
            VendorRating_lRec."Quantity Deviation" := PruRecLine_iRec."Accepted with Deviation Qty";
            VendorRating_lRec."Rejected Quantity" := PruRecLine_iRec."Rejected Quantity";
        end
        //RaviShah-NE
        else begin
            VendorRating_lRec."Quantity Accept" := PruRecLine_iRec.Quantity;
            VendorRating_lRec."Quantity Deviation" := PruRecLine_iRec.Quantity;
            VendorRating_lRec."Rejected Quantity" := PruRecLine_iRec.Quantity;
        end;


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
        if PurchRectLineFilter_gRec.GetFilter("No.") <> '' then
            VendorRating_lRec.SetFilter("Item No.", '%1', PurchRectLineFilter_gRec.GetFilter("No."));
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
                // VendorRating_lRec."Quality Factor" := ((TotalAcceptedQty_lDec + (0.5 * TotalDeviationQty_lDec)) / TotalReciptQty_lDec)
                //                                       * QualityFactor_lDec;
                //VendorRating_lRec."Quality Factor" := ((TotalAcceptedQty_lDec + (TotalDeviationQty_lDec * 0.5)) / TotalReciptQty_lDec) * QualityFactor_lDec;
                VendorRating_lRec."Quality Factor" := ((VendorRating_lRec."Quantity Accept" + (VendorRating_lRec."Quantity Deviation" * 0.5)) / VendorRating_lRec.Quantity) * QualityFactor_lDec; //T12067-N

                VendorRating_lRec."Delivery Factor" := Round((VendorRating_lRec."Delivery Percentage" * DeliveryFactor_lDec / 100), 0.01); //T12067-N
                // VendorRating_lRec."Delivery Factor" := Round(((TotalDeliveryPerc_lDec / TotalGRN_lDec) * DeliveryFactor_lDec) / 100, 0.01); //T12067-N
                // VendorRating_lRec."Quantity Factor" := (TotalAcceptedQty_lDec / TotalReciptQty_lDec) * QuantityFactor_lDec; //T12067-O
                VendorRating_lRec."Quantity Factor" := (VendorRating_lRec."Quantity Accept" / VendorRating_lRec.Quantity) * QuantityFactor_lDec; //T12067-N



                // VendorRating_lRec."Quality Factor" := (VendorRating_lRec."Quantity Accept" / VendorRating_lRec.Quantity) * QualityFactor_lDec;
                // VendorRating_lRec."Delivery Factor" := ((TotalDeliveryPerc_lDec / TotalGRN_lDec) * DeliveryFactor_lDec) / 100;
                //  VendorRating_lRec."Delivery Factor" := (VendorRating_lRec."Quantity Deviation" / VendorRating_lRec.Quantity) * DeliveryFactor_lDec; //T12067-O
                //  VendorRating_lRec."Quantity Factor" := (VendorRating_lRec."Rejected Quantity" / VendorRating_lRec.Quantity) * QuantityFactor_lDec; //T12067-O
                //T12067-NS
                // if VendorRating_lRec."Quantity Deviation" <> 0 then
                //     VendorRating_lRec."Delivery Factor" := (VendorRating_lRec."Quantity Deviation" / VendorRating_lRec.Quantity) * DeliveryFactor_lDec
                // else
                //     VendorRating_lRec."Delivery Factor" := (VendorRating_lRec."Quantity Accept" / VendorRating_lRec.Quantity) * DeliveryFactor_lDec;

                // if VendorRating_lRec."Rejected Quantity" <> 0 then
                //     VendorRating_lRec."Quantity Factor" := (VendorRating_lRec."Rejected Quantity" / VendorRating_lRec.Quantity) * QuantityFactor_lDec
                // else
                //     VendorRating_lRec."Quantity Factor" := (VendorRating_lRec."Quantity Accept" / VendorRating_lRec.Quantity) * QuantityFactor_lDec;
                //T12067-NE

                // VendorRating_lRec."Quantity Factor" := (TotalAcceptedQty_lDec / TotalReciptQty_lDec) * QuantityFactor_lDec;


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
}

