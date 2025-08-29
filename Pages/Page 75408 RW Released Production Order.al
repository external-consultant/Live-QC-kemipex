page 75408 "RW-Released Production Order"
{
    //T07638- Create new page
    Caption = 'Rework Released Production Order';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Order,Request Approval';
    SourceTable = "Production Order";
    SourceTableView = WHERE(Status = CONST(Released));
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    QuickEntry = false;
                    ToolTip = 'Specifies the description of the production order.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Manufacturing;
                    QuickEntry = false;
                    ToolTip = 'Specifies an additional part of the production order description.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the source type of the production order.';

                    trigger OnValidate()
                    begin
                        if xRec."Source Type" <> Rec."Source Type" then
                            Rec."Source No." := '';
                    end;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the item number or number of the source document that the entry originates from.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the variant code for production order item.';
                    //Visible = false;//12706

                }
                field("Production BOM Version"; Rec."Production BOM Version")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the Production BOM Version for production order item.';

                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = Manufacturing;
                    QuickEntry = false;
                    ToolTip = 'Specifies the search description.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies how many units of the item or the family to produce (production quantity).';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the due date of the production order.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = Manufacturing;
                    QuickEntry = false;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Manufacturing;
                    QuickEntry = false;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Manufacturing;
                    QuickEntry = false;
                    ToolTip = 'Specifies when the production order card was last modified.';
                }

                field("Quality Order"; rec."Quality Order")
                {
                    ApplicationArea = All;
                }

                field("Posted QC No,"; rec."Posted QC No,")
                {
                    ApplicationArea = All;
                }
                //T12542-NS
                field("QC Status"; Rec."QC Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type Of Transaction field.', Comment = '%';
                }
                field("Order Status"; Rec."Order Status")
                {
                    ApplicationArea = All;
                }
            }
            part(ProdOrderLines; "Released Prod. Order Lines")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Prod. Order No." = FIELD("No.");
                UpdatePropagation = Both;
            }
            group(Schedule)
            {
                Caption = 'Schedule';
#if not CLEAN17
                field("Starting Time"; StartingTime)
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies the starting time of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Starting Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';

                    trigger OnValidate()
                    begin
                        Rec.Validate("Starting Time", StartingTime);
                        CurrPage.Update(true);
                    end;
                }
                field("Starting Date"; StartingDate)
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies the starting date of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Starting Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';

                    trigger OnValidate()
                    begin
                        Rec.Validate("Starting Date", StartingDate);
                        CurrPage.Update(true);
                    end;
                }
                field("Ending Time"; EndingTime)
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ending time of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Ending Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';

                    trigger OnValidate()
                    begin
                        Rec.Validate("Ending Time", EndingTime);
                        CurrPage.Update(true);
                    end;
                }
                field("Ending Date"; EndingDate)
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ending date of the production order.';
                    Visible = DateAndTimeFieldVisible;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Ending Date-Time field should be used instead.';
                    ObsoleteTag = '17.0';

                    trigger OnValidate()
                    begin
                        Rec.Validate("Ending Date", EndingDate);
                        CurrPage.Update(true);
                    end;
                }
#endif
                field("Starting Date-Time"; Rec."Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies the starting date and starting time of the production order.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Ending Date-Time"; Rec."Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ending date and ending time of the production order.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    Importance = Promoted;
                    ToolTip = 'Specifies links between business transactions made for the item and an inventory account in the general ledger, to group amounts for that item type.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';

                    trigger OnValidate()
                    begin
                        ShortcutDimension1CodeOnAfterV;
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';

                    trigger OnValidate()
                    begin
                        ShortcutDimension2CodeOnAfterV;
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies the location code to which you want to post the finished product from this production order.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    Importance = Promoted;
                    ToolTip = 'Specifies a bin to which you want to post the finished items.';
                }
            }
            group("QC Details") //T12212
            {
                Caption = 'QC Details';
                field("Rework Order No."; rec."Rework Order No.")
                {
                    ApplicationArea = All;
                }
                field("Rework Quantity"; Rec."Rework Quantity")
                {
                    ApplicationArea = All;
                }
                field("QC Receipt No"; Rec."QC Receipt No")
                {
                    ApplicationArea = all;
                }
                field("Posted QC Receipt No"; Rec."Posted QC Receipt No")
                {
                    ApplicationArea = All;
                }
                field("Rejected Quantity (QC)"; Rec."Rejected Quantity (QC)")
                {
                    ApplicationArea = All;
                }
                field("Reject Reason"; rec."Reject Reason")
                {
                    ApplicationArea = All;
                }
                field("Rework Reason"; rec."Rework Reason")
                {
                    ApplicationArea = All;
                }

            }

            group("Rework Order Details") //T12212
            {
                Caption = 'Rework Order Details';

                field("Rework Order"; rec."Rework Order")
                {
                    ApplicationArea = All;

                }
                field("Source Order No."; rec."Source Order No.")
                {
                    ApplicationArea = All;
                }
                field("Source QC No."; rec."Source QC No.")
                {
                    ApplicationArea = All;
                }
                field("Source Posted QC No."; rec."Source Posted QC No.")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the item ledger entries of the item on the document or journal line.';
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        RunObject = Page "Capacity Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the capacity ledger entries of the involved production order. Capacity is recorded either as time (run time, stop time, or setup time) or as quantity (scrap quantity or output quantity).';
                    }
                    action("Value Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the value entries of the item on the document or journal line.';
                    }
                    action("&Warehouse Entries")
                    {
                        ApplicationArea = Warehouse;
                        Caption = '&Warehouse Entries';
                        Image = BinLedger;
                        RunObject = Page "Warehouse Entries";
                        RunPageLink = "Source Type" = FILTER(83 | 5406 | 5407),
                                      "Source Subtype" = FILTER("3" | "4" | "5"),
                                      "Source No." = FIELD("No.");
                        RunPageView = SORTING("Source Type", "Source Subtype", "Source No.");
                        ToolTip = 'View the history of quantities that are registered for the item in warehouse activities. ';
                    }
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim;
                    end;
                }
                action(Planning)
                {
                    ApplicationArea = Planning;
                    Caption = 'Plannin&g';
                    Image = Planning;
                    ToolTip = 'Plan supply orders for the production order order by order.';

                    trigger OnAction()
                    var
                        OrderPlanning: Page "Order Planning";
                    begin
                        OrderPlanning.SetProdOrder(Rec);
                        OrderPlanning.RunModal();
                    end;
                }
                action(Statistics)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Production Order Statistics";
                    RunPageLink = Status = FIELD(Status),
                                  "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Prod. Order Comment Sheet";
                    RunPageLink = Status = FIELD(Status),
                                  "Prod. Order No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action("Put-away/Pick Lines/Movement Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Put-away/Pick Lines/Movement Lines';
                    Image = PutawayLines;
                    RunObject = Page "Warehouse Activity Lines";
                    RunPageLink = "Source Type" = FILTER(5406 | 5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", "Unit of Measure Code", "Action Type", "Breakbulk No.", "Original Breakbulk");
                    ToolTip = 'View the list of ongoing inventory put-aways, picks, or movements for the order.';
                }
                action("Registered P&ick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Registered P&ick Lines';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Act.-Lines";
                    RunPageLink = "Source Type" = CONST(5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                    ToolTip = 'View the list of warehouse picks that have been made for the order.';
                }
                action("Registered Invt. Movement Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Registered Invt. Movement Lines';
                    Image = RegisteredDocs;
                    RunObject = Page "Reg. Invt. Movement Lines";
                    RunPageLink = "Source Type" = CONST(5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                    ToolTip = 'View the list of inventory movements that have been made for the order.';
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(RefreshProductionOrder)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Re&fresh Production Order';
                    Ellipsis = true;
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Calculate changes made to the production order header without involving production BOM levels. The function calculates and initiates the values of the component lines and routing lines based on the master data defined in the assigned production BOM and routing, according to the order quantity and due date on the production order''s header.';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        ProdOrder.SetRange(Status, Rec.Status);
                        ProdOrder.SetRange("No.", Rec."No.");
                        REPORT.RunModal(REPORT::"Refresh Production Order", true, true, ProdOrder);
                    end;
                }
                action("Re&plan")
                {
                    ApplicationArea = Planning;
                    Caption = 'Re&plan';
                    Ellipsis = true;
                    Image = Replan;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Calculate changes made to components and routings lines including items on lower production BOM levels for which it may generate new production orders.';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        ProdOrder.SetRange(Status, Rec.Status);
                        ProdOrder.SetRange("No.", Rec."No.");
                        REPORT.RunModal(REPORT::"Replan Production Order", true, true, ProdOrder);
                    end;
                }
                action("Change &Status")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Change &Status';
                    Ellipsis = true;
                    Image = ChangeStatus;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Change the production order to another status, such as Released.';

                    trigger OnAction()
                    begin
                        CurrPage.Update();
                        CODEUNIT.Run(CODEUNIT::"Prod. Order Status Management", Rec);
                    end;
                }
                action("&Update Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    Caption = '&Update Unit Cost';
                    Ellipsis = true;
                    Image = UpdateUnitCost;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Update the cost of the parent item per changes to the production BOM or routing.';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                    begin
                        ProdOrder.SetRange(Status, Rec.Status);
                        ProdOrder.SetRange("No.", Rec."No.");

                        REPORT.RunModal(REPORT::"Update Unit Cost", true, true, ProdOrder);
                    end;
                }
                action("&Reserve")
                {
                    ApplicationArea = Reservation;
                    Caption = '&Reserve';
                    Image = Reserve;
                    ToolTip = 'Reserve the quantity that is required on the document line that you opened this window for.';

                    trigger OnAction()
                    begin
                        CurrPage.ProdOrderLines.PAGE.PageShowReservation();
                    end;
                }
                action(OrderTracking)
                {
                    ApplicationArea = Planning;
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ToolTip = 'Tracks the connection of a supply to its corresponding demand. This can help you find the original demand that created a specific production order or purchase order.';

                    trigger OnAction()
                    begin
                        CurrPage.ProdOrderLines.PAGE.ShowTracking();
                    end;
                }
                action("C&opy Prod. Order Document")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'C&opy Prod. Order Document';
                    Ellipsis = true;
                    Image = CopyDocument;
                    ToolTip = 'Copy information from an existing production order record to a new one. This can be done regardless of the status type of the production order. You can, for example, copy from a released production order to a new planned production order. Note that before you start to copy, you have to create the new record.';

                    trigger OnAction()
                    begin
                        CopyProdOrderDoc.SetProdOrder(Rec);
                        CopyProdOrderDoc.RunModal();
                        Clear(CopyProdOrderDoc);
                    end;
                }
            }
            //Approval Process-NS
            group("Request Approval")
            {
                action("Send A&pproval request")
                {
                    Enabled = Not OpenApprovalEntriesExist_gBln ANd CanRequestApprovalForFlow_gBln;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = ALL;
                    trigger OnAction()
                    begin
                        If ProductionOrderWorkflowMgmt.CheckProductionOrderApprovalWorkFlowEnable(Rec) then
                            ProductionOrderWorkflowMgmt.OnSendProductionOrderForApproval(Rec);
                    end;
                }
                action("Cancel Approval request")
                {
                    Enabled = CanCancelApprovalForRecord_gBln or CanCancelApprovalForFlow_gBln;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = ALL;
                    trigger OnAction()
                    var

                    begin
                        ProductionOrderWorkflowMgmt.OnCancleProductionOrderForApproval(Rec);
                    end;
                }
                action("Reopen Order Status")
                {
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = ALL;
                    Caption = 'Re&open Approval';
                    Image = ReOpen;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";

                    begin
                        if Rec."Order Status" = Rec."Order Status"::Open then
                            exit;

                        //OnBeforeReopenTransferDoc(ServHeader);
                        if Rec."Order Status" <> Rec."Order Status"::Released then
                            Error('Document must be released to Reopen it');

                        Rec.Validate("Order Status", Rec."Order Status"::Open);
                        Rec.Modify(true);
                        //YT on workflow Enable you want to reopen in manual-(Send for Approval Button )Button need to enable
                        ApprovalEntry_gRec.reset;
                        ApprovalEntry_gRec.SetRange("Record ID to Approve", rec.RecordId);
                        ApprovalEntry_gRec.SetRange(Status, ApprovalEntry_gRec.Status::Open);
                        if ApprovalEntry_gRec.FindSet() then
                            ProductionOrderWorkflowMgmt.RejectedApprovalEntry(ApprovalEntry_gRec);
                        //
                    end;
                }
                action("Release Order Status")
                {
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = ALL;
                    Caption = 'Re&lease Approval';
                    Image = ReleaseDoc;
                    ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';

                    trigger OnAction()
                    var
                    begin
                        if Rec."Order Status" = Rec."Order Status"::Released then
                            exit;

                        if ProductionOrderWorkflowMgmt.IsProductionOrderApprovalWorkFlowEnable(Rec) then
                            Error('Kindly , use Send for Approval action for Sending approval.')
                        else begin
                            Rec."Order Status" := Rec."Order Status"::Released;
                            rec.Modify();
                        end;
                    end;
                }

                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ApplicationArea = ALL;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';
                    // RunObject = Page "Approval Entries";
                    // RunPageLink = "Document No." = field("No.");
                    trigger OnAction()
                    var
                    begin
                        OpenApprovalsProduction(Rec);
                    end;
                }

                // action(Approve)                
                // {
                //     Enabled = OpenApprovalEntriesExistforCurruser_gBln;
                //     Image = Approve;
                //     Promoted = true;
                //     PromotedIsBig = true;
                //     PromotedCategory = Category10;
                //     PromotedOnly = true;
                //     ApplicationArea = All;

                //     trigger OnAction()
                //     var
                //     begin
                //         ApprovalsMgmt_gCdu.ApproveRecordApprovalRequest(Rec.RecordId);
                //     end;
                // }


                // action(Reject)
                // {
                //     Enabled = OpenApprovalEntriesExistforCurruser_gBln;
                //     Image = Reject;
                //     Promoted = true;
                //     PromotedIsBig = true;
                //     PromotedCategory = Category10;
                //     PromotedOnly = true;
                //     ApplicationArea = All;
                //     trigger OnAction()
                //     var
                //     begin
                //         ApprovalsMgmt_gCdu.RejectRecordApprovalRequest(Rec.RecordId);
                //     end;
                // }
            }
            //Approval Process-NE
            group(Warehouse)
            {
                Caption = 'Warehouse';
                Image = Worksheets;
                action("Create Inventor&y Put-away/Pick/Movement")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Create Inventor&y Put-away/Pick/Movement';
                    Ellipsis = true;
                    Image = CreatePutAway;
                    ToolTip = 'Prepare to create inventory put-aways, picks, or movements for the parent item or components on the production order.';

                    trigger OnAction()
                    begin
                        Rec.CreateInvtPutAwayPick;
                    end;
                }
                action("Create I&nbound Whse. Request")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Create I&nbound Whse. Request';
                    Image = NewToDo;
                    ToolTip = 'Signal to the warehouse that the produced items are ready to be handled. The request enables the creation of the require warehouse document, such as a put-away.';

                    trigger OnAction()
                    var
                        WhseOutputProdRelease: Codeunit "Whse.-Output Prod. Release";
                    begin
                        if WhseOutputProdRelease.CheckWhseRqst(Rec) then
                            Message(Text002)
                        else begin
                            Clear(WhseOutputProdRelease);
                            if WhseOutputProdRelease.Release(Rec) then
                                Message(Text000)
                            else
                                Message(Text001);
                        end;
                    end;
                }
                action("Create Warehouse Pick")
                {
                    AccessByPermission = TableData "Bin Content" = R;
                    ApplicationArea = Warehouse;
                    Caption = 'Create Warehouse Pick';
                    Image = CreateWarehousePick;
                    ToolTip = 'Create warehouse pick documents for the production order components.';

                    trigger OnAction()
                    begin
                        Rec.SetHideValidationDialog(false);
                        Rec.CreatePick(UserId, 0, false, false, false);
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action("Job Card")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Job Card';
                    Ellipsis = true;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'View a list of the work in progress of a production order. Output, scrapped quantity, and production lead time are shown depending on the operation.';

                    trigger OnAction()
                    begin
                        ManuPrintReport.PrintProductionOrder(Rec, 0);
                    end;
                }
                action("Mat. &Requisition")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Mat. &Requisition';
                    Ellipsis = true;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'View a list of material requirements per production order. The report shows you the status of the production order, the quantity of end items and components with the corresponding required quantity. You can view the due date and location code of each component.';

                    trigger OnAction()
                    begin
                        ManuPrintReport.PrintProductionOrder(Rec, 1);
                    end;
                }
                action("Shortage List")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Shortage List';
                    Ellipsis = true;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'View a list of the missing quantity per production order. The report shows how the inventory development is planned from today until the set day - for example whether orders are still open.';

                    trigger OnAction()
                    begin
                        ManuPrintReport.PrintProductionOrder(Rec, 2);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Subcontractor - Dispatch List")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Subcontractor - Dispatch List';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Subcontractor - Dispatch List";
                ToolTip = 'View the list of material to be sent to manufacturing subcontractors.';
            }
        }
    }


    trigger OnInit()
    begin
        DateAndTimeFieldVisible := false;
    end;

    trigger OnOpenPage()
    begin
        DateAndTimeFieldVisible := false;
        Activate_lFnc;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistforCurruser_gBln := ApprovalsMgmt_gCdu.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);

        OpenApprovalEntriesExist_gBln := ApprovalsMgmt_gCdu.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord_gBln := ApprovalsMgmt_gCdu.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt_gCdu.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow_gBln, CanCancelApprovalForFlow_gBln);
        Activate_lFnc;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Rework Order" := true;
    end;



    var
        CopyProdOrderDoc: Report "Copy Production Order Document";
        ManuPrintReport: Codeunit "Manu. Print Report";
        Text000: Label 'Inbound Whse. Requests are created.';
        Text001: Label 'No Inbound Whse. Request is created.';
        Text002: Label 'Inbound Whse. Requests have already been created.';
#if not CLEAN17
        StartingTime: Time;
        EndingTime: Time;
        StartingDate: Date;
        EndingDate: Date;
        DateAndTimeFieldVisible: Boolean;
        WorkflowWebhookMgt_gCdu: Codeunit "Workflow Webhook Management";
        ApprovalsMgmt_gCdu: Codeunit "Approvals Mgmt.";
        OpenApprovalEntriesExistforCurruser_gBln: Boolean;
        OpenApprovalEntriesExist_gBln: Boolean;
        CanCancelApprovalForRecord_gBln: Boolean;
        CanCancelApprovalForFlow_gBln: Boolean;
        CanRequestApprovalForFlow_gBln: Boolean;
        ActionButtonVisible_gBln: Boolean;
        ProductionOrderWorkflowMgmt: Codeunit "Production Order Workflow Mgmt";
        EditibleProBomVersion_gBln: Boolean;
        ApprovalEntry_gRec: Record "Approval Entry";
#endif

    local procedure ShortcutDimension1CodeOnAfterV()
    begin
        CurrPage.ProdOrderLines.PAGE.UpdateForm(true);
    end;

    local procedure ShortcutDimension2CodeOnAfterV()
    begin
        CurrPage.ProdOrderLines.PAGE.UpdateForm(true);
    end;

    Local procedure Activate_lFnc()
    begin
        if rec."Order Status" in [rec."Order Status"::"Pending Approval", rec."Order Status"::Open] then
            ActionButtonVisible_gBln := false
        else
            ActionButtonVisible_gBln := true;

        if rec."Order Status" in [rec."Order Status"::"Pending Approval", rec."Order Status"::Released] then
            EditibleProBomVersion_gBln := false
        else
            EditibleProBomVersion_gBln := true;

        // if not ActionButtonVisible_gBln then
        //     CurrPage.Editable := false;

    end;

    local procedure OpenApprovalsProduction(ProductionOrder: Record "Production Order")
    begin
        RunWorkflowEntriesPage(
            ProductionOrder.RecordId(), DATABASE::"Production Order", Enum::"Approval Document Type"::Order, ProductionOrder."No.");
    end;

    Local procedure RunWorkflowEntriesPage(RecordIDInput: RecordID; TableId: Integer; DocumentType: Enum "Approval Document Type"; DocumentNo: Code[20])
    var
        ApprovalEntry: Record "Approval Entry";
        WorkflowWebhookEntry: Record "Workflow Webhook Entry";
        Approvals: Page Approvals;
        WorkflowWebhookEntries: Page "Workflow Webhook Entries";
        ApprovalEntries: Page "Approval Entries";
    begin

        // if we are looking at a particular record, we want to see only record related workflow entries
        if DocumentNo <> '' then begin
            ApprovalEntry.SetRange("Record ID to Approve", RecordIDInput);
            WorkflowWebhookEntry.SetRange("Record ID", RecordIDInput);
            // if we have flows created by multiple applications, start generic page filtered for this RecordID
            if not ApprovalEntry.IsEmpty() and not WorkflowWebhookEntry.IsEmpty() then begin
                Approvals.Setfilters(RecordIDInput);
                Approvals.Run();
            end else begin
                // otherwise, open the page filtered for this record that corresponds to the type of the flow
                if not WorkflowWebhookEntry.IsEmpty() then begin
                    WorkflowWebhookEntries.Setfilters(RecordIDInput);
                    WorkflowWebhookEntries.Run();
                    exit;
                end;

                if not ApprovalEntry.IsEmpty() then begin
                    ApprovalEntries.SetRecordFilters(TableId, DocumentType, DocumentNo);
                    ApprovalEntries.Run();
                    exit;
                end;

                // if no workflow exist, show (empty) joint workflows page
                Approvals.Setfilters(RecordIDInput);
                Approvals.Run();
            end
        end else
            // otherwise, open the page with all workflow entries
            Approvals.Run();
    end;
}

