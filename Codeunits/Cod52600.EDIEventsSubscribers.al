codeunit 52600 "IDL EDI Events & Subscribers"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Load Fields", OnAfterSetUpOutFields, '', false, false)]
    local procedure OnAfterSetUpOutFields();
    var
        LAXEDILoadFields: Codeunit "LAX EDI Load Fields";
        LAXFieldType: Enum "LAX EDI Virtual Field Type";
        LAXDataType: Enum "LAX EDI ERP Data Type";
    begin
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'SAC Amount', LAXDataType::Decimal, 'SAC Amount (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'SAC *01', LAXDataType::Text, 'SAC *01 (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'TDS*04', LAXDataType::Decimal, 'TDS*04 (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'Tax %', LAXDataType::Decimal, 'Tax % (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'Bill of Lading No.', LAXDataType::Text, 'Bill of Lading No. (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'EDI Discount Code', LAXDataType::Text, 'EDI Discount Code (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSINV', LAXFieldType::"EDI Out", 'EDI Description', LAXDataType::Text, 'EDI Description (IDL)');

        LAXEDILoadFields.WriteEDIOutFields('E_SLSASN', LAXFieldType::"EDI Out", 'Lading Quantity', LAXDataType::Integer, 'Lading Quantity (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSASN', LAXFieldType::"EDI Out", 'Packages (Top Level)', LAXDataType::Integer, 'Packages (Top Level) (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSASN', LAXFieldType::"EDI Out", 'Packages (Lower Level)', LAXDataType::Integer, 'Packages (Lower Level) (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSASN', LAXFieldType::"EDI Out", 'Trans_Method', LAXDataType::Text, 'Trans_Method (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSASN', LAXFieldType::"EDI Out", 'Master Pack', LAXDataType::Decimal, 'Master Pack (IDL)');
        LAXEDILoadFields.WriteEDIOutFields('E_SLSASN', LAXFieldType::"EDI Out", 'CTT*01', LAXDataType::Integer, 'CTT*01 (IDL)');


    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Sales Invoice Send", OnBeforeLoadEDIOut, '', false, false)]
    local procedure cod14002360_OnBeforeLoadEDIOut(EDIElement: Record "LAX EDI Element"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceLine: Record "Sales Invoice Line"; var CustomEDIOut: Boolean; var BoolenVariable: Boolean; var DateVariable: Date; var IntegerVariable: Integer; var DecimalVariable: Decimal; var TimeVariable: Time; var DateTimeVariable: DateTime; i: Integer; var OutFldArray: array[100] of Text);
    var
        SalesInvoiceLineRecLcl: Record "Sales Invoice Line";
        BOLFoundVarLcl: Boolean;
        TempSalesShptLine: Record "Sales Shipment Line" temporary;
        LAXBillofLadingLineRecLcl: Record "LAX Bill of Lading Line";
    begin
        case EDIElement."Field Name" of
            'SAC Amount':
                begin
                    OutFldArray[i] := '';
                    DecimalVariable := EDISingleInstance.GetSACAmount();
                    CustomEDIOut := true;
                end;
            'SAC *01':
                begin
                    OutFldArray[i] := '';
                    OutFldArray[i] := EDISingleInstance.GetSAC01();
                    CustomEDIOut := true;
                end;
            'EDI Discount Code':
                begin
                    OutFldArray[i] := '';
                    OutFldArray[i] := EDISingleInstance.GetEDIDiscountCode();
                    CustomEDIOut := true;
                end;
            'EDI Description':
                begin
                    OutFldArray[i] := '';
                    OutFldArray[i] := EDISingleInstance.GetEDIDescription();
                    CustomEDIOut := true;
                end;

            'TDS*04':
                begin
                    OutFldArray[i] := '';
                    PaymentTermsRecGbl.reset;
                    if SalesInvoiceHeader."Payment Discount %" <> 0 then begin
                        SalesInvoiceHeader.CalcFields("Amount Including VAT", Amount);
                        DecimalVariable := SalesInvoiceHeader.Amount * SalesInvoiceHeader."Payment Discount %" / 100;
                    end;
                    CustomEDIOut := true;
                end;
            'Tax %':
                begin
                    OutFldArray[i] := '';
                    SalesInvoiceLineRecLcl.Reset();
                    SalesInvoiceLineRecLcl.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLineRecLcl.SetFilter("VAT %", '<>%1', 0);
                    if SalesInvoiceLineRecLcl.FindFirst() then
                        DecimalVariable := SalesInvoiceLineRecLcl."VAT %";
                    CustomEDIOut := true;
                end;
            'Bill of Lading No.':
                begin
                    OutFldArray[i] := '';
                    BOLFoundVarLcl := false;
                    SalesInvoiceLineRecLcl.Reset();
                    SalesInvoiceLineRecLcl.SetRange("Document No.", SalesInvoiceHeader."No.");
                    SalesInvoiceLineRecLcl.SetRange(Type, SalesInvoiceLineRecLcl.Type::Item);
                    SalesInvoiceLineRecLcl.SetFilter(Quantity, '<>%1', 0);
                    if SalesInvoiceLineRecLcl.FindSet() then begin
                        repeat
                            TempSalesShptLine.Reset();
                            TempSalesShptLine.DeleteAll();
                            SalesInvoiceLineRecLcl.GetSalesShptLines(TempSalesShptLine);
                            if TempSalesShptLine.FindFirst() then begin
                                LAXBillofLadingLineRecLcl.Reset();
                                LAXBillofLadingLineRecLcl.SetRange(Type, LAXBillofLadingLineRecLcl.Type::"Sales Shipment (Posted)");
                                LAXBillofLadingLineRecLcl.SetRange("No.", TempSalesShptLine."Document No.");
                                if LAXBillofLadingLineRecLcl.FindFirst() then begin
                                    OutFldArray[i] := LAXBillofLadingLineRecLcl."Bill of Lading No.";
                                    BOLFoundVarLcl := true;
                                end;
                            end;
                        until (SalesInvoiceLineRecLcl.Next() = 0) OR BOLFoundVarLcl;
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI ASN Send", OnBeforeLoadEDIOut, '', false, false)]
    local procedure Cod14002358_OnBeforeLoadEDIOut(EDIElement: Record "LAX EDI Element"; BillOfLading: Record "LAX Bill of Lading"; BillOfLadingLine: Record "LAX Bill of Lading Line"; BillofLadingSummaryLine: Record "LAX BOL Summary Line"; var CustomEDIOut: Boolean; var BoolenVariable: Boolean; var DateVariable: Date; var IntegerVariable: Integer; var DecimalVariable: Decimal; var TimeVariable: Time; var DateTimeVariable: DateTime; i: Integer; var OutFldArray: array[100] of Text);
    var
        BOLInformationLineRecLcl: Record "LAX BOL Information Line";
        BOLLineRecLcl: Record "LAX Bill of Lading Line";
        LTLShipmentVarLcl: Boolean;
        PostedPackLineRecLcl: Record "LAX Posted Package Line";
        PostedPackLineRecLcl2: Record "LAX Posted Package Line";
        ItemUOMRecLcl: Record "Item Unit of Measure";
        SalesShptHeadRecLcl: Record "Sales Shipment Header";
        SalesShptLineRecLcl: Record "Sales Shipment Line";
        NoofShptLinesVarLcl: Integer;
    begin
        clear(LTLShipmentVarLcl);

        BOLLineRecLcl.reset;
        BOLLineRecLcl.SetRange("Bill of Lading No.", BillOfLading."No.");
        BOLLineRecLcl.SetRange(Type, BOLLineRecLcl.Type::"Sales Shipment (Posted)");
        if not BOLLineRecLcl.FindFirst() then
            BOLLineRecLcl.init;

        if not SalesShptHeadRecLcl.get(BOLLineRecLcl."No.") then
            SalesShptHeadRecLcl.Init();


        BOLInformationLineRecLcl.Reset();
        BOLInformationLineRecLcl.SetRange("Bill of Lading No.", BOLLineRecLcl."Bill of Lading No.");
        BOLInformationLineRecLcl.SetRange(Type, BOLInformationLineRecLcl.Type::"External Doc. No.");
        BOLInformationLineRecLcl.SetRange("Info. Line Type", BOLInformationLineRecLcl."Info. Line Type"::"Cust. Order Info.");
        if not BOLInformationLineRecLcl.FindFirst() then
            BOLInformationLineRecLcl.Init();

        if BOLInformationLineRecLcl."External Document No." <> '' then
            LTLShipmentVarLcl := true;

        case EDIElement."Field Name" of
            'Packages (Top Level)':
                begin
                    OutFldArray[i] := '';
                    IntegerVariable := BOLInformationLineRecLcl."Packages (Top Level)";
                    CustomEDIOut := true;
                end;
            'Packages (Lower Level)':
                begin
                    OutFldArray[i] := '';
                    IntegerVariable := BOLInformationLineRecLcl."Packages (Lower Level)";
                    CustomEDIOut := true;
                end;
            'Lading Quantity':
                begin
                    OutFldArray[i] := '';
                    if LTLShipmentVarLcl then
                        DecimalVariable := BOLInformationLineRecLcl."Packages (Lower Level)"
                    else
                        DecimalVariable := BOLInformationLineRecLcl."Packages (Top Level)";
                    CustomEDIOut := true;
                end;
            'Trans_Method':
                begin
                    OutFldArray[i] := '';
                    if LTLShipmentVarLcl then
                        OutFldArray[i] := 'M'
                    else
                        OutFldArray[i] := 'U';
                    CustomEDIOut := true;
                end;
            'Master Pack':
                begin
                    OutFldArray[i] := '';
                    PostedPackLineRecLcl.reset;
                    PostedPackLineRecLcl.SetRange("Package No.", BillofLadingSummaryLine."Package No.");
                    PostedPackLineRecLcl.SetRange("Line No.", BillofLadingSummaryLine."Package Line Line No.");
                    if PostedPackLineRecLcl.FindFirst() then begin
                        if PostedPackLineRecLcl.Type = PostedPackLineRecLcl.Type::Item then begin
                            ItemUOMRecLcl.reset;
                            ItemUOMRecLcl.SetRange("Item No.", PostedPackLineRecLcl."No.");
                            ItemUOMRecLcl.SetRange(Code, 'MP');
                            if ItemUOMRecLcl.FindFirst() then
                                DecimalVariable := ItemUOMRecLcl."Qty. per Unit of Measure"
                            else
                                DecimalVariable := 1;
                        end else begin
                            if PostedPackLineRecLcl.Type = PostedPackLineRecLcl.Type::Package then begin
                                PostedPackLineRecLcl2.SetRange("Posted Source ID", BillofLadingSummaryLine."Posted Source ID");
                                //PostedPackLineRecLcl2.SetRange("Package No.", PostedPackLineRecLcl."No.");
                                PostedPackLineRecLcl2.SetRange("No.", BillofLadingSummaryLine."Package Line No.");
                                if PostedPackLineRecLcl2.FindFirst() then begin
                                    ItemUOMRecLcl.reset;
                                    ItemUOMRecLcl.SetRange("Item No.", PostedPackLineRecLcl2."No.");
                                    ItemUOMRecLcl.SetRange(Code, 'MP');
                                    if ItemUOMRecLcl.FindFirst() then
                                        DecimalVariable := ItemUOMRecLcl."Qty. per Unit of Measure"
                                    else
                                        DecimalVariable := 1;
                                end;
                            end;
                        end;
                    end;
                    CustomEDIOut := true;
                end;
            'CTT*01':
                begin
                    OutFldArray[i] := '';
                    Clear(NoofShptLinesVarLcl);
                    SalesShptLineRecLcl.reset;
                    SalesShptLineRecLcl.SetRange("Document No.", SalesShptHeadRecLcl."No.");
                    SalesShptLineRecLcl.SetRange(Type, SalesShptLineRecLcl.Type::Item);
                    SalesShptLineRecLcl.SetFilter(Quantity, '<>%1', 0);
                    if SalesShptLineRecLcl.FindSet() then
                        repeat
                            NoofShptLinesVarLcl += 1;
                        until (SalesShptLineRecLcl.Next() = 0);
                    IntegerVariable := NoofShptLinesVarLcl;
                    CustomEDIOut := true;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", OnBeforeUpdateReceiveDocStatusFields, '', false, false)]
    local procedure cod14002365_OnBeforeUpdateReceiveDocStatusFields(var EDIRecDocHdr: Record "LAX EDI Receive Document Hdr.");
    Var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset;
        SalesHeader.SetCurrentKey("LAX EDI Order", "LAX EDI Trade Partner", "LAX EDI Internal Doc. No.");
        SalesHeader.SetRange("LAX EDI Internal Doc. No.", EDIRecDocHdr."Internal Doc. No.");
        if SalesHeader.Find('-') then
            repeat
                SalesHeader.Calcbottomline(SalesHeader)
            until SalesHeader.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Sales Invoice Send", OnBeforeReadAssocTables, '', false, false)]
    local procedure cod14002360_OnBeforeReadAssocTables(SalesInvoiceHeader: Record "Sales Invoice Header");
    begin
        EDISingleInstance.BuildBLDSalesInvoiceLines(SalesInvoiceHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Sales Invoice Send", OnBeforeNextEDISegment, '', false, false)]
    local procedure cod14002360_OnBeforeNextEDISegment(var EDISegment: Record "LAX EDI Segment"; LoopFinished: Boolean);
    begin
        If EDISegment.Segment = 'SAC-DISC' then begin
            if not EDISingleInstance.GetNextBLDSalesInvoiceLine() then
                LoopFinished := true
            else begin
                EDISegment.Next(-1);
                LoopFinished := false;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LAX EDI Create Sales Order", OnAfterSalesLineModify, '', false, false)]
    local procedure Cod14002365_OnAfterSalesLineModify(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; EDIRecDocFields: Record "LAX EDI Receive Document Field");
    begin
        if SalesLine."LAX EDI Original Qty." <> SalesLine.Quantity then begin
            SalesLine."IDL EDI Qty Discr." := true;
            SalesLine.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure COD414_OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean);
    begin
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            if EDIFunctionsGbl.EDIQtyDiscLinesExist(SalesHeader) then
                Error(EDIQtyPriceDiscExistsErrMsg);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSendSalesDocForApproval, '', false, false)]
    local procedure Cod1535_OnSendSalesDocForApproval(var SalesHeader: Record "Sales Header");
    begin
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            if EDIFunctionsGbl.EDIQtyDiscLinesExist(SalesHeader) then
                Error(EDIQtyPriceDiscExistsErrMsg);
        end;
    end;


    var
        EDIFunctionsGbl: Codeunit "IDL EDI Functions";
        EDIQtyPriceDiscExistsErrMsg:
                Label 'One or more line(s) have qty. discrepancy';
        LAXEDICreateSalesOrder:
                Codeunit "LAX EDI Create Sales Order";
        EDISingleInstance:
                Codeunit "IDL EDI Single Instance";

        PaymentTermsRecGbl:
                Record "Payment Terms";




}
